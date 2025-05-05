//
//  UIImage+Extension.swift
//  DensoScannerSDK_Demo
//
//  Copyright © 2018 SP1. All rights reserved.
//

import UIKit

extension UIImage {
	
	typealias RectCalculation = (_ parentSize: CGSize, _ newImageSize: CGSize) -> (CGRect)
	
	func with(image named: String, rect: RectCalculation) -> UIImage {
		return with(image: UIImage(named: named), rect: rect)
	}
	
	func with(image: UIImage?, rect: RectCalculation) -> UIImage {
		
		if let image = image {
			UIGraphicsBeginImageContext(size)
			
			draw(in: CGRect(origin: .zero, size: size))
			image.draw(in: rect(size, image.size))
			
			let newImage = UIGraphicsGetImageFromCurrentImageContext()
			UIGraphicsEndImageContext()
			return newImage!
		}
		
		return self
	}
	
	func maskWithColor(color: UIColor) -> UIImage? {
		UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
		let context = UIGraphicsGetCurrentContext()!
		let rect = CGRect(origin: CGPoint.zero, size: size)
		color.setFill()
		self.draw(in: rect)
		context.setBlendMode(.sourceIn)
		context.fill(rect)
		let resultImage = UIGraphicsGetImageFromCurrentImageContext()!
		UIGraphicsEndImageContext()
		return resultImage
	}
}
