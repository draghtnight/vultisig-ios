//
//  Sui.swift
//  VultisigApp
//
//  Created by Enrique Souza Soares on 24/04/24.
//

import Foundation
import SwiftUI
import BigInt
import WalletCore

class SuiService {
    static let shared = SuiService()
    private init() {}
    
    private let rpcURL = URL(string: Endpoint.suiServiceRpc)!
    private let jsonDecoder = JSONDecoder()
    
    func getGasInfo(coin: Coin) async throws -> (BigInt, [[String:String]]) {
        async let gasPrice = getReferenceGasPrice(coin: coin)
        async let allCoins = getAllCoins(coin: coin)
        return await (try gasPrice, try allCoins)
    }
    
    func getBalance(coin: Coin) async throws -> String {
        return try await getAllBalances(coin: coin)
    }
    
    func getAllBalances(coin: Coin) async throws -> String {
        do {
            let data = try await Utils.PostRequestRpc(
                rpcURL: rpcURL,
                method: "suix_getAllBalances",
                params: [coin.address]
            )
            
            if let result = Utils.extractResultFromJson(fromData: data, path: "result") as? [[String: Any]] {
                if let item = result.first(where: {
                    guard let coinType = $0["coinType"] as? String else { return false }
                    return coinType.lowercased().contains("\(coin.ticker.lowercased())")
                }),
                   let balance = item["totalBalance"] as? String {
                    return balance
                }
            }
            
            return "0"
        } catch {
            print ("Error fetching suix_getAllBalances: \(error.localizedDescription)")
            return "0"
        }
    }
    
    static func getTokenUSDValue(contractAddress: String) async -> Double {
        do {
            let urlString: String = Endpoint.suiTokenQuote()
            let dataResponse = try await Utils.asyncGetRequest(urlString: urlString, headers: [:])

            if let pools = Utils.extractResultFromJson(fromData: dataResponse, path: "data.pools") as? [[String: Any]] {
                
                let usdcAddress = "0xdba34672e30cb065b1f93e3ab55318768fd6fef66c15942c9f7cb846e2f900e7::usdc::USDC"

                // Find a pool where `contractAddress` is in either `coin_a` or `coin_b`
                let pool = pools.first { pool in
                    guard
                        let coinA = pool["coin_a"] as? [String: Any],
                        let coinAAddress = coinA["address"] as? String,
                        let coinB = pool["coin_b"] as? [String: Any],
                        let coinBAddress = coinB["address"] as? String
                    else {
                        return false
                    }

                    return (coinAAddress.uppercased().contains(contractAddress.uppercased()) && coinBAddress.uppercased().contains(usdcAddress.uppercased())) ||
                           (coinBAddress.uppercased().contains(contractAddress.uppercased()) && coinAAddress.uppercased().contains(usdcAddress.uppercased()))
                }

                // Debugging print to verify pool existence
                if let pool = pool {
                    print("Pool found: \(contractAddress)")
                } else {
                    print("No pool found for contract address: \(contractAddress)")
                    return 0.0
                }

                // Extract price
                if let priceString = pool?["price"] as? String, let price = Double(priceString) {
                    guard
                        let coinA = pool?["coin_a"] as? [String: Any],
                        let coinAAddress = coinA["address"] as? String
                    else {
                        return 0.0
                    }

                    // If USDC is `coin_a`, invert the price
                    if coinAAddress.uppercased().contains(usdcAddress.uppercased()) {
                        return price > 0 ? 1 / price : 0.0
                    }
                    
                    return price
                }
            }

            return 0.0

        } catch {
            print("Error fetching token price: \(error.localizedDescription)")
            return 0.0
        }
    }
    
    func getReferenceGasPrice(coin: Coin) async throws -> BigInt{
        do {
            let data = try await Utils.PostRequestRpc(rpcURL: rpcURL, method: "suix_getReferenceGasPrice", params:  [])
            if let result = Utils.extractResultFromJson(fromData: data, path: "result"),
               let resultString = result as? String {
                let intResult = resultString.toBigInt()
                return intResult
            } else {
                print("JSON decoding error")
            }
        } catch {
            print("Error fetching balance: \(error.localizedDescription)")
            throw error
        }
        return BigInt.zero
    }
    
