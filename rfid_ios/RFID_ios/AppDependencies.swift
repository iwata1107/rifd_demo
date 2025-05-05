// AppDependencies.swift
// RFID_ios
//
// Created by ChatGPT on 2025/05/04.
//

import Foundation
import DENSOScannerSDK
import Supabase  // Supabase クライアントを使うために追加

/// アプリ全体で共有する Manager 群を 1 か所で生成するコンテナ
@MainActor
final class AppDependencies: ObservableObject {

    let scannerManager:  ScannerManager
    let settingManager:  SettingManager
    let compareManager:  CompareMasterManager

    init() {
        // Scanner 周り
        let sm = ScannerManager()
        scannerManager = sm
        settingManager = SettingManager(scannerManager: sm)
        compareManager = CompareMasterManager(scannerManager: sm)

        // スキャナ準備完了後のコールバック
        scannerManager.onScannerReady = { [weak self] _, _ in
            self?.settingManager.refreshBatteryLevel()
        }

        // スキャナ初期化
        scannerManager.initializeScanner()
    }
}
