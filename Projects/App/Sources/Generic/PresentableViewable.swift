import Flow
import Form
import Foundation
import hCore
import Presentation
import UIKit

struct PresentableViewable<View: Viewable, SignalValue>: Presentable where View.Events == ViewableEvents, View.Matter: UIView, View.Result == Signal<SignalValue> {
    let viewable: View
    let customizeViewController: (_ vc: UIViewController) -> Void

    func materialize() -> (UIViewController, Signal<SignalValue>) {
        let viewController = UIViewController()
        customizeViewController(viewController)
        let containerView = UIView()
        viewController.view = containerView

        let bag = DisposeBag()

        bag += containerView.traitCollectionSignal.onValue { _ in
            self.customizeViewController(viewController)
        }

        return (viewController, containerView.add(viewable) { view in
            view.snp.remakeConstraints { make in
                make.top.bottom.trailing.leading.equalToSuperview()
            }
        }.hold(bag))
    }
}
