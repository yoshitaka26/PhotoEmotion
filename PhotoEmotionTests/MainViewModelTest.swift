//
//  MainViewModelTest.swift
//  PhotoEmotionTests
//
//  Created by Yoshitaka Tanaka on 2022/06/05.
//

import XCTest
import RxSwift
import RxCocoa
import RxTest

@testable import PhotoEmotion

class MainViewModelTest: XCTestCase {
    func testHandleAddPhotoBarButtonItem() {
        let disposeBag = DisposeBag()
        let scheduler = TestScheduler(initialClock: 0)
        let photoFirebaseRepository = MockPhotoFirebaseRepository(result: .success)
        let viewModel = MainViewModel(photoFirebaseRepository: photoFirebaseRepository)
        scheduler.scheduleAt(100) {
            viewModel.pushScreen
                .drive(onNext: {
                    XCTAssertTrue($0 == .upload)
                })
                .disposed(by: disposeBag)
        }
        scheduler.scheduleAt(200) {
            viewModel.handleAddPhotoBarButtonItem()
        }
        scheduler.start()
    }

    func testHandleListTableButton() {
        let disposeBag = DisposeBag()
        let scheduler = TestScheduler(initialClock: 0)
        let photoFirebaseRepository = MockPhotoFirebaseRepository(result: .success, emotionType: .sad)
        let viewModel = MainViewModel(photoFirebaseRepository: photoFirebaseRepository)
        scheduler.scheduleAt(100) {
            viewModel.pushScreen
                .drive(onNext: {
                    XCTAssertTrue($0 == .list(emotionType: .sad))
                })
                .disposed(by: disposeBag)
        }
        scheduler.scheduleAt(200) {
            viewModel.handleListTableButton(emotionType: .sad)
        }
        scheduler.start()
    }

    func testFetchImageWithSuccess() {
        let disposeBag = DisposeBag()
        let scheduler = TestScheduler(initialClock: 0)
        let photoFirebaseRepository = MockPhotoFirebaseRepository(result: .success)
        let viewModel = MainViewModel(photoFirebaseRepository: photoFirebaseRepository)
        scheduler.scheduleAt(100) {
            viewModel.viewWillAppear.accept(())
        }
        scheduler.scheduleAt(200) {
            viewModel.emotionListSubject
                .subscribe(onNext: {
                    XCTAssertTrue(!$0.isEmpty)
                })
                .disposed(by: disposeBag)
        }
        scheduler.start()
    }

    func testFetchImageWithFailure() {
        let disposeBag = DisposeBag()
        let scheduler = TestScheduler(initialClock: 0)
        let photoFirebaseRepository = MockPhotoFirebaseRepository(result: .failure)
        let viewModel = MainViewModel(photoFirebaseRepository: photoFirebaseRepository)
        scheduler.scheduleAt(100) {
            viewModel.presentScreen
                .drive(onNext: {
                    XCTAssertTrue($0 == .errorAlert(message: R.string.localizable.error_data_fetch_failed()))
                })
                .disposed(by: disposeBag)
        }
        scheduler.scheduleAt(200) {
            viewModel.viewWillAppear.accept(())
        }
        scheduler.start()
    }
}
