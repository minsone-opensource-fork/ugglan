import Apollo
import Flow
import Form
import hCore
import Presentation
import UIKit

struct OnboardingChat {
    @Inject var client: ApolloClient
}

extension OnboardingChat: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let bag = DisposeBag()

        ApplicationState.preserveState(.onboardingChat)

        let chat = Chat()
        let (viewController, future) = chat.materialize()
        viewController.navigationItem.hidesBackButton = true

        chat.chatState.fetch()

        let settingsButton = UIBarButtonItem()
        settingsButton.image = Asset.menuIcon.image
        settingsButton.tintColor = .brand(.primaryText())

        viewController.navigationItem.leftBarButtonItem = settingsButton

        bag += settingsButton.onValue { _ in
            viewController.present(
                About(state: .onboarding).withCloseButton,
                style: .detented(.scrollViewContentSize(20), .large),
                options: [
                    .allowSwipeDismissAlways,
                    .defaults,
                    .largeTitleDisplayMode(.always),
                    .prefersLargeTitles(true),
                ]
            )
        }

        let restartButton = UIBarButtonItem()
        restartButton.image = Asset.restart.image
        restartButton.tintColor = .brand(.primaryText())

        bag += restartButton.onValue { _ in
            let alert = Alert(
                title: L10n.chatRestartAlertTitle,
                message: L10n.chatRestartAlertMessage,
                actions: [
                    Alert.Action(
                        title: L10n.chatRestartAlertConfirm,
                        action: {
                            chat.reloadChatCallbacker.callAll()
                        }
                    ),
                    Alert.Action(
                        title: L10n.chatRestartAlertCancel,
                        action: {}
                    ),
                ]
            )

            viewController.present(alert)
        }

        viewController.navigationItem.rightBarButtonItem = restartButton

        let titleHedvigLogo = UIImageView()
        titleHedvigLogo.image = Asset.wordmark.image
        titleHedvigLogo.contentMode = .scaleAspectFit

        viewController.navigationItem.titleView = titleHedvigLogo

        titleHedvigLogo.snp.makeConstraints { make in
            make.width.equalTo(80)
        }

        bag += future.onValue { _ in }

        return (viewController, bag)
    }
}
