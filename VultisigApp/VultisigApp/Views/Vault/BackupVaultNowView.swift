//
//  BackupVaultNowView.swift
//  VultisigApp
//
//  Created by Amol Kumar on 2024-07-05.
//

import SwiftUI

struct BackupVaultNowView: View {
    let vault: Vault
    
    var body: some View {
        ZStack {
            Background()
            view
        }
        .navigationBarBackButtonHidden(true)
    }
    
    var view: some View {
        container
    }
    
    var content: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Spacer()
                logo
                Spacer()
                skipButton
            }
            image
            title
            Spacer()
            disclaimer
            Spacer()
            description
            Spacer()
            backupButton
        }
        .font(.body14MontserratMedium)
        .foregroundColor(.neutral0)
        .multilineTextAlignment(.center)
    }
    
    var logo: some View {
        Image("LogoWithTitle")
            .padding(.top, 30)
    }

    var title: some View {
        Text("Backups need to be done on every device in Vultisig")
            .foregroundColor(.neutral0)
            .font(.body24MontserratMedium)
            .fixedSize(horizontal: false, vertical: true)
    }

    var image: some View {
        Image("BackupNowImage")
            .offset(x: 5)
            .padding(.bottom, 6)
    }

    var disclaimer: some View {
        WarningView(text: "Back up your vault on every device individually!")
            .padding(.horizontal, 16)
            .fixedSize(horizontal: false, vertical: true)
    }

    var description: some View {
        Text("Each device has its own unique vault share, which are needed for recovery ")
            .padding(.horizontal, 32)
            .multilineTextAlignment(.center)
    }
    
    var backupButton: some View {
        NavigationLink {
            BackupPasswordSetupView(vault: vault, isNewVault: true)
        } label: {
            FilledButton(title: "Backup")
        }
        .padding(.horizontal, 40)
        .padding(.bottom, 10)
    }
    
    var skipButton: some View {
        NavigationLink {
            HomeView(selectedVault: vault, showVaultsList: false, shouldJoinKeygen: false)
        } label: {
            Image("x")
        }
        .padding(16)
    }
}

#Preview {
    BackupVaultNowView(vault: Vault.example)
        .frame(height: 600)
}
