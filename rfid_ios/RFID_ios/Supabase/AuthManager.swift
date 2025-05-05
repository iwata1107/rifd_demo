//
//  AuthManager.swift
//  RFID_ios
//
//  Created on 2025/05/05.
//

import Foundation
import Supabase
import Combine

/// 認証状態を管理するクラス
@MainActor
class AuthManager: ObservableObject {
    // 認証状態
    @Published var isAuthenticated: Bool = false
    @Published var currentUser: User? = nil
    @Published var isLoading: Bool = false

    // エラーハンドリング
    @Published var authError: Error? = nil

    // Supabaseクライアント
    private let supabase = SupabaseManager.shared.client

    init() {
        // アプリ起動時にセッションを復元
        Task {
            await restoreSession()
        }
    }

    /// メールとパスワードでサインイン
    func signIn(email: String, password: String) async -> Bool {
        isLoading = true
        authError = nil

        do {
            let authResponse = try await supabase.auth.signIn(
                email: email,
                password: password
            )

            currentUser = authResponse.user
            isAuthenticated = currentUser != nil
            isLoading = false
            return true
        } catch {
            authError = error
            isLoading = false
            return false
        }
    }

    /// メールとパスワードでサインアップ
    func signUp(email: String, password: String, fullName: String? = nil) async -> Bool {
        isLoading = true
        authError = nil

        do {
            var userMetadata: [String: String] = [:]
            if let fullName = fullName {
                userMetadata["full_name"] = fullName
            }

            let authResponse = try await supabase.auth.signUp(
                email: email,
                password: password,
                data: userMetadata
            )

            currentUser = authResponse.user
            isAuthenticated = currentUser != nil
            isLoading = false
            return true
        } catch {
            authError = error
            isLoading = false
            return false
        }
    }

    /// サインアウト
    func signOut() async {
        isLoading = true

        do {
            try await supabase.auth.signOut()
            currentUser = nil
            isAuthenticated = false
        } catch {
            authError = error
        }

        isLoading = false
    }

    /// セッションの復元
    func restoreSession() async {
        isLoading = true

        do {
            let session = try await supabase.auth.session
            currentUser = session?.user
            isAuthenticated = currentUser != nil
        } catch {
            currentUser = nil
            isAuthenticated = false
            authError = error
        }

        isLoading = false
    }
}
