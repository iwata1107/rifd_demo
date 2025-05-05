//  SettingManager.swift
//  RFID_ios
//
//  Created by 岩田照太 on 2025/05/05.
//  Debug, Buzzer On/Off 保存対応
//  読み取り強度（パワーレベル）選択機能追加

import Foundation
import Combine
import DENSOScannerSDK

@MainActor
final class SettingManager: ObservableObject {

    // MARK: - 公開プロパティ --------------------------------------------------
    @Published private(set) var batteryLevel: CommBattery = .COMM_BATTERY_UNDER10 {
        didSet { print("🟢 batteryLevel 変更 → \(batteryLevel)") }
    }
    @Published private(set) var isConnected: Bool = false {
        didSet { print("🟢 isConnected 変更 → \(isConnected)") }
    }

    /// 選択中ブザータイプ (B1/B2/B3)
    @Published var selectedBuzzer: CommBuzzerType = .COMM_BUZZER_B1 {
        didSet { print("🟢 selectedBuzzer 変更 → \(selectedBuzzer)") }
    }

    /// ブザー有効/無効スイッチ (UI で ON/OFF)
    @Published var isBuzzerOn: Bool = true {
        didSet {
            print("🟢 isBuzzerOn 変更 → \(isBuzzerOn)")
            toggleBuzzer(on: isBuzzerOn)
        }
    }

    // ──────────────────────────────────────────────────────────
    // ↓ ここから追加部分 ↓
    /// 読み取り強度（パワーレベル）範囲: 4〜30 dBm
    let readPowerRange: ClosedRange<Int> = 4...30

    /// 選択中の読み取りパワーレベル
    @Published var selectedReadPower: Int = 30 {
        didSet {
            print("🟢 selectedReadPower 変更 → \(selectedReadPower)dBm")
            updateReadPower()
        }
    }
    // ↑ ここまで追加部分 ↑
    // ──────────────────────────────────────────────────────────

    // MARK: - 依存関係 --------------------------------------------------------
    private weak var scannerManager: ScannerManager?
    private var cancellables = Set<AnyCancellable>()
    private var commScanner: CommScanner? { scannerManager?.commScanner }

    // MARK: - 初期化 ----------------------------------------------------------
    init(scannerManager: ScannerManager) {
        self.scannerManager = scannerManager
        print("🔸 SettingManager 初期化 — scannerManager: \(scannerManager)")
        observeScannerConnection()
        updateBatteryLevel()
    }
    deinit { print("🔴 SettingManager 解放") }

    // MARK: - パブリック API ---------------------------------------------------
    func refreshBatteryLevel() {
        print("🔸 refreshBatteryLevel() 呼び出し")
        updateBatteryLevel()
    }

    func playSelectedBuzzer() {
        guard isBuzzerOn else {
            print("⚠️ ブザーOFF設定のため鳴動スキップ")
            return
        }
        guard let scanner = commScanner, isConnected else {
            print("⚠️ ブザー鳴動失敗: スキャナ未接続")
            return
        }
        print("🔸 playSelectedBuzzer() – type: \(selectedBuzzer)")
        var error: NSError?
        scanner.buzzer(selectedBuzzer, error: &error)
        if let error = error {
            print("⚠️ ブザー鳴動失敗: \(error.localizedDescription)")
        } else {
            print("✅ ブザー鳴動成功: \(selectedBuzzer)")
        }
    }

    /// 設定一括保存 (UI の[保存]ボタンから呼ぶ想定)
    func saveAllSettings() {
        print("🔸 saveAllSettings() 開始")
        guard let scanner = commScanner, isConnected else {
            print("⚠️ saveAllSettings(): スキャナ未接続")
            return
        }

        // ▼ 既存の保存処理 -----------------------------
        let dataSetStruct = SettingDataSet() // Placeholder
        var result = sendCommScannerParams(settingDataSet: dataSetStruct, commScanner: scanner)
        if result {
            result = sendRFIDScannerSettings(settingDataSet: dataSetStruct, commScanner: scanner)
        }
        if result {
            result = sendBarcodeScannerSettings(settingDataSet: dataSetStruct, commScanner: scanner)
        }
        if result {
            result = toggleBuzzer(on: isBuzzerOn)
        }
        // ────────────────────────────────────────────────

        // 読み取り強度を最後に反映
        if result {
            _ = updateReadPower()
        }
    }

    // MARK: - 内部処理 --------------------------------------------------------
    private func observeScannerConnection() {
        scannerManager?.$isConnected
            .receive(on: DispatchQueue.main)
            .sink { [weak self] connected in
                guard let self = self else { return }
                self.isConnected = connected
                updateBatteryLevel()
            }
            .store(in: &cancellables)
    }

    private func updateBatteryLevel() {
        guard let scanner = commScanner, isConnected else {
            batteryLevel = .COMM_BATTERY_UNDER10
            return
        }
        var error: NSError?
        let level = scanner.getRemainingBattery(&error)
        batteryLevel = (error == nil) ? level : .COMM_BATTERY_UNDER10
    }

    @discardableResult
    private func toggleBuzzer(on enabled: Bool) -> Bool {
        guard let scanner = commScanner, isConnected else { return false }
        var error: NSError?
        guard let params = scanner.getParams(&error) else {
            print("⚠️ getParams 失敗: \(error?.localizedDescription ?? "")")
            return false
        }
        params.notification.sound.buzzer = enabled ? .BUZZER_ENABLE : .BUZZER_DISABLE
        scanner.setParams(params, error: &error)
        if let error = error {
            print("⚠️ setParams 失敗: \(error.localizedDescription)")
            return false
        }
        scanner.saveParams(&error)
        if let error = error {
            print("⚠️ saveParams 失敗: \(error.localizedDescription)")
            return false
        }
        return true
    }

    // ──────────────────────────────────────────────────────────
    // ↓ 修正: 読み取り強度反映メソッド ↓
    @discardableResult
    private func updateReadPower() -> Bool {
        guard let scanner = commScanner, isConnected else {
            print("⚠️ updateReadPower(): スキャナ未接続")
            return false
        }
        var error: NSError?
        guard let rfidScanner = scanner.getRFIDScanner() else {
            print("⚠️ getRFIDScanner() 失敗")
            return false
        }
        guard var settings = rfidScanner.getSettings(&error) else {
            print("⚠️ getSettings 失敗: \(error?.localizedDescription ?? "")")
            return false
        }
        settings.scan.powerLevelRead = Int32(selectedReadPower)
        rfidScanner.setSettings(settings, error: &error)
        if let error = error {
            print("⚠️ setSettings 失敗: \(error.localizedDescription)")
            return false
        }
        return true
    }
    // ↑ ここまで修正部分 ↑
    // ──────────────────────────────────────────────────────────

    // MARK: - 既存 send* メソッド -------------------------------
    private func sendCommScannerParams(settingDataSet: SettingDataSet, commScanner: CommScanner) -> Bool {
        scannerManager?.sendCommScannerParams(settingDataSet: settingDataSet, commScanner: commScanner) ?? false
    }
    private func sendRFIDScannerSettings(settingDataSet: SettingDataSet, commScanner: CommScanner) -> Bool {
        scannerManager?.sendRFIDScannerSettings(settingDataSet: settingDataSet, commScanner: commScanner) ?? false
    }
    private func sendBarcodeScannerSettings(settingDataSet: SettingDataSet, commScanner: CommScanner) -> Bool {
        scannerManager?.sendBarcodeScannerSettings(settingDataSet: settingDataSet, commScanner: commScanner) ?? false
    }
}
