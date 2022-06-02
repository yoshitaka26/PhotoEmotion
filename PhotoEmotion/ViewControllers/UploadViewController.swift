//
//  UploadViewController.swift
//  PhotoEmotion
//
//  Created by Yoshitaka Tanaka on 2022/05/27.
//

import UIKit
import PhotosUI
import RxSwift
import RxCocoa
import CropViewController
import PKHUD

class UploadViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    private lazy var picker: PHPickerViewController = {
        var configuration = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
        configuration.filter = .images
        configuration.selectionLimit = 1
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        return picker
    }()

    @IBOutlet private weak var imageButton: UIButton!
    @IBOutlet private weak var happyButton: UIButton!
    @IBOutlet private weak var sadButton: UIButton!
    @IBOutlet private weak var angryButton: UIButton!
    @IBOutlet private weak var scarredButton: UIButton!
    @IBOutlet private weak var uploadButton: UIButton!
    @IBOutlet private weak var corpImageBarButtonItem: UIBarButtonItem!

    private var isLoading: Bool = false {
        didSet {
            self.isLoading ? HUD.show(.progress) : HUD.hide()
        }
    }

    private let disposeBag = DisposeBag()
    private var viewModel: UploadViewModel!

    static func make() -> UploadViewController {
        let viewController = R.storyboard
            .uploadViewController
            .instantiateInitialViewController()!
        viewController.viewModel = UploadViewModel()
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

        viewModel.isLoading
            .subscribe(onNext: { [weak self] in
                self?.isLoading = $0
            })
            .disposed(by: disposeBag)

        viewModel.uploadResult
            .subscribe(onNext: { [weak self] result in
                switch result {
                case .success(let message):
                    HUD.show(.labeledSuccess(title: message, subtitle: nil))
                    HUD.hide(afterDelay: 1.5) { _ in
                        self?.viewModel.resetImage()
                    }
                case .failure(let error):
                    HUD.show(.labeledError(title: error.message, subtitle: nil))
                    HUD.hide(afterDelay: 2.0)
                }
            })
            .disposed(by: disposeBag)

        viewModel.presentScreen
            .drive(onNext: { [unowned self] screen in
                self.presentScreen(screen)
            })
            .disposed(by: disposeBag)

        viewModel.pushScreen
            .drive(onNext: { [unowned self] screen in
                switch screen {
                case .cropImage(let image):
                    let cropViewController = CropViewController(croppingStyle: .default, image: image)
                    cropViewController.delegate = self
                    self.navigationController?.pushViewController(cropViewController, animated: true)
                default:
                    self.navigationController?.pushScreen(screen)
                }
            })
            .disposed(by: disposeBag)

        viewModel.photoImage
            .drive(onNext: { [unowned self] image in
                self.imageView.image = image
            })
            .disposed(by: disposeBag)

        viewModel.photoEmotion
            .drive(onNext: { [unowned self] emotionType in
                self.clearEmotionButtons()
                switch emotionType {
                case .happy:
                    self.happyButton.backgroundColor = .systemOrange
                case .sad:
                    self.sadButton.backgroundColor = .systemBlue
                case .angry:
                    self.angryButton.backgroundColor = .systemRed
                case .scarred:
                    self.scarredButton.backgroundColor = .systemPurple
                case .other:
                    return
                }
            })
            .disposed(by: disposeBag)

        imageButton.rx.tap
            .subscribe(onNext: { [unowned self] _ in
                self.present(self.picker, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)

        happyButton.rx.tap
            .subscribe(onNext: { [unowned self] _ in
                self.viewModel.handleEmotionButton(emotionType: .happy)
            })
            .disposed(by: disposeBag)

        sadButton.rx.tap
            .subscribe(onNext: { [unowned self] _ in
                self.viewModel.handleEmotionButton(emotionType: .sad)
            })
            .disposed(by: disposeBag)

        angryButton.rx.tap
            .subscribe(onNext: { [unowned self] _ in
                self.viewModel.handleEmotionButton(emotionType: .angry)
            })
            .disposed(by: disposeBag)

        scarredButton.rx.tap
            .subscribe(onNext: { [unowned self] _ in
                self.viewModel.handleEmotionButton(emotionType: .scarred)
            })
            .disposed(by: disposeBag)

        viewModel.cropImageButtonEnabled
            .drive(onNext: { [unowned self] enabled in
                self.corpImageBarButtonItem.isEnabled = enabled
            })
            .disposed(by: disposeBag)

        corpImageBarButtonItem.rx.tap
            .subscribe(onNext: { [unowned self] _ in
                self.viewModel.handleCropImageBarButtonItem()
            })
            .disposed(by: disposeBag)

        viewModel.uploadImageButtonEnabled
            .drive(onNext: { [unowned self] enabled in
                self.uploadButton.isEnabled = enabled
            })
            .disposed(by: disposeBag)

        uploadButton.rx.tap
            .subscribe(onNext: { [unowned self] _ in
                self.viewModel.handleUploadButton()
            })
            .disposed(by: disposeBag)
    }

    private func clearEmotionButtons() {
        happyButton.backgroundColor = .clear
        sadButton.backgroundColor = .clear
        angryButton.backgroundColor = .clear
        scarredButton.backgroundColor = .clear
    }

    private func cropPhoto(image: UIImage) {
        let cropViewController = CropViewController(croppingStyle: .default, image: image)
        cropViewController.delegate = self
        present(cropViewController, animated: true)
    }
}

extension UploadViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        results.forEach { result in
            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] item, error in
                if let error = error {
                    debugPrint(error.localizedDescription)
                } else if let image = item as? UIImage {
                    self?.viewModel.handleImagePicker(selectedImage: image)
                }
            }
        }
        dismiss(animated: true)
    }
}

extension UploadViewController: CropViewControllerDelegate {
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        viewModel.handleDidCropToImage(croppedImage: image)
        self.navigationController?.popViewController(animated: true)
    }
}
