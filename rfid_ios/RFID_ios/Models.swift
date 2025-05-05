//
//  Model.swift
//  RFID_ios
//
//  Created by 岩田照太 on 2025/05/06.
//

import Foundation


struct Profile: Codable {
  let username: String?
  let fullName: String?
  let website: String?
  let avatarURL: String?

  enum CodingKeys: String, CodingKey {
    case username
    case fullName = "full_name"
    case website
    case avatarURL = "avatar_url"
  }
}

struct UpdateProfileParams: Encodable {
  let username: String
  let fullName: String
  let website: String
  enum CodingKeys: String, CodingKey {
    case username
    case fullName = "full_name"
    case website
  }
}

// MARK: - Inventory Models

enum TargetType: String, Codable {
    case clinic = "clinic"
    case cardShop = "card_shop"
    case apparelShop = "apparel_shop"
}

struct InventoryMaster: Codable, Identifiable {
    let id: String
    let createdAt: String
    let updatedAt: String
    let col1: String
    let col2: String?
    let col3: String?
    let productCode: String?
    let target: TargetType
    let userId: String?
    let productImage: String?

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case col1 = "col_1"
        case col2 = "col_2"
        case col3 = "col_3"
        case productCode = "product_code"
        case target
        case userId = "user_id"
        case productImage = "product_image"
    }
}

struct Item: Codable, Identifiable {
    let id: String
    let createdAt: String
    let updatedAt: String
    let rfid: String
    let inventoryMasterId: String
    let userId: String?
    let isInventoried: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case rfid
        case inventoryMasterId = "inventory_master_id"
        case userId = "user_id"
        case isInventoried = "is_inventoried"
    }
}

struct CreateItemParams: Encodable {
    let rfid: String
    let inventoryMasterId: String
    let isInventoried: Bool?

    enum CodingKeys: String, CodingKey {
        case rfid
        case inventoryMasterId = "inventory_master_id"
        case isInventoried = "is_inventoried"
    }
}
