//
//  SendCryptoHeader.swift
//  VultisigApp
//
//  Created by Amol Kumar on 2024-08-09.
//

import SwiftUI

struct SendCryptoHeader: View {
    let vault: Vault
    @ObservedObject var sendCryptoViewModel: SendCryptoViewModel
    @ObservedObject var shareSheetViewModel: ShareSheetViewModel
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        HStack {
            leadingAction
            Spacer()
            text
            Spacer()
            trailingAction
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 40)
        .padding(.top, 8)
    }
    
    var leadingAction: some View {
        backButton
    }
    
    var text: some View {
        Text(NSLocalizedString(sendCryptoViewModel.currentTitle, comment: ""))
            .foregroundColor(.neutral0)
            .font(.title3)
    }
    
    var trailingAction: some View {
        ZStack {
            NavigationQRShareButton(
                vault: vault, 
                type: .Keysign,
                renderedImage: shareSheetViewModel.renderedImage
            )
            .opacity(sendCryptoViewModel.currentIndex==3 ? 1 : 0)
            .disabled(sendCryptoViewModel.currentIndex != 3)
        }
    }
    
    var backButton: some View {
        let isDone = sendCryptoViewModel.currentIndex==5
        
        return Button {
            handleBackTap()
        } label: {
            NavigationBlankBackButton()
        }
        .opacity(isDone ? 0 : 1)
        .disabled(isDone)
    }
    
    private func handleBackTap() {
        guard sendCryptoViewModel.currentIndex>1 else {
            dismiss()
            return
        }
        
        sendCryptoViewModel.handleBackTap()
    }
}

#Preview {
    SendCryptoHeader(
        vault: Vault.example,
        sendCryptoViewModel: SendCryptoViewModel(),
        shareSheetViewModel: ShareSheetViewModel()
    )
}
