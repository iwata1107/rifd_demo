//
//  SupabaseConfig.swift
//  RFID_ios
//
//  Created on 2025/05/05.
//

import Foundation

/// Supabaseの接続情報を管理する構造体
struct SupabaseConfig {
    /// Supabaseプロジェクトのエンドポイント
    static let supabaseURL = "https://your-project-url.supabase.co"

    /// SupabaseのAnonymous API Key
    static let supabaseAnonKey = "your-anon-key"

    /// 設定が有効かどうかを確認
    static var isConfigValid: Bool {
        return supabaseURL != "https://your-project-url.supabase.co" &&
               supabaseAnonKey != "your-anon-key"
    }
}
