import Apollo
import Flow
import Form
import Foundation
import hCore
import hCoreUI
import hGraphQL
import UIKit

struct PaymentHeaderCard {
    @Inject var client: ApolloClient
}

extension PaymentHeaderCard: Viewable {
    func materialize(events _: ViewableEvents) -> (UIStackView, Disposable) {
        let view = UIStackView()
        view.axis = .vertical
        view.layoutMargins = UIEdgeInsets(top: 24, left: 15, bottom: 24, right: 15)
        view.isLayoutMarginsRelativeArrangement = true
        let bag = DisposeBag()

        let topView = UIView()
        topView.backgroundColor = .brand(.secondaryBackground())

        bag += topView.didLayoutSignal.onValue { _ in
            topView.applyRadiusMaskFor(topLeft: 10, bottomLeft: 0, bottomRight: 0, topRight: 10)
        }

        let topViewStack = UIStackView()
        topViewStack.layoutMargins = UIEdgeInsets(inset: 20)
        topViewStack.isLayoutMarginsRelativeArrangement = true
        topView.addSubview(topViewStack)

        topViewStack.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }

        let leftTopViewStack = UIStackView()
        leftTopViewStack.axis = .vertical
        leftTopViewStack.addArrangedSubview(UILabel(value: L10n.paymentsCardTitle, style: TextStyle.brand(.title1(color: .primary))))

        let dataSignal = client.fetch(query: GraphQL.MyPaymentQuery()).valueSignal

        let grossPriceSignal = dataSignal
            .map { $0.chargeEstimation.subscription.fragments.monetaryAmountFragment.amount }
            .toInt()
            .plain()
            .compactMap { $0 }
            .readable(initial: 0)
        let discountSignal = dataSignal.map { $0.chargeEstimation.discount.fragments.monetaryAmountFragment.amount }.toInt().plain().compactMap { $0 }.readable(initial: 0)
        let netSignal = dataSignal.map { $0.chargeEstimation.charge.fragments.monetaryAmountFragment.amount }.toInt().plain().compactMap { $0 }.readable(initial: 0)

        bag += leftTopViewStack.addArranged(PaymentHeaderPrice(grossPriceSignal: grossPriceSignal, discountSignal: discountSignal, monthlyNetPriceSignal: netSignal))

        topViewStack.addArrangedSubview(leftTopViewStack)

        let campaignTypeSignal = dataSignal.map { $0.redeemedCampaigns.first }.map { campaign -> CampaignBubble.CampaignType? in
            guard let campaign = campaign else {
                return nil
            }

            let incentiveFragment = campaign.fragments.campaignFragment.incentive?.fragments.incentiveFragment

            if let freeMonths = incentiveFragment?.asFreeMonths {
                return CampaignBubble.CampaignType.freeMonths(number: freeMonths.quantity ?? 0)
            } else if let monthlyDeduction = incentiveFragment?.asMonthlyCostDeduction {
                return CampaignBubble.CampaignType.monthlyDeduction(amount: monthlyDeduction.amount?.fragments.monetaryAmountFragment.monetaryAmount.formattedAmount ?? "")
            } else if let percentageDiscount = incentiveFragment?.asPercentageDiscountMonths {
                return CampaignBubble.CampaignType.percentageDiscount(value: percentageDiscount.percentageDiscount, months: percentageDiscount.percentageNumberOfMonths)
            }

            return nil
        }.plain().readable(initial: nil)

        bag += topViewStack.addArranged(CampaignBubble(campaignTypeSignal: campaignTypeSignal))

        view.addArrangedSubview(topView)

        let bottomView = UIView()
        bag += bottomView.applyShadow { _ in
            UIView.ShadowProperties(
                opacity: 0.05,
                offset: CGSize(width: 0, height: 6),
                radius: 8,
                color: UIColor.brand(.primaryShadowColor),
                path: nil
            )
        }
        bottomView.backgroundColor = .brand(.secondaryBackground())

        bag += bottomView.didLayoutSignal.onValue { _ in
            bottomView.applyRadiusMaskFor(topLeft: 0, bottomLeft: 10, bottomRight: 10, topRight: 0)
        }

        let bottomViewStack = UIStackView()
        bottomViewStack.layoutMargins = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        bottomViewStack.isLayoutMarginsRelativeArrangement = true
        bottomView.addSubview(bottomViewStack)

        bottomViewStack.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }

        bottomViewStack.addArrangedSubview(UILabel(value: L10n.paymentsCardDate, style: .brand(.body(color: .primary))))
        bag += bottomViewStack.addArranged(PaymentHeaderNextCharge())

        view.addArrangedSubview(bottomView)

        return (view, bag)
    }
}