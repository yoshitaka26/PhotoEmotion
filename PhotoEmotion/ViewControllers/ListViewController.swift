//
//  ListViewController.swift
//  PhotoEmotion
//
//  Created by Yoshitaka Tanaka on 2022/05/26.
//

import UIKit
import RxSwift
import RxCocoa
import ImageViewer
import PINRemoteImage

class ListViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            let layout = UICollectionViewFlowLayout()
            layout.minimumInteritemSpacing = 2
            layout.minimumLineSpacing = 2
            layout.sectionInset = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
            collectionView.collectionViewLayout = layout

            collectionView.register(R.nib.photoCollectionViewCell)

            collectionView.rx
                .setDelegate(self)
                .disposed(by: disposeBag)

            viewModel.photoList
                .drive(collectionView.rx.items) { collectionView, row, element in
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.nib.photoCollectionViewCell, for: IndexPath(row: row, section: 0)) as! PhotoCollectionViewCell
                    cell.render(photoItem: element)
                    return cell
                }
                .disposed(by: disposeBag)

            collectionView.rx.itemSelected
                .subscribe(onNext: { [unowned self] indexPath in
                    self.collectionView.deselectItem(at: indexPath, animated: true)
                    self.viewModel.handleCollectionCellSelected(index: indexPath.row)
                })
                .disposed(by: disposeBag)
        }
    }
    private let disposeBag = DisposeBag()
    private var viewModel: ListViewModel!
    private var listType: EmotionType?

    static func make(emotionType: EmotionType) -> ListViewController {
        let viewController = R.storyboard
            .listViewController
            .instantiateInitialViewController()!
        viewController.listType = emotionType
        viewController.viewModel = ListViewModel(listType: emotionType)
        return viewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        navigationItem.title = listType?.titleText
    }

    private func bind() {
        rx.viewWillAppear
            .bind(to: viewModel.viewWillAppear)
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
    }
}

extension ListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 10.0) / 3
        return CGSize(width: width, height: width)
    }
}

extension ListViewController: GalleryItemsDataSource {
    func itemCount() -> Int {
        return self.viewModel.photoListSubject.value.count
    }

    func provideGalleryItem(_ index: Int) -> GalleryItem {
        return GalleryItem.image { [weak self] imageCompletion in
            guard let self = self else { return }
            _ = PINRemoteImageManager.shared().downloadImage(with: URL(string: self.viewModel.photoListSubject.value[index].photoURL)!) { result in
                guard let image = result.image else { return }
                imageCompletion(image)
            }
        }
    }
}
