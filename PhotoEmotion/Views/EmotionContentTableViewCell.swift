//
//  EmotionContentTableViewCell.swift
//  PhotoEmotion
//
//  Created by Yoshitaka Tanaka on 2022/05/25.
//

import UIKit
import RxSwift
import RxCocoa

class EmotionContentTableViewCell: UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.register(R.nib.photoCollectionViewCell)

            collectionView.rx
                .setDelegate(self)
                .disposed(by: disposeBag)

            photoItems
                .drive(collectionView.rx.items) { collectionView, index, photoItem in
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.photoCollectionViewCell, for: IndexPath(row: index, section: 0))! // swiftlint:disable:this force_unwrapping
                    cell.render(photoItem: photoItem)
                    return cell
                }
                .disposed(by: disposeBag)

            collectionView.rx.itemSelected
                .subscribe(onNext: { [unowned self] indexPath in
                    self.collectionView.deselectItem(at: indexPath, animated: true)
                    self.delegate?.collectionImagePressed(self.photoItemsSubject.value[indexPath.row])
                })
                .disposed(by: disposeBag)
        }
    }
    private let photoItemsSubject = BehaviorRelay<[PhotoItem]>(value: [])
    var photoItems: Driver<[PhotoItem]> {
        return photoItemsSubject.asDriver(onErrorJustReturn: [])
    }
    weak var delegate: ListTableDelegate?
    private let disposeBag = DisposeBag()
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    class func defaultHeight(_ tableView: UITableView) -> CGFloat {
        return 80.0
    }
    func render(emotionListContents: EmotionListContents) {
        photoItemsSubject.accept(emotionListContents.contents)
    }
}

extension EmotionContentTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 75, height: 75)
    }
}
