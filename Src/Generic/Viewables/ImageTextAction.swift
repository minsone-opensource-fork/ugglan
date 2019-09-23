//
//  ImageTextAction.swift
//  test
//
//  Created by Sam Pettersson on 2019-09-23.
//

import Foundation
import UIKit
import Flow
import Form

struct ImageTextAction {
    let image: UIImage
    let title: String
    let body: String
    let actions: [Button]
    let showLogo: Bool
}

extension ImageTextAction: Viewable {
    func materialize(events: ViewableEvents) -> (UIScrollView, Signal<Button>) {
        let bag = DisposeBag()
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .secondaryBackground

        let containerView = UIStackView()
        containerView.axis = .horizontal
        containerView.alignment = .center
        containerView.layoutMargins = UIEdgeInsets(horizontalInset: 25, verticalInset: 25)
        containerView.isLayoutMarginsRelativeArrangement = true

        scrollView.embedView(containerView, scrollAxis: .vertical)

        let view = UIStackView()
        view.spacing = 28
        view.axis = .vertical
        view.alignment = .center

        if showLogo {
            let logoImageContainer = UIStackView()
            logoImageContainer.axis = .horizontal
            logoImageContainer.alignment = .center

            let logoImageView = UIImageView()
            logoImageView.image = Asset.wordmark.image
            logoImageView.contentMode = .scaleAspectFit

            logoImageView.snp.makeConstraints { make in
                make.height.equalTo(30)
            }

            logoImageContainer.addArrangedSubview(logoImageView)
            view.addArrangedSubview(logoImageContainer)
        }

        let headerImageContainer = UIStackView()
        headerImageContainer.axis = .horizontal
        headerImageContainer.alignment = .center

        let headerImageView = UIImageView()
        headerImageView.image = image
        headerImageView.contentMode = .scaleAspectFit

        headerImageView.snp.makeConstraints { make in
            make.height.equalTo(270)
        }

        headerImageContainer.addArrangedSubview(headerImageView)
        view.addArrangedSubview(headerImageContainer)

        let titleLabel = MultilineLabel(
            value: title,
            style: TextStyle.standaloneLargeTitle.aligned(to: .center)
        )
        bag += view.addArranged(titleLabel)

        let bodyLabel = MultilineLabel(
            value: body,
            style: TextStyle.body.aligned(to: .center)
        )
        bag += view.addArranged(bodyLabel)

        let buttonsContainer = UIStackView()
        buttonsContainer.axis = .vertical
        buttonsContainer.spacing = 15
        buttonsContainer.layoutMargins = UIEdgeInsets(horizontalInset: 0, verticalInset: 15)
        buttonsContainer.isLayoutMarginsRelativeArrangement = true

        let shadowView = UIView()

        let gradient = CAGradientLayer()
        gradient.locations = [0, 0.1, 0.9, 1]
        shadowView.layer.addSublayer(gradient)
        
        func setGradientColors() {
            gradient.colors = [
                UIColor.secondaryBackground.withAlphaComponent(0.2).cgColor,
                UIColor.secondaryBackground.cgColor,
            ]
        }
        
        bag += shadowView.traitCollectionSignal.onValue { _ in
            setGradientColors()
        }

        bag += shadowView.didLayoutSignal.onValue { _ in
            gradient.frame = shadowView.bounds
        }

        buttonsContainer.addSubview(shadowView)

        shadowView.snp.makeConstraints { make in
            make.width.height.centerY.centerX.equalToSuperview()
        }
        
        bag += scrollView.embedPinned(buttonsContainer, edge: .bottom, minHeight: 70)

        containerView.addArrangedSubview(view)
        
        return (scrollView, Signal { callback in
            bag += self.actions.map { button in
                buttonsContainer.addArranged(button.wrappedIn(UIStackView())) { stackView in
                    stackView.axis = .vertical
                    stackView.alignment = .center
                }
            }
            
            bag += self.actions.map { button in
                button.onTapSignal.onValue { _ in
                    callback(button)
                }
            }
            
            return bag
        })
    }
}