    func getAllCoins(coin: Coin) async throws -> [[String:String]] {
        
        do {
            let data = try await Utils.PostRequestRpc(rpcURL: rpcURL, method: "suix_getAllCoins", params: [coin.address])
            
            if let coins: [SuiCoin] = Utils.extractResultFromJson(fromData: data, path: "result.data", type: [SuiCoin].self) {
                let allCoins = coins.filter{ $0.coinType.uppercased().contains("SUI") || $0.coinType.uppercased().contains(coin.ticker.uppercased()) }.map { coin in
                    var coinDict = [String: String]()
                    coinDict["objectID"] = coin.coinObjectId.description
                    coinDict["version"] = String(coin.version)
                    coinDict["objectDigest"] = coin.digest
                    coinDict["balance"] = String(coin.balance)
                    coinDict["coinType"] = String(coin.coinType)
                    return coinDict
                }
                
                return allCoins
            } else {
                print("Failed to decode coins")
            }
        } catch {
            print("Error fetching balance: \(error.localizedDescription)")
            throw error
        }
        return []
    }
    
    func getAllTokens(coin: Coin) async throws -> [[String: String]] {
        
        do {
            let data = try await Utils.PostRequestRpc(rpcURL: rpcURL, method: "suix_getOwnedObjects", params: [coin.address])
            
            if let objects: [[String: Any]] = Utils.extractResultFromJson(fromData: data, path: "result.data") as? [[String: Any]] {
                var tokens: [[String: String]] = []
                
                for obj in objects {
                    if let objData = obj["data"] as? [String: Any],
                       let objectId = objData["objectId"] as? String {
                        
                        // Fetch object details
                        let objectDetails = try await Utils.PostRequestRpc(rpcURL: rpcURL, method: "sui_getObject", params: [objectId, ["showContent": true]])
                        
                        if let coinType = Utils.extractResultFromJson(fromData: objectDetails, path: "result.data.content.type") as? String {
                            if let start = coinType.range(of: "<"), let end = coinType.range(of: ">") {
                                let extractedType = String(coinType[start.upperBound..<end.lowerBound])
                                tokens.append([
                                    "objectID": objectId,
                                    "coinType": extractedType
                                ])
                            }
                        }
                    }
                }
                
                return tokens
            } else {
                print("Failed to decode owned objects")
            }
        } catch {
            print("Error fetching tokens: \(error.localizedDescription)")
            throw error
        }
        return []
    }
    
    func getAllTokensWithMetadata(coin: Coin) async throws -> [CoinMeta] {
        let allTokens = try await getAllTokens(coin: coin) // Get tokens first
        
        var tokensWithMetadata: [CoinMeta] = []
        
        for token in allTokens {
            if let objType = token["coinType"] {
                do {
                    
                    let metadata = try await Utils.PostRequestRpc(rpcURL: rpcURL, method: "suix_getCoinMetadata", params: [objType])
                    
                    let tokenData: [String: String] = [
                        "objectID": token["objectID"] ?? "",
                        "type": objType,
                        "symbol": Utils.extractResultFromJson(fromData: metadata, path: "result.symbol") as? String ?? "Unknown",
                        "name": Utils.extractResultFromJson(fromData: metadata, path: "result.name") as? String ?? "Unknown",
                        "decimals": (Utils.extractResultFromJson(fromData: metadata, path: "result.decimals") as? Int ?? 0).description,
                        "logo": Utils.extractResultFromJson(fromData: metadata, path: "result.iconUrl") as? String ?? ""
                    ]
                    
                    let coinMeta = CoinMeta(
                        chain: .sui,
                        ticker: tokenData["symbol"]!,
                        logo: tokenData["logo"]!,
                        decimals: Int(tokenData["decimals"] ?? "0")!,
                        priceProviderId: "",
                        contractAddress: objType,
                        isNativeToken: tokenData["symbol"]! == TokensStore.Token.suiSUI.ticker ? true : false
                    )
                    
                    tokensWithMetadata.append(coinMeta)
                } catch {
                    print("Error fetching metadata for \(objType): \(error.localizedDescription)")
                }
            }
        }
        
        return tokensWithMetadata.filter { $0.isNativeToken == false }
    }
    
    func executeTransactionBlock(unsignedTransaction: String, signature: String) async throws -> String{
        do {
            let data = try await Utils.PostRequestRpc(rpcURL: rpcURL, method: "sui_executeTransactionBlock", params:  [unsignedTransaction, [signature]])
            
            if let error = Utils.extractResultFromJson(fromData: data, path: "error.message") as? String {
                return error.description
            }
            
            if let result = Utils.extractResultFromJson(fromData: data, path: "result.digest") as? String {
                return result.description
            }
        } catch {
            return error.localizedDescription
        }
        return .empty
    }
}

private extension SuiService {
    
    enum Errors: Error {
        case getBalanceFailed
    }
}
