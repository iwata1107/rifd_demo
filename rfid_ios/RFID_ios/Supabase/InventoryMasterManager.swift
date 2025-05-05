//
//  InventoryMasterManager.swift
//  RFID_ios
//
//  Created on 2025/05/05.
//

import Foundation
import Supabase
import Combine

/// 在庫管理マスターのデータモデル
struct InventoryMaster: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let description: String?
    let target: String?
    let createdAt: Date
    let updatedAt: Date?
    let userId: String?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case target
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case userId = "user_id"
    }
}

/// 在庫管理マスターのデータを管理するクラス
@MainActor
class InventoryMasterManager: ObservableObject {
    // 在庫管理マスターのリスト
    @Published var inventoryMasters: [InventoryMaster] = []
    @Published var isLoading: Bool = false
    @Published var error: Error? = nil

    // Supabaseクライアント
    private let supabase = SupabaseManager.shared.client

    /// 全ての在庫管理マスターを取得
    func fetchInventoryMasters() async {
        isLoading = true
        error = nil

        do {
            let response = try await supabase
                .from("inventory_masters")
                .select()
                .order("created_at", ascending: false)
                .execute()

            let data = try response.decoded(to: [InventoryMaster].self)
            self.inventoryMasters = data
        } catch {
            self.error = error
            print("Error fetching inventory masters: \(error)")
        }

        isLoading = false
    }

    /// 特定のターゲット（業種）の在庫管理マスターを取得
    func fetchInventoryMastersByTarget(target: String) async {
        isLoading = true
        error = nil

        do {
            let response = try await supabase
                .from("inventory_masters")
                .select()
                .eq("target", value: target)
                .order("created_at", ascending: false)
                .execute()

            let data = try response.decoded(to: [InventoryMaster].self)
            self.inventoryMasters = data
        } catch {
            self.error = error
            print("Error fetching inventory masters by target: \(error)")
        }

        isLoading = false
    }

    /// IDで在庫管理マスターを取得
    func fetchInventoryMaster(id: String) async -> InventoryMaster? {
        isLoading = true
        error = nil

        do {
            let response = try await supabase
                .from("inventory_masters")
                .select()
                .eq("id", value: id)
                .single()
                .execute()

            let data = try response.decoded(to: InventoryMaster.self)
            isLoading = false
            return data
        } catch {
            self.error = error
            print("Error fetching inventory master by id: \(error)")
            isLoading = false
            return nil
        }
    }

    /// 在庫管理マスターを作成
    func createInventoryMaster(name: String, description: String?, target: String?) async -> InventoryMaster? {
        isLoading = true
        error = nil

        let newMaster = [
            "name": name,
            "description": description as Any,
            "target": target as Any
        ] as [String : Any]

        do {
            let response = try await supabase
                .from("inventory_masters")
                .insert(values: newMaster)
                .single()
                .execute()

            let data = try response.decoded(to: InventoryMaster.self)
            await fetchInventoryMasters() // リストを更新
            isLoading = false
            return data
        } catch {
            self.error = error
            print("Error creating inventory master: \(error)")
            isLoading = false
            return nil
        }
    }

    /// 在庫管理マスターを更新
    func updateInventoryMaster(id: String, name: String?, description: String?, target: String?) async -> InventoryMaster? {
        isLoading = true
        error = nil

        var updates: [String: Any] = [:]
        if let name = name { updates["name"] = name }
        if let description = description { updates["description"] = description }
        if let target = target { updates["target"] = target }
        updates["updated_at"] = Date().iso8601String

        do {
            let response = try await supabase
                .from("inventory_masters")
                .update(values: updates)
                .eq("id", value: id)
                .single()
                .execute()

            let data = try response.decoded(to: InventoryMaster.self)
            await fetchInventoryMasters() // リストを更新
            isLoading = false
            return data
        } catch {
            self.error = error
            print("Error updating inventory master: \(error)")
            isLoading = false
            return nil
        }
    }

    /// 在庫管理マスターを削除
    func deleteInventoryMaster(id: String) async -> Bool {
        isLoading = true
        error = nil

        do {
            _ = try await supabase
                .from("inventory_masters")
                .delete()
                .eq("id", value: id)
                .execute()

            await fetchInventoryMasters() // リストを更新
            isLoading = false
            return true
        } catch {
            self.error = error
            print("Error deleting inventory master: \(error)")
            isLoading = false
            return false
        }
    }
}

// Date拡張 - ISO8601文字列変換用
extension Date {
    var iso8601String: String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.string(from: self)
    }
}
