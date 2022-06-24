//
//  ListViewModelTest.swift
//  PhotoEmotionTests
//
//  Created by Yoshitaka Tanaka on 2022/06/17.
//

import XCTest
import RxSwift
import RxCocoa
import RxTest

@testable import PhotoEmotion

class ListViewModelTest: XCTestCase {
    func testhandleCollectionCellSelected() {
        let disposeBag = DisposeBag()
        let scheduler = TestScheduler(initialClock: 0)
        let photoFirebaseRepository = MockPhotoFirebaseRepository(result: .success, emotionType: .angry)
        let viewModel = ListViewModel(listType: .angry, photoFirebaseRepository: photoFirebaseRepository)
        let tapCellIndex: Int = 1
        scheduler.scheduleAt(100) {
            viewModel.presentScreen
                .drive(onNext: {
                    XCTAssertTrue($0 == .galleryView(index: tapCellIndex))
                })
                .disposed(by: disposeBag)
        }
        scheduler.scheduleAt(200) {
            viewModel.handleCollectionCellSelected(index: tapCellIndex)
        }
        scheduler.start()
    }

    func testFetchImageWithSuccess() {
        let disposeBag = DisposeBag()
        let scheduler = TestScheduler(initialClock: 0)
        let photoFirebaseRepository = MockPhotoFirebaseRepository(result: .success)
        let viewModel = ListViewModel(listType: .scared, photoFirebaseRepository: photoFirebaseRepository)
        scheduler.scheduleAt(100) {
            viewModel.viewWillAppear.accept(())
        }
        scheduler.scheduleAt(200) {
            viewModel.photoList
                .drive(onNext: {
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
        let viewModel = ListViewModel(listType: .scared, photoFirebaseRepository: photoFirebaseRepository)
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
