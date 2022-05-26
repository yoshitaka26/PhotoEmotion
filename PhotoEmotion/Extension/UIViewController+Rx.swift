//
//  UIViewController+Rx.swift
//  PhotoEmotion
//
//  Created by Yoshitaka Tanaka on 2022/05/26.
//

import UIKit
import RxSwift
import RxCocoa

public extension Reactive where Base: UIViewController {
    private func controlEvent(for selector: Selector) -> ControlEvent<Void> {
        return ControlEvent(events: sentMessage(selector).map { _ in })
    }

    var viewWillAppear: ControlEvent<Void> {
        return controlEvent(for: #selector(UIViewController.viewWillAppear))
    }

    var viewDidAppear: ControlEvent<Void> {
        return controlEvent(for: #selector(UIViewController.viewDidAppear))
    }

    var viewWillDisappear: ControlEvent<Void> {
        return controlEvent(for: #selector(UIViewController.viewWillDisappear))
    }

    var viewDidDisappear: ControlEvent<Void> {
        return controlEvent(for: #selector(UIViewController.viewDidDisappear))
    }

    var viewWillLayoutSubviews: ControlEvent<Void> {
        return controlEvent(for: #selector(UIViewController.viewWillLayoutSubviews))
    }

    var viewDidLayoutSubviews: ControlEvent<Void> {
        return controlEvent(for: #selector(UIViewController.viewDidLayoutSubviews))
    }

    var willMoveToParent: ControlEvent<Void> {
        return controlEvent(for: #selector(UIViewController.willMove(toParent:)))
    }

    var didMoveToParent: ControlEvent<Void> {
        return controlEvent(for: #selector(UIViewController.didMove(toParent:)))
    }

    var didReceiveMemoryWarning: ControlEvent<Void> {
        return controlEvent(for: #selector(UIViewController.didReceiveMemoryWarning))
    }
}
