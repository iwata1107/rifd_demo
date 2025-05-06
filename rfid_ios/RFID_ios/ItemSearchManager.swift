//
//  ItemSearchManager.swift
//  RFID_ios
//
//  Created by 岩田照太 on 2025/05/06.
//

import Foundation
import Combine
import Supabase

@MainActor
final class ItemSearchManager: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var searchedItem: Item?
    @Published private(set) var inventoryMaster: InventoryMaster?
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    // MARK: - Dependencies
    private let scanner: ScannerManager
    private var cancellables = Set<AnyCancellable>()

    init(scannerManager: ScannerManager) {
        self.scanner = scannerManager

        // スキャナーからのRFID読み取り結果を監視
        scanner.$scannedUII
            .sink { [weak self] tags in
                guard let self = self, !tags.isEmpty else { return }
                // 最新のタグを自動検索
                if let latestTag = tags.last {
                    Task {
                        await self.searchItemByRFID(rfid: latestTag)
                    }
                }
            }
            .store(in: &cancellables)
    }

    /// RFIDタグで商品を検索
    func searchItemByRFID(rfid: String) async {
        guard !rfid.isEmpty else {
            errorMessage = "RFIDが空です"
            return
        }

        isLoading = true
        errorMessage = nil
        searchedItem = nil
        inventoryMaster = nil

        do {
            print("🔍 RFID検索開始: \(rfid)")

            // itemsテーブルからRFIDで検索
            let query = supabase
                .from("items")
                .select("*, inventory_masters(*)")
                .eq("rfid", value: rfid)
                .limit(1)

            let response = try await query.execute()
            print("📦 レスポンスステータス: \(response.status)")

            let data = response.data
            if let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]],
               !jsonArray.isEmpty {

                print("✅ JSONパース成功: 件数=\(jsonArray.count)")

                if let itemData = jsonArray.first {
                    // アイテムデータの解析
                    guard let id = itemData["id"] as? String,
                          let rfid = itemData["rfid"] as? String,
                          let masterId = itemData["inventory_master_id"] as? String,
                          let createdAt = itemData["created_at"] as? String,
                          let updatedAt = itemData["updated_at"] as? String else {
                        throw NSError(domain: "ParseError", code: 1, userInfo: [NSLocalizedDescriptionKey: "必須フィールドが見つかりません"])
                    }

                    let isInventoried = itemData["is_inventoried"] as? Bool ?? false
                    let userId = itemData["user_id"] as? String

                    let item = Item(
                        id: id,
                        createdAt: createdAt,
                        updatedAt: updatedAt,
                        rfid: rfid,
                        inventoryMasterId: masterId,
                        userId: userId,
                        isInventoried: isInventoried
                    )

                    // マスターデータの解析
                    if let invData = itemData["inventory_masters"] as? [String: Any],
                       let invId = invData["id"] as? String,
                       let col1 = invData["col_1"] as? String,
                       let targetStr = invData["target"] as? String,
                       let invCreated = invData["created_at"] as? String,
                       let invUpdated = invData["updated_at"] as? String {

                        let col2 = invData["col_2"] as? String
                        let col3 = invData["col_3"] as? String
                        let productCode = invData["product_code"] as? String
                        let userId = invData["user_id"] as? String
                        let productImage = invData["product_image"] as? String

                        let targetType: TargetType = TargetType(rawValue: targetStr) ?? .clinic
                        let master = InventoryMaster(
                            id: invId,
                            createdAt: invCreated,
                            updatedAt: invUpdated,
                            col1: col1,
                            col2: col2,
                            col3: col3,
                            productCode: productCode,
                            target: targetType,
                            userId: userId,
                            productImage: productImage
                        )

                        self.inventoryMaster = master
                    }

                    self.searchedItem = item
                    print("✅ 商品情報取得成功: RFID=\(rfid)")
                }
            } else {
                errorMessage = "商品が見つかりませんでした"
                print("ℹ️ 商品が見つかりません: RFID=\(rfid)")
            }
        } catch {
            errorMessage = "検索エラー: \(error.localizedDescription)"
            print("⚠️ 検索エラー: \(error)")
        }

        isLoading = false
    }

    /// 検索結果をクリア
    func clearSearchResults() {
        searchedItem = nil
        inventoryMaster = nil
        errorMessage = nil
    }
}
