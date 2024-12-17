//
//  LibType.swift
//  VultisigApp
//
//  Created by Johnny Luo on 4/12/2024.
//

import VultisigCommonData
import Foundation

enum LibType : Int,Codable {
    case GG20 = 0
    case DKLS = 1
    func toVSLibType()->VSLibType{
        switch self {
        case .GG20:
            return .gg20
        case .DKLS:
            return .dkls
        }
    }
}

extension VSLibType {
    func toLibType()->LibType{
        switch self {
        case .gg20:
            return .GG20
        case .dkls:
            return .DKLS
        default:
            return .GG20
        }
    }
}

func GetLibType() -> LibType {
    let useDKLS = UserDefaults.standard.bool(forKey: "isDKLSEnabled")
    if useDKLS {
        return .DKLS
    }
    #if DEBUG
    return .DKLS
    #else
    return .GG20
    #endif
    
}
