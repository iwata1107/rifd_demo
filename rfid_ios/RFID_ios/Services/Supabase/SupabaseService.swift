//
//  SupabaseService.swift
//  RFID_ios
//
//  Created on 2025/05/05.
//

import Foundation
import Supabase
import Combine

/// Supabaseサービスを提供するクラス
class SupabaseService {
    // シングルトンインスタンス
    static let shared = SupabaseService()

    // Supabaseクライアント
    private let client: SupabaseClient

    // 初期化
    private init() {
        client = SupabaseClient(
            supabaseURL: URL(string: SupabaseConfig.supabaseURL)!,
            supabaseKey: SupabaseConfig.supabaseAnonKey
        )

        if !SupabaseConfig.isConfigValid {
            print("⚠️ Supabase設定が未完了です。SupabaseConfig.swiftファイルを編集してください。")
        }
    }

    // MARK: - 認証関連

    /// メールとパスワードでサインイン
    func signIn(email: String, password: String) async throws -> User {
        let authResponse = try await client.auth.signIn(
            email: email,
            password: password
        )

        guard let user = authResponse.user else {
            throw NSError(domain: "SupabaseService", code: 1001, userInfo: [NSLocalizedDescriptionKey: "ユーザー情報の取得に失敗しました"])
        }

        return User(
            id: user.id,
            email: user.email,
            createdAt: user.createdAt ?? Date(),
            updatedAt: user.updatedAt,
            userMetadata: user.userMetadata
        )
    }

    /// メールとパスワードでサインアップ
    func signUp(email: String, password: String, userData: [String: Any]? = nil) async throws -> User {
        let authResponse = try await client.auth.signUp(
            email: email,
            password: password,
            data: userData
        )

        guard let user = authResponse.user else {
            throw NSError(domain: "SupabaseService", code: 1002, userInfo: [NSLocalizedDescriptionKey: "ユーザー登録に失敗しました"])
        }

        return User(
            id: user.id,
            email: user.email,
            createdAt: user.createdAt ?? Date(),
            updatedAt: user.updatedAt,
            userMetadata: user.userMetadata
        )
    }

    /// サインアウト
    func signOut() async throws {
        try await client.auth.signOut()
    }

    /// 現在のセッションを取得
    func getSession() async throws -> User? {
        let session = try await client.auth.session

        guard let user = session?.user else {
            return nil
        }

        return User(
            id: user.id,
            email: user.email,
            createdAt: user.createdAt ?? Date(),
            updatedAt: user.updatedAt,
            userMetadata: user.userMetadata
        )
    }

    // MARK: - データベース関連

    /// 在庫管理マスターの一覧を取得
    func fetchInventoryMasters() async throws -> [InventoryMaster] {
        let response = try await client
            .from("inventory_masters")
            .select()
            .order("created_at", ascending: false)
            .execute()

        return try response.decoded(to: [InventoryMaster].self)
    }

    /// 特定のターゲット（業種）の在庫管理マスターを取得
    func fetchInventoryMastersByTarget(target: String) async throws -> [InventoryMaster] {
        let response = try await client
            .from("inventory_masters")
            .select()
            .eq("target", value: target)
            .order("created_at", ascending: false)
            .execute()

        return try response.decoded(to: [InventoryMaster].self)
    }

    /// IDで在庫管理マスターを取得
    func fetchInventoryMaster(id: String) async throws -> InventoryMaster {
        let response = try await client
            .from("inventory_masters")
            .select()
            .eq("id", value: id)
            .single()
            .execute()

        return try response.decoded(to: InventoryMaster.self)
    }

    /// 在庫管理マスターを作成
    func createInventoryMaster(name: String, description: String?, target: String?) async throws -> InventoryMaster {
        var newMaster: [String: Any] = ["name": name]
        if let description = description { newMaster["description"] = description }
        if let target = target { newMaster["target"] = target }

        let response = try await client
            .from("inventory_masters")
            .insert(values: newMaster)
            .single()
            .execute()

        return try response.decoded(to: InventoryMaster.self)
    }

    /// 在庫管理マスターを更新
    func updateInventoryMaster(id: String, name: String?, description: String?, target: String?) async throws -> InventoryMaster {
        var updates: [String: Any] = [:]
        if let name = name { updates["name"] = name }
        if let description = description { updates["description"] = description }
        if let target = target { updates["target"] = target }
        updates["updated_at"] = Date().iso8601String

        let response = try await client
            .from("inventory_masters")
            .update(values: updates)
            .eq("id", value: id)
            .single()
            .execute()

        return try response.decoded(to: InventoryMaster.self)
    }

    /// 在庫管理マスターを削除
    func deleteInventoryMaster(id: String) async throws {
        _ = try await client
            .from("inventory_masters")
            .delete()
            .eq("id", value: id)
            .execute()
    }
}
