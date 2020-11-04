import Flow
import Form
import Foundation
import hCore
import hCoreUI
import Presentation
import UIKit

struct ContractDetailPresentableRow: Hashable, Equatable {
    static func == (lhs: ContractDetailPresentableRow, rhs: ContractDetailPresentableRow) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    let id = UUID()
    let presentable: AnyPresentable<UIViewController, Disposable>

    func calculateContentSize(_ fitting: CGSize) -> CGSize {
        let bag = DisposeBag()

        defer {
            bag.dispose()
        }

        let viewController = presentable.materialize(into: bag)

        viewController.view.snp.makeConstraints { make in
            make.width.equalTo(fitting.width)
        }

        viewController.view.setNeedsLayout()
        viewController.view.layoutIfNeeded()

        let scrollView = viewController.view as? UIScrollView

        return scrollView?.contentSize ?? .zero
    }
}

extension ContractDetailPresentableRow: Reusable {
    static func makeAndConfigure() -> (make: UIView, configure: (ContractDetailPresentableRow) -> Disposable) {
        let view = UIView()

        return (view, { `self` in
            let bag = DisposeBag()

            let viewController = self.presentable.materialize(into: bag)
            view.addSubview(viewController.view)

            viewController.view.snp.makeConstraints { make in
                make.top.bottom.trailing.leading.equalToSuperview()
            }

            view.viewController?.addChild(viewController)
            viewController.didMove(toParent: view.viewController)

            if let scrollView = viewController.view as? UIScrollView {
                scrollView.isScrollEnabled = false
            }

            bag += {
                viewController.removeFromParent()
            }

            return bag
        })
    }
}
