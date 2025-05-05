//import SwiftUI
//import DENSOScannerSDK
//
//


import SwiftUI

struct ContentView: View {
    @EnvironmentObject var scanner: ScannerManager
    @EnvironmentObject var deps:    AppDependencies   // 簡易アクセス

    @State private var tab: Tab = .scanner

    var body: some View {
        NavigationView {
            VStack(spacing: 12) {
                // …（既存 UI はそのまま）…

                Picker("機能", selection: $tab) {
                    ForEach(Tab.allCases) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(SegmentedPickerStyle())

                Group {
                    switch tab {
                    case .scanner : scannerPanel
                    case .settings: SettingsView()
                    case .compare : CompareMasterView()
                    }
                }
                .frame(maxHeight: .infinity)
            }
            .padding()
            .navigationTitle("RFID Demo")
        }
    }
}




// MARK: - 各パネル
private extension ContentView {

    // スキャナ操作
    var scannerPanel: some View {
        VStack {
            List(scanner.scannedUII, id: \.self) { Text($0) }

            HStack(spacing: 10) {
                // Start / Stop を 1 ボタンでトグル
                Button {
                    scanner.readState == .standby ? scanner.startScan()
                                                   : scanner.stopScan()
                } label: {
                    Text(scanner.readState == .standby ? "スキャン開始" : "スキャン停止")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                Button("クリア") { scanner.clearScannedData() }
                    .buttonStyle(.bordered)

                // ★ 新規：再接続
                Button("再接続") { scanner.reconnect() }
                    .buttonStyle(.bordered)
            }
        }
    }
}

// MARK: - タブ
private extension ContentView {
    enum Tab: String, CaseIterable, Identifiable {
        case scanner = "スキャナ"
        case settings = "設定"
        case compare = "比較"          // ←追加
        var id: String { rawValue }
    }
}
