//
//  KeyGearListItem.swift
//  test
//
//  Created by Sam Pettersson on 2020-01-27.
//

import Flow
import Form
import Foundation
import Kingfisher

struct KeyGearListItem {
    let id: String
    let imageUrl: URL?
    let name: String
    let wasAddedAutomatically: Bool
    let category: KeyGearItemCategory

    private let callbacker = Callbacker<Void>()
}

extension KeyGearListItem: SignalProvider {
    var providedSignal: Signal<Void> {
        return callbacker.providedSignal
    }
}

extension KeyGearListItem: Reusable {
    static var addedAutomaticallyTag: UIView {
        let addedAutomaticallyBlurView = UIVisualEffectView()
        addedAutomaticallyBlurView.isUserInteractionEnabled = false
        addedAutomaticallyBlurView.layer.cornerRadius = 8
        addedAutomaticallyBlurView.layer.masksToBounds = true
        addedAutomaticallyBlurView.effect = UIBlurEffect(style: .prominent)

        let addedAutomaticallyStackView = UIStackView()
        addedAutomaticallyStackView.layoutMargins = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)
        addedAutomaticallyStackView.isLayoutMarginsRelativeArrangement = true
        addedAutomaticallyBlurView.contentView.addSubview(addedAutomaticallyStackView)

        addedAutomaticallyStackView.snp.makeConstraints { make in
            make.top.bottom.trailing.leading.equalToSuperview()
        }

        let addedAutomaticallyLabel = UILabel(
            value: String(key: .KEY_GEAR_ADDED_AUTOMATICALLY_TAG),
            style: .bodySmallSmallLeft
        )
        addedAutomaticallyStackView.addArrangedSubview(addedAutomaticallyLabel)

        return addedAutomaticallyBlurView
    }

    static func makeAndConfigure() -> (make: UIControl, configure: (KeyGearListItem) -> Disposable) {
        let view = UIControl()
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        view.backgroundColor = .midnight500

        let imageView = UIImageView()
        imageView.isUserInteractionEnabled = false
        imageView.contentMode = .scaleAspectFill
        view.addSubview(imageView)

        imageView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }

        let addedAutomaticallyTag = self.addedAutomaticallyTag
        view.addSubview(addedAutomaticallyTag)

        addedAutomaticallyTag.snp.makeConstraints { make in
            make.top.equalTo(10)
            make.leading.equalTo(10)
        }

        let label = UILabel(value: "", style: .headlineSmallNegSmallNegCenter)
        view.addSubview(label)

        label.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.bottom.equalToSuperview().inset(10)
        }

        label.sizeToFit()

        return (view, { `self` in
            let bag = DisposeBag()

            bag += view.applyBorderColor { _ -> UIColor in
                UIColor.primaryBorder
            }

            label.value = self.name

            addedAutomaticallyTag.isHidden = !self.wasAddedAutomatically

            let touchUpInsideSignal = view.trackedTouchUpInsideSignal

            bag += touchUpInsideSignal.feedback(type: .impactLight)

            bag += view.signal(for: .touchDown).animated(style: AnimationStyle.easeOut(duration: 0.35)) {
                view.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
            }

            bag += view.delayedTouchCancel(delay: 0.1).animated(style: AnimationStyle.easeOut(duration: 0.35)) {
                view.transform = CGAffineTransform.identity
            }
            
            if let imageUrl = self.imageUrl {
                imageView.kf.setImage(with: imageUrl, options: [
                   .cacheOriginalImage,
                   .backgroundDecode,
                   .transition(.fade(0.25)),
               ])
            } else {
                imageView.image = self.category.image
            }
            
            bag += view.signal(for: .touchUpInside).onValue { _ in
                self.callbacker.callAll()
            }

            return bag
        })
    }
}