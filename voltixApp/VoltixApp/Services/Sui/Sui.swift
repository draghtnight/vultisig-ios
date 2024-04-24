//
//  Sui.swift
//  VoltixApp
//
//  Created by Enrique Souza Soares on 24/04/24.
//

import Foundation
import SwiftUI

class SuiService {
    static let shared = SuiService()
    private init() {}
    
    private var cacheFeePrice: [String: (data: Int64, timestamp: Date)] = [:]
    private var cacheLatestCheckpointSequenceNumber: [String: (data: Int64, timestamp: Date)] = [:]
    private let rpcURL = URL(string: Endpoint.suiServiceRpc)!
    private let jsonDecoder = JSONDecoder()
    
    func getBalance(coin: Coin) async throws -> (rawBalance: String, priceRate: Double){
        var rawBalance = "0"
        let priceRateFiat = await CryptoPriceService.shared.getPrice(priceProviderId: coin.priceProviderId)
        
        do {
            let data = try await Utils.PostRequestRpc(rpcURL: rpcURL, method: "suix_getBalance", params:  [coin.address])
            
            let totalBalance = Utils.extractResultFromJson(fromData: data, path: "result.totalBalance") as! String
            
            rawBalance = totalBalance.description
        } catch {
            print("Error fetching balance: \(error.localizedDescription)")
            throw error
        }
        return (rawBalance,priceRateFiat)
    }
    
    func getReferenceFee(coin: Coin) async throws -> Int64{
        let cacheKey = "\(coin.chain.name.lowercased())-fee-price"
        if let cachedData: Int64 = await Utils.getCachedData(cacheKey: cacheKey, cache: cacheFeePrice, timeInSeconds: 60*5) {
            return cachedData
        }
        
        do {
            let data = try await Utils.PostRequestRpc(rpcURL: rpcURL, method: "suix_getReferenceGasPrice", params:  [])
            
            if let result = Utils.extractResultFromJson(fromData: data, path: "result"),
               let resultNumber = result as? NSNumber {
                let intResult = Int64(resultNumber.intValue)
                self.cacheFeePrice[cacheKey] = (data: intResult, timestamp: Date())
                return intResult
            } else {
                print("JSON decoding error")
            }
        } catch {
            print("Error fetching balance: \(error.localizedDescription)")
            throw error
        }
        return Int64.zero
    }
    
    func getLatestCheckpointSequenceNumber(coin: Coin) async throws -> Int64{
        let cacheKey = "\(coin.chain.name.lowercased())-getLatestCheckpointSequenceNumber"
        if let cachedData: Int64 = await Utils.getCachedData(cacheKey: cacheKey, cache: cacheLatestCheckpointSequenceNumber, timeInSeconds: 60*5) {
            return cachedData
        }
        
        do {
            let data = try await Utils.PostRequestRpc(rpcURL: rpcURL, method: "suix_getReferenceGasPrice", params:  [])
            
            if let result = Utils.extractResultFromJson(fromData: data, path: "result"),
               let resultNumber = result as? NSNumber {
                let intResult = Int64(resultNumber.intValue)
                self.cacheLatestCheckpointSequenceNumber[cacheKey] = (data: intResult, timestamp: Date())
                return intResult
            } else {
                print("JSON decoding error")
            }
        } catch {
            print("Error fetching balance: \(error.localizedDescription)")
            throw error
        }
        return Int64.zero
    }
    
    func executeTransactionBlock(coin: Coin) async throws -> String{
        
        do {
            let data = try await Utils.PostRequestRpc(rpcURL: rpcURL, method: "sui_executeTransactionBlock", params:  [])
            
            if let result = Utils.extractResultFromJson(fromData: data, path: "result.digest"),
               let resultString = result as? NSString {
                let StringResult = resultString.description
                return StringResult
            } else {
                print("JSON decoding error")
            }
        } catch {
            print("Error fetching balance: \(error.localizedDescription)")
            throw error
        }
        return .empty
    }
}
