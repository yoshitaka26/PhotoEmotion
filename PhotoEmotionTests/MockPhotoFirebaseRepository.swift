//
//  MockPhotoFirebaseRepository.swift
//  PhotoEmotionTests
//
//  Created by Yoshitaka Tanaka on 2022/06/05.
//

import UIKit
import RxSwift
import RxCocoa
@testable import PhotoEmotion

class MockPhotoFirebaseRepository: PhotoFirebaseRepositoryable {
    var resultType: TestResultType
    var emotionType: EmotionType = .happy
    var photoItems: [PhotoItem] {
        [
            PhotoItem(id: "001", photoURL: "", tag: emotionType.rawValue),
            PhotoItem(id: "002", photoURL: "", tag: emotionType.rawValue),
            PhotoItem(id: "003", photoURL: "", tag: emotionType.rawValue)
        ]
    }

    required init(result: TestResultType) {
        self.resultType = result
    }

    func fetch(emotionType: EmotionType) -> Single<[PhotoItem]> {
        return Single<[PhotoItem]>.create(subscribe: { single in
            switch self.resultType {
            case .success:
                single(.success(self.photoItems))
            case .failure:
                single(.failure(APIError.customError(message: "")))
            }
            return Disposables.create()
        })
    }

    func upload(image: UIImage, emotionType: EmotionType, imageId: UUID) -> Completable {
        return Completable.create { completable in
            switch self.resultType {
            case .success:
                completable(.completed)
            case .failure:
                completable(.error(APIError.imageUploadError))
            }
            return Disposables.create()
        }
    }
}
