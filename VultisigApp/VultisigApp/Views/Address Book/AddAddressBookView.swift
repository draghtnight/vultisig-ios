//
//  AddAddressBookView.swift
//  VultisigApp
//
//  Created by Amol Kumar on 2024-07-11.
//

import SwiftUI
import SwiftData

struct AddAddressBookView: View {
    let count: Int
    
    @EnvironmentObject var coinSelectionViewModel: CoinSelectionViewModel
    @EnvironmentObject var homeViewModel: HomeViewModel
    
    @State var title = ""
    @State var address = ""
    @State var selectedChain: CoinMeta? = nil
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
//    @Query var savedAddresses: [AddressBookItem]
    
    var body: some View {
        ZStack {
            Background()
            view
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle(NSLocalizedString("addAddress", comment: ""))
        .toolbar {
            ToolbarItem(placement: Placement.topBarLeading.getPlacement()) {
                NavigationBackButton()
            }
        }
        .onAppear {
            setData()
        }
    }
    
    var view: some View {
        VStack(spacing: 22) {
            content
            button
        }
        .padding(.horizontal, 16)
    }
    
    var content: some View {
        ScrollView {
            VStack(spacing: 22) {
                tokenSelector
                titleField
                addressField
            }
            .padding(.top, 30)
        }
    }
    
    var tokenSelector: some View {
        AddressBookChainSelector(selected: $selectedChain)
    }
    
    var titleField: some View {
        AddressBookTextField(title: "title", text: $title)
    }
    
    var addressField: some View {
        AddressBookTextField(title: "address", text: $address, showActions: true)
    }
    
    var button: some View {
        Button {
            addAddress()
        } label: {
            FilledButton(title: "saveAddress")
                .padding(.bottom, 40)
        }
    }
    
    private func setData() {
        guard let vault = homeViewModel.selectedVault else {
            return
        }
        
        coinSelectionViewModel.setData(for: vault)
        
        let key = coinSelectionViewModel.groupedAssets.keys.sorted().first ?? ""
        selectedChain = coinSelectionViewModel.groupedAssets[key]?.first
    }
    
    private func addAddress() {
        guard let selectedChain else {
            return
        }
        
        let data = AddressBookItem(
            title: title,
            address: address,
            coinMeta: selectedChain, 
            order: count
        )
        modelContext.insert(data)
        
        dismiss()
    }
}

#Preview {
    AddAddressBookView(count: 0)
        .environmentObject(CoinSelectionViewModel())
        .environmentObject(HomeViewModel())
}
