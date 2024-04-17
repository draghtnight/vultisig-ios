//
//  NetworkPromptType.swift
//  VoltixApp
//
//  Created by Amol Kumar on 2024-04-16.
//

import SwiftUI

enum NetworkPromptType: String, CaseIterable {
    case WiFi
    case Hotspot
    case Cellular
    
    func getImage() -> Image {
        let name: String
        
        switch self {
        case .WiFi:
            name = "wifi"
        case .Hotspot:
            name = "personalhotspot"
        case .Cellular:
            name = "cellularbars"
        }
        
        return Image(systemName: name)
    }
}
