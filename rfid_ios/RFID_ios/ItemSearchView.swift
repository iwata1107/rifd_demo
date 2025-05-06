//
//  ItemSearchView.swift
//  RFID_ios
//
//  Created by 岩田照太 on 2025/05/06.
//

import SwiftUI

struct ItemSearchView: View {
    @EnvironmentObject var scanner: ScannerManager
    @EnvironmentObject var itemSearchManager: ItemSearchManager

    @State private var selectedRFID: String?
    @State private var manualSearchRFID: String = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 手動検索部分
                VStack(alignment: .leading, spacing: 8) {
                    Text("商品検索")
                        .font(.headline)
                        .fontWeight(.bold)

                    HStack {
                        TextField(
                            "RFIDを入力",
                            text: $manualSearchRFID
                        )
                        .textFieldStyle(.roundedBorder)
                        .padding(.vertical, 4)

                        Button("検索") {
                            Task {
                                await itemSearchManager.searchItemByRFID(rfid: manualSearchRFID)
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.regular)
                        .disabled(manualSearchRFID.isEmpty)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)

                // 検索結果表示
                if itemSearchManager.isLoading {
                    ProgressView("検索中...")
                        .padding()
                } else if let errorMessage = itemSearchManager.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .cornerRadius(10)
                } else if let item = itemSearchManager.searchedItem, let master = itemSearchManager.inventoryMaster {
                    // 商品情報表示
                    VStack(alignment: .leading, spacing: 16) {
                        Text("商品情報")
                            .font(.headline)
                            .fontWeight(.bold)
                            .padding(.horizontal)

                        if let imageURL = master.productImage, !imageURL.isEmpty {
                            AsyncImage(url: URL(string: imageURL)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(height: 200)
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                        }

                        Group {
                            ItemSearchInfoRow(label: "RFID", value: item.rfid)
                            ItemSearchInfoRow(label: "商品名", value: master.col1)
                            if let col2 = master.col2, !col2.isEmpty { ItemSearchInfoRow(label: "説明", value: col2) }
                            if let col3 = master.col3, !col3.isEmpty { ItemSearchInfoRow(label: "詳細", value: col3) }
                            if let code = master.productCode, !code.isEmpty { ItemSearchInfoRow(label: "商品コード", value: code) }
                            ItemSearchInfoRow(label: "対象", value: master.target.rawValue)
                            ItemSearchInfoRow(label: "棚卸し状態", value: item.isInventoried ? "済" : "未")
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                    .background(Color.gray.opacity(0.1))
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
                                        Task {
                                            await itemSearchManager.searchItemByRFID(rfid: rfid)
                                        }
                                    }) {
                                        HStack {
                                            Text(rfid)
                                                .padding()
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                        }
                                    }
                                    .buttonStyle(
                                        ItemSearchSelectionButtonStyle(
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
                        itemSearchManager.clearSearchResults()
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
            }
            .padding()
        }
        .navigationTitle("商品検索")
    }
}

// 情報表示用の行
struct ItemSearchInfoRow: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.body)
        }
        .padding(.vertical, 2)
    }
}

// カスタム選択ボタンスタイル
struct ItemSearchSelectionButtonStyle: ButtonStyle {
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

