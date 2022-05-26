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

    private var photoListSubject = BehaviorRelay<[PhotoItem]>(value: [])
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
        return Completable.create { completable in
            // TODO: データ取得処理を追加
            completable(.completed) as! Disposable
        }
    }
}
