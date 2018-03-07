
//
//  UIImage+Extension.swift
//  ZPOperator
//
//  Created by 杜进新 on 2017/7/1.
//  Copyright © 2017年 dujinxin. All rights reserved.
//

import UIKit
import Photos

extension UIImage {
    
    /// 依据宽度等比例对图片重新绘制
    ///
    /// - Parameters:
    ///   - originalImage: 原图
    ///   - scaledWidth: 将要缩放或拉伸的宽度
    ///   - scaleHeight: 将要缩放或拉伸的高度，默认为0，高度根据比例自动调整
    /// - Returns: 新的图片
    class func image(originalImage:UIImage? ,to scaledWidth:CGFloat, scaleHeight:CGFloat = 0) -> UIImage? {
        guard let image = originalImage else {
            return UIImage.init()
        }
        let imageWidth = image.size.width
        let imageHeigth = image.size.height
        let width = scaledWidth
        let height = (scaleHeight == 0) ? (image.size.height / (image.size.width / width)) : scaleHeight
        
        let widthScale = imageWidth / width
        let heightScale = imageHeigth / height
        
        UIGraphicsBeginImageContext(CGSize(width: width, height: height))
        
        if widthScale > heightScale {
            image.draw(in: CGRect(x: 0, y: 0, width: imageWidth / heightScale, height: heightScale))
        } else {
            image.draw(in: CGRect(x: 0, y: 0, width: width, height: imageHeigth / widthScale))
        }
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    static func image(originalImage:UIImage?,rect:CGRect,radius:CGFloat) -> UIImage? {
        guard let image = originalImage else {
            return UIImage.init()
        }
        //opaque 是否透明 false透明 true不透明
        //scale 绘制分辨率，默认为1.0,会模糊，设置为0会自动根据屏幕分辨率来绘制
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        
        
        //let path = UIBezierPath(arcCenter: self.center, radius: radius, startAngle: pid_t * 0, endAngle: pid_t * 2, clockwise: true)
        //let path = UIBezierPath(ovalIn: rect)
        let path = UIBezierPath(roundedRect: rect, cornerRadius: radius)
        //剪切
        path.addClip()
        
        image.draw(in: rect)
        
        //path.lineCapStyle = .round
        UIColor.groupTableViewBackground.setStroke()
        path.lineWidth = 3
        //path.stroke(with: .color, alpha: 0.8)
        path.stroke()
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        
        return newImage
    }
    static func imageScreenshot(view: UIView) -> UIImage? {
        let rect = view.bounds
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        
        view.layer.render(in: context!)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
}
