//
//  MainViewModel.swift
//  PhotoEmotion
//
//  Created by Yoshitaka Tanaka on 2022/05/26.
//

import RxSwift
import RxCocoa
import FirebaseFirestore
import PINRemoteImage

protocol MainViewModelable {
    var isLoading: BehaviorRelay<Bool> { get }
    var viewWillAppear: PublishRelay<Void> { get }
    var emotionListSubject: BehaviorRelay<[EmotionListContents]> { get }
    var galleryImage: BehaviorRelay<UIImage?> { get }
    var pushScreen: Driver<Screen> { get }
    var presentScreen: Driver<Screen> { get }
    func handleSettingBarButtonItem()
    func handleAddPhotoBarButtonItem()
    func handleListTableButton(emotionType: EmotionType)
    func handleCollectionCellImage(_ photoItem: PhotoItem)
}

final class MainViewModel {

    private(set) var isLoading = BehaviorRelay<Bool>(value: false)
    private(set) var viewWillAppear = PublishRelay<Void>()

    private var apiAccessCount = BehaviorRelay<Int>(value: 0)

    private(set) var emotionListSubject = BehaviorRelay<[EmotionListContents]>(value: [])
    private(set) var galleryImage = BehaviorRelay<UIImage?>(value: nil)

    private var pushScreenSubject = PublishRelay<Screen>()
    var pushScreen: Driver<Screen> {
        return pushScreenSubject.asDriver(onErrorJustReturn: .other)
    }

    private var presentScreenSubject = PublishRelay<Screen>()
    var presentScreen: Driver<Screen> {
        return presentScreenSubject.asDriver(onErrorJustReturn: .other)
    }

    private let disposeBag = DisposeBag()
    private let photoFirebaseRepository: PhotoFirebaseRepositoryable

    convenience init() {
        self.init(photoFirebaseRepository: PhotoFirebaseRepository.shared)
    }

    init(photoFirebaseRepository: PhotoFirebaseRepositoryable) {
        self.photoFirebaseRepository = photoFirebaseRepository
        subscribe()
    }

    private func subscribe() {
        viewWillAppear
            .subscribe(onNext: { [unowned self] _ in
            EmotionType.allCases.forEach { emotionType in
                self.fetchData(emotionType: emotionType)
                    .subscribe()
                    .disposed(by: disposeBag)
            }
        })
        .disposed(by: disposeBag)

        apiAccessCount
            .subscribe(onNext: { [unowned self] count in
                self.isLoading.accept(count != 0)
        })
        .disposed(by: disposeBag)
    }

    private func fetchData(emotionType: EmotionType) -> Completable {
        apiAccessCount.accept(apiAccessCount.value + 1)
        return photoFirebaseRepository.fetch(emotionType: emotionType)
            .do(
                onSuccess: { [weak self] photoItems in
                    guard let self = self else { return }
                    self.apiAccessCount.accept(self.apiAccessCount.value - 1)
                    guard !photoItems.isEmpty else { return }
                    var contents = self.emotionListSubject.value
                    if !contents.contains(where: { $0.type == emotionType }) {
                        contents.append(EmotionListContents.init(type: emotionType, contents: Array(photoItems.prefix(6))))
                    } else {
                        contents = contents.map { emotionList in
                            if emotionList.type == emotionType {
                                return EmotionListContents.init(type: emotionList.type, contents: Array(photoItems.prefix(6)))
                            } else {
                                return emotionList
                            }
                        }
                    }
                    self.emotionListSubject.accept(contents.sorted(by: <))
                },
                onError: { [weak self] error in
                    guard let self = self else { return }
                    self.apiAccessCount.accept(self.apiAccessCount.value - 1)
                    self.presentScreenSubject
                        .accept(.errorAlert(message: R.string.localizable.error_data_fetch_failed()))
                    print(error.localizedDescription)
                }
            )
            .map { _ in }
            .asCompletable()
    }
}

extension MainViewModel: MainViewModelable {
    func handleSettingBarButtonItem() {
        pushScreenSubject.accept(.setting)
    }

    func handleAddPhotoBarButtonItem() {
        pushScreenSubject.accept(.upload)
    }

    func handleListTableButton(emotionType: EmotionType) {
        pushScreenSubject.accept(.list(emotionType: emotionType))
    }

    func handleCollectionCellImage(_ photoItem: PhotoItem) {
        _ = PINRemoteImageManager.shared().downloadImage(with: URL(string: photoItem.photoURL)!) { [weak self] result in
            guard let self = self, let image = result.image else { return }
            self.galleryImage.accept(image)
            self.presentScreenSubject.accept(.galleryView(index: 0))
        }
    }
}
