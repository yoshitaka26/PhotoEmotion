//
//  PhotoItem.swift
//  PhotoEmotion
//
//  Created by Yoshitaka Tanaka on 2022/05/26.
//

import Foundation

struct PhotoItem: Codable {
    let id: String
    let userId: String
    let title: String
    let photoURL: String
    let tag: String
    let uploadDate: Date
    let modifyDate: Date
    let deleteFlag: Bool
}
