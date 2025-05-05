//
//  UITextView+Extension.swift
//  DensoScannerSDK_Demo
//
//  Copyright © 2018 SP1. All rights reserved.
//

import UIKit

extension UITextView {
	
	func add(image: UIImage) {
		var attributedString :NSMutableAttributedString!
		attributedString = NSMutableAttributedString(attributedString: attributedText)
		let textAttachment = NSTextAttachment()
		textAttachment.image = image
		
		let oldWidth = textAttachment.image!.size.width;
		
		//I'm subtracting 10px to make the image display nicely, accounting
		//for the padding inside the textView
		
		let scaleFactor = oldWidth
		textAttachment.image = UIImage(cgImage: textAttachment.image!.cgImage!, scale: scaleFactor, orientation: .up)
		let attrStringWithImage = NSAttributedString(attachment: textAttachment)
		attributedString.append(attrStringWithImage)
		attributedText = attributedString
	}
}
