//
//  BlowfishService.swift
//  VultisigApp
//
//  Created by Enrique Souza Soares on 22/07/24.
//

import Foundation
import BigInt

struct BlowfishService {
    static let shared = BlowfishService()
    
    func scanTransactions
    (
        chain: Chain,
        userAccount: String,
        origin: String,
        txObjects: [BlowfishRequest.BlowfishTxObject],
        simulatorConfig: BlowfishRequest.BlowfishSimulatorConfig? = nil
    ) async throws -> BlowfishResponse? {
        
        guard let supportedChain = blowfishChainName(chain: chain) else {
            return nil
        }
        
        guard let supportedNetwork = blowfishNetwork(chain: chain) else {
            return nil
        }
        
        let blowfishRequest = BlowfishRequest(
            userAccount: userAccount,
            metadata: BlowfishRequest.BlowfishMetadata(origin: origin),
            txObjects: txObjects,
            simulatorConfig: simulatorConfig
        )
        
        let endpoint = Endpoint.fetchBlowfishTransactions(chain: supportedChain, network: supportedNetwork)
        let headers = ["X-Api-Version" : "2023-06-05"]
        let body = try JSONEncoder().encode(blowfishRequest)
        let dataResponse = try await Utils.asyncPostRequest(urlString: endpoint, headers: headers, body: body)
        let response = try JSONDecoder().decode(BlowfishResponse.self, from: dataResponse)
        
        return response
    }
    
    enum DecodingCustomError: Error {
        case dataCorrupted(DecodingError.Context)
        case keyNotFound(CodingKey, DecodingError.Context)
        case valueNotFound(Any.Type, DecodingError.Context)
        case typeMismatch(Any.Type, DecodingError.Context)
    }

    func scanSolanaTransactions
    (
        userAccount: String,
        origin: String,
        transactions: [String]
    ) async throws -> BlowfishResponse? {
        
        let blowfishRequest = BlowfishSolanaRequest(
            userAccount: userAccount,
            metadata: BlowfishSolanaRequest.BlowfishMetadata(origin: origin),
            transactions: transactions
        )
        
        let endpoint = Endpoint.fetchBlowfishSolanaTransactions()
        let headers = ["X-Api-Version" : "2023-06-05"]
        let body = try JSONEncoder().encode(blowfishRequest)
        let dataResponse = try await Utils.asyncPostRequest(urlString: endpoint, headers: headers, body: body)
        
        do {
            let response = try JSONDecoder().decode(BlowfishResponse.self, from: dataResponse)
            return response
        } catch let DecodingError.dataCorrupted(context) {
            print("Data corrupted: \(context)")
            throw DecodingCustomError.dataCorrupted(context)
        } catch let DecodingError.keyNotFound(key, context) {
            print("Key '\(key)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
            throw DecodingCustomError.keyNotFound(key, context)
        } catch let DecodingError.valueNotFound(value, context) {
            print("Value '\(value)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
            throw DecodingCustomError.valueNotFound(value, context)
        } catch let DecodingError.typeMismatch(type, context) {
            print("Type '\(type)' mismatch:", context.debugDescription)
            print("codingPath:", context.codingPath)
            throw DecodingCustomError.typeMismatch(type, context)
        } catch {
            print("Error decoding JSON:", error)
            throw error
        }
    }
    
    func blowfishEVMTransactionScan(
        fromAddress: String,
        toAddress: String,
        amountInRaw: BigInt,
        memo: String?,
        chain: Chain
    ) async throws -> BlowfishResponse? {
        
        let amountDataHex = amountInRaw.serializeForEvm().map { byte in String(format: "%02x", byte) }.joined()
        let amountHex = "0x" + amountDataHex
        
        var memoHex: String? = nil
        
        if memo != nil {
            let memoDataHex = memo?.data(using: .utf8)?.map { byte in String(format: "%02x", byte) }.joined()
            if memoDataHex != nil {
                memoHex = "0x" + (memoDataHex ?? "")
            }
        }
        
        let txObjects = [
            BlowfishRequest.BlowfishTxObject(
                from: fromAddress,
                to: toAddress,
                value: amountHex,
                data: memoHex
            )
        ]
        
        let response = try await scanTransactions(
            chain: chain,
            userAccount: fromAddress,
            origin: "https://api.vultisig.com",
            txObjects: txObjects
        )
        
        return response
        
    }
    
    func blowfishSolanaTransactionScan(fromAddress: String, zeroSignedTransaction: String) async throws -> BlowfishResponse? {
        
        let response = try await scanSolanaTransactions(
            userAccount: fromAddress,
            origin: "https://api.vultisig.com",
            transactions: [zeroSignedTransaction]
            
        )
        
        return response
        
    }
    
    func blowfishChainName(chain: Chain) -> String? {
        switch chain {
        case.ethereum:
            return "ethereum"
        case.polygon:
            return "polygon"
        case.avalanche:
            return "avalanche"
        case.arbitrum:
            return "arbitrum"
        case.optimism:
            return "optimism"
        case.base:
            return "base"
        case.blast:
            return "blast"
        case.bscChain:
            return "bnb"
        case.solana:
            return "solana"
        case.thorChain:
            return nil
        case.bitcoin,.bitcoinCash,.litecoin,.dogecoin,.dash,.gaiaChain,.kujira,.mayaChain,.cronosChain,.sui,.polkadot,.zksync,.dydx:
            return nil
        }
    }
    
    func blowfishNetwork(chain: Chain) -> String? {
        switch chain {
        case .ethereum:
            return "mainnet"
        case .polygon:
            return "mainnet"
        case .avalanche:
            return "mainnet"
        case .arbitrum:
            return "one"
        case .optimism:
            return "mainnet"
        case .base:
            return "mainnet"
        case .blast:
            return "mainnet"
        case .bscChain:
            return "mainnet"
        case .solana:
            return "mainnet"
        case .thorChain:
            return nil
        case .bitcoin,.bitcoinCash,.litecoin,.dogecoin,.dash,.gaiaChain,.kujira,.mayaChain,.cronosChain,.sui,.polkadot,.zksync,.dydx:
            return nil
        }
    }
    
}
