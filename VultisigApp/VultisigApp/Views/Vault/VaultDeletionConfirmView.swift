//
//  VaultDeletionConfirmView.swift
//  VultisigApp
//
//  Created by Amol Kumar on 2024-06-05.
//

import SwiftUI
import SwiftData

struct VaultDeletionConfirmView: View {
    let vault: Vault
    
    @State var permanentDeletionCheck = false
    @State var canLoseFundCheck = false
    @State var vaultBackupCheck = false
    
    @State var showAlert = false
    @State var navigateBackToHome = false
    
    @State var isPhoneSE = false
    
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var homeViewModel: HomeViewModel
    
    let vaults: [Vault]
    
    var body: some View {
        content
    }
    
    var details: some View {
        VaultDeletionDetails(vault: vault, isPhoneSE: isPhoneSE)
    }
    
    private func delete() {
        guard allFieldsChecked() else {
            showAlert = true
            return
        }
        homeViewModel.selectedVault = nil
        modelContext.delete(vault)
        do {
            try modelContext.save()
        } catch {
            print("Error: \(error)")
        }
        ApplicationState.shared.currentVault = nil
        navigateBackToHome = true
    }
    
    private func allFieldsChecked() -> Bool {
        permanentDeletionCheck && canLoseFundCheck && vaultBackupCheck
    }
    
    var alert: Alert {
        Alert(
            title: Text(NSLocalizedString("reviewConditions", comment: "")),
            message: Text(NSLocalizedString("reviewConditionsMessage", comment: "")),
            dismissButton: .default(Text(NSLocalizedString("ok", comment: "")))
        )
    }
    
    func setData(_ proxy: GeometryProxy) {
        let screenWidth = proxy.size.width
        
        if screenWidth<380 {
            isPhoneSE = true
        }
    }
}

#Preview {
    VaultDeletionConfirmView(vault: Vault.example, vaults: [])
        .environmentObject(HomeViewModel())
}
