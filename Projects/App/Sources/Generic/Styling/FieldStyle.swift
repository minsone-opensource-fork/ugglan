import Flow
import Form
import Foundation
import UIKit

extension FieldStyle {
    static let `default` = FieldStyle.default.restyled { (style: inout FieldStyle) in
        style.cursorColor = .brand(.primaryTintColor)
        style.text = .brand(.headline(color: .secondary))
        style.placeholder = .brand(.headline(color: .quartenary))
    }

    static let defaultRight = FieldStyle.default.restyled { (style: inout FieldStyle) in
        style.cursorColor = .brand(.primaryTintColor)
        style.text = TextStyle.brand(.headline(color: .secondary)).aligned(to: .right)
        style.placeholder = TextStyle.brand(.headline(color: .quartenary)).aligned(to: .right)
    }

    static let editableRow = FieldStyle.default.restyled { (style: inout FieldStyle) in
        style.cursorColor = .brand(.primaryTintColor)
        style.text = TextStyle.brand(.headline(color: .secondary)).aligned(to: .right)
    }
}
