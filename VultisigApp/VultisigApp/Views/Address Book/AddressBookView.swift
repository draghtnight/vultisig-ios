//
//  AddressBookView.swift
//  VultisigApp
//
//  Created by Amol Kumar on 2024-07-10.
//

import SwiftUI
import SwiftData

struct AddressBookView: View {
    var shouldReturnAddress = true
    @Binding var returnAddress: String
    
    @Query var savedAddresses: [AddressBookItem]
    
    @Environment(\.modelContext) var modelContext
    @EnvironmentObject var coinSelectionViewModel: CoinSelectionViewModel
    
    @State var title: String = ""
    @State var address: String = ""
    @State var isEditing = false
    
    @State var coin: Coin?
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Background()
            main
            addAddressButton
        }
        .navigationBarBackButtonHidden(true)
#if os(iOS)
        .navigationTitle(NSLocalizedString("addressBook", comment: ""))
        .toolbar {
            ToolbarItem(placement: Placement.topBarLeading.getPlacement()) {
                NavigationBackButton()
            }
            
            if savedAddresses.count != 0 {
                ToolbarItem(placement: Placement.topBarTrailing.getPlacement()) {
                    navigationButton
                }
            }
        }
#endif
        .onDisappear {
            withAnimation {
                isEditing = false
            }
        }
    }
    
    var main: some View {
        VStack {
#if os(macOS)
            headerMac
#endif
            view
        }
    }
    
    var headerMac: some View {
        AddressBookHeader(
            count: savedAddresses.count, 
            isEditing: $isEditing
        )
    }
    
    var view: some View {
        ZStack {
            if savedAddresses.count == 0 {
                emptyView
            } else {
                list
            }
        }
    }
    
    var emptyView: some View {
        VStack {
            Spacer()
            ErrorMessage(text: "noSavedAddresses")
            Spacer()
        }
    }
    
    var emptyViewChain: some View {
        VStack {
            Spacer()
            ErrorMessage(text: "noSavedAddressesForChain")
            Spacer()
        }
    }
    
    var list: some View {
        let filteredAddress = savedAddresses.filter {
            coin == nil || (coin != nil && $0.coinMeta.chain.chainType == coin?.chainType)
        }
        
        return ZStack {
            if filteredAddress.count > 0 {
                List {
                    ForEach(filteredAddress.sorted(by: {
                        $0.order < $1.order
                    }), id: \.id) { address in
                        AddressBookCell(
                            address: address,
                            shouldReturnAddress: shouldReturnAddress,
                            isEditing: isEditing,
                            returnAddress: $returnAddress
                        )
                    }
                    .onMove(perform: isEditing ? move: nil)
                    .padding(.horizontal, 15)
                    .background(Color.backgroundBlue)
                }
                .listStyle(PlainListStyle())
                .buttonStyle(BorderlessButtonStyle())
                .colorScheme(.dark)
                .scrollContentBackground(.hidden)
                .padding(.top, 30)
                .padding(.bottom, isEditing ? 100 : 0)
                .background(Color.backgroundBlue.opacity(0.9))
            } else {
                emptyViewChain
            }
        }
#if os(macOS)
        .padding(.horizontal, 18)
#endif
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
            if isEditing {
                doneButton
            } else {
                NavigationEditButton()
            }
        }
    }
    
    var doneButton: some View {
        Text(NSLocalizedString("done", comment: ""))
            .font(.body18MenloBold)
            .foregroundColor(.neutral0)
    }
    
    var addAddressButton: some View {
        let condition = isEditing || savedAddresses.count == 0
        
        return NavigationLink {
            AddAddressBookView(count: savedAddresses.count, coin: coin?.toCoinMeta())
        } label: {
            FilledButton(title: "addAddress")
                .padding(.horizontal, 16)
#if os(iOS)
                .padding(.vertical, 30)
#elseif os(macOS)
                .padding(.vertical, 50)
                .padding(.horizontal, 24)
#endif
        }
        .frame(height: condition ? nil : 0)
        .animation(.easeInOut, value: isEditing)
        .clipped()
        .background(Color.backgroundBlue)
    }
    
    private func toggleEdit() {
        withAnimation {
            isEditing.toggle()
        }
    }
    
    private func move(from: IndexSet, to: Int) {
        var s = savedAddresses.sorted(by: { $0.order < $1.order })
        s.move(fromOffsets: from, toOffset: to)
        for (index, item) in s.enumerated() {
                item.order = index
        }
        try? self.modelContext.save()
    }
    
    private func moveDown(fromIndex: Int, toIndex: Int) {
        for index in fromIndex...toIndex {
            savedAddresses[index].order = savedAddresses[index].order-1
        }
        savedAddresses[fromIndex].order = toIndex
    }
    
    private func moveUp(fromIndex: Int, toIndex: Int) {
        savedAddresses[fromIndex].order = toIndex
        for index in toIndex...fromIndex {
            savedAddresses[index].order = savedAddresses[index].order+1
        }
    }
}

#Preview {
    AddressBookView(returnAddress: .constant(""), coin: Coin.example)
        .environmentObject(CoinSelectionViewModel())
        .environmentObject(HomeViewModel())
}
