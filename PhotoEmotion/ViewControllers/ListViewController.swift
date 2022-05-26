//
//  ListViewController.swift
//  PhotoEmotion
//
//  Created by Yoshitaka Tanaka on 2022/05/26.
//

import UIKit
import RxSwift
import RxCocoa

class ListViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            let layout = UICollectionViewFlowLayout()
            layout.minimumInteritemSpacing = 5
            layout.minimumLineSpacing = 5
            layout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
            collectionView.collectionViewLayout = layout

            collectionView.register(R.nib.photoCollectionViewCell)

            collectionView.rx
                .setDelegate(self)
                .disposed(by: disposeBag)

            viewModel.photoList
                .drive(collectionView.rx.items) { [weak self] collectionView, row, element in
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.nib.photoCollectionViewCell, for: IndexPath(row: row, section: 0)) as! PhotoCollectionViewCell
                    cell.render(photoItem: element)
                    return cell
                }
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
    }
    
    private func bind() {
        rx.viewWillAppear
            .bind(to: viewModel.viewWillAppear)
            .disposed(by: disposeBag)

        viewModel.presentScreen
            .drive(onNext: { [unowned self] screen in
                self.presentScreen(screen)
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
        let width = collectionView.frame.width / 3
        return CGSize(width: width, height: width)
    }
}
