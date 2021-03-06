import Flow
import Form
import Foundation
import hCore
import hCoreUI
import hGraphQL
import Presentation
import UIKit

typealias EmbarkNumberActionData = GraphQL.EmbarkStoryQuery.Data.EmbarkStory.Passage.Action.AsEmbarkNumberAction

struct EmbarkNumberAction {
    let state: EmbarkState
    let data: EmbarkNumberActionData
}

extension EmbarkNumberAction: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Signal<GraphQL.EmbarkLinkFragment>) {
        let bag = DisposeBag()

        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 10

        let box = UIView()
        box.backgroundColor = .brand(.secondaryBackground())
        box.layer.cornerRadius = 10
        bag += box.applyShadow { _ -> UIView.ShadowProperties in
            UIView.ShadowProperties(
                opacity: 0.25,
                offset: CGSize(width: 0, height: 6),
                radius: 8,
                color: .brand(.primaryShadowColor),
                path: nil
            )
        }

        let boxStack = UIStackView()
        boxStack.axis = .vertical
        boxStack.edgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)

        return (view, Signal { callback in

            func handleSubmit(textValue: String) {
                let key = self.data.numberActionData.key
                self.state.store.setValue(key: key, value: textValue)
                if let passageName = self.state.passageNameSignal.value {
                    self.state.store.setValue(key: "\(passageName)Result", value: textValue)
                }
                callback(self.data.numberActionData.link.fragments.embarkLinkFragment)
            }

            let masking = Masking(type: .digits)
            let textField = EmbarkInput(
                placeholder: self.data.numberActionData.placeholder,
                keyboardType: masking.keyboardType,
                textContentType: masking.textContentType,
                masking: masking
            )
            let (textInputView, textSignal) = textField.materialize(events: events)
            boxStack.addArrangedSubview(textInputView)

            bag += textField.shouldReturn.set { value -> Bool in
                handleSubmit(textValue: value)
                return true
            }

            if let unit = self.data.numberActionData.unit {
                let unitLabel = MultilineLabel(value: unit, style: TextStyle.brand(.body(color: .primary)).centerAligned)
                bag += boxStack.addArranged(unitLabel)
            }

            box.addSubview(boxStack)
            boxStack.snp.makeConstraints { make in
                make.top.bottom.right.left.equalToSuperview()
            }

            view.addArrangedSubview(box)

            let button = Button(
                title: self.data.numberActionData.link.fragments.embarkLinkFragment.label,
                type: .standard(backgroundColor: .black, textColor: .white)
            )

            bag += view.addArranged(button)

            bag += button.onTapSignal.withLatestFrom(textSignal.plain()).onValue { _, textValue in
                handleSubmit(textValue: textValue)
            }

            return bag
        })
    }
}
