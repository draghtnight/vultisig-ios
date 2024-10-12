//
//
//  VaultDetailView.swift
//  VultisigApp
//
//  Created by Amol Kumar on 2024-03-07.
//

import SwiftUI

struct VaultDetailView: View {
    @Binding var showVaultsList: Bool
    @ObservedObject var vault: Vault
    
    @EnvironmentObject var appState: ApplicationState
    @EnvironmentObject var viewModel: VaultDetailViewModel
    @EnvironmentObject var homeViewModel: HomeViewModel
    @EnvironmentObject var tokenSelectionViewModel: CoinSelectionViewModel
    @EnvironmentObject var settingsDefaultChainViewModel: SettingsDefaultChainViewModel
    
    @State var showSheet = false
    @State var isLoading = true
    @State var showScanner = false
    @State var shouldJoinKeygen = false
    @State var shouldKeysignTransaction = false
    @State var shouldSendCrypto = false

    @State var isSendLinkActive = false
    @State var isSwapLinkActive = false
    @State var isMemoLinkActive = false
    @State var showAlert: Bool = false
    @State var selectedChain: Chain? = nil

    @StateObject var sendTx = SendTransaction()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Background()
            view
            scanButton
            PopupCapsule(text: "addressCopied", showPopup: $showAlert)
        }
        .onAppear {
            appState.currentVault = homeViewModel.selectedVault
            onAppear()
        }
        .onChange(of: homeViewModel.selectedVault?.pubKeyECDSA) {
            if appState.currentVault?.pubKeyECDSA == homeViewModel.selectedVault?.pubKeyECDSA {
                return
            }
            print("on vault Pubkey change \(homeViewModel.selectedVault?.pubKeyECDSA ?? "")")
            appState.currentVault = homeViewModel.selectedVault
            setData()
        }
        .onChange(of: homeViewModel.selectedVault?.coins) {
            setData()
        }
        .navigationDestination(isPresented: $isSendLinkActive) {
            SendCryptoView(
                tx: sendTx,
                vault: vault
            )
        }
        .navigationDestination(isPresented: $isSwapLinkActive) {
            if let fromCoin = viewModel.selectedGroup?.nativeCoin {
                SwapCryptoView(fromCoin: fromCoin, vault: vault)
            }
        }
        .navigationDestination(isPresented: $isMemoLinkActive) {
            TransactionMemoView(
                tx: sendTx,
                vault: vault
            )
        }
        .sheet(isPresented: $showSheet, content: {
            NavigationView {
                ChainSelectionView(showChainSelectionSheet: $showSheet, vault: vault)
            }
        })
    }
    
    var emptyList: some View {
        ErrorMessage(text: "noChainSelected")
            .padding(.vertical, 50)
            .listRowInsets(EdgeInsets())
            .listRowSeparator(.hidden)
            .frame(maxWidth: .infinity)
            .multilineTextAlignment(.center)
            .background(Color.backgroundBlue)
    }
    
    var balanceContent: some View {
        VaultDetailBalanceContent(vault: vault)
    }
    
    var addButton: some View {
        HStack {
            chooseChainButton
            Spacer()
        }
        .padding(16)
        .background(Color.backgroundBlue)
        .listRowInsets(EdgeInsets())
        .listRowSeparator(.hidden)
    }
    
    var pad: some View {
        Color.backgroundBlue
            .frame(height: 150)
            .listRowInsets(EdgeInsets())
            .listRowSeparator(.hidden)
    }
    
    var chooseChainButtonLabel: some View {
        HStack(spacing: 10) {
            Image(systemName: "plus")
            Text(NSLocalizedString("chooseChains", comment: "Choose Chains"))
        }
    }
    
    var loader: some View {
        HStack(spacing: 20) {
            Text(NSLocalizedString("fetchingVaultDetails", comment: ""))
                .font(.body16Menlo)
                .foregroundColor(.neutral0)
            
            ProgressView()
                .preferredColorScheme(.dark)
        }
        .padding(.vertical, 50)
        .listRowInsets(EdgeInsets())
        .listRowSeparator(.hidden)
        .frame(maxWidth: .infinity)
        .multilineTextAlignment(.center)
        .background(Color.backgroundBlue)
    }
    
    var backupNowWidget: some View {
        BackupNowDisclaimer(vault: vault)
            .padding(.horizontal, 16)
            .padding(.top, 20)
            .background(Color.backgroundBlue)
    }
    
    private func onAppear() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            isLoading = false
        }
        setData()
    }
    
    private func setData() {
        if homeViewModel.selectedVault == nil {
            return
        }
        
        viewModel.fetchCoins(for: vault)
        viewModel.updateBalance(vault: vault)
        viewModel.getGroupAsync(tokenSelectionViewModel)
        
        tokenSelectionViewModel.setData(for: vault)
        settingsDefaultChainViewModel.setData(tokenSelectionViewModel.groupedAssets)
        viewModel.categorizeCoins(vault: vault)
    }
    
    func getActions() -> some View {
        let selectedGroup = viewModel.selectedGroup
        
        return ChainDetailActionButtons(group: selectedGroup ?? GroupedChain.example, sendTx: sendTx, isSendLinkActive: $isSendLinkActive, isSwapLinkActive: $isSwapLinkActive, isMemoLinkActive: $isMemoLinkActive)
            .padding(16)
            .padding(.horizontal, 12)
            .redacted(reason: selectedGroup == nil ? .placeholder : [])
            .background(Color.backgroundBlue)
            .listRowInsets(EdgeInsets())
            .listRowSeparator(.hidden)
    }
}

#Preview {
    VaultDetailView(showVaultsList: .constant(false), vault: Vault.example)
        .environmentObject(ApplicationState())
        .environmentObject(VaultDetailViewModel())
        .environmentObject(CoinSelectionViewModel())
        .environmentObject(HomeViewModel())
        .environmentObject(SettingsDefaultChainViewModel())
}
