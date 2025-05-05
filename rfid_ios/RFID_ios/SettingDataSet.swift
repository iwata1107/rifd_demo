//
//  SettingDataSet.swift (minimal版)
//  RFID_ios
//
//  Created by ChatGPT on 2025/05/05.
//
//  ────────────────────────────────────────────────────────────────
//  👉 最小構成: 今は "ブザー ON/OFF" だけ保存できれば良い、という要求に
//     絞ったプレーンなデータセットです。
//  ────────────────────────────────────────────────────────────────
//  必要になったらプロパティを段階的に追加していけるよう、拡張しやすい
//  シンプルな実装にしています。
//

import UIKit

// MARK: - 共通プロトコル ------------------------------------------------------

/// 設定要素の共通インターフェース（今回は height のみ）
protocol SettingData: Codable {
    var height: CGFloat { get }
}

// MARK: - スイッチタイプ -------------------------------------------------------

/// ON/OFF を持つシンプルな設定要素
final class SettingDataWithSwitch: SettingData {
    var headerText: String = ""
    var isEnabled: Bool = false
    var height: CGFloat { 64.0 }

    init(headerText: String = "", isEnabled: Bool = false) {
        self.headerText = headerText
        self.isEnabled  = isEnabled
    }
}

// MARK: - SettingDataSet (最小) ----------------------------------------------

/// *今は* ブザー設定だけを扱うミニマルなデータモデル。
/// 今後項目が増えたら、プロパティと `values` 配列に追加していく。
final class SettingDataSet: Codable {

    // ① 今回必要なのはブザー ON/OFF だけ
    var buzzer: SettingDataWithSwitch?

    /// 空のデータセット生成
    init() {
        // デフォルトは ON
        self.buzzer = SettingDataWithSwitch(headerText: "Buzzer", isEnabled: true)
    }

    /// 要素を配列化（順番は定義順）。登録項目が増えたらここを拡張
    var values: [SettingData] {
        get { [buzzer].compactMap { $0 } }
        set(v) {
            guard v.count >= 1 else { return }
            buzzer = v[0] as? SettingDataWithSwitch
        }
    }
}
