//
//  CoinCell.swift
//  VoltixApp
//
//  Created by Amol Kumar on 2024-03-08.
//

import SwiftUI

struct CoinCell: View {
    let coin: Coin
    let group: GroupedChain
    let vault: Vault
    
    @StateObject var tx = SendTransaction()
    @StateObject var coinViewModel = CoinViewModel()
	
    var body: some View {
        cell
            .task {
                await setData()
            }
    }
    
    var cell: some View {
        VStack(alignment: .leading, spacing: 15) {
            header
            amount
            buttons
        }
        .padding(16)
        .background(Color.blue600)
    }
    
    var header: some View {
        HStack {
            title
            Spacer()
            quantity
        }
    }
    
    var title: some View {
        Text(tx.coin.ticker)
            .font(.body20Menlo)
            .foregroundColor(.neutral0)
    }
    
    var quantity: some View {
        let balance = coinViewModel.coinBalance
        
        return Text(balance ?? "1000")
            .font(.body16Menlo)
            .foregroundColor(.neutral0)
            .redacted(reason: balance==nil ? .placeholder : [])
    }
    
    var amount: some View {
        let balance = coinViewModel.balanceUSD
        
        return Text(balance ?? "0.0000")
            .font(.body16MenloBold)
            .foregroundColor(.neutral0)
            .redacted(reason: balance==nil ? .placeholder : [])
    }
    
    var buttons: some View {
        HStack(spacing: 20) {
            swapButton
            sendButton
        }
    }
    
    var swapButton: some View {
        NavigationLink {
            //SendInputDetailsView(presentationStack: .constant([]), tx: tx)
        } label: {
            Text(NSLocalizedString("swap", comment: "Swap button text").uppercased())
                .font(.body16MenloBold)
                .foregroundColor(.persianBlue200)
                .padding(.vertical, 5)
                .frame(maxWidth: .infinity)
                .background(Color.blue800)
                .cornerRadius(50)
        }
    }
    
    var sendButton: some View {
        NavigationLink {
            SendCryptoView(tx: tx, group: group, vault: vault)
        } label: {
            Text(NSLocalizedString("send", comment: "Send button text").uppercased())
                .font(.body16MenloBold)
                .foregroundColor(.turquoise600)
                .padding(.vertical, 5)
                .frame(maxWidth: .infinity)
                .background(Color.blue800)
                .cornerRadius(50)
        }
    }
    
	//TODO: The tx gas is being set here, but it should be set inside the load data
	//This SET data is calling the loadData multiples times for the same coin
    private func setData() async {
        tx.coin = coin
        tx.gas = coin.feeDefault
		await coinViewModel.loadData(
            tx: tx
        )
    }
}

#Preview {
    CoinCell(coin: Coin.example, group: GroupedChain.example, vault: Vault.example)
}
