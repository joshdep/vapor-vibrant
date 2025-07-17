//
//  Image.swift
//  swift-vibrant-ios
//
//  Created by Bryce Dougherty on 5/3/20.
//  Copyright © 2020 Bryce Dougherty. All rights reserved.
//

import Foundation
import SwiftGD

public class VibrantImage {
    var image: Image
    
    init(image: Image) {
        self.image = image
    }
    
    func applyFilter(_ filter: Filter) -> [UInt8] {
        guard let imageData = self.getImageData() else {
            return []
        }
        var pixels = imageData
        let n = pixels.count / 4
        var offset: Int
        var r, g, b, a: UInt8
        
        for i in 0..<n {
            offset = i * 4
            r = pixels[offset + 0]
            g = pixels[offset + 1]
            b = pixels[offset + 2]
            a = pixels[offset + 3]
            
            if (!filter.f(r,g,b,a)) {
                pixels[offset + 3] = 0
            }
        }
        return pixels
    }
    
    func getImageData() -> [UInt8]? {
        return VibrantImage.makeBytes(from: self.image)
    }
    
    func scaleTo(size maxSize: CGFloat?, quality: Int) {
        let width = CGFloat(image.size.width)
        let height = CGFloat(image.size.height)
        
        var ratio: CGFloat = 1.0
        if maxSize != nil && maxSize! > 0 {
            let maxSide = max(width, height)
            if maxSide > CGFloat(maxSize!) {
                ratio = CGFloat(maxSize!) / maxSide
            }
        } else {
            ratio = 1 / CGFloat(quality)
        }
        
        if ratio < 1 {
            self.scale(by: ratio)
        }
    }
    
    func scale(by scale: CGFloat) {
        self.image = VibrantImage.scaleImage(image: self.image, by: scale)
    }
    
    private static func scaleImage(image: Image, by scale: CGFloat) -> Image {
        if scale == 1 { return image }
        
        let newWidth = CGFloat(image.size.width) * scale
        let newHeight = CGFloat(image.size.height) * scale
        let newImage = image.resizedTo(width: Int(newWidth), height: Int(newHeight))
        
        return newImage ?? image
    }
    
    private static func makeBytes(from image: Image) -> [UInt8]? {
        let width = image.size.width
        let height = image.size.height
        var bytes: [UInt8] = []

        for y in 0..<height {
            for x in 0..<width {
                let color = image.get(pixel: Point(x: x, y: y))
                let r = UInt8((color.redComponent * 255).rounded())
                let g = UInt8((color.greenComponent * 255).rounded())
                let b = UInt8((color.blueComponent * 255).rounded())
                let a = UInt8((color.alphaComponent * 255).rounded()) // Usually 1.0 unless transparency is present

                bytes.append(contentsOf: [r, g, b, a])
            }
        }

        return bytes
    }

}
