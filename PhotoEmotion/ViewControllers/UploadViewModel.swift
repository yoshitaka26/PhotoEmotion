//
//  UploadViewModel.swift
//  PhotoEmotion
//
//  Created by Yoshitaka Tanaka on 2022/05/27.
//

import UIKit
import RxSwift
import RxCocoa

final class UploadViewModel {

    private(set) var isLoading = BehaviorRelay<Bool>(value: false)
    private(set) var viewWillAppear = PublishRelay<Void>()

    private var imageSubject = BehaviorRelay<UIImage>(value: R.image.add_photo()!)
    var photoImage: Driver<UIImage> {
        return imageSubject.asDriver()
    }

    private var cropImageButtonEnabledSubject = BehaviorRelay<Bool>(value: false)
    var cropImageButtonEnabled: Driver<Bool> {
        return cropImageButtonEnabledSubject.asDriver()
    }

    private var photoEmotionSubject = BehaviorRelay<EmotionType>(value: .happy)
    var photoEmotion: Driver<EmotionType> {
        return photoEmotionSubject.asDriver()
    }

    private var uploadImageButtonEnabledSubject = BehaviorRelay<Bool>(value: false)
    var uploadImageButtonEnabled: Driver<Bool> {
        return uploadImageButtonEnabledSubject.asDriver()
    }

    private var pushScreenSubject = PublishRelay<Screen>()
    var pushScreen: Driver<Screen> {
        return pushScreenSubject.asDriver(onErrorJustReturn: .other)
    }

    private var presentScreenSubject = PublishRelay<Screen>()
    var presentScreen: Driver<Screen> {
        return presentScreenSubject.asDriver(onErrorJustReturn: .other)
    }

    private let disposeBag = DisposeBag()

    init() {
        subscribe()
    }

    private func subscribe() {
        viewWillAppear.subscribe(onNext: { [unowned self] _ in
        })
        .disposed(by: disposeBag)
    }

    func handleImagePicker(selectedImage: UIImage) {
        self.imageSubject.accept(selectedImage)
        self.cropImageButtonEnabledSubject.accept(true)
        self.uploadImageButtonEnabledSubject.accept(true)
    }

    func handleDidCropToImage(croppedImage: UIImage) {
        self.imageSubject.accept(croppedImage)
    }

    func handleEmotionButton(emotionType: EmotionType) {
        self.photoEmotionSubject.accept(emotionType)
    }

    func handleCropImageBarButtonItem() {
        self.pushScreenSubject.accept(.cropImage(image: imageSubject.value))
    }

    func handleUploadButton() {
        // TODO: アップロード処理
    }
}
