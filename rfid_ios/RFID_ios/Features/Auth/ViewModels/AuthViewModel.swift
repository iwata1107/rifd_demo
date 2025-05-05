//
//  AuthViewModel.swift
//  RFID_ios
//
//  Created on 2025/05/05.
//

import Foundation
import Combine

/// 認証状態を管理するViewModel
@MainActor
class AuthViewModel: ObservableObject {
    // 認証状態
    @Published var isAuthenticated: Bool = false
    @Published var currentUser: User? = nil
    @Published var isLoading: Bool = false

    // エラーハンドリング
    @Published var authError: Error? = nil

    // Supabaseサービス
    private let supabaseService = SupabaseService.shared

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
            currentUser = try await supabaseService.signIn(email: email, password: password)
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
            var userMetadata: [String: Any]? = nil
            if let fullName = fullName {
                userMetadata = ["full_name": fullName]
            }

            currentUser = try await supabaseService.signUp(
                email: email,
                password: password,
                userData: userMetadata
            )

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
            try await supabaseService.signOut()
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
            currentUser = try await supabaseService.getSession()
            isAuthenticated = currentUser != nil
        } catch {
            currentUser = nil
            isAuthenticated = false
            authError = error
        }

        isLoading = false
    }
}
