//
//  PhotoHashHelper.swift
//  ClearAlgorithms
//
//  Created by priders on 2021/8/31.
//

import UIKit
struct ColorHash {
    var r:Float = 0
    var g:Float = 0
    var b:Float = 0
    var a:Float = 0
    
    static func *(p1:CGFloat,p2:ColorHash) ->ColorHash{
        return ColorHash(r: Float(p1) * p2.r, g: Float(p1) * p2.g, b: Float(p1) * p2.b, a: Float(p1) * p2.a)
    }
    
    static func +(p1:ColorHash,p2:ColorHash) ->ColorHash{
        return ColorHash(r: p1.r + p2.r, g: p1.g + p2.g, b: p1.b + p2.b, a: p1.a + p2.a)
    }

    
    static func getColorHash(data:UnsafePointer<UInt8>,point:CGPoint,width:CGFloat) -> ColorHash{
        let offset = Int(point.x + point.y * width)
        let red = data[offset]
        let green = data[offset+1]
        let blue = data[offset+2]
        let alpha = data[offset+3]
        return ColorHash(r: Float(red), g: Float(green), b: Float(blue), a: Float(alpha))
    }
}

class PhotoHashHelper: NSObject {


    static func ImageDhash(_ image:UIImage) -> UnsafeMutablePointer<Int32> {
        guard let cimage = image.cgImage,
              let provider = cimage.dataProvider,
              let providerData = provider.data,
              let data = CFDataGetBytePtr(providerData) else{
            return UnsafeMutablePointer<Int32>.allocate(capacity: 1)
        }
        let width = cimage.width
        let height = cimage.height
        
        let wFactor = CGFloat(width / 9)
        let hFactor = CGFloat(height / 8)
        
        
        let pixelsBuffer = UnsafeMutablePointer<Int32>.allocate(capacity: 8 * 9)
        let ouputBuffer = UnsafeMutablePointer<Int32>.allocate(capacity: 8 * 8)

        
        for y in 0..<8 {
            for x in 0..<9 {
                let newPointX = CGFloat(x) * wFactor
                let newPointY = CGFloat(y) * hFactor
                let newPoint = CGPoint(x: newPointX, y: newPointY)
                
                let p1 = CGPoint(x: floor(newPointX) , y: floor(newPointY))
                let p2 = CGPoint(x: ceil(newPointX) , y: floor(newPointY))
                let p3 = CGPoint(x: floor(newPointX) , y: ceil(newPointY))
                let p4 = CGPoint(x: ceil(newPointX) , y: ceil(newPointY))
                
                let u = newPoint.x - floor(newPointX)
                let v = newPoint.y - floor(newPointY)
                
                let color1 = ColorHash.getColorHash(data: data, point: p1, width: wFactor)
                let color2 = ColorHash.getColorHash(data: data, point: p2, width: wFactor)
                let color3 = ColorHash.getColorHash(data: data, point: p3, width: wFactor)
                let color4 = ColorHash.getColorHash(data: data, point: p4, width: wFactor)
                
                let newColor = (1-u) * (1-v) * color1 + (1-u) * v * color3 + u * (1-v) * color2 + u * v * color4
                let gray = (newColor.r + newColor.g + newColor.b) / 3
                pixelsBuffer[x + y * 9] = Int32(gray)
            }
        }
        
        for i in 0..<8 {
            let rowStartIndex = i * 8
            for j in 0..<8 {
                let currentIndex = rowStartIndex + j
                let beforeGray = pixelsBuffer[currentIndex]
                let thisGray = pixelsBuffer[currentIndex+1]
                ouputBuffer[currentIndex] = beforeGray > thisGray ? 1 : 0
            }
        }
        pixelsBuffer.deallocate()
        return ouputBuffer

    }
    
    static func colorMultiplys(_ point:CGPoint,multiplysArr:CGFloat...) -> Float{
        
        
        return 1.0
    }
}
