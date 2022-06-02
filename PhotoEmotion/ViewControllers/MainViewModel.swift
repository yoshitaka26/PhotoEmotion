//
//  MainViewModel.swift
//  PhotoEmotion
//
//  Created by Yoshitaka Tanaka on 2022/05/26.
//

import RxSwift
import RxCocoa
import FirebaseFirestore

final class MainViewModel {

    private(set) var isLoading = BehaviorRelay<Bool>(value: false)
    private(set) var viewWillAppear = PublishRelay<Void>()

    private var apiAccessCount = BehaviorRelay<Int>(value: 0)

    var emotionListSubject = BehaviorRelay<[EmotionListContents]>(value: [])

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
        return PhotoFirebaseRepository.fetch(emotionType: emotionType)
            .do(
                onSuccess: { [weak self] photoItems in
                    guard let self = self else { return }
                    self.apiAccessCount.accept(self.apiAccessCount.value - 1)
                    var contents = self.emotionListSubject.value
                    if !contents.contains(where: { $0.type == emotionType }) {
                        contents.append(EmotionListContents.init(type: emotionType, contents: photoItems))
                    } else {
                        contents = contents.map { emotionList in
                            if emotionList.type == emotionType {
                                return EmotionListContents.init(type: emotionList.type, contents: photoItems)
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

extension MainViewModel {
    func handleSettingBarButtonItem() {
        pushScreenSubject.accept(.setting)
    }

    func handleAddPhotoBarButtonItem() {
        pushScreenSubject.accept(.upload)
    }

    func handleListTableButton(emotionType: EmotionType) {
        pushScreenSubject.accept(.list(emotionType: emotionType))
    }
}
