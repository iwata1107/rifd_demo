//
//  AvatorImage.swift
//  RFID_ios
//
//  Created by 岩田照太 on 2025/05/06.
//

import SwiftUI

struct AvatarImage: Transferable, Equatable {
  let image: Image
  let data: Data

  static var transferRepresentation: some TransferRepresentation {
    DataRepresentation(importedContentType: .image) { data in
      guard let image = AvatarImage(data: data) else {
        throw TransferError.importFailed
      }

      return image
    }
  }
}

extension AvatarImage {
  init?(data: Data) {
    guard let uiImage = UIImage(data: data) else {
      return nil
    }

    let image = Image(uiImage: uiImage)
    self.init(image: image, data: data)
  }
}

enum TransferError: Error {
  case importFailed
}
