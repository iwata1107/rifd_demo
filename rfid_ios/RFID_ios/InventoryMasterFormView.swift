// InventoryMasterFormView.swift
// RFID_ios
//
// Created on 2025/05/06.
//

import SwiftUI
import PhotosUI

struct InventoryMasterFormView: View {
    @EnvironmentObject var inventoryMasterManager: InventoryMasterManager
    @State private var selectedImage: Image?
    @State private var selectedUIImage: UIImage?
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var imageSelection: PhotosPickerItem?

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // タイトル
                Text("在庫管理マスター登録")
                    .font(.title)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 10)

                // フォーム
                VStack(spacing: 16) {
                    // 項目1（必須）
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("項目1")
                                .font(.headline)
                            Text("*")
                                .foregroundColor(.red)
                        }

                        TextField("項目1を入力してください", text: $inventoryMasterManager.col1)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.vertical, 4)

                        if let error = inventoryMasterManager.validationErrors.first(where: { $0.contains("項目1") }) {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }

                    // 項目2
                    VStack(alignment: .leading, spacing: 8) {
                        Text("項目2")
                            .font(.headline)

                        TextEditor(text: $inventoryMasterManager.col2)
                            .frame(height: 100)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                            .padding(.vertical, 4)

                        if let error = inventoryMasterManager.validationErrors.first(where: { $0.contains("項目2") }) {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }

                    // 項目3
                    VStack(alignment: .leading, spacing: 8) {
                        Text("項目3")
                            .font(.headline)

                        TextField("項目3を入力してください", text: $inventoryMasterManager.col3)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.vertical, 4)

                        if let error = inventoryMasterManager.validationErrors.first(where: { $0.contains("項目3") }) {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }

                    // 商品コード
                    VStack(alignment: .leading, spacing: 8) {
                        Text("商品コード")
                            .font(.headline)

                        TextField("商品コード/SKUを入力", text: $inventoryMasterManager.productCode)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.vertical, 4)

                        if let error = inventoryMasterManager.validationErrors.first(where: { $0.contains("商品コード") }) {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }

                    // 業種選択
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("業種")
                                .font(.headline)
                            Text("*")
                                .foregroundColor(.red)
                        }

                        Picker("業種を選択", selection: $inventoryMasterManager.targetType) {
                            Text("クリニック").tag(TargetType.clinic)
                            Text("カードショップ").tag(TargetType.cardShop)
                            Text("アパレルショップ").tag(TargetType.apparelShop)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.vertical, 4)
                    }

                    // 商品画像
                    VStack(alignment: .leading, spacing: 8) {
                        Text("商品画像")
                            .font(.headline)

                        if let image = selectedImage {
                            ZStack(alignment: .topTrailing) {
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 200)
                                    .cornerRadius(8)

                                Button(action: {
                                    selectedImage = nil
                                    selectedUIImage = nil
                                    inventoryMasterManager.productImage = nil
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.white)
                                        .background(Color.black.opacity(0.7))
                                        .clipShape(Circle())
                                }
                                .padding(8)
                            }
                        } else {
                            PhotosPicker(selection: $imageSelection, matching: .images) {
                                VStack {
                                    Image(systemName: "photo")
                                        .font(.system(size: 30))
                                    Text("画像を選択")
                                        .font(.headline)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 150)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                            }
                        }
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)

                // エラーメッセージ
                if let error = inventoryMasterManager.errorMessage {
                    Text(error)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .cornerRadius(8)
                }

                // 登録ボタン
                Button(action: registerMaster) {
                    HStack {
                        if inventoryMasterManager.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .padding(.trailing, 8)
                        }
                        Text("登録する")
                            .font(.headline)
                        Image(systemName: "arrow.right.circle.fill")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
                .disabled(inventoryMasterManager.isLoading || !inventoryMasterManager.isFormValid)
                .opacity(inventoryMasterManager.isFormValid ? 1.0 : 0.6)
                .padding(.top, 10)
            }
            .padding()
        }
        .navigationTitle("マスター登録")
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("通知"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        .onChange(of: imageSelection) { newValue in
            guard let newValue else { return }
            Task {
                do {
                    // Data を取得
                    if let data = try await newValue.loadTransferable(type: Data.self) {
                        if let uiImg = UIImage(data: data) {
                            await MainActor.run {
                                selectedUIImage = uiImg
                                selectedImage = Image(uiImage: uiImg)
                            }
                            // 画像アップロード
                            if let url = await inventoryMasterManager.uploadImage(imageData: data) {
                                await MainActor.run {
                                    inventoryMasterManager.productImage = url
                                }
                            }
                        }
                    }
                } catch {
                    print("画像の取得に失敗しました: \(error)")
                }
            }
        }
    }

    private func registerMaster() {
        Task {
            let success = await inventoryMasterManager.createInventoryMaster()

            await MainActor.run {
                showAlert = true
                if success {
                    alertMessage = "マスターを登録しました"
                    selectedImage = nil
                    selectedUIImage = nil
                } else {
                    alertMessage = inventoryMasterManager.errorMessage ?? "登録に失敗しました"
                }
            }
        }
    }
}

// プレビュー用のダミーデータ
#if DEBUG
struct InventoryMasterFormView_Previews: PreviewProvider {
    static var previews: some View {
        // プレビュー用のダミーデータ
        Text("プレビューは実行時に確認してください")
    }
}
#endif
