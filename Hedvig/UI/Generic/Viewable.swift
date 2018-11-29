//
//  Viewable.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-11-29.
//  Copyright © 2018 Hedvig AB. All rights reserved.
//

import Flow
import Foundation
import SnapKit
import UIKit

protocol Viewable {
    func materialize() -> (UIView, Disposable)
    func makeConstraints(make: ConstraintMaker)
}
