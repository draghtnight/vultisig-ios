//
//  ReshareRequest.swift
//  VultisigApp
//
//  Created by Johnny Luo on 1/9/2024.
//

import Foundation
struct ReshareRequest : Hashable,Codable{
    let name: String
    let public_key: String
    let session_id: String
    let hex_encryption_key: String
    let hex_chain_code: String
    let local_party_id: String
    let encryption_password: String
    let email: String
}
