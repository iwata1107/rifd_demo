// InventoryMasterManager.swift
// RFID_ios
//
// Created on 2025/05/06.
//

import Foundation
import SwiftUI
import Combine
import Supabase

@MainActor
final class InventoryMasterManager: ObservableObject {
    // フォーム入力値
    @Published var col1: String = ""
    @Published var col2: String = ""
    @Published var col3: String = ""
    @Published var productCode: String = ""
    @Published var targetType: TargetType = .cardShop
    @Published var productImage: String? = nil

    // 状態管理
    @Published var errorMessage: String? = nil
    @Published var isLoading: Bool = false
    @Published var isSuccess: Bool = false

    // 依存性
    private let scanner: ScannerManager

    init(scannerManager: ScannerManager) {
        self.scanner = scannerManager
    }

    // バリデーション
    var isFormValid: Bool {
        !col1.isEmpty && col1.count <= 100
    }

    var validationErrors: [String] {
        var errors = [String]()

        if col1.isEmpty {
            errors.append("項目1は必須です")
        } else if col1.count > 100 {
            errors.append("項目1は100文字以内で入力してください")
        }

        if !col2.isEmpty && col2.count > 500 {
            errors.append("項目2は500文字以内で入力してください")
        }

        if !col3.isEmpty && col3.count > 50 {
            errors.append("項目3は50文字以内で入力してください")
        }

        if !productCode.isEmpty && productCode.count > 50 {
            errors.append("商品コードは50文字以内で入力してください")
        }

        return errors
    }

    // マスター登録処理
    func createInventoryMaster() async -> Bool {
        guard isFormValid else {
            errorMessage = validationErrors.first
            return false
        }

        isLoading = true
        errorMessage = nil

        do {
            let currentUser = try await supabase.auth.session.user
            let params = CreateInventoryMasterParams(
                col1: col1,
                col2: col2.isEmpty ? nil : col2,
                col3: col3.isEmpty ? nil : col3,
                productCode: productCode.isEmpty ? nil : productCode,
                target: targetType.rawValue,
                userId: currentUser.id.uuidString,
                productImage: productImage
            )

            // Supabaseを使用してデータベースに登録
            try await supabase
                .from("inventory_masters")
                .insert(params)
                .execute()

            isLoading = false
            isSuccess = true
            resetForm()

            return true
        } catch {
            print("Error creating inventory master: \(error)")
            isLoading = false
            errorMessage = "マスター登録に失敗しました: \(error.localizedDescription)"
            return false
        }
    }

    // 画像アップロード処理
    func uploadImage(imageData: Data) async -> String? {
        do {
            // ファイル名
            let fileExt  = "jpg"
            let fileName = UUID().uuidString
            let filePath = "\(fileName).\(fileExt)"

            // ① アップロード（rename 後のシグネチャ）
            try await supabase.storage
                .from("product-images")
                .upload(filePath,                   // ← ラベルなし
                        data: imageData)            // ← data: ラベル

            // ② 公開 URL 取得（getPublicURL）
            let urlString = try supabase.storage
                .from("product-images")
                .getPublicURL(path: filePath)       // ← path: ラベル必須
                .absoluteString                     // URL → String

            return urlString
        } catch {
            print("Error uploading image: \(error)")
            errorMessage = "画像のアップロードに失敗しました: \(error.localizedDescription)"
            return nil
        }
    }


    // フォームリセット
    func resetForm() {
        col1 = ""
        col2 = ""
        col3 = ""
        productCode = ""
        targetType = .cardShop
        productImage = nil
        errorMessage = nil
    }
}
