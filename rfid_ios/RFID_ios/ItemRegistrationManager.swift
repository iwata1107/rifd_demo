// ItemRegistrationManager.swift
// RFID_ios
//
// Created on 2025/05/06.
//

import Foundation
import Combine
import Supabase

@MainActor
final class ItemRegistrationManager: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var inventoryMasters: [InventoryMaster] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    @Published var selectedMaster: InventoryMaster?
    @Published var productCodeInput: String = ""

    // MARK: - Dependencies
    private let scanner: ScannerManager

    init(scannerManager: ScannerManager) {
        self.scanner = scannerManager
    }

    /// 商品コードでマスタを検索
    func searchMastersByProductCode() async {
        guard !productCodeInput.isEmpty else {
            errorMessage = "商品コードを入力してください"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let query = supabase
                .from("inventory_masters")
                .select()
                .ilike("product_code", pattern: "%\(productCodeInput)%")

            // デコードは .value プロパティで
            let masters: [InventoryMaster] = try await query.execute().value

            self.inventoryMasters = masters
            if masters.isEmpty {
                errorMessage = "該当する商品が見つかりませんでした"
            }
        } catch {
            errorMessage = "検索エラー: \(error.localizedDescription)"
            inventoryMasters = []
        }

        isLoading = false
    }

    /// 選択されたマスタとRFIDを使用してアイテムを登録
    func registerItem(rfid: String) async -> Bool {
        guard let master = selectedMaster else {
            errorMessage = "商品マスタが選択されていません"
            return false
        }
        guard !rfid.isEmpty else {
            errorMessage = "RFIDが読み取られていません"
            return false
        }

        isLoading = true
        errorMessage = nil

        do {
            struct CreateItemParams: Encodable {
                let rfid: String
                let inventoryMasterId: String

                enum CodingKeys: String, CodingKey {
                    case rfid
                    case inventoryMasterId = "inventory_master_id"
                }
            }

            let params = CreateItemParams(
                rfid: rfid,
                inventoryMasterId: master.id
            )

            print("登録パラメータ: rfid=\(rfid), inventory_master_id=\(master.id)")

            // 挿入クエリ実行
            _ = try await supabase
                .from("items")
                .insert(params)
                .execute()

            isLoading = false
            return true
        } catch {
            print("登録エラー詳細: \(error)")
            errorMessage = "登録エラー: \(error.localizedDescription)"
            isLoading = false
            return false
        }
    }

    /// 検索結果をクリア
    func clearSearchResults() {
        inventoryMasters = []
        selectedMaster = nil
        errorMessage = nil
    }
}
