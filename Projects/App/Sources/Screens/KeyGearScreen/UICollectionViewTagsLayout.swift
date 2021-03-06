import Foundation
import UIKit

class UICollectionViewTagLayout: UICollectionViewFlowLayout {
    override required init() {
        super.init()
        estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        minimumLineSpacing = 10
        minimumInteritemSpacing = 10
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutAttributesForElements(
        in rect: CGRect
    ) -> [UICollectionViewLayoutAttributes]? {
        guard let attributes = super.layoutAttributesForElements(in: rect) else {
            return []
        }
        var x: CGFloat = sectionInset.left
        var y: CGFloat = -1.0

        for attr in attributes {
            if attr.representedElementCategory != .cell {
                continue
            }
            if attr.frame.origin.y >= y { x = sectionInset.left }
            attr.frame.origin.x = x
            x += attr.frame.width + minimumInteritemSpacing
            y = attr.frame.maxY
        }

        return attributes
    }
}
