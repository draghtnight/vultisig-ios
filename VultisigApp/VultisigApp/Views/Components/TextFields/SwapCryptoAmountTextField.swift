//
//  SwapCryptoAmountTextField.swift
//  VultisigApp
//
//  Created by Amol Kumar on 2024-05-25.
//

import SwiftUI

struct SwapCryptoAmountTextField: View {
    let title: String
    let balanceString: String
    @Binding var amount: String

    var onChange: (String) async -> Void

    @Environment(\.isEnabled) private var isEnabled

    var body: some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
            .background(Color.blue600)
            .cornerRadius(10)
    }
    
    var content: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                titleContent
                textField
            }
            
            Spacer()
            balance
        }
    }
    
    var titleContent: some View {
        Text(NSLocalizedString(title, comment: ""))
            .font(.body12Menlo)
            .foregroundColor(.neutral200)
    }
    
    var textField: some View {
        ZStack(alignment: .trailing) {
            if amount.isEmpty {
                Text(NSLocalizedString("enterAmount", comment: ""))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            field
        }
        .font(.body20MenloBold)
        .foregroundColor(.neutral0)
    }
    
    var field: some View {
        HStack(spacing: 0) {
            TextField(NSLocalizedString("enterAmount", comment: "").capitalized, text: Binding<String>(
                get: { amount },
                set: {
                    let newValue = $0.formatCurrency()

                    guard amount != newValue else { return }
                    amount = newValue

                    DebounceHelper.shared.debounce {
                        Task { await onChange(newValue) }
                    }
                }
            ))
            .submitLabel(.next)
            .textInputAutocapitalization(.never)
            .keyboardType(.decimalPad)
            .textContentType(.oneTimeCode)
            .disableAutocorrection(true)
            .textFieldStyle(TappableTextFieldStyle())
            .foregroundColor(isEnabled ? .neutral0 : .neutral300)
        }
    }
    
    var balance: some View {
        Group {
            Text(NSLocalizedString("balance", comment: "")) +
            Text(": ") +
            Text(balanceString)
        }
        .font(.body12Menlo)
        .foregroundColor(.neutral200)
    }
}

#Preview {
    SwapCryptoAmountTextField(
        title: "to",
        balanceString: "1.1",
        amount: .constant(.empty),
        onChange: { _ in }
    )
}
