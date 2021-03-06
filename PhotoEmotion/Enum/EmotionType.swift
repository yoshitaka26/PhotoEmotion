//
//  EmotionType.swift
//  PhotoEmotion
//
//  Created by Yoshitaka Tanaka on 2022/05/26.
//

import Foundation

enum EmotionType: String, CaseIterable {
    case happy
    case sad
    case angry
    case scared
    case other

    var typeNumber: Int {
        switch self {
        case .happy:
            return 100
        case .sad:
            return 200
        case .angry:
            return 300
        case .scared:
            return 400
        case .other:
            return 999
        }
    }

    var titleText: String {
        self.rawValue.prefix(1).uppercased() + self.rawValue.dropFirst()
    }
}
