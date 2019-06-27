
//
//  ApplyDiscount.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-06-12.
//

import Apollo
import Flow
import Form
import Foundation
import Presentation
import UIKit

struct ApplyDiscount {
    let client: ApolloClient

    private let didRedeemValidCodeCallbacker = Callbacker<Void>()

    var didRedeemValidCodeSignal: Signal<Void> {
        return didRedeemValidCodeCallbacker.providedSignal
    }

    init(client: ApolloClient = ApolloContainer.shared.client) {
        self.client = client
    }
}

extension ApplyDiscount: Presentable {
    func materialize() -> (UIViewController, Future<Void>) {
        let viewController = UIViewController()

        let bag = DisposeBag()

        let containerView = UIStackView()
        bag += containerView.applySafeAreaBottomLayoutMargin()

        viewController.view = containerView

        let view = UIStackView()
        view.spacing = 5
        view.axis = .vertical
        view.layoutMargins = UIEdgeInsets(horizontalInset: 24, verticalInset: 32)
        view.isLayoutMarginsRelativeArrangement = true

        containerView.addArrangedSubview(view)

        let titleLabel = MultilineLabel(
            value: String(key: .REFERRAL_ADDCOUPON_HEADLINE),
            style: .standaloneLargeTitle
        )
        bag += view.addArranged(titleLabel)

        let descriptionLabel = MultilineLabel(
            value: String(key: .REFERRAL_ADDCOUPON_BODY),
            style: .bodyOffBlack
        )
        bag += view.addArranged(descriptionLabel)

        let textField = TextField(value: "", placeholder: String(key: .REFERRAL_ADDCOUPON_INPUTPLACEHOLDER))
        bag += view.addArranged(textField.wrappedIn(UIStackView())) { stackView in
            stackView.isLayoutMarginsRelativeArrangement = true
            stackView.layoutMargins = UIEdgeInsets(horizontalInset: 0, verticalInset: 20)
        }

        let submitButton = Button(
            title: String(key: .REFERRAL_ADDCOUPON_BTN_SUBMIT),
            type: .standard(backgroundColor: .purple, textColor: .white)
        )

        let loadableSubmitButton = LoadableButton(button: submitButton)
        bag += loadableSubmitButton.isLoadingSignal.map { !$0 }.bindTo(textField.enabledSignal)

        bag += view.addArranged(loadableSubmitButton.wrappedIn(UIStackView())) { stackView in
            stackView.axis = .vertical
            stackView.alignment = .center
        }

        let terms = DiscountTerms()
        bag += view.addArranged(terms)

        bag += view.didLayoutSignal.map { _ in
            view.systemLayoutSizeFitting(CGSize.zero)
        }.onValue { size in
            view.snp.remakeConstraints { make in
                make.height.equalTo(size.height)
            }
        }

        bag += containerView.applyPreferredContentSize(on: viewController)

        return (viewController, Future { completion in
            bag += loadableSubmitButton
                .onTapSignal
                .atValue { _ in
                    loadableSubmitButton.isLoadingSignal.value = true
                }
                .withLatestFrom(textField.value.plain())
                .mapLatestToFuture { _, discountCode in self.client.perform(mutation: RedeemCodeMutation(code: discountCode)) }
                .delay(by: 0.5)
                .atValue { _ in
                    loadableSubmitButton.isLoadingSignal.value = false
                }
                .onValue { result in
                    if result.errors != nil {
                        let alert = Alert(
                            title: String(key: .REFERRAL_ERROR_MISSINGCODE_HEADLINE),
                            message: String(key: .REFERRAL_ERROR_MISSINGCODE_BODY),
                            actions: [Alert.Action(title: String(key: .REFERRAL_ERROR_MISSINGCODE_BTN)) {}]
                        )

                        viewController.present(alert)
                    } else {
                        self.didRedeemValidCodeCallbacker.callAll()
                        completion(.success)
                    }
                }

            return bag
        })
    }
}
