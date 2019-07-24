//
//  ScreenShots.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-07-22.
//

import Apollo
import Flow
import Form
import Presentation
import SnapshotTesting
import UIKit
import XCTest

class ScreenShots: SnapShotTestCase {
    func testDashboard() {
        let dashboard = Dashboard(
            remoteConfig: RemoteConfigContainer()
        )

        let tabBarController = UITabBarController()

        let dashboardPresentation = Presentation(
            dashboard,
            style: .default,
            options: [.defaults, .prefersLargeTitles(true)]
        )

        bag += tabBarController.presentTabs(dashboardPresentation)

        waitForQuery(DashboardQuery()) {
            assertSnapshot(matching: tabBarController, as: .image(on: .iPhoneSe))
            assertSnapshot(matching: tabBarController, as: .image(on: .iPhoneX))
            assertSnapshot(matching: tabBarController, as: .image(on: .iPhone8))
            assertSnapshot(matching: tabBarController, as: .image(on: .iPadPro10_5))
        }
    }
}