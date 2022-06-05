//
//  PhotoFirebaseRepositoryable.swift
//  PhotoEmotion
//
//  Created by Yoshitaka Tanaka on 2022/06/05.
//

import RxSwift
import RxCocoa

protocol PhotoFirebaseRepositoryable {
    func fetch(emotionType: EmotionType) -> Single<[PhotoItem]>
    func upload(image: UIImage, emotionType: EmotionType, imageId: UUID) -> Completable
}
