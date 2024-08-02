//
//  GeneralCodeScannerView.swift
//  VultisigApp
//
//  Created by Amol Kumar on 2024-05-30.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

#if os(iOS)
import CodeScanner
import AVFoundation
#endif

struct GeneralCodeScannerView: View {
    @Binding var showSheet: Bool
    @Binding var shouldJoinKeygen: Bool
    @Binding var shouldKeysignTransaction: Bool
    @Binding var shouldSendCrypto: Bool
    
    @State var isGalleryPresented = false
    @State var isFilePresented = false
    
    @Query var vaults: [Vault]
    
    @EnvironmentObject var settingsDefaultChainViewModel: SettingsDefaultChainViewModel
    @EnvironmentObject var deeplinkViewModel: DeeplinkViewModel
    @EnvironmentObject var viewModel: HomeViewModel
    
    var body: some View {
        ZStack(alignment: .bottom) {
            #if os(iOS)
            CodeScannerView(
                codeTypes: [.qr],
                isGalleryPresented: $isGalleryPresented,
                videoCaptureDevice: AVCaptureDevice.zoomedCameraForQRCode(withMinimumCodeSize: 20),
                completion: handleScan
            )
            #endif
            HStack(spacing: 0) {
                galleryButton
                    .frame(maxWidth: .infinity)

                fileButton
                    .frame(maxWidth: .infinity)
            }
        }
        .ignoresSafeArea()
        .fileImporter(
            isPresented: $isFilePresented,
            allowedContentTypes: [UTType.image],
            allowsMultipleSelection: false
        ) { result in
            do {
                let qrCode = try Utils.handleQrCodeFromImage(result: result)
                let result = String(data: qrCode, encoding: .utf8) // Set the QR code result to the binding
                guard let url = URL(string: result ?? .empty) else {
                    return
                }
                
                deeplinkViewModel.extractParameters(url, vaults: vaults)
                presetValuesForDeeplink(url)
            } catch {
                print(error)
            }
        }
    }
    
    var galleryButton: some View {
        Button {
            isGalleryPresented.toggle()
        } label: {
            OpenButton(buttonIcon: "photo.stack", buttonLabel: "uploadFromGallery")
        }
        .padding(.bottom, 50)
    }
    
    var fileButton: some View {
        Button {
            isFilePresented.toggle()
        } label: {
            OpenButton(buttonIcon: "folder", buttonLabel: "uploadFromFiles")
        }
        .padding(.bottom, 50)
    }
    
    #if os(iOS)
    private func handleScan(result: Result<ScanResult, ScanError>) {
        switch result {
        case .success(let result):
            guard let url = URL(string: result.string) else {
                return
            }
            deeplinkViewModel.extractParameters(url, vaults: vaults)
            presetValuesForDeeplink(url)
        case .failure(_):
            return
        }
    }
    #endif
    
    private func presetValuesForDeeplink(_ url: URL) {
        shouldJoinKeygen = false
        shouldKeysignTransaction = false
        
        guard let type = deeplinkViewModel.type else {
            return
        }
        deeplinkViewModel.type = nil
        
        switch type {
        case .NewVault:
            moveToCreateVaultView()
        case .SignTransaction:
            moveToVaultsView()
        case .Unknown:
            moveToSendView()
        }
    }
    
    private func moveToCreateVaultView() {
        shouldSendCrypto = false
        showSheet = false
        shouldJoinKeygen = true
    }
    
    private func moveToVaultsView() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            showSheet = false
            shouldSendCrypto = false
            shouldKeysignTransaction = true
        }
    }
    
    private func moveToSendView() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            shouldJoinKeygen = false
            showSheet = false
            checkForAddress()
        }
    }
    
    private func checkForAddress() {
        for asset in settingsDefaultChainViewModel.baseChains {
            let isValid = asset.chain.coinType.validate(address: deeplinkViewModel.address ?? "")
            
            if isValid {
                deeplinkViewModel.selectedChain = asset.chain
                shouldSendCrypto = true
            }
        }
        shouldSendCrypto = true
    }
}

#Preview {
    GeneralCodeScannerView(
        showSheet: .constant(true),
        shouldJoinKeygen: .constant(true),
        shouldKeysignTransaction: .constant(true), 
        shouldSendCrypto: .constant(true)
    )
    .environmentObject(DeeplinkViewModel())
    .environmentObject(SettingsDefaultChainViewModel())
    .environmentObject(HomeViewModel())
}
