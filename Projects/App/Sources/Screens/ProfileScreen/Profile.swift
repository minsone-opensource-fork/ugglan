//
//  Profile.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2019-01-02.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Apollo
import Flow
import Form
import Presentation
import UIKit

struct Profile {
    @Inject var client: ApolloClient
}

extension Profile: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let bag = DisposeBag()

        let viewController = UIViewController()
        viewController.displayableTitle = L10n.profileTitle
        viewController.installChatButton()

        let form = FormView()

        let profileSection = ProfileSection(
            presentingViewController: viewController
        )

        bag += form.append(profileSection)

        bag += form.append(Spacing(height: 20))

        let otherSection = OtherSection(
            presentingViewController: viewController
        )

        bag += form.append(otherSection)

        bag += form.append(Spacing(height: 20))

        let logoutSection = LogoutSection(
            presentingViewController: viewController
        )

        bag += form.append(logoutSection)

        let query = ProfileQuery()

        bag += client.watch(query: query)
            .compactMap { $0.data }
            .bindTo(profileSection.dataSignal)

        bag += viewController.install(form) { scrollView in
            let refreshControl = UIRefreshControl()
            bag += self.client.refetchOnRefresh(query: query, refreshControl: refreshControl)

            scrollView.refreshControl = refreshControl
            bag += scrollView.chainAllControlResponders(shouldLoop: true, returnKey: .next)
        }

        return (viewController, bag)
    }
}

extension Profile: Tabable {
    func tabBarItem() -> UITabBarItem {
        return UITabBarItem(
            title: L10n.tabProfileTitle,
            image: Asset.profileTab.image,
            selectedImage: nil
        )
    }
}