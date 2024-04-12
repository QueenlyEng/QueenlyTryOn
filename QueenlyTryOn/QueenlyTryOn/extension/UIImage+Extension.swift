//
//  UIImage+Extension.swift
//  QueenlyTryOnTestApp
//
//  Created by Mica Morales on 4/3/24.
//

import UIKit
import VideoToolbox

extension UIImage {
    convenience init?(pixelBuffer: CVPixelBuffer) {
        var cgImage: CGImage?
        VTCreateCGImageFromCVPixelBuffer(pixelBuffer, options: nil, imageOut: &cgImage)
        
        guard let cgImage = cgImage else {
            return nil
        }
        
        self.init(cgImage: cgImage)
    }
    
    convenience init?(pixelBuffer: CVPixelBuffer, scale: CGFloat, orientation: Orientation) {
        var cgImage: CGImage?
        VTCreateCGImageFromCVPixelBuffer(pixelBuffer, options: nil, imageOut: &cgImage)
        
        guard let cgImage = cgImage else {
            return nil
        }
        
        self.init(cgImage: cgImage, scale: scale, orientation: orientation)
    }
    
    func resized(to newSize: CGSize, scale: CGFloat = 1) -> UIImage {
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = scale
        let renderer = UIGraphicsImageRenderer(size: newSize, format: format)
        let image = renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: newSize))
        }
        return image
    }
    
    func isEmpty() -> Bool {
        return size.width == .zero || size.height == .zero
    }
    
    func cropAlpha() -> QCroppedImage {
        guard let cgImage = cgImage else {
            return QCroppedImage(origImage: self, resultImage: self, cropBounds: CGRect(origin: .zero, size: size))
        }
        
        let width = cgImage.width
        let height = cgImage.height
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bytesPerPixel: Int = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8
        let bitmapInfo: UInt32 = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
        
        guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo),
              let ptr = context.data?.assumingMemoryBound(to: UInt8.self) else {
            return QCroppedImage(origImage: self, resultImage: self, cropBounds: CGRect(origin: .zero, size: size))
        }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        var minX: Int = width
        var minY: Int = height
        var maxX: Int = 0
        var maxY: Int = 0
        
        for x in 0..<width {
            for y in 0..<height {
                
                let i = bytesPerRow * Int(y) + bytesPerPixel * Int(x)
                let a = CGFloat(ptr[i + 3]) / 255.0
                
                if a >= 0.75 {
                    if (x < minX) { minX = x }
                    if (x > maxX) { maxX = x }
                    if (y < minY) { minY = y }
                    if (y > maxY) { maxY = y }
                }
            }
        }
        
        let rect = CGRect(x: CGFloat(minX),
                          y: CGFloat(minY),
                          width: CGFloat(maxX-minX),
                          height: CGFloat(maxY-minY))
        let croppedImage = crop(to: rect)
        return QCroppedImage(origImage: self, resultImage: croppedImage, cropBounds: rect)
    }
    
    func crop(to bounds: CGRect) -> UIImage {
        guard let cgImage = cgImage else {
            return self
        }
        if let imageRef: CGImage = cgImage.cropping(to: bounds) {
            let image: UIImage = UIImage(cgImage: imageRef, scale: scale, orientation: imageOrientation)
            return image
        }
        return self
    }
    
    func rotated(by rotationAngle: CGFloat) -> UIImage? {
        var rotatedImage = self
        let rotatedSize = CGRect(origin: .zero, size: CGSize(width: size.width, height: size.height)).applying(CGAffineTransform(rotationAngle: rotationAngle)).integral.size
        UIGraphicsBeginImageContext(rotatedSize)
        if let context = UIGraphicsGetCurrentContext() {
            context.translateBy(x: rotatedSize.width / 2.0, y: rotatedSize.height / 2.0)
            context.rotate(by: rotationAngle)
            draw(in: CGRect(x: -size.width / 2.0, y: -size.height / 2.0, width: size.width, height: size.height))
            rotatedImage = UIGraphicsGetImageFromCurrentImageContext() ?? self
        }
        UIGraphicsEndImageContext()
        return rotatedImage
    }
    
    func flippedHorizontally() -> UIImage {
        var flippedImage = self
        UIGraphicsBeginImageContext(size)
        if let context = UIGraphicsGetCurrentContext() {
            context.translateBy(x: size.width, y: 0)
            context.scaleBy(x: -1, y: 1)
            draw(in: CGRect(origin: .zero, size: size))
            flippedImage = UIGraphicsGetImageFromCurrentImageContext() ?? self
        }
        UIGraphicsEndImageContext()
        return flippedImage
    }
    
    func convertPoint(_ point: CGPoint, to view: UIView) -> CGPoint {
        var targetPoint = point
        let targetSize = view.frame.size
        
        let ratioX = targetSize.width / size.width;
        let ratioY = targetSize.height / size.height;
        
        let scale = min(ratioX, ratioY);
        
        targetPoint.x *= scale;
        targetPoint.y *= scale;
        
        targetPoint.x += (view.frame.size.width - size.width * scale) / 2.0;
        targetPoint.y += (view.frame.size.height - size.height * scale) / 2.0;
        
        return targetPoint
    }
    
}
