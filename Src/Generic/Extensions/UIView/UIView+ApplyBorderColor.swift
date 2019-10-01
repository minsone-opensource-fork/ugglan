//
//  UIView+ApplyBorderColor.swift
//  test
//
//  Created by Sam Pettersson on 2019-09-27.
//

import Foundation
import UIKit
import Flow

extension UIView {
    func applyBorderColor(_ dynamic: @escaping (_ trait: UITraitCollection) -> UIColor) -> Disposable {
        traitCollectionSignal.atOnce().with(weak: self).onValue { trait, `self` in
            let color = dynamic(trait)
            self.layer.borderColor = color.cgColor
        }
    }
}