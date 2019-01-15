//
//  UITabBarController+Presentation.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2019-01-13.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Flow
import Foundation
import Presentation
import UIKit

protocol Tabable {
    func tabBarItem() -> UITabBarItem
}

extension UITabBarController {
    // swiftlint:disable identifier_name
    func presentTabs<
        A: Presentable & Tabable,
        AMatter: UIViewController,
        B: Presentable & Tabable,
        BMatter: UIViewController
    >(
        _ a: Presentation<A>,
        _ b: Presentation<B>
    ) -> Disposable where
        A.Matter == AMatter,
        A.Result == Disposable,
        B.Matter == BMatter,
        B.Result == Disposable {
        let bag = DisposeBag()

        let aMaterialized = a.presentable.materialize()
        let bMaterialized = b.presentable.materialize()

        bag += a.transform(aMaterialized.1)
        bag += b.transform(bMaterialized.1)

        let aViewController = aMaterialized.0.embededInNavigationController(a.options)
        let bViewController = bMaterialized.0.embededInNavigationController(b.options)

        a.configure(aMaterialized.0, bag)
        b.configure(bMaterialized.0, bag)

        viewControllers = [aViewController, bViewController]

        if let navigationController = aViewController as? UINavigationController {
            navigationController.tabBarItem = a.presentable.tabBarItem()
        }

        if let navigationController = bViewController as? UINavigationController {
            navigationController.tabBarItem = b.presentable.tabBarItem()
        }

        return bag
    }

    // swiftlint:enable identifier_name
}
