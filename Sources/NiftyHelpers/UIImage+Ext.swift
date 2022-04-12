//
//  UIImageExtensions.swift
//  Color Replacement
//
//  Created by Iiro Alhonen on 15.04.21.
//
#if !os(macOS)
import UIKit

/**
 Extends UIImage giving the ability to change a color in an image with another.
 - Authors: Iiro Alhonen
 - Version: 2021-06-08
 */
extension UIImage {
    /**
     Replaces a color in the image with a different color.
     - Parameter color: color to be replaced.
     - Parameter with: the new color to be used.
     - Parameter tolerance: tolerance, between 0 and 1. 0 won't change any colors,
                            1 will change all of them. 0.5 is default.
     - Returns: image with the replaced color.
     */
    func replaceColor(_ color: UIColor, with: UIColor, tolerance: CGFloat = 0.5) -> UIImage {
        guard let imageRef = self.cgImage else {
            return self
        }
        // Get color components from replacement color
        let withColorComponents = with.cgColor.components
        let newRed = UInt8(withColorComponents![0] * 255)
        let newGreen = UInt8(withColorComponents![1] * 255)
        let newBlue = UInt8(withColorComponents![2] * 255)
        let newAlpha = UInt8(withColorComponents![3] * 255)

        let width = imageRef.width
        let height = imageRef.height

        let bitmapByteCount = imageRef.bytesPerRow * height

        let rawData = UnsafeMutablePointer<UInt8>.allocate(capacity: bitmapByteCount)
        defer {
            rawData.deallocate()
        }

        guard let colorSpace = CGColorSpace(name: CGColorSpace.genericRGBLinear) else {
            return self
        }

        guard let context = CGContext(
            data: rawData,
            width: width,
            height: height,
            bitsPerComponent: imageRef.bitsPerComponent,
            bytesPerRow: imageRef.bytesPerRow,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
                | CGBitmapInfo.byteOrder32Big.rawValue
        ) else {
            return self
        }

        let rc = CGRect(x: 0, y: 0, width: width, height: height)
        // Draw source image on created context.
        context.draw(imageRef, in: rc)
        let pixelCount = width * height
        let bytesPerPixel = imageRef.bitsPerPixel / 8
        // Iterate through pixels.
        DispatchQueue.concurrentPerform(iterations: pixelCount, execute: { pixel in
            let byteIndex = pixel * bytesPerPixel
            // Get color of current pixel.
            let red = CGFloat(rawData[byteIndex + 0]) / 255
            let green = CGFloat(rawData[byteIndex + 1]) / 255
            let blue = CGFloat(rawData[byteIndex + 2]) / 255
            let alpha = CGFloat(rawData[byteIndex + 3]) / 255
            let currentColor = UIColor(red: red, green: green, blue: blue, alpha: alpha)
            // Replace pixel if the color is close enough to the color being replaced.
            if compareColor(firstColor: color, secondColor: currentColor, tolerance: tolerance) {
                rawData[byteIndex + 0] = newRed
                rawData[byteIndex + 1] = newGreen
                rawData[byteIndex + 2] = newBlue
                rawData[byteIndex + 3] = newAlpha
            }
        })

        // Retrieve image from memory context.
        guard let image = context.makeImage() else {
            return self
        }
        let result = UIImage(cgImage: image)
        return result
    }

    /**
     Check if two colors are the same (or close enough given the tolerance).
     - Parameter firstColor: first color used in the comparisson.
     - Parameter secondColor: second color used in the comparisson.
     - Parameter tolerance: how much variation can there be for the function to return true.
                            0 is less sensitive (will always return false),
                            1 is more sensitive (will always return true).
     */
    private func compareColor(
        firstColor: UIColor,
        secondColor: UIColor,
        tolerance: CGFloat
    ) -> Bool {
        var r1: CGFloat = 0.0, g1: CGFloat = 0.0, b1: CGFloat = 0.0, a1: CGFloat = 0.0;
        var r2: CGFloat = 0.0, g2: CGFloat = 0.0, b2: CGFloat = 0.0, a2: CGFloat = 0.0;

        firstColor.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        secondColor.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)

        return abs(r1 - r2) <= tolerance
            && abs(g1 - g2) <= tolerance
            && abs(b1 - b2) <= tolerance
            && abs(a1 - a2) <= tolerance
    }

}
#endif
