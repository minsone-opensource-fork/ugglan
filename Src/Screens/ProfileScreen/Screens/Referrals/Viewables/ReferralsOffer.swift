//
//  ReferralsOffer.swift
//  ugglan
//
//  Created by Sam Pettersson on 2019-03-18.
//

import Foundation
import UIKit
import Flow
import Form

struct ReferralsOffer {
    enum Mode {
        case receiver, sender
        
        func titleText() -> String {
            switch self {
            case .receiver:
                return String(.REFERRALS_OFFER_RECEIVER_TITLE)
            case .sender:
                return String(.REFERRALS_OFFER_SENDER_TITLE)
            }
        }
        
        func labelText(incentive: Int) -> String {
            switch self {
            case .receiver:
                return String(.REFERRALS_OFFER_RECEIVER_VALUE(incentive: String(incentive)))
            case .sender:
                return String(.REFERRALS_OFFER_SENDER_VALUE(incentive: String(incentive)))
            }
        }
    }
    
    let mode: Mode
    let incentive: Int
    
    init(
        mode: Mode
    ) {
        self.mode = mode
        self.incentive = RemoteConfigContainer().referralsIncentive()
    }
}

extension ReferralsOffer: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let containerView = UIStackView()
        containerView.axis = .vertical
        containerView.edgeInsets = UIEdgeInsets(
            top: 0,
            left: 20,
            bottom: 0,
            right: 20
        )
        containerView.isLayoutMarginsRelativeArrangement = true
        
        let title = UILabel(value: mode.titleText(), style: .boldSmallTitle)
        containerView.addArrangedSubview(title)
        
        let view = UIStackView()
        view.axis = .horizontal
        view.alignment = .leading
        
        containerView.addArrangedSubview(view)
        view.spacing = 10
        
        let icon = Icon(
            icon: Asset.greenCircularCheckmark,
            iconWidth: 15
        )
        view.addArrangedSubview(icon)
        
        icon.snp.makeConstraints { make in
            make.width.equalTo(icon.iconWidth)
        }
        
        let label = MultilineLabel(
            styledText: StyledText(
                text: mode.labelText(incentive: incentive),
                style: .bodyOffBlack
            )
        )
        
        let bag = DisposeBag()
        bag += view.addArangedSubview(label) { labelView in
            labelView.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
            }
        }
        
        return (containerView, bag)
    }
}
