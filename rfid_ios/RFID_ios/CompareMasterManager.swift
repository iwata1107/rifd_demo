//
//  CompareMasterManager.swift
//  RFID_ios
//
//  2025-05-05  Security-Scoped 対応
//

import Foundation
import Combine
import Supabase

@MainActor
final class CompareMasterManager: ObservableObject {

    // ───────── 公開プロパティ ─────────
    @Published private(set) var masterFileName = "未選択"
    @Published private(set) var masterTags:  Set<String> = []
    @Published private(set) var actualTags:  Set<String> = []
    @Published var selectedTarget: TargetType = .clinic
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    // RFIDとアイテム情報のマッピング
    @Published private(set) var itemsMap: [String: Item] = [:]
    @Published private(set) var inventoryMastersMap: [String: InventoryMaster] = [:]

    // 差分表示用
    var uncountedTags: [String] { Array(masterTags.subtracting(actualTags)) }
    var outerTags:     [String] { Array(actualTags.subtracting(masterTags)) }

    // ───────── 依存関係 ─────────
    private var cancellables = Set<AnyCancellable>()

    init(scannerManager: ScannerManager) {
        // Scanner 側の読取結果を監視
        scannerManager.$scannedUII
            .sink { [weak self] list in
                guard let self = self else { return }
                self.actualTags = Set(list)
                print("🔄 スキャンタグ更新: 実測タグ数=\(self.actualTags.count)")
                // マスターと一致したタグを自動棚卸し
                self.autoMarkMatchingTags()
            }
            .store(in: &cancellables)
    }

    // ───────── マッチしたタグを自動で棚卸しマーク ─────────
    private func autoMarkMatchingTags() {
        let matches = masterTags.intersection(actualTags)
        print("🔍 マッチタグ検出: 件数=\(matches.count) -> \(matches)")
        for rfid in matches {
            if let item = itemsMap[rfid], !item.isInventoried {
                print("🔄 自動棚卸し実行: RFID=\(rfid)")
                Task {
                    await markAsInventoried(rfid: rfid)
                }
            } else {
                print("ℹ️ スキップ: 既に棚卸し済みまたはアイテム不明: RFID=\(rfid)")
            }
        }
    }

    // ───────── Supabaseからアイテム読み込み ─────────
    func loadItemsByTarget() async {
        isLoading = true
        errorMessage = nil

        do {
            print("🔍 \(selectedTarget.rawValue)のアイテムを読み込み開始")
            let query = supabase
                .from("items")
                .select("*, inventory_masters!inner(*)")
                .eq("inventory_masters.target", value: selectedTarget.rawValue)

            print("📊 実行クエリ: items + inventory_masters, target=\(selectedTarget.rawValue)")
            let response = try await query.execute()
            print("📦 レスポンスステータス: \(response.status)")

            let data = response.data
            print("📊 取得データサイズ: \(data.count) bytes")

            if let dataString = String(data: data, encoding: .utf8) {
                let previewLength = min(dataString.count, 100)
                print("📄 データプレビュー: \(dataString.prefix(previewLength))...")
            }

            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase

            if let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                print("✅ JSONパース成功: 件数=\(jsonArray.count)")

                var newItemsMap: [String: Item] = [:]
                var newMasterIds: Set<String> = []
                var newInventoryMasters: [String: InventoryMaster] = [:]

                for itemData in jsonArray {
                    guard let id = itemData["id"] as? String,
                          let rfid = itemData["rfid"] as? String,
                          let masterId = itemData["inventory_master_id"] as? String,
                          let createdAt = itemData["created_at"] as? String,
                          let updatedAt = itemData["updated_at"] as? String else {
                        print("⚠️ 必須フィールドが見つかりません: \(itemData)")
                        continue
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
                    newItemsMap[rfid] = item
                    newMasterIds.insert(masterId)

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
                        newInventoryMasters[invId] = master
                    }
                }

                // データ更新
                self.itemsMap = newItemsMap
                self.masterTags = Set(newItemsMap.keys)
                self.inventoryMastersMap = newInventoryMasters
                print("✅ データ処理完了: アイテム=\(newItemsMap.count)、マスター=\(newInventoryMasters.count)")

                // 自動棚卸し試行
                autoMarkMatchingTags()

                masterFileName = "\(selectedTarget.rawValue)の商品 (\(newItemsMap.count)件)"

            } else {
                if data.count <= 2 {
                    print("ℹ️ 空の配列を受信")
                    self.itemsMap = [:]
                    self.masterTags = []
                    self.inventoryMastersMap = [:]
                    masterFileName = "\(selectedTarget.rawValue)の商品 (0件)"
                } else {
                    throw NSError(domain: "JSONParseError", code: 1, userInfo: [NSLocalizedDescriptionKey: "JSONデータの形式が不正です"])
                }
            }

        } catch let error {
            errorMessage = "読込エラー: \(error.localizedDescription)"
            print("⚠️ Supabase読込エラー: \(error)")
        }

