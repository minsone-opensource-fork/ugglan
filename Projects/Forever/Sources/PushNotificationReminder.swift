//
//  PushNotificationReminder.swift
//  Forever
//
//  Created by Sam Pettersson on 2020-06-22.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Foundation
import Flow
import hCoreUI
import hCore
import Presentation
import UIKit

struct PushNotificationReminder {}

extension PushNotificationReminder: Conditional, Presentable {
    enum PushNotificationReminderError: Error {
        case skipped
        case failed
    }
    
    func condition() -> Bool {
        !UIApplication.shared.isRegisteredForRemoteNotifications
    }
    
    func materialize() -> (UIViewController, Future<Void>) {
        let viewController = UIViewController()
        let bag = DisposeBag()
        
        let skipBarButton = UIBarButtonItem(title: L10n.NavBar.skip, style: .destructive)
        viewController.navigationItem.rightBarButtonItem = skipBarButton

        let imageTextAction = ImageTextAction<Void>(
            image: .init(image: Asset.pushNotificationReminderIllustration.image),
            title: L10n.ReferralsAllowPushNotificationSheet.headline,
            body: L10n.ReferralsAllowPushNotificationSheet.body,
            actions: [
                (
                    (),
                    Button(
                        title: L10n.ReferralsAllowPushNotificationSheet.Allow.button,
                        type: .standard(
                            backgroundColor: .brand(.primaryButtonBackgroundColor),
                            textColor: .brand(.primaryButtonTextColor)
                        )
                    )
                ),
            ],
            showLogo: false
        )

        return (viewController, Future { completion in
            bag += viewController.install(imageTextAction).onValue {
                let center = UNUserNotificationCenter.current()
                center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                    DispatchQueue.main.async {
                        if error != nil {
                            completion(.failure(PushNotificationReminderError.failed))
                        } else {
                            completion(.success)
                        }
                    }
                }
            }
            
            bag += skipBarButton.onValue {
                completion(.failure(PushNotificationReminderError.skipped))
            }

            return DelayedDisposer(bag, delay: 2)
        })
    }
}