//
//  UIViewController+Router.swift
//  PhotoEmotion
//
//  Created by Yoshitaka Tanaka on 2022/05/26.
//

import UIKit

extension UIViewController {
    func presentScreen(_ screen: Screen) {
        switch screen {
        case .errorAlert(let message):
            let alert = UIAlertController.singleErrorAlert(message: message)
            present(alert, animated: true, completion: nil)
        default: break
        }
    }
}
