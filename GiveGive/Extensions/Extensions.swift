//
//  Extensions.swift
//  GiveGive
//
//  Created by Joanne Yager on 2023-11-23.
//

import Foundation
import SwiftUI

extension UIImage {
    func compress() -> UIImage? {
            guard let imageData = self.pngData() else { return nil }
            let megaByte = 300.0
            
            var resizingImage = self
            var imageSizeKB = Double(imageData.count) / megaByte
            
            while imageSizeKB > megaByte {
                guard let resizedImage = resizingImage.resized(withPercentage: 0.5),
                      let imageData = resizedImage.pngData() else { return nil }
                
                resizingImage = resizedImage
                imageSizeKB = Double(imageData.count) / megaByte
            }
            
            return resizingImage
        }
    
    func resized(withPercentage percentage: CGFloat) -> UIImage? {
        let newSize = CGSize(width: size.width * percentage, height: size.height * percentage)
        
        return self.preparingThumbnail(of: newSize)
    }
}

extension UIImage {
    
    func pixelate() -> UIImage? {
        let image = self
        guard let currentCGImage = image.cgImage else { return nil }
        let currentCIImage = CIImage(cgImage: currentCGImage)

        let filter = CIFilter(name: "CIPixellate")
        filter?.setValue(currentCIImage, forKey: kCIInputImageKey)
        filter?.setValue(8, forKey: kCIInputScaleKey)
        guard let outputImage = filter?.outputImage else { return nil }

        let context = CIContext()

        if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
            let processedImage = UIImage(cgImage: cgimg)
            print(processedImage.size)
            return processedImage
        }
        
        return nil
    }
}
