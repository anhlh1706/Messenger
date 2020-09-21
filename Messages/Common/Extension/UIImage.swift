//
//  UIImage.swift
//  Base
//
//  Created by Hoàng Anh on 29/07/2020.
//  Copyright © 2020 Hoàng Anh. All rights reserved.
//

import UIKit

extension UIImage {
    
    convenience init?(color: UIColor) {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context: CGContext? = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
    
    convenience init(barcode: String) {
        let data = barcode.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CICode128BarcodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)
            
            if let output = filter.outputImage?.transformed(by: transform) {
                self.init(ciImage: output)
                return
            }
        }
        self.init()
    }
    
    func resized(toSize size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height))
        return UIGraphicsGetImageFromCurrentImageContext()!
    }
    
    func resizeToFit(size: CGSize) -> UIImage {
        let aspect = self.size.width / self.size.height
        if size.width / aspect <= size.height {
            return resized(toSize: CGSize(width: size.width, height: size.width / aspect))
        } else {
            return resized(toSize: CGSize(width: size.height * aspect, height: size.height))
        }
    }
    
    func scale(withPercentage percentage: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: size.width * percentage, height: size.height * percentage)
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    func scaledImage() -> UIImage? {
        guard let imageData = pngData() else { return nil }
        
        var resizingImage = self
        var imageSizeKB = Double(imageData.count) / 1000.0 // ! Or devide for 1024 if you need KB but not kB
        
        while imageSizeKB > 5000 { // ! Or use 500 if you need KB but not kB
            guard let resizedImage = resizingImage.scale(withPercentage: 0.8),
                let imageData = resizedImage.pngData()
                else { return nil }
            
            resizingImage = resizedImage
            imageSizeKB = Double(imageData.count) / 1000.0 // ! Or devide for 1024 if you need KB but not kB
        }
        
        return resizingImage
    }
    
    func png() -> Data? {
        return flattened()?.pngData()
    }
    
    func flattened() -> UIImage? {
        if imageOrientation == .up { return self }
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
