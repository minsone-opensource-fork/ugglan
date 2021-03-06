import Flow
import Form
import Foundation
@testable import hCoreUI
import SnapshotTesting
import Testing
import XCTest

final class ToastTests: XCTestCase {
    override func setUp() {
        super.setUp()
        setupScreenShotTests()
        DefaultStyling.installCustom()
    }

    func test() {
        let toast = Toast(symbol: .none, body: "Testing a title!")

        materializeViewable(toast) { view in
            view.snp.makeConstraints { make in
                make.width.equalTo(400)
            }

            assertSnapshot(matching: view, as: .image)
        }
    }
}
