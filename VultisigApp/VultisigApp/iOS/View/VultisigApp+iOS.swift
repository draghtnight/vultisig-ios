//
//  VultisigApp+iOS.swift
//  VultisigApp
//
//  Created by Amol Kumar on 2024-09-18.
//

#if os(iOS)
import SwiftUI

extension VultisigApp {
    var content: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(applicationState) // Shared monolithic mutable state
                .environmentObject(vaultDetailViewModel)
                .environmentObject(coinSelectionViewModel)
                .environmentObject(accountViewModel)
                .environmentObject(deeplinkViewModel)
                .environmentObject(settingsViewModel)
                .environmentObject(homeViewModel)
                .environmentObject(settingsDefaultChainViewModel)
                .environmentObject(phoneCheckUpdateViewModel)
        }
    }
}
#endif
