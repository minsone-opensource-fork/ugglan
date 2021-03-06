import Form
import Foundation
import UIKit

public enum SpacingType {
    case top
    case inbetween
    case custom(_ height: CGFloat)

    public var height: CGFloat {
        switch self {
        case let .custom(height):
            return height
        case .top:
            return 40
        case .inbetween:
            return 16
        }
    }
}

public extension SubviewOrderable {
    func appendSpacing(_ type: SpacingType) {
        let view = UIView()

        view.snp.makeConstraints { make in
            make.height.equalTo(type.height)
        }

        append(view)
    }
}
