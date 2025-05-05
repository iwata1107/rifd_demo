//
//  InventoryMaster.swift
//  RFID_ios
//
//  Created on 2025/05/05.
//

import Foundation

/// 在庫管理マスターのデータモデル
struct InventoryMaster: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let description: String?
    let target: String?
    let createdAt: Date
    let updatedAt: Date?
    let userId: String?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case target
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case userId = "user_id"
    }
}

// Date拡張 - ISO8601文字列変換用
extension Date {
    var iso8601String: String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.string(from: self)
    }
}
