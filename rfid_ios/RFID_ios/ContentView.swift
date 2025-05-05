// ContentView.swift
// RFID_ios
//
// Created on 2025/05/06.
//

import SwiftUI
import Supabase

struct ContentView: View {
    @EnvironmentObject var scanner: ScannerManager
    @State private var tab: Tab = .scanner
    @State private var isAuthenticated = false

    var body: some View {
        Group {
            if isAuthenticated {
                NavigationView {
                    VStack(spacing: 12) {
                        Picker("機能", selection: $tab) {
                            ForEach(Tab.allCases) { Text($0.rawValue).tag($0) }
                        }
                        .pickerStyle(.segmented)

                        Group {
                            switch tab {
                            case .scanner:
                                scannerPanel
                            case .settings:
                                SettingsView()
                            case .compare:
                                CompareMasterView()
                            case .profile:
                                ProfileView()
                            case .registration:
                                ItemRegistrationView()
                            }
                        }
                        .frame(maxHeight: .infinity)
                    }
                    .padding()
                    .navigationTitle("RFID Demo")
                }
            } else {
                AuthView()
            }
        }
        .task {
            for await state in supabase.auth.authStateChanges {
                if [.initialSession, .signedIn, .signedOut].contains(state.event) {
                    isAuthenticated = state.session != nil
                }
            }
        }
    }
}

// MARK: - 各パネル
private extension ContentView {
    var scannerPanel: some View {
        VStack {
            List(scanner.scannedUII, id: \.self) { Text($0) }

            HStack(spacing: 10) {
                Button {
                    scanner.readState == .standby
                        ? scanner.startScan()
                        : scanner.stopScan()
                } label: {
                    Text(scanner.readState == .standby ? "スキャン開始" : "スキャン停止")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                Button("クリア") { scanner.clearScannedData() }
                    .buttonStyle(.bordered)

                Button("再接続") { scanner.reconnect() }
                    .buttonStyle(.bordered)
            }
        }
    }
}

// MARK: - タブ定義
extension ContentView {
    enum Tab: String, CaseIterable, Identifiable {
        case scanner     = "スキャナ"
        case settings    = "設定"
        case compare     = "比較"
        case profile     = "プロフィール"
        case registration = "登録"
        var id: String { rawValue }
    }
}
