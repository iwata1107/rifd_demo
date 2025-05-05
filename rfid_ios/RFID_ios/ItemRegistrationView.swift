// ItemRegistrationView.swift
// RFID_ios
//
// Created on 2025/05/06.
//

import SwiftUI

struct ItemRegistrationView: View {
    @EnvironmentObject var itemRegistrationManager: ItemRegistrationManager
    @EnvironmentObject var scanner: ScannerManager

    @State private var selectedRFID: String?
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isRegistering = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 商品コード入力
                VStack(alignment: .leading, spacing: 8) {
                    Text("商品コード")
                        .font(.headline)
                        .fontWeight(.bold)

                    HStack {
                        TextField(
                            "商品コードを入力",
                            text: $itemRegistrationManager.productCodeInput
                        )
                        .textFieldStyle(.roundedBorder)
                        .padding(.vertical, 4)

                        Button("検索") {
                            Task {
                                await itemRegistrationManager.searchMastersByProductCode()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.regular)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)

                // 検索結果
                if !itemRegistrationManager.inventoryMasters.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("検索結果")
                            .font(.headline)
                            .fontWeight(.bold)
                            .padding(.horizontal)

                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(itemRegistrationManager.inventoryMasters) { master in
                                    Button(action: {
                                        itemRegistrationManager.selectedMaster = master
                                    }) {
                                        VStack(alignment: .leading, spacing: 6) {
                                            Text("商品コード: \(master.productCode ?? "未設定")")
                                                .font(.headline)
                                            Text("詳細: \(master.col1)")
                                                .font(.subheadline)
                                            if let col2 = master.col2 {
                                                Text("追加情報: \(col2)")
                                                    .font(.caption)
                                            }
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding()
                                    }
                                    .buttonStyle(
                                        SelectionButtonStyle(
                                            isSelected: itemRegistrationManager.selectedMaster?.id == master.id
                                        )
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }
                        .frame(maxHeight: 220)
                    }
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                }

                // エラーメッセージ
                if let error = itemRegistrationManager.errorMessage {
                    Text(error)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .cornerRadius(10)
                }

                // RFID読み取り結果
                VStack(alignment: .leading, spacing: 8) {
                    Text("RFID読み取り結果")
                        .font(.headline)
                        .fontWeight(.bold)
                        .padding(.horizontal)

                    if scanner.scannedUII.isEmpty {
                        Text("RFIDをスキャンしてください")
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 8) {
                                ForEach(scanner.scannedUII, id: \.self) { rfid in
                                    Button(action: {
                                        selectedRFID = rfid
                                    }) {
                                        HStack {
                                            Text(rfid)
                                                .padding()
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                        }
                                    }
                                    .buttonStyle(
                                        SelectionButtonStyle(
                                            isSelected: selectedRFID == rfid
                                        )
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }
                        .frame(maxHeight: 150)
                    }
                }
                .padding(.vertical)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)

                // スキャン操作ボタン
                HStack(spacing: 15) {
                    Button {
                        scanner.readState == .standby
                            ? scanner.startScan()
                            : scanner.stopScan()
                    } label: {
                        HStack {
                            Image(systemName: scanner.readState == .standby ? "barcode.viewfinder" : "stop.circle")
                            Text(scanner.readState == .standby ? "スキャン開始" : "スキャン停止")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.regular)

                    Button(action: {
                        scanner.clearScannedData()
                        selectedRFID = nil
                    }) {
                        HStack {
                            Image(systemName: "trash")
                            Text("クリア")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.regular)
                }

                // 登録ボタン
                Button(action: registerItem) {
                    HStack {
                        if isRegistering {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .padding(.trailing, 8)
                        }
                        Text("登録")
                            .font(.headline)
                        Image(systemName: "arrow.right.circle.fill")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.regular)
                .disabled(
                    itemRegistrationManager.selectedMaster == nil ||
                    selectedRFID == nil ||
                    isRegistering
                )
                .padding(.top, 8)
                .opacity(
                    (itemRegistrationManager.selectedMaster == nil ||
                    selectedRFID == nil ||
                    isRegistering) ? 0.6 : 1.0
                )
            }
        }
        .padding()
        .navigationTitle("商品登録")
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("通知"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    private func registerItem() {
        guard let selectedRFID = selectedRFID else { return }
        isRegistering = true

        Task {
            let success = await itemRegistrationManager.registerItem(rfid: selectedRFID)

            await MainActor.run {
                isRegistering = false
                showAlert = true
                if success {
                    alertMessage = "商品を登録しました"
                    scanner.clearScannedData()
                    self.selectedRFID = nil
                    itemRegistrationManager.clearSearchResults()
                    itemRegistrationManager.productCodeInput = ""
                } else {
                    alertMessage = itemRegistrationManager.errorMessage ?? "登録に失敗しました"
                }
            }
        }
    }
}

// カスタム選択ボタンスタイル
struct SelectionButtonStyle: ButtonStyle {
    var isSelected: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected
                          ? Color.blue.opacity(0.2)
                          : Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: isSelected ? 2 : 1)
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
            .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}
