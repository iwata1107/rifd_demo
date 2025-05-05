//
//  AppDependencies.swift
//  RFID_ios
//
//  Created by ChatGPT on 2025/05/04.
//

import Foundation
import DENSOScannerSDK

/// アプリ全体で共有する依存関係を管理するコンテナ
@MainActor
final class AppDependencies: ObservableObject {

    // サービス
    let scannerService: ScannerService
    let supabaseService: SupabaseService

    // 機能別ViewModel
    let authViewModel: AuthViewModel
    let inventoryViewModel: InventoryViewModel

    // 既存のマネージャー
    let settingManager: SettingManager
    let compareManager: CompareMasterManager

    init() {
        // サービスの初期化
        scannerService = ScannerService()
        supabaseService = SupabaseService.shared

        // ViewModelの初期化
        authViewModel = AuthViewModel()
        inventoryViewModel = InventoryViewModel()

        // 既存のマネージャーの初期化
        settingManager = SettingManager(scannerManager: scannerService)
        compareManager = CompareMasterManager(scannerManager: scannerService)

        // READY 後の処理など…
        scannerService.onScannerReady = { [weak self] _, _ in
            self?.settingManager.refreshBatteryLevel()
        }
    }
}
