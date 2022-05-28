//
//  UINavigationController+Router.swift
//  PhotoEmotion
//
//  Created by Yoshitaka Tanaka on 2022/05/26.
//

import UIKit

extension UINavigationController {
    func pushScreen(_ screen: Screen) {
        switch screen {
        case .list(let emotionType):
            let viewController = ListViewController.make(emotionType: emotionType)
            pushViewController(viewController, animated: true)
        case .setting:
            // TODO: 設定画面へ
            break
        case .upload:
            let viewController = UploadViewController.make()
            pushViewController(viewController, animated: true)
        default:
            break
        }
    }
}
