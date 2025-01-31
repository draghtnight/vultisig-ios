//
//  PeerDiscoveryView.swift
//  VultisigApp
//

import OSLog
import SwiftUI
import RiveRuntime

struct PeerDiscoveryView: View {
    let tssType: TssType
    let vault: Vault
    let selectedTab: SetupVaultState
    let fastSignConfig: FastSignConfig?

    @StateObject var viewModel = KeygenPeerDiscoveryViewModel()
    @StateObject var participantDiscovery = ParticipantDiscovery(isKeygen: true)
    @StateObject var shareSheetViewModel = ShareSheetViewModel()
    
    @State var qrCodeImage: Image? = nil
    @State var isLandscape: Bool = true
    @State var isPhoneSE = false
    
    @State var screenWidth: CGFloat = .zero
    @State var screenHeight: CGFloat = .zero
    
    @State var showInfoSheet: Bool = false
    @State var hideBackButton: Bool = false
    @State private var showInvalidNumberOfSelectedDevices = false
    
    @Environment(\.displayScale) var displayScale
    
#if os(iOS)
    @State var orientation = UIDevice.current.orientation
#endif
    
    let columns = [
        GridItem(.adaptive(minimum: 160)),
        GridItem(.adaptive(minimum: 160)),
        GridItem(.adaptive(minimum: 160)),
    ]
    
    let phoneColumns = [
        GridItem(.adaptive(minimum: 160)),
        GridItem(.adaptive(minimum: 160))
    ]
    
    let adaptiveColumns = [
        GridItem(.adaptive(minimum: 160, maximum: 400), spacing: 16)
    ]
    
    let logger = Logger(subsystem: "peers-discory", category: "communication")
    let animationVM = RiveViewModel(fileName: "QRCodeScanned", autoPlay: true)
    
    var body: some View {
        content
            .task {
                viewModel.startDiscovery()
            }
            .onAppear {
                viewModel.setData(
                    vault: vault,
                    tssType: tssType, 
                    state: selectedTab,
                    participantDiscovery: participantDiscovery,
                    fastSignConfig: fastSignConfig
                )
                setData()
            }
            .onDisappear {
                viewModel.stopMediator()
            }
            .onFirstAppear {
                showInfo()
            }
    }
    
    var states: some View {
        VStack {
            switch (viewModel.status, selectedTab.hasOtherDevices) {
            case (.WaitingForDevices, false): 
                if viewModel.isLookingForDevices {
                    /// Wait until server join to go to keygen view
                    lookingForDevices
                } else {
                    /// Direct to Keygen for FastVaults
                    keygenView
                }
            case (.WaitingForDevices, true):
                waitingForDevices
            case (.Summary, _):
                summary
            case (.Keygen, _):
                keygenView
            case (.Failure, _):
                failureText
            }
        }
        .foregroundColor(.neutral0)
        .blur(radius: showInfoSheet ? 1 : 0)
        .animation(.easeInOut, value: showInfoSheet)
    }

    var waitingForDevices: some View {
        VStack(spacing: 0) {
            views
            bottomButton
        }
    }
    
    var summary: some View {
        KeyGenSummaryView(
            state: selectedTab,
            tssType: tssType,
            viewModel: viewModel
        )
    }
    
    var views: some View {
        ZStack {
            if isLandscape {
                landscapeContent
            } else {
                portraitContent
            }
        }
    }
    
    var portraitContent: some View {
        VStack(spacing: 0) {
            qrCode
            list
        }
    }
    
    var qrCode: some View {
        paringBarcode
    }
    
    var list: some View {
        ZStack {
            if isLandscape {
                gridList
            } else {
                scrollList
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    var lookingForDevices: some View {
        LookingForDevicesLoader(
            tssType: tssType,
            selectedTab: selectedTab
        )
    }
    
    func disableContinueButton() -> Bool {
        switch selectedTab {
        case .fast:
            return viewModel.selections.count < 2
        case .active:
            return viewModel.selections.count < 3
        case .secure:
            return viewModel.selections.count < 2
        }
    }
    
    var keygenView: some View {
        KeygenView(
            vault: viewModel.vault,
            tssType: tssType,
            keygenCommittee: viewModel.selections.map { $0 },
            vaultOldCommittee: viewModel.vault.signers.filter { viewModel.selections.contains($0)},
            mediatorURL: viewModel.serverAddr,
            sessionID: viewModel.sessionID,
            encryptionKeyHex: viewModel.encryptionKeyHex ?? "",
            oldResharePrefix: viewModel.vault.resharePrefix ?? "",
            fastSignConfig: fastSignConfig,
            isInitiateDevice: true,
            hideBackButton: $hideBackButton,
            selectedTab: selectedTab
        )
    }
    
    var failureText: some View {
        VStack{
            Text(self.viewModel.errorMessage)
                .font(.body15MenloBold)
                .multilineTextAlignment(.center)
                .foregroundColor(.red)
        }
    }
    
    var listTitle: some View {
        Text(NSLocalizedString("devices", comment: ""))
            .frame(maxWidth: .infinity, alignment: .leading)
            .font(.body22BrockmannMedium)
            .foregroundColor(.neutral0)
            .padding(.bottom, 8)
            .padding(.horizontal, 24)
    }
    
    func setData(_ proxy: GeometryProxy) {
        screenWidth = proxy.size.width
        screenHeight = proxy.size.height
        
        if screenWidth<380 {
            isPhoneSE = true
        }
    }
    
    private func showInfo() {
        guard selectedTab == .secure else {
            return
        }
        
        showInfoSheet = true
    }
}

#Preview {
    PeerDiscoveryView(tssType: .Keygen, vault: Vault.example, selectedTab: .fast, fastSignConfig: nil)
}
