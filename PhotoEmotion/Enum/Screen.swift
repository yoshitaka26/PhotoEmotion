//
//  Screen.swift
//  PhotoEmotion
//
//  Created by Yoshitaka Tanaka on 2022/05/26.
//

import Foundation
import UIKit

enum Screen {
    case main
    case list(emotionType: EmotionType)
    case galleryView(index: Int)
    case upload
    case cropImage(image: UIImage)
    case setting
    case errorAlert(message: String)
    case other
}

func ==(a: Screen, b: Screen) -> Bool {
    switch (a, b) {
    case (.main, .main),
        (.list, .list),
        (.galleryView, .galleryView),
        (.upload, .upload),
        (.cropImage, .cropImage),
        (.setting, .setting),
        (.errorAlert, .errorAlert),
        (.other, .other):
        return true
    default:
        return false
    }
}
