//
//  InventoryViewModel.swift
//  RFID_ios
//
//  Created on 2025/05/05.
//

import Foundation
import Combine

/// 在庫管理マスターのデータを管理するViewModel
@MainActor
class InventoryViewModel: ObservableObject {
    // 在庫管理マスターのリスト
    @Published var inventoryMasters: [InventoryMaster] = []
    @Published var isLoading: Bool = false
    @Published var error: Error? = nil

    // 選択中のマスター
    @Published var selectedMaster: InventoryMaster? = nil

    // Supabaseサービス
    private let supabaseService = SupabaseService.shared

    /// 全ての在庫管理マスターを取得
    func fetchInventoryMasters() async {
        isLoading = true
        error = nil

        do {
            inventoryMasters = try await supabaseService.fetchInventoryMasters()
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
            inventoryMasters = try await supabaseService.fetchInventoryMastersByTarget(target: target)
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
            let master = try await supabaseService.fetchInventoryMaster(id: id)
            selectedMaster = master
            isLoading = false
            return master
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

        do {
            let newMaster = try await supabaseService.createInventoryMaster(
                name: name,
                description: description,
                target: target
            )

            // リストを更新
            await fetchInventoryMasters()
            isLoading = false
            return newMaster
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

        do {
            let updatedMaster = try await supabaseService.updateInventoryMaster(
                id: id,
                name: name,
                description: description,
                target: target
            )

            // リストを更新
            await fetchInventoryMasters()

            // 選択中のマスターを更新
            if selectedMaster?.id == id {
                selectedMaster = updatedMaster
            }

            isLoading = false
            return updatedMaster
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
            try await supabaseService.deleteInventoryMaster(id: id)

            // リストを更新
            await fetchInventoryMasters()

            // 選択中のマスターをクリア
            if selectedMaster?.id == id {
                selectedMaster = nil
            }

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
