//
//  CreateVaultView+iOS.swift
//  VultisigApp
//
//  Created by Amol Kumar on 2024-09-06.
//

#if os(iOS)
import SwiftUI

extension CreateVaultView {
    var main: some View {
        view
            .navigationDestination(isPresented: $shouldJoinKeygen) {
                JoinKeygenView(vault: createVault())
            }
            .sheet(isPresented: $showSheet, content: {
                GeneralCodeScannerView(
                    showSheet: $showSheet,
                    shouldJoinKeygen: $shouldJoinKeygen,
                    shouldKeysignTransaction: .constant(false), // CodeScanner used for keygen only
                    shouldSendCrypto: .constant(false),         // -
                    selectedChain: .constant(nil),              // -
                    sendTX: SendTransaction()                   // -
                )
            })
    }
    
    var scanButton: some View {
        ZStack {
            if ProcessInfo.processInfo.isiOSAppOnMac {
                scanMacButton
            } else {
                scanPhoneButton
            }
        }
    }
}
#endif
