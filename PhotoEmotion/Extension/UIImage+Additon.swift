//
//  UIImage+Additon.swift
//  PhotoEmotion
//
//  Created by Yoshitaka Tanaka on 2022/05/28.
//

import UIKit

extension UIImage {
    func resize(width: CGFloat, height: CGFloat) -> UIImage? {
        let resizedSize = CGSize(width: width, height: height)
        UIGraphicsBeginImageContextWithOptions(resizedSize, false, 0.0)
        draw(in: CGRect(origin: .zero, size: resizedSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage
    }
}
