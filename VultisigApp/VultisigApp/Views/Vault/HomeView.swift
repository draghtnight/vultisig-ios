//
//  HomeView.swift
//  VultisigApp
//
//  Created by Amol Kumar on 2024-03-11.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @State var selectedVault: Vault? = nil
    
    @EnvironmentObject var deeplinkViewModel: DeeplinkViewModel
    @EnvironmentObject var viewModel: HomeViewModel
    @EnvironmentObject var macCameraServiceViewModel: MacCameraServiceViewModel
    
    @State var vaults: [Vault] = []
    
    @State var showVaultsList = false
    @State var isEditingVaults = false
    @State var showMenu = false
    @State var didUpdate = true
    @State var shouldJoinKeygen = false
    @State var shouldKeysignTransaction = false
    
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        ZStack {
            Background()
            
            if showMenu {
                SettingsView(showMenu: $showMenu, homeViewModel: viewModel)
            } else {
                main
            }
        }
    }
    
    var main: some View {
        VStack(spacing: 0) {
#if os(macOS)
            headerMac
            Separator()
#endif
            view
        }
    }
    
    var headerMac: some View {
        HomeHeader(
            showMenu: $showMenu,
            showVaultsList: $showVaultsList,
            isEditingVaults: $isEditingVaults
        )
    }
    
    var view: some View {
        VStack(spacing: 0) {
            ZStack {
                if let vault = viewModel.selectedVault {
                    VaultDetailView(showVaultsList: $showVaultsList, vault: vault)
                }
                
                VaultsView(viewModel: viewModel, showVaultsList: $showVaultsList, isEditingVaults: $isEditingVaults)
            }
        }
        .navigationBarBackButtonHidden(true)
#if os(iOS)
        .toolbar {
            ToolbarItem(placement: Placement.topBarLeading.getPlacement()) {
                menuButton
            }
            ToolbarItem(placement: Placement.principal.getPlacement()) {
                navigationTitle
            }
            ToolbarItem(placement: Placement.topBarTrailing.getPlacement()) {
                editButton
            }
        }
#endif
        .onAppear {
            setData()
        }
        .navigationDestination(isPresented: $shouldJoinKeygen) {
            JoinKeygenView(vault: Vault(name: "Main Vault"))
        }
        .navigationDestination(isPresented: $shouldKeysignTransaction) {
            if let vault = viewModel.selectedVault {
                JoinKeysignView(vault: vault)
            }
        }
    }
    
    var navigationTitle: some View {
        ZStack {
            HStack {
                title
                
                if viewModel.selectedVault != nil {
                    Image(systemName: "chevron.up")
                        .font(.body8Menlo)
                        .bold()
                        .foregroundColor(.neutral0)
                        .rotationEffect(.degrees(showVaultsList ? 0 : 180))
                }
            }
        }
        .onTapGesture {
            switchView()
        }
    }
    
    var title: some View {
        VStack(spacing: 0) {
            Text(NSLocalizedString("vaults", comment: "Vaults"))
            Text(viewModel.selectedVault?.name ?? NSLocalizedString("vault", comment: "Home view title"))
        }
        .offset(y: showVaultsList ? 9 : -10)
        .frame(height: 20)
        .clipped()
        .bold()
        .foregroundColor(.neutral0)
        .font(.body)
    }
    
    var menuButton: some View {
        Button {
            showMenu.toggle()
        } label: {
            NavigationMenuButton()
        }
        
    }
    
    var editButton: some View {
        NavigationHomeEditButton(
            vault: viewModel.selectedVault,
            showVaultsList: showVaultsList,
            isEditingVaults: $isEditingVaults
        )
    }
    
    private func setData() {
        fetchVaults()
        shouldJoinKeygen = false
        shouldKeysignTransaction = false
        
        macCameraServiceViewModel.stopSession()
        
        if let vault = selectedVault {
            viewModel.setSelectedVault(vault)
            selectedVault = nil
            return
        } else {
            viewModel.loadSelectedVault(for: vaults)
        }
        
        presetValuesForDeeplink()
    }
    
    private func presetValuesForDeeplink() {
        guard let type = deeplinkViewModel.type else {
            return
        }
        deeplinkViewModel.type = nil
        
        switch type {
        case .NewVault:
            moveToCreateVaultView()
        case .SignTransaction:
            moveToVaultsView()
        case .Unknown:
            return
        }
    }
    
    private func moveToCreateVaultView() {
        showVaultsList = false
        shouldJoinKeygen = true
    }
    
    private func moveToVaultsView() {
        guard let vault = deeplinkViewModel.selectedVault else {
            return
        }
        
        viewModel.setSelectedVault(vault)
        showVaultsList = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            shouldKeysignTransaction = true
        }
    }
    
    private func switchView() {
        guard viewModel.selectedVault != nil else {
            return
        }
        
        withAnimation(.easeInOut) {
            showVaultsList.toggle()
        }
    }
    
    private func fetchVaults() {
        let fetchVaultDescriptor = FetchDescriptor<Vault>()
        do {
            vaults = try modelContext.fetch(fetchVaultDescriptor)
        } catch {
            print(error)
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(DeeplinkViewModel())
        .environmentObject(HomeViewModel())
        .environmentObject(MacCameraServiceViewModel())
}
