//
//  ListViewModel.swift
//  PhotoEmotion
//
//  Created by Yoshitaka Tanaka on 2022/05/26.
//

import RxSwift
import RxCocoa

final class ListViewModel {

    private(set) var isLoading = BehaviorRelay<Bool>(value: false)
    private(set) var viewWillAppear = PublishRelay<Void>()

    var photoListSubject = BehaviorRelay<[PhotoItem]>(value: [])
    var photoList: Driver<[PhotoItem]> {
        return photoListSubject.asDriver(onErrorJustReturn: [])
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
    private let listType: EmotionType
    private let photoFirebaseRepository: PhotoFirebaseRepositoryable

    convenience init(listType: EmotionType) {
        self.init(listType: listType, photoFirebaseRepository: PhotoFirebaseRepository.shared)
    }

    init(listType: EmotionType, photoFirebaseRepository: PhotoFirebaseRepositoryable) {
        self.photoFirebaseRepository = photoFirebaseRepository
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
        return photoFirebaseRepository.fetch(emotionType: listType)
            .do(
                onSuccess: { [weak self] photoItems in
                    guard let self = self else { return }
                    self.photoListSubject.accept(photoItems)
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
}

extension ListViewModel {
    func handleCollectionCellSelected(index: Int) {
        presentScreenSubject.accept(.galleryView(index: index))
    }
}
