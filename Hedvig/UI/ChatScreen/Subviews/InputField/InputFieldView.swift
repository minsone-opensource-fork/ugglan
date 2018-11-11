//
//  InputFieldView.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-11-07.
//  Copyright © 2018 Sam Pettersson. All rights reserved.
//

import Foundation
import UIKit
import Tempura
import PinLayout
import DynamicColor

let blurEffect = UIBlurEffect(style: .light)

class InputFieldView: UIView, View, UITextViewDelegate {
    var textView = UITextView()
    var blurView = UIVisualEffectView(effect: blurEffect)
    var borderView = UIView()
    var safeAreaContainer = UIView()
    var heightConstraint: NSLayoutConstraint?
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        self.setup()
        self.style()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        safeAreaContainer.translatesAutoresizingMaskIntoConstraints = false
        
        safeAreaContainer.addSubview(borderView)
        safeAreaContainer.addSubview(textView)
        blurView.contentView.addSubview(safeAreaContainer)
        addSubview(blurView)
        
        safeAreaContainer.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        safeAreaContainer.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor).isActive = true
        safeAreaContainer.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor).isActive = true
        
        safeAreaContainer.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor).isActive = true
        
        heightConstraint = safeAreaContainer.heightAnchor.constraint(equalToConstant: 60)
        heightConstraint?.isActive = true
        
        textView.delegate = self
    }
    
    func style() {
        let grayColor = HedvigColors.darkGray.lighter(amount: 0.30)
        
        blurView.backgroundColor = HedvigColors.white.withAlphaComponent(0.3)
        textView.backgroundColor = HedvigColors.white.withAlphaComponent(0.5)
        textView.layer.cornerRadius = 20
        textView.layer.borderColor = grayColor.cgColor
        textView.layer.borderWidth = 1
        textView.font = HedvigFonts.circularStdBook?.withSize(15)
        textView.tintColor = HedvigColors.purple
        borderView.backgroundColor = grayColor
    }
    
    func update() {
    }
    
    override func layoutSubviews() {
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 8, bottom: 10, right: 8)
        textView.pin.width(95%)
        textView.pin.height(max(textView.contentSize.height, 40))
        textView.pin.top(10)
        textView.pin.left(2.5%)
        borderView.pin.width(100%)
        borderView.pin.height(1)
        borderView.pin.top(0)
    }
    
    override var intrinsicContentSize: CGSize {
        return .zero
    }
    
    func textViewDidChange(_ textView: UITextView) {
        self.heightConstraint?.constant = max(textView.contentSize.height + 20, 60)
        self.setNeedsLayout()
    }
}
