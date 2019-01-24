//
//  InsuranceCertificate.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2019-01-17.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Flow
import Form
import Foundation
import Presentation
import SafariServices
import UIKit

struct InsuranceCertificate {
    let certificateUrl: ReadWriteSignal<String?>
}

extension InsuranceCertificate: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let bag = DisposeBag()

        let viewController = UIViewController()
        viewController.title = String.translation(.MY_INSURANCE_CERTIFICATE_TITLE)

        let webView = UIWebView()
        webView.backgroundColor = .offWhite

        bag += webView.didFinishLoadSignal.onValue {
            webView.scrollView.contentOffset = CGPoint(x: 0, y: -webView.layoutMargins.top)
        }

        bag += certificateUrl.atOnce().onValue { value in
            guard let value = value else { return }
            let url = URL(string: value)!
            webView.loadRequest(URLRequest(url: url))
        }

        viewController.view = webView

        bag += viewController.navigationItem.addItem(
            UIBarButtonItem(system: .action),
            position: .right
        ).withLatestFrom(certificateUrl).onValueDisposePrevious { _, value -> Disposable? in
            guard let value = value else { return NilDisposer() }

            let activityView = ActivityView(
                activityItems: [value],
                applicationActivities: nil
            )

            let activityViewPresentation = Presentation(
                activityView,
                style: .activityView,
                options: .defaults
            )

            return viewController.present(activityViewPresentation).disposable
        }

        return (viewController, bag)
    }
}