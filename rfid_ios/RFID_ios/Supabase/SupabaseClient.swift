//
//  SupabaseClient.swift
//  RFID_ios
//
//  Created on 2025/05/05.
//

import Foundation
import Supabase

/// Supabaseクライアントを管理するシングルトンクラス
class SupabaseManager {
    static let shared = SupabaseManager()

    // Supabaseクライアント
    private(set) lazy var client = SupabaseClient(
        supabaseURL: URL(string: SupabaseConfig.supabaseURL)!,
        supabaseKey: SupabaseConfig.supabaseAnonKey
    )

    // 設定が有効かどうか
    var isConfigValid: Bool {
        return SupabaseConfig.isConfigValid
    }

    private init() {
        if !isConfigValid {
            print("⚠️ Supabase設定が未完了です。SupabaseConfig.swiftファイルを編集してください。")
        }
    }
}
