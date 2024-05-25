//
//  VultisigApp.swift
//  VultisigApp
//

import Mediator
import SwiftData
import SwiftUI
import WalletCore

@main

struct VultisigApp: App {
    @Environment(\.scenePhase) private var scenePhase

    @StateObject var applicationState = ApplicationState.shared
    @StateObject var vaultDetailViewModel = VaultDetailViewModel()
    @StateObject var tokenSelectionViewModel = TokenSelectionViewModel()
    @StateObject var accountViewModel = AccountViewModel()
    @StateObject var deeplinkViewModel = DeeplinkViewModel()
    @StateObject var settingsViewModel = SettingsViewModel.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(applicationState) // Shared monolithic mutable state
                .environmentObject(vaultDetailViewModel)
                .environmentObject(tokenSelectionViewModel)
                .environmentObject(accountViewModel)
                .environmentObject(deeplinkViewModel)
                .environmentObject(settingsViewModel)
        }
        .modelContainer(sharedModelContainer)
        .onChange(of: scenePhase) {
            switch scenePhase {
            case .active:
                continueLogin()
            case .background:
                resetLogin()
            default:
                break
            }
        }
    }
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Vault.self,
            Coin.self,
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )
        do {
            let modelContainer = try ModelContainer(
                for: schema,
                migrationPlan: MigrationPlan.self,
                configurations: [modelConfiguration]
            )
            Storage.shared.modelContext = modelContainer.mainContext
            return modelContainer
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    private func continueLogin() {
        accountViewModel.enableAuth()
    }
    
    private func resetLogin() {
        accountViewModel.revokeAuth()
    }
}

private extension VultisigApp {

    enum SchemaV1: VersionedSchema {
        static var versionIdentifier = Schema.Version(1, 0, 0)

        static var models: [any PersistentModel.Type] {
            [Vault.self, Coin.self]
        }
    }

    enum MigrationPlan: SchemaMigrationPlan {
        static var schemas: [any VersionedSchema.Type] {
            return [SchemaV1.self]
        }

        static var stages: [MigrationStage] {
            return []
        }
    }
}
