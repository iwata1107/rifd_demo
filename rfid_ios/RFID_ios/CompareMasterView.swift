//
//  CompareMasterView.swift
//  RFID_ios
//
//  2025-05-05  SwiftUI-only 版
//

import SwiftUI
import Foundation

struct CompareMasterView: View {
    @EnvironmentObject var cmp: CompareMasterManager
    @State private var showingDetails: String? = nil
    @State private var showingResetConfirmation = false

    var body: some View {
        VStack {
            // Target選択
            Picker("対象", selection: $cmp.selectedTarget) {
                Text("クリニック").tag(TargetType.clinic)
                Text("カードショップ").tag(TargetType.cardShop)
                Text("アパレル").tag(TargetType.apparelShop)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            .onChange(of: cmp.selectedTarget) { newValue in
                print("🔄 ターゲット変更: \(newValue.rawValue)")
                Task {
                    await cmp.loadItemsByTarget()
                }
            }

            // 棚卸しリセットボタン
            Button("棚卸しステータスをリセット") {
                showingResetConfirmation = true
            }
            .buttonStyle(.bordered)
            .padding(.horizontal)
            .padding(.bottom)
            .alert("確認", isPresented: $showingResetConfirmation) {
                Button("キャンセル", role: .cancel) { }
                Button("リセット", role: .destructive) {
                    Task {
                        await cmp.resetInventoryStatus()
                    }
                }
            } message: {
                Text("選択された対象（\(cmp.selectedTarget.rawValue)）の全アイテムの棚卸しステータスをリセットします。この操作は元に戻せません。")
            }

            List {
                // ① データ情報表示
                HStack {
                    Text("データ: \(cmp.masterFileName)")
                        .font(.subheadline)
                        .lineLimit(1)
                    Spacer()
                }

                // ② 数値サマリ：LazyVGrid で横並び
                LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 4)) {
                    StatCell(title: "マスター", value: cmp.masterTags.count)
                    StatCell(title: "読取済",  value: cmp.actualTags.count)
                    StatCell(title: "未読込",  value: cmp.uncountedTags.count)
                    StatCell(title: "外れ",    value: cmp.outerTags.count)
                }
                .padding(.vertical, 4)

                // ③ 未読込タグ
                if !cmp.uncountedTags.isEmpty {
                    Section("未読込タグ") {
                        ForEach(cmp.uncountedTags, id: \.self) { rfid in
                            Button(action: { showingDetails = rfid }) {
                                HStack {
                                    Text(rfid)
                                    Spacer()
                                    Image(systemName: "info.circle")
                                        .foregroundColor(.blue)
                                }
                            }
                            .foregroundColor(.primary)
                        }
                    }
                }

                // ④ 外れタグ
                if !cmp.outerTags.isEmpty {
                    Section("外れタグ") {
                        ForEach(cmp.outerTags, id: \.self, content: Text.init)
                    }
                }
            }
            .listStyle(.insetGrouped)
        }
        .navigationTitle("棚卸し")
        .sheet(item: Binding(
            get: { showingDetails.map { ItemDetailWrapper(rfid: $0) } },
            set: { showingDetails = $0?.rfid }
        )) { wrapper in
            ItemDetailView(rfid: wrapper.rfid, cmp: cmp)
        }
        .onAppear {
            Task {
                await cmp.loadItemsByTarget()
            }
        }
    }
}

// アイテム詳細表示用のラッパー
struct ItemDetailWrapper: Identifiable {
    let rfid: String
    var id: String { rfid }
}

// アイテム詳細表示View
struct ItemDetailView: View {
    let rfid: String
    let cmp: CompareMasterManager
    @Environment(\.dismiss) private var dismiss
    @State private var isUpdating = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    if let item = cmp.itemsMap[rfid],
                       let master = cmp.getInventoryMaster(for: rfid) {

                        Group {
                            HStack {
                                Text("RFID:")
                                    .fontWeight(.bold)
                                Text(rfid)
                            }

                            Divider()

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
                                InfoRow(label: "商品名", value: master.col1)
                                if let col2 = master.col2, !col2.isEmpty { InfoRow(label: "説明", value: col2) }
                                if let col3 = master.col3, !col3.isEmpty { InfoRow(label: "詳細", value: col3) }
                                if let code = master.productCode, !code.isEmpty { InfoRow(label: "商品コード", value: code) }
                                InfoRow(label: "対象", value: master.target.rawValue)
                                InfoRow(label: "棚卸し状態", value: item.isInventoried ? "済" : "未")
                            }

                            Spacer(minLength: 30)

                            Button(action: {
                                isUpdating = true
                                Task {
                                    await cmp.markAsInventoried(rfid: rfid)
                                    isUpdating = false
                                    dismiss()
                                }
                            }) {
                                HStack {
                                    if isUpdating {
                                        ProgressView()
                                            .padding(.trailing, 5)
                                    }
                                    Text(item.isInventoried ? "棚卸し済み" : "棚卸しする")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(item.isInventoried ? Color.gray : Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                            }
                            .disabled(item.isInventoried || isUpdating)
                        }
                        .padding(.horizontal)

                    } else {
                        Text("アイテム情報の取得に失敗しました")
                            .padding()
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("アイテム詳細")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("閉じる") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// 情報表示用の行
struct InfoRow: View {
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

// ―― 共通部品 -------------------------------------------------------
private struct StatCell: View {
    let title: String; let value: Int
    var body: some View {
        VStack {
            Text("\(value)").font(.title3.bold())
            Text(title).font(.caption2)
        }
        .frame(maxWidth: .infinity)
    }
}
