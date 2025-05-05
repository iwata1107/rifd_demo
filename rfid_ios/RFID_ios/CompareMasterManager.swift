//
//  CompareMasterManager.swift
//  RFID_ios
//
//  2025-05-05  Security-Scoped 対応
//

import Foundation
import Combine

@MainActor
final class CompareMasterManager: ObservableObject {

    // ───────── 公開プロパティ ─────────
    @Published private(set) var masterFileName = "未選択"
    @Published private(set) var masterTags:  Set<String> = []
    @Published private(set) var actualTags:  Set<String> = []

    var uncountedTags: [String] { Array(masterTags.subtracting(actualTags)) }
    var outerTags:     [String] { Array(actualTags.subtracting(masterTags)) }

    // ───────── 依存関係 ─────────
    private var cancellables = Set<AnyCancellable>()

    init(scannerManager: ScannerManager) {
        // Scanner 側の読取結果を監視
        scannerManager.$scannedUII
            .sink { [weak self] list in
                self?.actualTags = Set(list)
            }
            .store(in: &cancellables)
    }

    // ───────── CSV 読み込み ─────────
    func loadMaster(from url: URL) {

        // 1) セキュリティスコープを取得
        guard url.startAccessingSecurityScopedResource() else {
            print("⚠️ CSV へのアクセスを取得できませんでした")
            return
        }
        defer { url.stopAccessingSecurityScopedResource() }

        // 2) 文字列として読み込み
        guard let text = try? String(contentsOf: url, encoding: .utf8) else {
            print("⚠️ CSV 読み込み失敗")
            return
        }

        // 3) 行単位でパース
        let rawTags = text
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        // 4) 必要ならバリデーション（例：8桁以上の16進）
        let normalized = rawTags.filter { $0.count >= 8 }

        masterFileName = url.lastPathComponent
        masterTags     = Set(normalized)

        if rawTags.count != masterTags.count {
            print("⚠️ CSV 内に重複タグ \(rawTags.count - masterTags.count) 件")
        }
    }
}
