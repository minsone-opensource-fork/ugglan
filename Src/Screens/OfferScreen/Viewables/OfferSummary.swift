//
//  OfferSummary.swift
//  test
//
//  Created by Sam Pettersson on 2019-10-03.
//

import Flow
import Form
import Foundation
import UIKit

struct OfferSummary {}

extension OfferSummary: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()
        let outerView = UIStackView()
        outerView.axis = .vertical
        
        let backgroundColor = UIColor.init(dynamic: { trait -> UIColor in
            trait.userInterfaceStyle == .dark ? UIColor.black.lighter(amount: 0.1) : .midnight700
        })
        
        bag += outerView.addArranged(Blob(color: backgroundColor, position: .top))

        let containerView = UIView()
        containerView.backgroundColor = backgroundColor
        outerView.addArrangedSubview(containerView)

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 15
        stackView.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 30, right: 20)
        stackView.isLayoutMarginsRelativeArrangement = true

        containerView.addSubview(stackView)

        stackView.snp.makeConstraints { make in
            make.trailing.leading.top.bottom.equalToSuperview()
        }

        let titleLabel = ApolloMultilineLabel(query: OfferQuery()) {
            StyledText(text: $0.insurance.address ?? "", style: TextStyle.offerSummaryTitle.centerAligned)
        }
        bag += stackView.addArranged(titleLabel)

        let descriptionLabel = MultilineLabel(
            value: String(key: .OFFER_HOUSE_SUMMARY_DESC),
            style: TextStyle.body.colored(.white).centerAligned
        )
        bag += stackView.addArranged(descriptionLabel)

        bag += stackView.addArranged(Spacing(height: 10))

        bag += stackView.addArranged(ExpandableContent(content: InsuranceSummarySection(), isExpanded: .static(false)))

        bag += outerView.addArranged(Blob(color: .secondaryBackground, position: .top)) { blobView in
            blobView.backgroundColor = backgroundColor
        }

        return (outerView, bag)
    }
}