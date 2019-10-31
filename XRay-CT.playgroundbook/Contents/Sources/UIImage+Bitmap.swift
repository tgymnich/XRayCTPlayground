//
//  UIImage+Bitmap.swift
//  XRay-CT
//
//  Created by Tim Gymnich on 3/16/19.
//  Copyright © 2019 Tim Gymnich. All rights reserved.
//

import UIKit

extension UIImage {
    /// Creates a UIImage from a 8-Bit bitmap
    static func imageFrom(bitmap: [UInt8], width: Int, height: Int) -> UIImage? {
        guard width > 0 && height > 0 else { return nil }
        guard bitmap.count == width * height else { return nil }
        
        var data = bitmap
        guard let provider = CGDataProvider(data: NSData(bytes: &data, length: data.count * MemoryLayout<UInt8>.size)) else { return nil }
        
        guard let cgImage = CGImage(width: width,
                                    height: height,
                                    bitsPerComponent: 8,
                                    bitsPerPixel: 8,
                                    bytesPerRow: width * MemoryLayout<UInt8>.size,
                                    space: CGColorSpaceCreateDeviceGray(),
                                    bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue),
                                    provider: provider,
                                    decode: nil,
                                    shouldInterpolate: false,
                                    intent: .defaultIntent)
            else { return nil }
        
        return UIImage(cgImage: cgImage)
    }
    
}

extension CGImage {
    /// Returns a UInt8 Array of the grayscale pixel data.
    func grayScalePixelData() -> [UInt8] {
        let size = width * height
        let context = CGContext(data: nil,
                                width: width,
                                height: height,
                                bitsPerComponent: 8,
                                bytesPerRow: width,
                                space:  CGColorSpaceCreateDeviceGray(),
                                bitmapInfo: CGImageAlphaInfo.none.rawValue)
        
        context?.draw(self, in: CGRect(x: 0, y: 0, width: width, height: height))
        let buffer = UnsafeBufferPointer(start: context?.data?.assumingMemoryBound(to: UInt8.self), count: size)
        let pixelData = Array(buffer)
        return pixelData
    }
}

