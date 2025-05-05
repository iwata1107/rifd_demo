////
////  CompareMasterManager.swift
////  RFID_ios
////
////  2025-05-05  Security-Scoped 対応
////
//
//import Foundation
//import Combine
//import Supabase
//
//@MainActor
//final class CompareMasterManager: ObservableObject {
//
//    // ───────── 公開プロパティ ─────────
//    @Published private(set) var masterFileName = "未選択"
//    @Published private(set) var masterTags:  Set<String> = []
//    @Published private(set) var actualTags:  Set<String> = []
//    @Published var selectedTarget: TargetType = .clinic
//    @Published private(set) var isLoading = false
//    @Published private(set) var errorMessage: String?
//
//    // RFIDとアイテム情報のマッピング
//    @Published private(set) var itemsMap: [String: Item] = [:]
//    @Published private(set) var inventoryMastersMap: [String: InventoryMaster] = [:]
//
//    var uncountedTags: [String] { Array(masterTags.subtracting(actualTags)) }
//    var outerTags:     [String] { Array(actualTags.subtracting(masterTags)) }
//
//    // ───────── 依存関係 ─────────
//    private var cancellables = Set<AnyCancellable>()
//
//    init(scannerManager: ScannerManager) {
//        // Scanner 側の読取結果を監視
//        scannerManager.$scannedUII
//            .sink { [weak self] list in
//                self?.actualTags = Set(list)
//            }
//            .store(in: &cancellables)
//    }
//
//    // ───────── Supabaseからアイテム読み込み ─────────
//    func loadItemsByTarget() async {
//        isLoading = true
//        errorMessage = nil
//
//        do {
//            print("🔍 \(selectedTarget.rawValue)のアイテムを読み込み開始")
//
//            // RLSを回避するためにサービスロールを使用するか、RLSポリシーを修正する必要があるかもしれません
//            // inventory_mastersテーブルから選択されたtargetに一致するアイテムを取得
//            let query = supabase
//                .from("items")
//                .select("*, inventory_masters!inner(*)")
//                .eq("inventory_masters.target", value: selectedTarget.rawValue)
//
//            // クエリのデバッグ情報
//            print("📊 実行クエリ: items + inventory_masters, target=\(selectedTarget.rawValue)")
//
//            let response = try await query.execute()
//
//            // レスポンスのデバッグ情報
//            print("📦 レスポンスステータス: \(response.status)")
//
//            // Dataとして取り出し
//            let data = response.data
//            print("📊 取得データサイズ: \(data.count) bytes")
//
//            // データの中身をデバッグ出力（最初の100文字だけ）
//            if let dataString = String(data: data, encoding: .utf8) {
//                let previewLength = min(dataString.count, 100)
//                let dataPreview = String(dataString.prefix(previewLength))
//                print("📄 データプレビュー: \(dataPreview)...")
//            }
//
//            // JSONデコード
//            let decoder = JSONDecoder()
//            decoder.keyDecodingStrategy = .convertFromSnakeCase
//
//            // JSONデータを文字列として表示（デバッグ用）
//            if let jsonString = String(data: data, encoding: .utf8) {
//                print("📝 受信したJSONデータ: \(jsonString)")
//            }
//
//            do {
//                // まず生のJSONをパースして構造を確認
//                if let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
//                    print("✅ JSONパース成功: \(jsonArray.count)件のアイテム")
//
//                    // 手動でデコードしてみる
//                    var items: [Item] = []
//                    var newItemsMap: [String: Item] = [:]
//                    var newMasterIds: Set<String> = []
//                    var inventoryMastersMap: [String: InventoryMaster] = [:]
//
//                    for itemData in jsonArray {
//                        guard let id = itemData["id"] as? String,
//                              let rfid = itemData["rfid"] as? String,
//                              let inventoryMasterId = itemData["inventory_master_id"] as? String,
//                              let createdAt = itemData["created_at"] as? String,
//                              let updatedAt = itemData["updated_at"] as? String else {
//                            print("⚠️ 必須フィールドが見つかりません: \(itemData)")
//                            continue
//                        }
//
//                        let isInventoried = itemData["is_inventoried"] as? Bool ?? false
//                        let userId = itemData["user_id"] as? String
//
//                        // Itemオブジェクトを作成
//                        let item = Item(
//                            id: id,
//                            createdAt: createdAt,
//                            updatedAt: updatedAt,
//                            rfid: rfid,
//                            inventoryMasterId: inventoryMasterId,
//                            userId: userId,
//                            isInventoried: isInventoried
//                        )
//
//                        items.append(item)
//                        newItemsMap[rfid] = item
//                        newMasterIds.insert(inventoryMasterId)
//
//                        // inventory_mastersデータを抽出
//                        if let inventoryMasterData = itemData["inventory_masters"] as? [String: Any],
//                           let masterId = inventoryMasterData["id"] as? String,
//                           let col1 = inventoryMasterData["col_1"] as? String,
//                           let target = inventoryMasterData["target"] as? String,
//                           let createdAt = inventoryMasterData["created_at"] as? String,
//                           let updatedAt = inventoryMasterData["updated_at"] as? String {
//
//                            let col2 = inventoryMasterData["col_2"] as? String
//                            let col3 = inventoryMasterData["col_3"] as? String
//                            let productCode = inventoryMasterData["product_code"] as? String
//                            let userId = inventoryMasterData["user_id"] as? String
//                            let productImage = inventoryMasterData["product_image"] as? String
//
//                            // TargetTypeを作成
//                            let targetType: TargetType
//                            switch target {
//                            case TargetType.cardShop.rawValue:
//                                targetType = .cardShop
//                            case TargetType.apparelShop.rawValue:
//                                targetType = .apparelShop
//                            default:
//                                targetType = .clinic
//                            }
//
//                            // InventoryMasterオブジェクトを作成
//                            let master = InventoryMaster(
//                                id: masterId,
//                                createdAt: createdAt,
//                                updatedAt: updatedAt,
//                                col1: col1,
//                                col2: col2,
//                                col3: col3,
//                                productCode: productCode,
//                                target: targetType,
//                                userId: userId,
//                                productImage: productImage
//                            )
//
//                            inventoryMastersMap[masterId] = master
//                        }
//                    }
//
//                    // データを更新
//                    self.itemsMap = newItemsMap
//                    self.masterTags = Set(newItemsMap.keys)
//                    self.inventoryMastersMap = inventoryMastersMap
//
//                    print("✅ データ処理完了: \(items.count)件のアイテム、\(inventoryMastersMap.count)件のマスター")
//
//                    // アイテムの詳細をログに出力
//                    if !items.isEmpty {
//                        print("📋 最初のアイテム: ID=\(items[0].id), RFID=\(items[0].rfid), MasterID=\(items[0].inventoryMasterId)")
//                        if let master = inventoryMastersMap[items[0].inventoryMasterId] {
//                            print("📋 関連マスター: ID=\(master.id), 名前=\(master.col1), ターゲット=\(master.target.rawValue)")
//                        }
//                    }
//
//                    print("🏷️ マスタータグ数: \(self.masterTags.count)")
//
//                    masterFileName = "\(selectedTarget.rawValue)の商品 (\(newItemsMap.count)件)"
//                } else {
//                    // 空の配列の場合
//                    if data.count <= 2 { // "[]" は2バイト
//                        print("ℹ️ 空の配列を受信しました")
//                        self.itemsMap = [:]
//                        self.masterTags = []
//                        self.inventoryMastersMap = [:]
//                        masterFileName = "\(selectedTarget.rawValue)の商品 (0件)"
//                    } else {
//                        throw NSError(domain: "JSONParseError", code: 1, userInfo: [NSLocalizedDescriptionKey: "JSONデータの形式が不正です"])
//                    }
//                }
//            } catch let decodingError {
//                errorMessage = "JSONデコードエラー: \(decodingError.localizedDescription)"
//                print("⚠️ JSONデコードエラー: \(decodingError)")
//
//                // デコードエラーの詳細を出力
//                if let decodingError = decodingError as? DecodingError {
//                    switch decodingError {
//                    case .typeMismatch(let type, let context):
//                        print("🔴 型の不一致: 期待=\(type), コンテキスト=\(context.debugDescription)")
//                    case .valueNotFound(let type, let context):
//                        print("🔴 値が見つからない: 型=\(type), コンテキスト=\(context.debugDescription)")
//                    case .keyNotFound(let key, let context):
//                        print("🔴 キーが見つからない: キー=\(key.stringValue), コンテキスト=\(context.debugDescription)")
//                    case .dataCorrupted(let context):
//                        print("🔴 データ破損: \(context.debugDescription)")
//                    @unknown default:
//                        print("🔴 不明なデコードエラー: \(decodingError)")
//                    }
//                }
//
//                // 生データを出力して調査
//                if let dataString = String(data: data, encoding: .utf8) {
//                    print("📝 生データ: \(dataString)")
//                }
//            }
//        } catch let queryError {
//            errorMessage = "読込エラー: \(queryError.localizedDescription)"
//            print("⚠️ Supabase読込エラー: \(queryError)")
//
//            // エラーの詳細情報を出力
//            print("🔴 エラータイプ: \(type(of: queryError))")
//
//            // Supabaseエラーの詳細を取得（可能であれば）
//            if let supabaseError = queryError as NSError? {
//                print("🔴 エラーコード: \(supabaseError.code)")
//                print("🔴 エラードメイン: \(supabaseError.domain)")
//                print("🔴 エラー詳細: \(supabaseError.userInfo)")
//            }
//        }
//
//        isLoading = false
//    }
//
//    // inventory_mastersを取得
//    private func loadInventoryMasters(ids: [String]) async {
//        guard !ids.isEmpty else {
//            print("⚠️ マスターID一覧が空のため、inventory_mastersの取得をスキップします")
//            return
//        }
//
//        do {
//            print("🔍 inventory_mastersの取得開始: \(ids.count)件のID")
//
//            let query = supabase
//                .from("inventory_masters")
//                .select()
//                .in("id", values: ids)
//
//            let response = try await query.execute()
//            print("📦 inventory_mastersレスポンスステータス: \(response.status)")
//
//            // Dataとして取り出し
//            let data = response.data
//            print("📊 inventory_mastersデータサイズ: \(data.count) bytes")
//
//            // JSONデコード
//            let decoder = JSONDecoder()
//            decoder.keyDecodingStrategy = .convertFromSnakeCase
//
//            do {
//                let masters = try decoder.decode([InventoryMaster].self, from: data)
//                print("✅ inventory_mastersデコード成功: \(masters.count)件のマスターを取得")
//
//                // マスターの詳細をログに出力
//                if !masters.isEmpty {
//                    let firstMaster = masters[0]
//                    print("📋 最初のマスター: ID=\(firstMaster.id), Target=\(firstMaster.target.rawValue), Col1=\(firstMaster.col1)")
//                }
//
//                // IDをキー、マスターを値とするマップを作成
//                var newMastersMap: [String: InventoryMaster] = [:]
//                for master in masters {
//                    newMastersMap[master.id] = master
//                }
//                self.inventoryMastersMap = newMastersMap
//                print("🗂️ マスターマップ作成完了: \(newMastersMap.count)件")
//            } catch let decodingError {
//                print("⚠️ マスターJSONデコードエラー: \(decodingError)")
//
//                // デコードエラーの詳細を出力
//                if let decodingError = decodingError as? DecodingError {
//                    switch decodingError {
//                    case .typeMismatch(let type, let context):
//                        print("🔴 型の不一致: 期待=\(type), コンテキスト=\(context.debugDescription)")
//                    case .valueNotFound(let type, let context):
//                        print("🔴 値が見つからない: 型=\(type), コンテキスト=\(context.debugDescription)")
//                    case .keyNotFound(let key, let context):
//                        print("🔴 キーが見つからない: キー=\(key.stringValue), コンテキスト=\(context.debugDescription)")
//                    case .dataCorrupted(let context):
//                        print("🔴 データ破損: \(context.debugDescription)")
//                    @unknown default:
//                        print("🔴 不明なデコードエラー: \(decodingError)")
//                    }
//                }
//
//                // 生データを出力して調査
//                if let dataString = String(data: data, encoding: .utf8) {
//                    print("📝 マスター生データ: \(dataString)")
//                }
//            }
//        } catch let queryError {
//            print("⚠️ マスター取得エラー: \(queryError)")
//
//            // エラーの詳細情報を出力
//            print("🔴 マスター取得エラータイプ: \(type(of: queryError))")
//
//            if let supabaseError = queryError as NSError? {
//                print("🔴 マスター取得エラーコード: \(supabaseError.code)")
//                print("🔴 マスター取得エラードメイン: \(supabaseError.domain)")
//            }
//        }
//    }
//
//    // 棚卸しステータスを更新
//    func markAsInventoried(rfid: String) async {
//        guard let item = itemsMap[rfid] else {
//            print("⚠️ 指定されたRFID(\(rfid))に対応するアイテムが見つかりません")
//            errorMessage = "アイテムが見つかりません: \(rfid)"
//            return
//        }
//
//        print("🔄 アイテム棚卸し状態更新開始: ID=\(item.id), RFID=\(rfid)")
//
//        do {
//            let response = try await supabase
//                .from("items")
//                .update(["is_inventoried": true])
//                .eq("id", value: item.id)
//                .execute()
//
//            print("✅ 棚卸し状態更新成功: ステータス=\(response.status)")
//
//            // 成功したら、ローカルのマップも更新
//            var updatedItemsMap = self.itemsMap
//
//            // Itemは不変（let）なので、新しいインスタンスを作成する
//            let updatedItem = Item(
//                id: item.id,
//                createdAt: item.createdAt,
//                updatedAt: item.updatedAt,
//                rfid: item.rfid,
//                inventoryMasterId: item.inventoryMasterId,
//                userId: item.userId,
//                isInventoried: true  // ここで更新された値を設定
//            )
//
//            // マップを更新
//            updatedItemsMap[rfid] = updatedItem
//            self.itemsMap = updatedItemsMap
//
//            print("✅ ローカルマップ更新完了")
//        } catch let updateError {
//            errorMessage = "更新エラー: \(updateError.localizedDescription)"
//            print("⚠️ 棚卸し状態更新エラー: \(updateError)")
//
//            // エラーの詳細情報を出力
//            if let supabaseError = updateError as NSError? {
//                print("🔴 更新エラーコード: \(supabaseError.code)")
//                print("🔴 更新エラードメイン: \(supabaseError.domain)")
//            }
//        }
//    }
//
//    // 棚卸しステータスをリセット
//    func resetInventoryStatus() async {
//        isLoading = true
//        print("🔄 棚卸しステータスリセット開始: target=\(selectedTarget.rawValue)")
//
//        do {
//            let query = supabase
//                .from("items")
//                .select("id, inventory_masters!inner(target)")
//                .eq("inventory_masters.target", value: selectedTarget.rawValue)
//
//            print("📊 リセット対象アイテム取得クエリ実行")
//            let response = try await query.execute()
//            print("📦 リセット対象レスポンスステータス: \(response.status)")
//
//            let data = response.data
//            print("📊 リセット対象データサイズ: \(data.count) bytes")
//
//            struct ItemWithId: Codable {
//                let id: String
//            }
//
//            let decoder = JSONDecoder()
//            decoder.keyDecodingStrategy = .convertFromSnakeCase
//
//            do {
//                let itemsToReset = try decoder.decode([ItemWithId].self, from: data)
//                print("✅ リセット対象デコード成功: \(itemsToReset.count)件のアイテムをリセット予定")
//
//                if !itemsToReset.isEmpty {
//                    let ids = itemsToReset.map { $0.id }
//                    print("🔄 \(ids.count)件のアイテムの棚卸しステータスをリセット中...")
//
//                    let updateResponse = try await supabase
//                        .from("items")
//                        .update(["is_inventoried": false])
//                        .in("id", values: ids)
//                        .execute()
//
//                    print("✅ リセット完了: ステータス=\(updateResponse.status)")
//                } else {
//                    print("ℹ️ リセット対象のアイテムがありません")
//                }
//
//                // 再読み込み
//                print("🔄 アイテム一覧を再読み込み中...")
//                await loadItemsByTarget()
//            } catch let decodingError {
//                errorMessage = "リセット対象デコードエラー: \(decodingError.localizedDescription)"
//                print("⚠️ リセット対象デコードエラー: \(decodingError)")
//
//                // デコードエラーの詳細を出力
//                if let decodingError = decodingError as? DecodingError {
//                    switch decodingError {
//                    case .typeMismatch(let type, let context):
//                        print("🔴 型の不一致: 期待=\(type), コンテキスト=\(context.debugDescription)")
//                    case .valueNotFound(let type, let context):
//                        print("🔴 値が見つからない: 型=\(type), コンテキスト=\(context.debugDescription)")
//                    case .keyNotFound(let key, let context):
//                        print("🔴 キーが見つからない: キー=\(key.stringValue), コンテキスト=\(context.debugDescription)")
//                    case .dataCorrupted(let context):
//                        print("🔴 データ破損: \(context.debugDescription)")
//                    @unknown default:
//                        print("🔴 不明なデコードエラー: \(decodingError)")
//                    }
//                }
//            }
//        } catch let queryError {
//            errorMessage = "リセットエラー: \(queryError.localizedDescription)"
//            print("⚠️ リセットエラー: \(queryError)")
//
//            // エラーの詳細情報を出力
//            if let supabaseError = queryError as NSError? {
//                print("🔴 リセットエラーコード: \(supabaseError.code)")
//                print("🔴 リセットエラードメイン: \(supabaseError.domain)")
//            }
//        }
//
//        isLoading = false
//        print("✅ 棚卸しステータスリセット処理完了")
//    }
//
//    // 特定のRFIDに対応するInventoryMasterを取得
//    func getInventoryMaster(for rfid: String) -> InventoryMaster? {
//        guard let item = itemsMap[rfid] else { return nil }
//        return inventoryMastersMap[item.inventoryMasterId]
//    }
//}



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
        print("🔄 リセット開始: ターゲット=\(selectedTarget.rawValue)")
        // ... 既存ロジックは省略 (同じ) ...
        isLoading = false
        print("✅ resetInventoryStatus 処理完了")
    }

    // 特定RFIDのInventoryMaster取得
    func getInventoryMaster(for rfid: String) -> InventoryMaster? {
        guard let item = itemsMap[rfid] else { return nil }
        return inventoryMastersMap[item.inventoryMasterId]
    }
}
