//
//  String+Extension.swift
//  DensoScannerSDK_Demo
//
//  Created by SP1Team on 11/6/18.
//  Copyright © 2018 SP1. All rights reserved.
//

import Foundation

extension String {
	func localized(withComment comment: String? = nil) -> String {
		return NSLocalizedString(self, comment: comment ?? "")
	}
}

extension Array where Element : Hashable {
	var unique: [Element] {
		return Array(Set(self))
	}
}
