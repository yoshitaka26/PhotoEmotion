//
//  PhotoCollectionViewCell.swift
//  PhotoEmotion
//
//  Created by Yoshitaka Tanaka on 2022/05/25.
//

import UIKit
import RxSwift
import RxCocoa
import PINRemoteImage

class PhotoCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var photoImageView: UIImageView! {
        didSet {
            photoItemSubject.subscribe(onNext: { [unowned self] photoItem in
                self.photoImageView.pin_setImage(from: URL(string: photoItem.photoURL))
            }).disposed(by: disposeBag)
        }
    }
    private let disposeBag = DisposeBag()
    private let photoItemSubject = PublishRelay<PhotoItem>()
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func render(photoItem: PhotoItem) {
        photoItemSubject.accept(photoItem)
    }
}
