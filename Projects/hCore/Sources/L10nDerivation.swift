//
//  L10nDerivation.swift
//  hCore
//
//  Created by sam on 18.5.20.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Foundation

public struct L10nDerivation {
    public let table: String
    public let key: String
    public let args: [CVarArg]

    /// render the text key again, useful if you have changed the language during runtime
    public func render() -> String {
        return L10n.tr(table, key, args)
    }
}

public extension String {
    static var derivedFromL10n: UInt8 = 0

    /// set when String is derived from a L10n key
    var derivedFromL10n: L10nDerivation? {
        get {
            guard let value = objc_getAssociatedObject(
                self,
                &String.derivedFromL10n
            ) as? L10nDerivation? else {
                return nil
            }

            return value
        }
        set(newValue) {
            objc_setAssociatedObject(
                self,
                &String.derivedFromL10n,
                newValue,
                objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
}