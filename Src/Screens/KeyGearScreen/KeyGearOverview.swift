//
//  Stuff.swift
//  test
//
//  Created by Sam Pettersson on 2020-01-23.
//

import Apollo
import Flow
import Form
import Foundation
import Presentation
import UIKit
import WatchConnectivity

struct KeyGearOverview {
    @Inject var client: ApolloClient

    func autoAddDevices() {
        if WCSession.isSupported() {
            let bag = DisposeBag()
            let session = WCSession.default
            let coordinator = Coordinator { [unowned bag] in
                bag.dispose()
            }
            bag.hold(coordinator)
            session.delegate = coordinator

            session.activate()

            class Coordinator: NSObject, WCSessionDelegate {
                let onDone: () -> Void

                init(onDone: @escaping () -> Void) {
                    self.onDone = onDone
                }

                func session(_ session: WCSession, activationDidCompleteWith _: WCSessionActivationState, error _: Error?) {
                    if session.isPaired {
                        print("have an apple watch")
                    }

                    onDone()
                }

                func sessionDidBecomeInactive(_: WCSession) {}

                func sessionDidDeactivate(_: WCSession) {}
            }
        }
    }
}

extension KeyGearOverview: Presentable {
    class KeyGearOverviewViewController: UIViewController {
        override func viewWillAppear(_ animated: Bool) {
            navigationController?.setNavigationBarHidden(false, animated: animated)
        }
    }

    func materialize() -> (UIViewController, Disposable) {
        let bag = DisposeBag()
        let viewController = KeyGearOverviewViewController()
        viewController.title = String(key: .KEY_GEAR_TAB_TITLE)

        autoAddDevices()
        
        bag += viewController.install(KeyGearListCollection()) { collectionView in
            let refreshControl = UIRefreshControl()
                   bag += client.refetchOnRefresh(query: KeyGearItemsQuery(), refreshControl: refreshControl)
            
            collectionView.refreshControl = refreshControl
            
        }.onValue { result in
            switch result {
            case .add:
                viewController.present(AddKeyGearItem(), style: .modally()).onValue { id in
                    viewController.present(KeyGearItem(id: id), style: .default, options: [.largeTitleDisplayMode(.never), .autoPop])
                }
            case let .row(id):
                viewController.present(KeyGearItem(id: id), style: .default, options: [.largeTitleDisplayMode(.never), .autoPop])
            }
        }

        return (viewController, bag)
    }
}

extension KeyGearOverview: Tabable {
    func tabBarItem() -> UITabBarItem {
        return UITabBarItem(
            title: String(key: .KEY_GEAR_TAB_TITLE),
            image: Asset.keyGearTabIcon.image,
            selectedImage: Asset.keyGearTabIcon.image
        )
    }
}