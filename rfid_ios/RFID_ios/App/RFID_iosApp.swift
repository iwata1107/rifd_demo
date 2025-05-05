//
//  RFID_iosApp.swift
//  RFID_ios
//
//  Created by 岩田照太 on 2024/11/13.
//

import SwiftUI
import DENSOScannerSDK
import Supabase

@main
struct DensoScannerApp: App {
    @StateObject private var deps = AppDependencies()

    init() {
        // Supabaseのセットアップ
        setupSupabase()
    }

    var body: some Scene {
        WindowGroup {
            MainContentView()
                .environmentObject(deps)
                .environmentObject(deps.scannerService)
                .environmentObject(deps.settingManager)
                .environmentObject(deps.compareManager)
                .environmentObject(deps.authViewModel)
                .environmentObject(deps.inventoryViewModel)
        }
    }

    // Supabaseの設定
    private func setupSupabase() {
        // ここでSupabaseの設定を行う場合は実装
        // 例: ログレベルの設定など
    }
}
