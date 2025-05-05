//
//  CompareMasterView.swift
//  RFID_ios
//
//  2025-05-05  SwiftUI-only 版
//

import SwiftUI
import UniformTypeIdentifiers     // UTType

struct CompareMasterView: View {
    @EnvironmentObject var cmp: CompareMasterManager
    @State private var showImporter = false

    var body: some View {
        List {                     // ← ここを List に
            // ① ファイル名 & 読み込みボタン
            HStack {
                Text("マスター: \(cmp.masterFileName)")
                    .font(.subheadline)
                    .lineLimit(1)
                Spacer()
                Button("選択…") { showImporter = true }
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
                    ForEach(cmp.uncountedTags, id: \.self, content: Text.init)
                }
            }

            // ④ 外れタグ
            if !cmp.outerTags.isEmpty {
                Section("外れタグ") {
                    ForEach(cmp.outerTags, id: \.self, content: Text.init)
                }
            }
        }
        .listStyle(.insetGrouped)          // iOS17 なら .insetGrouped が今風
        .navigationTitle("Compare Master")
        .fileImporter(
            isPresented: $showImporter,
            allowedContentTypes: [.commaSeparatedText, .plainText],
            allowsMultipleSelection: false
        ) { result in
            if case .success(let urls) = result, let url = urls.first {
                cmp.loadMaster(from: url)
            }
        }
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

// MARK: - サブビュー
private struct StatView: View {
    let title: String
    let value: Int
    var body: some View {
        VStack {
            Text("\(value)").font(.title2).bold()
            Text(title).font(.caption)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct ListSection: View {
    let title: String
    let items: [String]
    var body: some View {
        if !items.isEmpty {
            Section(title) {
                List(items, id: \.self) { Text($0) }
                    .frame(maxHeight: 120)     // 適宜調整
            }
        }
    }
}
