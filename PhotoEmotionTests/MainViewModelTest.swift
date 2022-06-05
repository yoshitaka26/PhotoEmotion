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
}
