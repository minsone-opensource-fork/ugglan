//
//  AppDelegate.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-11-07.
//  Copyright © 2018 Sam Pettersson. All rights reserved.
//

import Apollo
import Flow
import Presentation
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    let bag = DisposeBag()
    let navigationController = UINavigationController()
    let window = UIWindow(frame: UIScreen.main.bounds)

    func application(
        _: UIApplication,
        didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        window.rootViewController = navigationController

        let marketing = Marketing()

        let compose = Presentation<Marketing>(marketing, style: .marketing, options: .unanimated) { (_: Marketing.Matter, _: DisposeBag) -> Void in
            return ()
        }

        HedvigApolloClient.initClient().onValue { _ in
            self.bag += self.navigationController.present(compose)
            self.window.makeKeyAndVisible()
        }

        return true
    }
}
