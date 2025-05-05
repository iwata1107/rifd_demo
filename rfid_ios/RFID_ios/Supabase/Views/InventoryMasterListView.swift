//
//  InventoryMasterListView.swift
//  RFID_ios
//
//  Created on 2025/05/05.
//

import SwiftUI

struct InventoryMasterListView: View {
    @EnvironmentObject var inventoryManager: InventoryMasterManager
    @State private var searchText = ""
    @State private var showingDetail: InventoryMaster? = nil

    var filteredMasters: [InventoryMaster] {
        if searchText.isEmpty {
            return inventoryManager.inventoryMasters
        } else {
            return inventoryManager.inventoryMasters.filter { master in
                master.name.localizedCaseInsensitiveContains(searchText) ||
                (master.description?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                if inventoryManager.isLoading {
                    ProgressView("読み込み中...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if inventoryManager.inventoryMasters.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "tray")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80, height: 80)
                            .foregroundColor(.gray)

                        Text("データがありません")
                            .font(.title2)
                            .foregroundColor(.gray)

                        Button(action: {
                            Task {
                                await inventoryManager.fetchInventoryMasters()
                            }
                        }) {
                            Text("再読み込み")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(filteredMasters) { master in
                            Button(action: {
                                showingDetail = master
                            }) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(master.name)
                                        .font(.headline)

                                    if let description = master.description, !description.isEmpty {
                                        Text(description)
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                            .lineLimit(2)
                                    }

                                    if let target = master.target, !target.isEmpty {
                                        Text("業種: \(target)")
                                            .font(.caption)
                                            .foregroundColor(.blue)
                                    }

                                    Text("作成日: \(formattedDate(master.createdAt))")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 4)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .searchable(text: $searchText, prompt: "マスター名で検索")
                    .refreshable {
                        await inventoryManager.fetchInventoryMasters()
                    }
                }
            }
            .navigationTitle("在庫マスター一覧")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        Task {
                            await inventoryManager.fetchInventoryMasters()
                        }
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .sheet(item: $showingDetail) { master in
                InventoryMasterDetailView(master: master)
            }
            .alert(isPresented: Binding<Bool>(
                get: { inventoryManager.error != nil },
                set: { if !$0 { inventoryManager.error = nil } }
            )) {
                Alert(
                    title: Text("エラー"),
                    message: Text(inventoryManager.error?.localizedDescription ?? "不明なエラーが発生しました"),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
        .onAppear {
            Task {
                await inventoryManager.fetchInventoryMasters()
            }
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
}

struct InventoryMasterDetailView: View {
    let master: InventoryMaster
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("基本情報")) {
                    LabeledContent("ID", value: master.id)
                    LabeledContent("名前", value: master.name)

                    if let description = master.description, !description.isEmpty {
                        LabeledContent("説明", value: description)
                    }

                    if let target = master.target, !target.isEmpty {
                        LabeledContent("業種", value: target)
                    }
                }

                Section(header: Text("日時情報")) {
                    LabeledContent("作成日時", value: formattedDate(master.createdAt))

                    if let updatedAt = master.updatedAt {
                        LabeledContent("更新日時", value: formattedDate(updatedAt))
                    }
                }

                if let userId = master.userId {
                    Section(header: Text("その他")) {
                        LabeledContent("作成者ID", value: userId)
                    }
                }
            }
            .navigationTitle("マスター詳細")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("閉じる") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
}

struct InventoryMasterListView_Previews: PreviewProvider {
    static var previews: some View {
        InventoryMasterListView()
            .environmentObject(InventoryMasterManager())
    }
}
