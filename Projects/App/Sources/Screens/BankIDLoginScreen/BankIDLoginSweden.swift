//
//  BankIDLoginSweden.swift
//  project
//
//  Created by Sam Pettersson on 2020-03-19.
//

import Apollo
import Flow
import Form
import Foundation
import Presentation
import UIKit

struct BankIDLoginSweden {
    @Inject var client: ApolloClient
}

extension BankIDLoginSweden: Presentable {
    func materialize() -> (UIViewController, Future<Void>) {
        let viewController = UIViewController()
        let bag = DisposeBag()

        let view = UIView()
        view.backgroundColor = .primaryBackground
        viewController.view = view
        viewController.title = L10n.bankidLoginTitle

        let containerStackView = UIStackView()
        containerStackView.axis = .vertical
        containerStackView.alignment = .center

        view.addSubview(containerStackView)

        containerStackView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
        }

        let containerView = UIStackView()
        containerView.spacing = 15
        containerView.axis = .vertical
        containerView.alignment = .center
        containerView.layoutMargins = UIEdgeInsets(horizontalInset: 15, verticalInset: 24)
        containerView.isLayoutMarginsRelativeArrangement = true
        containerStackView.addArrangedSubview(containerView)

        let headerContainer = UIStackView()
        headerContainer.axis = .vertical
        headerContainer.spacing = 15

        containerView.addArrangedSubview(headerContainer)

        let iconContainerView = UIView()

        iconContainerView.snp.makeConstraints { make in
            make.height.width.equalTo(120)
        }

        let imageView = UIImageView()
        imageView.image = Asset.bankIdLogo.image
        imageView.tintColor = .primaryText

        iconContainerView.addSubview(imageView)

        imageView.snp.makeConstraints { make in
            make.height.width.equalToSuperview()
        }

        headerContainer.addArrangedSubview(iconContainerView)

        bag += headerContainer.addArranged(LoadingIndicator(showAfter: 0, size: 50).wrappedIn(UIStackView()))

        let statusLabel = MultilineLabel(value: L10n.signStartBankid, style: .rowTitle)
        bag += containerView.addArranged(statusLabel)

        let closeButtonContainer = UIStackView()
        closeButtonContainer.animationSafeIsHidden = true
        containerView.addArrangedSubview(closeButtonContainer)

        let closeButton = Button(title: "Stäng", type: .standard(backgroundColor: .purple, textColor: .white))
        bag += closeButtonContainer.addArranged(closeButton)

        let statusSignal = client.subscribe(
            subscription: BankIdAuthSubscriptionSubscription()
        ).compactMap { $0.data?.authStatus?.status }

        bag += statusSignal.skip(first: 1).onValue { authStatus in
            let statusText: String

            switch authStatus {
            case .initiated:
                statusText = L10n.bankIdAuthTitleInitiated
            case .inProgress:
                statusText = L10n.bankIdAuthTitleInitiated
            case .failed:
                statusText = L10n.bankIdAuthTitleInitiated
            case .success:
                statusText = L10n.bankIdAuthTitleInitiated
            case .__unknown:
                statusText = L10n.bankIdAuthTitleInitiated
            }

            statusLabel.styledTextSignal.value = StyledText(text: statusText, style: .rowTitle)
        }

        bag += client.perform(mutation: BankIdAuthMutation()).delay(by: 0.5).valueSignal.compactMap { result in result.data?.bankIdAuth.autoStartToken }.onValue { autoStartToken in
            let urlScheme = Bundle.main.urlScheme ?? ""
            guard let url = URL(string: "bankid:///?autostarttoken=\(autoStartToken)&redirect=\(urlScheme)://bankid") else { return }

            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                viewController.present(BankIDLoginQR(autoStartURL: url), options: [.prefersNavigationBarHidden(false)])
            }
        }

        return (viewController, Future { completion in
            bag += closeButton.onTapSignal.onValue {
                completion(.failure(BankIdSignError.failed))
            }

            bag += statusSignal.distinct().onValue { authState in
                if authState == .success {
                    let appDelegate = UIApplication.shared.appDelegate

//                    if let fcmToken = ApplicationState.getFirebaseMessagingToken() {
//                        appDelegate.registerFCMToken(fcmToken)
//                    }

                    AnalyticsCoordinator().setUserId()

                    let window = appDelegate.window
                    bag += window.present(LoggedIn(), animated: true)
                }
            }

            return bag
        })
    }
}