        isLoading = false
        print("✅ loadItemsByTarget 処理完了")
    }

    // ───────── 棚卸しステータス更新 ─────────
    func markAsInventoried(rfid: String) async {
        guard let item = itemsMap[rfid] else {
            print("⚠️ アイテム不明: RFID=\(rfid)")
            errorMessage = "アイテムが見つかりません: \(rfid)"
            return
        }
        print("🔄 更新開始: ID=\(item.id), RFID=\(rfid)")
        do {
            let response = try await supabase
                .from("items")
                .update(["is_inventoried": true])
                .eq("id", value: item.id)
                .execute()
            print("✅ 棚卸し更新成功: ステータス=\(response.status)")

            var updatedMap = itemsMap
            let updatedItem = Item(
                id: item.id,
                createdAt: item.createdAt,
                updatedAt: item.updatedAt,
                rfid: item.rfid,
                inventoryMasterId: item.inventoryMasterId,
                userId: item.userId,
                isInventoried: true
            )
            updatedMap[rfid] = updatedItem
            self.itemsMap = updatedMap
            print("✅ ローカルマップ更新完了: RFID=\(rfid)")
        } catch let updateError {
            errorMessage = "更新エラー: \(updateError.localizedDescription)"
            print("⚠️ 更新エラー: \(updateError)")
        }
    }

    // ───────── 棚卸しステータスリセット ─────────
    func resetInventoryStatus() async {
        isLoading = true
        errorMessage = nil
        print("🔄 リセット開始: ターゲット=\(selectedTarget.rawValue)")

        do {
            // リセット対象のアイテムIDを取得
            let ids = itemsMap.values.map { $0.id }
            if ids.isEmpty {
                print("ℹ️ リセット対象がありません")
            } else {
                print("🔄 データベースリセット対象IDs: \(ids)")
                // バッチ更新
                let response = try await supabase
                    .from("items")
                    .update(["is_inventoried": false])
                    .in("id", values: ids)
                    .execute()
                print("✅ リセット成功: ステータス=\(response.status)")
            }

            // ローカルマップのリセット
            var updatedMap: [String: Item] = [:]
            for (rfid, item) in itemsMap {
                let resetItem = Item(
                    id: item.id,
                    createdAt: item.createdAt,
                    updatedAt: item.updatedAt,
                    rfid: item.rfid,
                    inventoryMasterId: item.inventoryMasterId,
                    userId: item.userId,
                    isInventoried: false
                )
                updatedMap[rfid] = resetItem
            }
            self.itemsMap = updatedMap
            self.masterTags = Set(updatedMap.keys)
            print("✅ ローカルマップリセット完了: アイテム数=\(updatedMap.count)")

        } catch let error {
            errorMessage = "リセットエラー: \(error.localizedDescription)"
            print("⚠️ リセットエラー: \(error)")
        }

        isLoading = false
        print("✅ resetInventoryStatus 処理完了")
    }

    // 特定RFIDのInventoryMaster取得
    func getInventoryMaster(for rfid: String) -> InventoryMaster? {
        guard let item = itemsMap[rfid] else { return nil }
        return inventoryMastersMap[item.inventoryMasterId]
    }
}
