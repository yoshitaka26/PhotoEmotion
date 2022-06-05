//
//  ListViewModel.swift
//  PhotoEmotion
//
//  Created by Yoshitaka Tanaka on 2022/05/26.
//

import RxSwift
import RxCocoa
import PINRemoteImage

final class ListViewModel {

    private(set) var isLoading = BehaviorRelay<Bool>(value: false)
    private(set) var viewWillAppear = PublishRelay<Void>()

    private var photoListSubject = BehaviorRelay<[PhotoItem]>(value: [])
    var photoList: Driver<[PhotoItem]> {
        return photoListSubject.asDriver(onErrorJustReturn: [])
    }
    private(set) var galleryImages = BehaviorRelay<[UIImage]>(value: [])

    private var pushScreenSubject = PublishRelay<Screen>()
    var pushScreen: Driver<Screen> {
        return pushScreenSubject.asDriver(onErrorJustReturn: .other)
    }

    private var presentScreenSubject = PublishRelay<Screen>()
    var presentScreen: Driver<Screen> {
        return presentScreenSubject.asDriver(onErrorJustReturn: .other)
    }

    private let disposeBag = DisposeBag()
    private let listType: EmotionType

    init(listType: EmotionType) {
        self.listType = listType
        subscribe()
    }

    private func subscribe() {
        viewWillAppear.subscribe(onNext: { [unowned self] _ in
            self.fetchData()
                .subscribe()
                .disposed(by: disposeBag)
        })
        .disposed(by: disposeBag)
    }

    private func fetchData() -> Completable {
        return PhotoFirebaseRepository.fetch(emotionType: listType)
            .do(
                onSuccess: { [weak self] photoItems in
                    guard let self = self else { return }
                    self.photoListSubject.accept(photoItems)
                    photoItems.forEach {
                        self.prefetchImages(url: URL(string: $0.photoURL)!)
                    }
                },
                onError: { [weak self] error in
                    guard let self = self else { return }
                    self.presentScreenSubject
                        .accept(.errorAlert(message: R.string.localizable.error_data_fetch_failed()))
                    print(error.localizedDescription)
                }
            )
            .map { _ in }
            .asCompletable()
    }

    private func prefetchImages(url: URL) {
        _ = PINRemoteImageManager.shared().downloadImage(with: url) { [weak self] result in
            guard let self = self, let image = result.image else { return }
            var photoList = self.galleryImages.value
            photoList.append(image)
            self.galleryImages.accept(photoList)
        }
    }
}

extension ListViewModel {
    func handleCollectionCellSelected(index: Int) {
        presentScreenSubject.accept(.galleryView(index: index))
    }
}
