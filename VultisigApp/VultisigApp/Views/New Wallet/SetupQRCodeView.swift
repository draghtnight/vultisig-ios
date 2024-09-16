//
//  SetupQRCodeView.swift
//  VultisigApp
//
//  Created by Amol Kumar on 2024-03-07.
//

import SwiftData
import SwiftUI

struct SetupQRCodeView: View {
    let tssType: TssType
    let vault: Vault
    
    @State var selectedTab: SetupVaultState = .fast
    
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var viewModel: HomeViewModel
    
    var body: some View {
        ZStack {
            Background()
            main
        }
#if os(iOS)
        .navigationTitle(NSLocalizedString("setup", comment: "Setup title"))
        .toolbar {
            ToolbarItem(placement: Placement.topBarTrailing.getPlacement()) {
                NavigationHelpButton()
            }
        }
#endif
    }
    
    var main: some View {
        VStack(spacing: 0) {
#if os(macOS)
            headerMac
#endif
            view
        }
    }
    
    var headerMac: some View {
        GeneralMacHeader(title: "setup")
            .padding(.bottom, 8)
    }
    
    var view: some View {
        VStack {
            tabView
            button
        }
    }
    
    var tabView: some View {
        SetupVaultTabView(selectedTab: $selectedTab)
    }
    
    var button: some View {
        VStack(spacing: 20) {
            startButton
        }
        .padding(.horizontal, 40)
        .padding(.bottom, 40)
    }
    
    var startButton: some View {
        NavigationLink {
            if tssType == .Keygen {
                NewWalletNameView(
                    tssType: tssType,
                    vault: vault,
                    selectedTab: selectedTab
                )
            } else {
                if selectedTab.isFastVault {
                    FastVaultEmailView(
                        tssType: tssType,
                        vault: vault,
                        selectedTab: selectedTab
                    )
                } else {
                    PeerDiscoveryView(
                        tssType: tssType,
                        vault: vault,
                        selectedTab: selectedTab, 
                        fastVaultEmail: nil,
                        fastVaultPassword: nil
                    )
                }

            }
        } label: {
            FilledButton(title: "start".uppercased())
        }
    }
}

#Preview {
    SetupQRCodeView(
        tssType: .Keygen, 
        vault: Vault.example
    )
    .environmentObject(HomeViewModel())
}
