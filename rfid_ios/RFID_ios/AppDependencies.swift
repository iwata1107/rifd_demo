//
//  AppDependencies.swift
//  RFID_ios
//
//  Created by ChatGPT on 2025/05/04.
//

import Foundation
import DENSOScannerSDK

/// アプリ全体で共有する Manager 群を 1 か所で生成するコンテナ
@MainActor
final class AppDependencies: ObservableObject {

    let scannerManager: ScannerManager
    let settingManager: SettingManager
    let compareManager: CompareMasterManager
    let authManager: AuthManager
    let inventoryManager: InventoryMasterManager

    init() {
        // スキャナー関連のマネージャー
        let sm = ScannerManager()
        scannerManager = sm
        settingManager = SettingManager(scannerManager: sm)
        compareManager = CompareMasterManager(scannerManager: sm)

        // Supabase関連のマネージャー
        authManager = AuthManager()
        inventoryManager = InventoryMasterManager()

        // READY 後の処理など…
        scannerManager.onScannerReady = { [weak self] _, _ in
            self?.settingManager.refreshBatteryLevel()
        }
        scannerManager.initializeScanner()
    }
}
