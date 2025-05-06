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
                            case .masterRegistration:
                                InventoryMasterFormView()
                            case .search:
                                ItemSearchView()
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
        ScrollView {
            VStack(spacing: 16) {
                // 読取済みタグ一覧
                if scanner.scannedUII.isEmpty {
                    Text("RFIDをスキャンしてください")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, minHeight: 120)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                } else {
                    List(scanner.scannedUII, id: \.self) {
                        Text($0)
                    }
                    .frame(height: min(CGFloat(scanner.scannedUII.count) * 44, CGFloat(300)))
                    .listStyle(.plain)
                }

                // 操作ボタン
                HStack(spacing: 12) {
                    Button {
                        scanner.readState == .standby
                            ? scanner.startScan()
                            : scanner.stopScan()
                    } label: {
                        HStack {
                            Image(systemName: scanner.readState == .standby ? "barcode.viewfinder" : "stop.circle")
                            Text(scanner.readState == .standby ? "スキャン開始" : "スキャン停止")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)

                    Button {
                        scanner.clearScannedData()
                    } label: {
                        Image(systemName: "trash")
                        Text("クリア")
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)

                    Button {
                        scanner.reconnect()
                    } label: {
                        Image(systemName: "arrow.triangle.2.circlepath")
                        Text("再接続")
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
            }
            .padding(.vertical)
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
        case masterRegistration = "マスター登録"
        case search      = "商品検索"
        var id: String { rawValue }
    }
}
