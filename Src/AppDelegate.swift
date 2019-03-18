//
//  AppDelegate.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-11-07.
//  Copyright © 2018 Sam Pettersson. All rights reserved.
//

import Apollo
import Disk
import Firebase
import FirebaseAnalytics
import FirebaseRemoteConfig
import Flow
import Form
import Presentation
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    let bag = DisposeBag()
    let navigationController = UINavigationController()
    let window = UIWindow(frame: UIScreen.main.bounds)
    private let applicationWillTerminateCallbacker = Callbacker<Void>()
    let applicationWillTerminateSignal: Signal<Void>

    override init() {
        applicationWillTerminateSignal = applicationWillTerminateCallbacker.signal()
        super.init()
    }

    func logout() {
        let token = AuthorizationToken(token: "")
        try? Disk.save(token, to: .applicationSupport, as: "authorization-token.json")

        window.rootViewController = navigationController

        presentMarketing()
    }

    func presentMarketing() {
        let marketing = Marketing()

        let marketingPresentation = Presentation(
            marketing,
            style: .marketing,
            options: .defaults
        ).onValue({ _ in
            let loggedIn = LoggedIn()
            self.bag += self.window.present(loggedIn, options: [], animated: true)
        })

        bag += navigationController.present(marketingPresentation)
    }

    func applicationWillTerminate(_: UIApplication) {
        applicationWillTerminateCallbacker.callAll()
    }

    func application(
        _: UIApplication,
        didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        FirebaseApp.configure()

        let remoteConfig = RemoteConfig.remoteConfig()
        let fetchDuration: TimeInterval = 0

        remoteConfig.fetch(withExpirationDuration: fetchDuration, completionHandler: { _, _ in
            remoteConfig.activateFetched()
        })

        window.backgroundColor = .offWhite
        window.rootViewController = navigationController
        viewControllerWasPresented = { viewController in
            let mirror = Mirror(reflecting: viewController)
            Analytics.setScreenName(
                viewController.debugPresentationTitle,
                screenClass: String(describing: mirror.subjectType)
            )

            if viewController.debugPresentationTitle == "LoggedIn" {
                Analytics.setUserProperty("true", forName: "isMember")
            }
        }
        alertActionWasPressed = { _, title in
            if let localizationKey = title.localizationKey?.toString() {
                Analytics.logEvent("alert_action_tap_\(localizationKey)", parameters: [:])
            }
        }

        let hasLoadedCallbacker = Callbacker<Void>()

        let launch = Launch(
            hasLoadedSignal: hasLoadedCallbacker.signal()
        )

        let launchPresentation = Presentation(
            launch,
            style: .modally(
                presentationStyle: .overCurrentContext,
                transitionStyle: .none,
                capturesStatusBarAppearance: true
            ),
            options: [.unanimated, .prefersNavigationBarHidden(true)]
        )

        bag += navigationController.present(launchPresentation)
        window.makeKeyAndVisible()

        let apolloEnvironment = HedvigApolloEnvironmentConfig(
            endpointURL: URL(string: "https://graphql.dev.hedvigit.com/graphql")!,
            wsEndpointURL: URL(string: "wss://graphql.dev.hedvigit.com/subscriptions")!
        )

        DefaultStyling.installCustom()

        let token = AuthorizationToken(token: "a8Za/PaA2jQqsg==.Lt9hKLFD8+oFBg==.hEprAa/drNxv5g==")
        try? Disk.save(token, to: .applicationSupport, as: "authorization-token.json")

        HedvigApolloClient.shared.initClient(environment: apolloEnvironment).delay(by: 0.5).onValue { client, store in
            HedvigApolloClient.shared.client = client
            HedvigApolloClient.shared.store = store
            HedvigApolloClient.shared.remoteConfig = remoteConfig

            self.presentMarketing()

            hasLoadedCallbacker.callAll()

            TranslationsRepo.fetch(client: client)
        }

        return true
    }
}
