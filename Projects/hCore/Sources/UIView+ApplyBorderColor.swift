import Flow
import Foundation
import UIKit

public extension UIView {
    func applyBorderColor(_ dynamic: @escaping (_ trait: UITraitCollection) -> UIColor) -> Disposable {
        traitCollectionSignal.atOnce().with(weak: self).onValue { trait, `self` in
            let color = dynamic(trait)
            self.layer.borderColor = color.cgColor
        }
    }
}
