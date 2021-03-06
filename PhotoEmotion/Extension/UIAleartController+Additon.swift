//
//  UIAleartController+Additon.swift
//  PhotoEmotion
//
//  Created by Yoshitaka Tanaka on 2022/05/26.
//

import UIKit

extension UIAlertController {
    class func singleAlert(title: String, message: String, completion: (() -> Void)? = nil) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) -> Void in
            if let completion = completion {
                completion()
            }
        }))
        return alert
    }

    class func singleErrorAlert(message: String, completion: (() -> Void)? = nil) -> UIAlertController {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) -> Void in
            if let completion = completion {
                completion()
            }
        }))
        return alert
    }

    class func doubleSelectionAlert(title: String, message: String, otherTitle: String, completion: (() -> Void)? = nil) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: otherTitle, style: .default, handler: { (_) -> Void in
            if let completion = completion {
                completion()
            }
        }))
        return alert
    }

    class func doubleSelectionErrorAlert(message: String, otherTitle: String, completion: (() -> Void)? = nil) -> UIAlertController {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: otherTitle, style: .default, handler: { (_) -> Void in
            if let completion = completion {
                completion()
            }
        }))
        return alert
    }
}
