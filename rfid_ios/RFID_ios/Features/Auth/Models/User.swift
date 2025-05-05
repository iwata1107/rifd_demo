//
//  User.swift
//  RFID_ios
//
//  Created on 2025/05/05.
//

import Foundation

/// ユーザーのデータモデル
struct User: Identifiable, Codable, Equatable {
    let id: String
    let email: String?
    let createdAt: Date
    let updatedAt: Date?
    let userMetadata: [String: Any]?

    enum CodingKeys: String, CodingKey {
        case id
        case email
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case userMetadata = "user_metadata"
    }

    init(id: String, email: String?, createdAt: Date, updatedAt: Date? = nil, userMetadata: [String: Any]? = nil) {
        self.id = id
        self.email = email
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.userMetadata = userMetadata
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        email = try container.decodeIfPresent(String.self, forKey: .email)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt)

        // userMetadataはJSONオブジェクトなので特別な処理が必要
        if let metadataData = try container.decodeIfPresent(Data.self, forKey: .userMetadata) {
            userMetadata = try JSONSerialization.jsonObject(with: metadataData) as? [String: Any]
        } else {
            userMetadata = nil
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(email, forKey: .email)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encodeIfPresent(updatedAt, forKey: .updatedAt)

        // userMetadataをJSONデータに変換
        if let metadata = userMetadata, let metadataData = try? JSONSerialization.data(withJSONObject: metadata) {
            try container.encode(metadataData, forKey: .userMetadata)
        }
    }

    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id &&
               lhs.email == rhs.email &&
               lhs.createdAt == rhs.createdAt &&
               lhs.updatedAt == rhs.updatedAt
    }
}
