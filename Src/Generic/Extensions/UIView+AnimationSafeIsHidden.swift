//
//  UIView+AnimationSafeIsHidden.swift
//  ugglan
//
//  Created by Sam Pettersson on 2019-07-31.
//

import Foundation
import UIKit

 extension UIView {
    /// Workaround for the UIStackView bug where setting hidden to true with animation doesn't work
    var animationSafeIsHidden: Bool {
        get {
            return self.isHidden
        }
        set {
            if self.isHidden != newValue {
                self.isHidden = newValue
            }
        }
    }
}