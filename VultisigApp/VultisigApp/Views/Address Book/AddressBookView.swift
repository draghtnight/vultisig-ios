//
//  AddressBookView.swift
//  VultisigApp
//
//  Created by Amol Kumar on 2024-07-10.
//

import SwiftUI

struct AddressBookView: View {
    var shouldReturnAddress = true
    @Binding var returnAddress: String
    
    @EnvironmentObject var addressBookViewModel: AddressBookViewModel
    @EnvironmentObject var coinSelectionViewModel: CoinSelectionViewModel
    
    @State var title: String = ""
    @State var address: String = ""
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Background()
            view
            addAddressButton
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle(NSLocalizedString("addressBook", comment: ""))
        .toolbar {
            ToolbarItem(placement: Placement.topBarLeading.getPlacement()) {
                NavigationBackButton()
            }
            ToolbarItem(placement: Placement.topBarTrailing.getPlacement()) {
                navigationButton
            }
        }
        .onDisappear {
            withAnimation {
                addressBookViewModel.isEditing = false
            }
        }
    }
    
    var view: some View {
        List {
            ForEach(addressBookViewModel.savedAddresses, id: \.id) { address in
                AddressBookCell(
                    address: address,
                    shouldReturnAddress: shouldReturnAddress,
                    returnAddress: $returnAddress
                )
            }
            .onMove(perform: addressBookViewModel.isEditing ? addressBookViewModel.move: nil)
            .background(Color.backgroundBlue)
        }
        .listStyle(PlainListStyle())
        .buttonStyle(BorderlessButtonStyle())
        .colorScheme(.dark)
        .scrollContentBackground(.hidden)
        .padding(15)
        .padding(.top, 10)
        .background(Color.backgroundBlue)
    }
    
    var navigationButton: some View {
        Button {
            toggleEdit()
        } label: {
            navigationEditButton
        }
    }
    
    var navigationEditButton: some View {
        ZStack {
            if addressBookViewModel.isEditing {
                doneButton
            } else {
                NavigationEditButton()
            }
        }
    }
    
    var doneButton: some View {
        Text(NSLocalizedString("done", comment: ""))
#if os(iOS)
            .font(.body18MenloBold)
            .foregroundColor(.neutral0)
#elseif os(macOS)
            .font(.body18Menlo)
#endif
    }
    
    var addAddressButton: some View {
        NavigationLink {
            AddAddressBookView()
        } label: {
            FilledButton(title: "addAddress")
                .padding(.horizontal, 16)
                .padding(.vertical, 40)
        }
        .frame(height: addressBookViewModel.isEditing ? nil : 0)
        .animation(.easeInOut, value: addressBookViewModel.isEditing)
        .clipped()
    }
    
    private func toggleEdit() {
        withAnimation {
            addressBookViewModel.isEditing.toggle()
        }
    }
}

#Preview {
    AddressBookView(returnAddress: .constant(""))
        .environmentObject(AddressBookViewModel())
        .environmentObject(CoinSelectionViewModel())
        .environmentObject(HomeViewModel())
}
