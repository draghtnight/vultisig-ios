//
//  ServerBackupVerificationView+iOS.swift
//  VultisigApp
//
//  Created by Amol Kumar on 2024-11-13.
//

#if os(iOS)
import SwiftUI

extension ServerBackupVerificationView {
    var container: some View {
        content
            .navigationTitle(NSLocalizedString("serverBackupVerification", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: Placement.topBarLeading.getPlacement()) {
                    backButton
                }
            }
    }
    
    var content: some View {
        VStack(alignment: .leading, spacing: 12) {
            title
            textField
            Spacer()
            disclaimer
            button
        }
        .padding(.horizontal, 16)
    }
    
    var backButton: some View {
        Button(action: {
            viewModel.setupLinkActive = true
            viewModel.isLinkActive = false
        }) {
            Image(systemName: "chevron.backward")
                .font(.body18MenloBold)
                .foregroundColor(.neutral0)
        }
    }
}
#endif
