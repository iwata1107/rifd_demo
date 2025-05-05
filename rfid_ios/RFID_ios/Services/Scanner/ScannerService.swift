//
//  ScannerService.swift
//  RFID_ios
//
//  Created on 2025/05/05.
//

import Foundation
import DENSOScannerSDK
import Combine

/// スキャナーとの通信を管理するサービス
@MainActor
final class ScannerService: NSObject, ObservableObject, RFIDDataDelegate, ScannerStatusListener {

    // MARK: - 公開プロパティ

    /// スキャナーの状態
    enum ReadState {
        case standby
        case reading
    }

    /// 現在の読み取り状態
    @Published var readState: ReadState = .standby

    /// スキャンしたUII（タグID）のリスト
    @Published var scannedUII: [String] = []

    /// スキャナーの接続状態
    @Published var isConnected: Bool = false

    /// スキャナーの準備状態
    @Published var isReady: Bool = false

    /// エラー情報
    @Published var errorMessage: String? = nil

    /// スキャナー準備完了時のコールバック
    var onScannerReady: ((CommScanner, Bool) -> Void)?

    // MARK: - 内部プロパティ

    /// スキャナーマネージャー
    private var commManager: CommManager?

    /// RFIDスキャナー
    private var rfidScanner: RFIDScanner?

    // MARK: - 初期化

    override init() {
        super.init()
        initializeScanner()
    }

    // MARK: - 公開メソッド

    /// スキャナーの初期化
    func initializeScanner() {
        // CommManagerの初期化
        commManager = CommManager.sharedManager()

        // スキャナーの検索
        let scanners = commManager?.scanForScanners()

        if let scanner = scanners?.first {
            // スキャナーの取得
            commManager?.connect(scanner)

            // リスナーの設定
            scanner.addStatusListener(self)

            // RFIDスキャナーの取得
            rfidScanner = scanner.getRFIDScanner()

            // デリゲートの設定
            rfidScanner?.setDataDelegate(self)

            isConnected = true
        } else {
            errorMessage = "スキャナーが見つかりませんでした"
        }
    }

    /// スキャンの開始
    func startScan() {
        guard let rfidScanner = rfidScanner, isReady else {
            errorMessage = "スキャナーの準備ができていません"
            return
        }

        do {
            try rfidScanner.startScan()
            readState = .reading
        } catch {
            errorMessage = "スキャン開始エラー: \(error.localizedDescription)"
        }
    }

    /// スキャンの停止
    func stopScan() {
        guard let rfidScanner = rfidScanner else { return }

        do {
            try rfidScanner.stopScan()
            readState = .standby
        } catch {
            errorMessage = "スキャン停止エラー: \(error.localizedDescription)"
        }
    }

    /// スキャンデータのクリア
    func clearScannedData() {
        scannedUII.removeAll()
    }

    /// スキャナーの再接続
    func reconnect() {
        if let scanner = commManager?.scanForScanners().first {
            commManager?.connect(scanner)
        } else {
            errorMessage = "スキャナーが見つかりませんでした"
        }
    }

    // MARK: - RFIDDataDelegate

    func onRFIDDataReceived(_ event: RFIDDataReceivedEvent!) {
        if let data = event.data {
            let uii = data.uii

            // 重複チェック
            if !scannedUII.contains(uii) {
                scannedUII.append(uii)
            }
        }
    }

    // MARK: - ScannerStatusListener

    func onScannerStatusChanged(_ scanner: CommScanner!, status: Int32, param: Int32) {
        switch status {
        case SCANNER_STATUS_READY:
            isReady = true
            onScannerReady?(scanner, true)
        case SCANNER_STATUS_COMM_ERROR:
            isConnected = false
            isReady = false
            errorMessage = "通信エラーが発生しました"
        default:
            break
        }
    }
}
