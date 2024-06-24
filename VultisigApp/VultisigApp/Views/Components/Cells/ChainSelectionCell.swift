//
//  ChainSelectionCell.swift
//  VultisigApp
//
//  Created by Amol Kumar on 2024-03-13.
//

import SwiftUI

struct ChainSelectionCell: View {
    let assets: [CoinMeta]
    @Binding var showAlert: Bool
    
    @State var isSelected = false
    @State var selectedTokensCount = 0
    @EnvironmentObject var tokenSelectionViewModel: CoinSelectionViewModel
    
    var body: some View {
        content
            .onAppear {
                setData()
            }
            .onChange(of: tokenSelectionViewModel.selection) { oldValue, newValue in
                setData()
            }
    }
    
    var content: some View {
        ZStack {
            if selectedTokensCount>1, isSelected {
                disabledContent
            } else {
                enabledContent
            }
        }
    }
    
    var enabledContent: some View {
        cell
    }
    
    var disabledContent: some View {
        Button {
            showAlert = true
        } label: {
            cell
                .disabled(true)
        }
    }
    
    var cell: some View {
        let nativeAsset = assets[0]
        return CoinSelectionCell(asset: nativeAsset)
            //.redacted(reason: nativeAsset==nil ? .placeholder : [])
    }
    
    private func setData() {
        guard let nativeAsset = assets.first else {
            return
        }
        
        if tokenSelectionViewModel.selection.contains(where: { cm in
            cm.chain == nativeAsset.chain && cm.ticker == nativeAsset.ticker
        }) {
            isSelected = true
        } else {
            isSelected = false
        }
        
        countSelectedToken()
    }
    
    private func countSelectedToken() {
        selectedTokensCount = 0
        for asset in assets {
            if tokenSelectionViewModel.selection.contains(where: { cm in
                cm.chain == asset.chain && cm.ticker == asset.ticker
            }) {
                selectedTokensCount += 1
            }
        }
    }
}

#Preview {
    ZStack {
        Background()
        ChainSelectionCell(assets: [], showAlert: .constant(false))
    }
    .environmentObject(CoinSelectionViewModel())
}
