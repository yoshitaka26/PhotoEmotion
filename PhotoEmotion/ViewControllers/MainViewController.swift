//
//  MainViewController.swift
//  PhotoEmotion
//
//  Created by Yoshitaka Tanaka on 2022/05/24.
//

import UIKit
import RxSwift
import RxCocoa

protocol ListTableDelegate: AnyObject {
    func headerButtonPressed(_ emotionType: EmotionType)
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
        }
    }
    private let disposeBag = DisposeBag()
    private let viewModel = MainViewModel()

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

extension MainViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.emotionListSubject.value.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: R.reuseIdentifier.emotionTitleHeaderTableViewCell) as! EmotionTitleHeaderTableViewCell
        let emotionListContents = viewModel.emotionListSubject.value[section]
        header.render(emotionListContents: emotionListContents)
        header.delegate = self
        return header
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.emotionContentTableViewCell, for: indexPath) as! EmotionContentTableViewCell
        let emotionListContents = viewModel.emotionListSubject.value[indexPath.section]
        cell.render(emotionListContents: emotionListContents)
        return cell
    }
}

extension MainViewController: ListTableDelegate {
    func headerButtonPressed(_ emotionType: EmotionType) {
        viewModel.handleListTableButton(emotionType: emotionType)
    }
}
