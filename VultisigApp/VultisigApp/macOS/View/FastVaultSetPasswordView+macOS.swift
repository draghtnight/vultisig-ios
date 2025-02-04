//
//  FastVaultSetPasswordView+macOS.swift
//  VultisigApp
//
//  Created by Amol Kumar on 2024-09-18.
//

#if os(macOS)
import SwiftUI

extension FastVaultSetPasswordView {
    var content: some View {
        ZStack {
            Background()
            main

            if isLoading {
                Loader()
            }
        }
    }
    
    var main: some View {
        VStack {
            headerMac
            view
        }
        .navigationDestination(isPresented: $isLinkActive) {
            FastVaultSetHintView(tssType: tssType, vault: vault, selectedTab: selectedTab, fastVaultEmail: fastVaultEmail, fastVaultPassword: password, fastVaultExist: fastVaultExist)
        }
    }

    var headerMac: some View {
        GeneralMacHeader(title: "")
    }
    
    var view: some View {
        VStack {
            passwordField
            Spacer()
            button
        }
        .padding(.horizontal, 25)
    }
}
#endif
