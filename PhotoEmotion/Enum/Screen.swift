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
    case imageView(index: Int)
    case upload
    case cropImage(image: UIImage)
    case setting
    case errorAlert(message: String)
    case other
}
