//
//  MainContentView.swift
//  RFID_ios
//
//  Created on 2025/05/05.
//

import SwiftUI

struct MainContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var scannerService: ScannerService
    @EnvironmentObject var settingManager: SettingManager
    @EnvironmentObject var compareManager: CompareMasterManager
    @EnvironmentObject var inventoryViewModel: InventoryViewModel

    @State private var tab: Tab = .scanner

    var body: some View {
        Group {
            if authViewModel.isLoading {
                loadingView
            } else if !authViewModel.isAuthenticated {
                LoginView()
            } else {
                mainTabView
            }
        }
    }

    // ローディング表示
    private var loadingView: some View {
        VStack {
            ProgressView("読み込み中...")
            Text("認証情報を確認しています")
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.top, 8)
        }
    }

    // メインのタブビュー
    private var mainTabView: some View {
        TabView(selection: $tab) {
            scannerTab
                .tabItem {
                    Label("スキャナー", systemImage: "barcode.viewfinder")
                }
                .tag(Tab.scanner)

            InventoryMasterListView()
                .tabItem {
                    Label("マスター", systemImage: "list.bullet.clipboard")
                }
                .tag(Tab.inventory)

            CompareMasterView()
                .tabItem {
                    Label("比較", systemImage: "arrow.left.arrow.right")
                }
                .tag(Tab.compare)

            SettingView()
                .tabItem {
                    Label("設定", systemImage: "gear")
                }
                .tag(Tab.settings)

            profileTab
                .tabItem {
                    Label("プロフィール", systemImage: "person.circle")
                }
                .tag(Tab.profile)
        }
    }

    // スキャナータブ
    private var scannerTab: some View {
        NavigationView {
            VStack(spacing: 12) {
                List(scannerService.scannedUII, id: \.self) { Text($0) }

                HStack(spacing: 10) {
                    Button {
                        scannerService.readState == .standby ? scannerService.startScan()
                                                             : scannerService.stopScan()
                    } label: {
                        Text(scannerService.readState == .standby ? "スキャン開始" : "スキャン停止")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)

                    Button("クリア") { scannerService.clearScannedData() }
                        .buttonStyle(.bordered)

                    Button("再接続") { scannerService.reconnect() }
                        .buttonStyle(.bordered)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .navigationTitle("RFIDスキャナー")
        }
    }

    // プロフィールタブ
    private var profileTab: some View {
        NavigationView {
            VStack {
                if let user = authViewModel.currentUser {
                    Form {
                        Section(header: Text("アカウント情報")) {
                            LabeledContent("メールアドレス", value: user.email ?? "不明")

                            if let metadata = user.userMetadata,
                               let fullName = metadata["full_name"] as? String {
                                LabeledContent("氏名", value: fullName)
                            }

                            LabeledContent("ユーザーID", value: user.id)
                        }

                        Section {
                            Button("ログアウト", role: .destructive) {
                                Task {
                                    await authViewModel.signOut()
                                }
                            }
                        }
                    }
                } else {
                    Text("ユーザー情報を読み込めませんでした")
                        .foregroundColor(.red)
                }
            }
            .navigationTitle("プロフィール")
        }
    }
}

// タブの種類
private enum Tab: String, CaseIterable, Identifiable {
    case scanner = "スキャナー"
    case inventory = "マスター"
    case compare = "比較"
    case settings = "設定"
    case profile = "プロフィール"

    var id: String { rawValue }
}

struct MainContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainContentView()
            .environmentObject(AuthViewModel())
            .environmentObject(ScannerService())
            .environmentObject(SettingManager(scannerManager: ScannerService()))
            .environmentObject(CompareMasterManager(scannerManager: ScannerService()))
            .environmentObject(InventoryViewModel())
    }
}
