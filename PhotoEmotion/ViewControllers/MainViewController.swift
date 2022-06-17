//
//  MainViewController.swift
//  PhotoEmotion
//
//  Created by Yoshitaka Tanaka on 2022/05/24.
//

import UIKit
import RxSwift
import RxCocoa
import PKHUD
import ImageViewer

protocol ListTableDelegate: AnyObject {
    func headerButtonPressed(_ emotionType: EmotionType)
    func collectionImagePressed(_ photoItem: PhotoItem)
}

final class MainViewController: UIViewController {
    @IBOutlet private weak var settingBarButtonItem: UIBarButtonItem!
    @IBOutlet private weak var addPhotoBarButtonItem: UIBarButtonItem!

    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.registerHeaderFooterView(R.nib.emotionTitleHeaderTableViewCell)
            tableView.register(R.nib.emotionContentTableViewCell)
            tableView.tableFooterView = UIView()

            tableView.rx
                .setDelegate(self)
                .disposed(by: disposeBag)

            tableView.rx
                .setDataSource(self)
                .disposed(by: disposeBag)

            viewModel.emotionListSubject
                .subscribe(onNext: { [weak self] _ in
                    DispatchQueue.main.async {
                        self?.tableView.reloadData()
                    }
                })
                .disposed(by: disposeBag)
        }
    }

    private var isLoading: Bool = false {
        didSet {
            self.isLoading ? HUD.show(.progress) : HUD.hide()
        }
    }

    private let disposeBag = DisposeBag()
    private let viewModel: MainViewModelable = MainViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }

    private func bind() {
        rx.viewWillAppear
            .bind(to: viewModel.viewWillAppear)
            .disposed(by: disposeBag)

        viewModel.isLoading
            .subscribe(onNext: { [weak self] in
                self?.isLoading = $0
            })
            .disposed(by: disposeBag)

        viewModel.presentScreen
            .drive(onNext: { [unowned self] screen in
                switch screen {
                case .galleryView(let index):
                    let viewController = GalleryViewController(startIndex: index, itemsDataSource: self, configuration: [ .deleteButtonMode(.none), .thumbnailsButtonMode(.none)])
                    self.presentImageGallery(viewController)
                default:
                    self.presentScreen(screen)
                }
            })
            .disposed(by: disposeBag)
        viewModel.pushScreen
            .drive(onNext: { [unowned self] screen in
                self.navigationController?.pushScreen(screen)
            })
            .disposed(by: disposeBag)

        settingBarButtonItem.rx.tap
            .subscribe(onNext: { [unowned self] _ in
                self.viewModel.handleSettingBarButtonItem()
            })
            .disposed(by: disposeBag)

        addPhotoBarButtonItem.rx.tap
            .subscribe(onNext: { [unowned self] _ in
                self.viewModel.handleAddPhotoBarButtonItem()
            })
            .disposed(by: disposeBag)
    }
}

extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return EmotionContentTableViewCell.defaultHeight(tableView)
    }
}

// swiftlint:disable:next force_unwrapping
extension MainViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.emotionListSubject.value.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: R.reuseIdentifier.emotionTitleHeaderTableViewCell)!
        let emotionListContents = viewModel.emotionListSubject.value[section]
        header.render(emotionListContents: emotionListContents)
        header.delegate = self
        return header
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.emotionContentTableViewCell, for: indexPath)!
        let emotionListContents = viewModel.emotionListSubject.value[indexPath.section]
        cell.render(emotionListContents: emotionListContents)
        cell.delegate = self
        return cell
    }
}
// swiftlint:disable:previous force_unwrapping

extension MainViewController: ListTableDelegate {
    func headerButtonPressed(_ emotionType: EmotionType) {
        viewModel.handleListTableButton(emotionType: emotionType)
    }

    func collectionImagePressed(_ photoItem: PhotoItem) {
        viewModel.handleCollectionCellImage(photoItem)
    }
}

extension MainViewController: GalleryItemsDataSource {
    func itemCount() -> Int {
        return viewModel.galleryImage.value != nil ? 1 : 0
    }

    func provideGalleryItem(_ index: Int) -> GalleryItem {
        return GalleryItem.image { $0(self.viewModel.galleryImage.value) }
    }
}
