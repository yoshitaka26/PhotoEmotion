//
//  EmotionTitleHeaderTableViewCell.swift
//  PhotoEmotion
//
//  Created by Yoshitaka Tanaka on 2022/05/25.
//

import UIKit
import RxSwift
import RxCocoa

class EmotionTitleHeaderTableViewCell: UITableViewHeaderFooterView {

    @IBOutlet weak var emotionLabel: UILabel! {
        didSet {
            emotionType
                .subscribe(onNext: { [unowned self] emotionType in
                    self.emotionLabel.text = emotionType.titleText
                })
                .disposed(by: disposeBag)
        }
    }
    @IBOutlet weak var pushListButton: UIButton! {
        didSet {
            pushListButton.rx.tap
                .subscribe(onNext: { [unowned self] _ in
                    self.delegate?.headerButtonPressed(emotionType.value)
                })
                .disposed(by: disposeBag)
        }
    }
    weak var delegate: ListTableDelegate?
    private let emotionType = BehaviorRelay<EmotionType>(value: .other)
    private let disposeBag = DisposeBag()
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func render(emotionListContents: EmotionListContents) {
        emotionType.accept(emotionListContents.type)
    }
}
