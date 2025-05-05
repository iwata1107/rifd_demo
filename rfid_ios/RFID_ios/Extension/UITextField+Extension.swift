//
//  UITextField+Extension.swift
//  DensoScannerSDK_Demo
//
//  Copyright © 2018 SP1. All rights reserved.
//

import UIKit

extension UITextField {
	func setLeftPaddingPoints(_ padding: CGFloat){
		let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: padding, height: frame.size.height))
		leftView = paddingView
		leftViewMode = .always
	}
}
