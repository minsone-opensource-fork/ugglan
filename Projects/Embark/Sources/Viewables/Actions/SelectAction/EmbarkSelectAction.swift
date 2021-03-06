import Flow
import Foundation
import hCore
import hGraphQL
import Presentation
import UIKit

typealias EmbarkSelectActionData = GraphQL.EmbarkStoryQuery.Data.EmbarkStory.Passage.Action.AsEmbarkSelectAction

struct EmbarkSelectAction {
    let state: EmbarkState
    let data: EmbarkSelectActionData
}

extension EmbarkSelectAction: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Signal<GraphQL.EmbarkLinkFragment>) {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 10

        let bag = DisposeBag()

        return (view, Signal { callback in
            let options = self.data.selectActionData.options
            let numberOfStacks = options.count % 2 == 0 ? options.count / 2 : Int(floor(Double(options.count) / 2) + 1)

            for iteration in 1 ... numberOfStacks {
                let stack = UIStackView()
                stack.spacing = 10
                stack.distribution = .fillEqually
                view.addArrangedSubview(stack)

                let optionsSlice = Array(options[2 * iteration - 2 ..< min(2 * iteration, options.count)])
                bag += optionsSlice.map { option in
                    stack.addArranged(EmbarkSelectActionOption(data: option)).onValue { result in
                        result.keys.enumerated().forEach { offset, key in
                            let value = result.values[offset]
                            self.state.store.setValue(key: key, value: value)
                        }

                        if let passageName = self.state.passageNameSignal.value {
                            self.state.store.setValue(
                                key: "\(passageName)Result",
                                value: result.textValue
                            )
                        }

                        callback(option.link.fragments.embarkLinkFragment)
                    }
                }
                if optionsSlice.count < 2 { stack.addArrangedSubview(UIView()) }
            }

            return bag
        })
    }
}
