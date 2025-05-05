//
//  ScannerManager.swift  (デバッグ強化版 最小スタブ実装)
//  RFIDScannerApp
//
//  Swift-6  /  DENSO-WAVE SDK 2025-05-05
//
//  ▷ 追加点
//    • 各主要イベントに "🇯🇵" マーク付きの日本語ログを追加
//    • runRead の実行前後、タイムアウト、エラー箇所など詳細に出力
//    • stub メソッドも呼び出し元が一目で分かるようにログ強化
//
//  ⚠️ 実際にパラメータ送信を実装する際は、stub を置き換えてください。
//
import Foundation
import DENSOScannerSDK
import Combine
import UIKit

final class ScannerManager: NSObject,
                            ObservableObject,
                            ScannerAcceptStatusListener,
                            RFIDDataDelegate,
                            ScannerStatusListener {

    // MARK: - Published -----------------------------------------------------
    @Published private(set) var isConnected   = false
    @Published private(set) var statusMessage = "スキャナを待機中…"
    @Published private(set) var scannedUII: [String] = []
    @Published private(set) var readState: ReadState = .standby

    // MARK: - Callbacks ------------------------------------------------------
    var onConnected:        ((RFIDScanner, CommScanner) -> Void)?
    var onScannerReady:     ((RFIDScanner, CommScanner) -> Void)?
    var onReadStateChanged: ((ReadState) -> Void)?

    // MARK: - SDK Objects ----------------------------------------------------
    private(set) var rfidScanner:  RFIDScanner?
    private(set) var commScanner:  CommScanner?

    // MARK: - Internal State -------------------------------------------------
    private var isOperatingScanner = false
    private var bgObserverToken: NSObjectProtocol?

    // MARK: - Initialization -------------------------------------------------
    func initializeScanner() {
        print("🇯🇵 [Init] スキャナ初期化開始")
        if CommManager.sharedInstance() == nil { CommManager.initialize() }
        let mgr = CommManager.sharedInstance()!
        mgr.addAcceptStatusListener(listener: self)
        mgr.startAccept()

        // バックグラウンド移行時に読み取り停止
        bgObserverToken = NotificationCenter.default.addObserver(
            forName: UIApplication.willResignActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            print("🇯🇵 [BG] アプリバックグラウンド → 読み取り停止")
            Task { @MainActor in self.runRead(action: .stop) }
        }

        Task { @MainActor in self.statusMessage = "スキャナ待機中…" }
    }

    deinit {
        if let t = bgObserverToken { NotificationCenter.default.removeObserver(t) }
        print("🇯🇵 [Deinit] ScannerManager 解放")
    }

    // MARK: - Public Controls ----------------------------------------------
    func startScan() { Task { @MainActor in self.runRead(action: .start) } }
    func stopScan()  { Task { @MainActor in self.runRead(action: .stop ) } }

    func reconnect() {
        print("🇯🇵 [Reconnect] 再接続要求")
        releaseScanner()
        CommManager.sharedInstance()?.startAccept()
        Task { @MainActor in self.statusMessage = "再接続を試行中…" }
    }

    func clearScannedData() {
        Task { @MainActor in
            self.scannedUII.removeAll()
            self.statusMessage = "スキャンデータをクリアしました"
        }
    }

    // MARK: - SDK Callbacks --------------------------------------------------
    func OnScannerAppeared(scanner: CommScanner!) {
        print("🇯🇵 [Detect] スキャナ検出 → \(scanner.getModel() ?? "unknown")")
        var err: NSError?
        scanner.claim(&err)
        if let e = err {
            print("🛑 [Detect] CLAIM 失敗: \(e.localizedDescription)")
            updateUI(message: "接続失敗: \(e.localizedDescription)")
            return
        }
        print("✅ [Detect] CLAIM 成功")
        commScanner = scanner
        commScanner?.addStatusListener(self)
        rfidScanner = commScanner?.getRFIDScanner()
        rfidScanner?.setDataDelegate(delegate: self)

        if let r = rfidScanner, let c = commScanner {
            print("🔔 [Callback] onConnected 発火")
            onConnected?(r, c)
        }

        updateUI(connected: true, message: "接続完了: \(scanner.getModel() ?? "Unknown")")
    }

    func OnScannerDisappeared(scanner: CommScanner!) {
        print("🇯🇵 [Disconnect] スキャナ切断検出")
        releaseScanner()
        updateUI(connected: false, message: "スキャナが切断されました")
    }

    func OnScannerStatusChanged(scanner: CommScanner!, state: CommStatusChangedEvent!) {
        let st = state.getStatus()
        print("🇯🇵 [Status] 状態変化 → raw=\(st.rawValue)")
        switch st {
        case .SCANNER_STATUS_CLAIMED:
            waitRFIDReady(scanner)
        case .SCANNER_STATUS_CLOSE_WAIT, .SCANNER_STATUS_CLOSED:
            print("🛑 [Status] CLOSE 系ステータス検出")
            releaseScanner()
            updateUI(connected: false, message: "スキャナ切断")
        default:
            print("⚠️ [Status] 不明ステータス: raw=\(st.rawValue)")
        }
    }

    // MARK: - RFIDScanner Ready Polling -------------------------------------
    private func waitRFIDReady(_ scanner: CommScanner, retry: Int = 10) {
        if let r = scanner.getRFIDScanner() {
            print("✅ [RFID] RFIDScanner 取得成功 — 残リトライ \(retry)")
            attachAndNotify(rfid: r, comm: scanner)
            return
        }
        guard retry > 0 else {
            print("🛑 [RFID] 取得タイムアウト — 初期化失敗")
            updateUI(message: "RFID 初期化失敗")
            return
        }
        print("… [RFID] まだ nil — 残リトライ \(retry)")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.waitRFIDReady(scanner, retry: retry - 1)
        }
    }

    private func attachAndNotify(rfid: RFIDScanner, comm: CommScanner) {
        print("🇯🇵 [Attach] attachAndNotify 実行")
        rfidScanner = rfid
        commScanner = comm
        rfidScanner?.setDataDelegate(delegate: self)
        updateUI(connected: true, message: "使用可能です")
        print("🔔 [Callback] onScannerReady 発火")
        onScannerReady?(rfid, comm)
    }

    // MARK: - RFID Data Receive --------------------------------------------
    func OnRFIDDataReceived(scanner: CommScanner!, rfidEvent: RFIDDataReceivedEvent!) {
        let tags = rfidEvent.getRFIDData()
            .compactMap { $0.getUII() }
            .map { $0.map { String(format: "%02X", $0) }.joined() }
        print("📦 [RFID] データ受信 → 件数 \(tags.count)")
        Task { @MainActor in
            for tag in tags where !self.scannedUII.contains(tag) {
                self.scannedUII.append(tag)
            }
        }
    }

    // MARK: - Read Control ---------------------------------------------------
    @MainActor
    private func runRead(action: ReadAction) {
        print("🇯🇵 [Read] runRead → \(action == .start ? "開始" : "停止")")
        guard !isOperatingScanner else { print("⚠️ [Read] 他操作中"); return }
        guard readState.runnable(action: action) else { print("⚠️ [Read] 無効アクション"); return }
        guard let rfid = rfidScanner else {
            print("🛑 [Read] rfidScanner == nil")
            statusMessage = "スキャナが接続されていません"
            return
        }

        isOperatingScanner = true
        var err: NSError?
        switch action {
        case .start: rfid.openInventory(&err)
        case .stop : rfid.close(&err)
        }
        isOperatingScanner = false

        if let e = err {
            print("🛑 [Read] エラー: \(e.localizedDescription)")
            statusMessage = "通信エラー: \(e.localizedDescription)"
        } else {
            print("✅ [Read] 正常終了")
            readState = ReadState.nextState(action: action)
            onReadStateChanged?(readState)
            statusMessage = action == .start ? "スキャン中…" : "スキャン停止"
        }
    }

    // MARK: - Release --------------------------------------------------------
    private func releaseScanner() {
        print("🇯🇵 [Release] リソース解放開始")
        var e: NSError?
        rfidScanner?.setDataDelegate(delegate: nil)
        rfidScanner?.close(&e)
        commScanner?.getParams(&e)
        rfidScanner = nil
        commScanner = nil
        readState   = .standby
        isConnected = false
    }

    // MARK: - UI Utility -----------------------------------------------------
    private func updateUI(connected: Bool? = nil, message: String) {
        Task { @MainActor in
            if let c = connected { self.isConnected = c }
            self.statusMessage = message
        }
    }

    // ───────────────────────────────────────────────
    // MARK: - SettingManager 連携用スタブ
    // ───────────────────────────────────────────────
    @discardableResult
    func sendCommScannerParams(settingDataSet: SettingDataSet,
                               commScanner: CommScanner) -> Bool {
        print("📨 [Stub] sendCommScannerParams — 呼び出し確認 OK")
        return true
    }

    @discardableResult
    func sendRFIDScannerSettings(settingDataSet: SettingDataSet,
                                 commScanner: CommScanner) -> Bool {
        print("📨 [Stub] sendRFIDScannerSettings — 呼び出し確認 OK")
        return true
    }

    @discardableResult
    func sendBarcodeScannerSettings(settingDataSet: SettingDataSet,
                                    commScanner: CommScanner) -> Bool {
        print("📨 [Stub] sendBarcodeScannerSettings — 呼び出し確認 OK")
        return true
    }
}

// MARK: - Read enums --------------------------------------------------------
enum ReadAction { case start, stop }

enum ReadState {
    case standby, reading
    func nextAction() -> ReadAction { self == .standby ? .start : .stop }
    func runnable(action: ReadAction) -> Bool { action == nextAction() }
    static func nextState(action: ReadAction) -> ReadState {
        action == .start ? .reading : .standby
    }
}
