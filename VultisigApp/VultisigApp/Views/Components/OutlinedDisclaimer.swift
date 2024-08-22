//
//  OutlinedDisclaimer.swift
//  VultisigApp
//
//  Created by Amol Kumar on 2024-08-21.
//

import SwiftUI

struct OutlinedDisclaimer: View {
    let text: String
    
    var body: some View {
        content
    }
    
    var content: some View {
        HStack(spacing: 12) {
            Image(systemName: "info.circle")
                .foregroundStyle(LinearGradient.primaryGradient)
                .font(.body14Menlo)
            
            Text(text)
                .font(.body12Menlo)
                .foregroundColor(.neutral0)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
            #if os(iOS)
                .stroke(LinearGradient.primaryGradient, lineWidth: 1)
            #elseif os(macOS)
                .stroke(LinearGradient.primaryGradient, lineWidth: 2)
            #endif
        )
    }
}

#Preview {
    OutlinedDisclaimer(text: "String")
}
