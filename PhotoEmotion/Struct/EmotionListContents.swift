//
//  EmotionListContents.swift
//  PhotoEmotion
//
//  Created by Yoshitaka Tanaka on 2022/05/26.
//

import Foundation

struct EmotionListContents: Equatable {
    let type: EmotionType
    let contents: [PhotoItem]

    static func == (lhs: EmotionListContents, rhs: EmotionListContents) -> Bool {
        return lhs.type == rhs.type
    }

    static func < (lhs: EmotionListContents, rhs: EmotionListContents) -> Bool {
        return lhs.type.typeNumber < rhs.type.typeNumber
    }
}
