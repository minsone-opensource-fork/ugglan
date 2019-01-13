//
//  DefaultStyling.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2019-01-03.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Form
import Foundation

extension DefaultStyling {
    static func installCustom() {
        ListTableView.self.appearance().backgroundColor = .offWhite

        for view in [FormScrollView.self, FormTableView.self] {
            view.appearance(
                for: UITraitCollection(userInterfaceIdiom: .pad)
            ).backgroundColor = .offWhite
            view.appearance().backgroundColor = .offWhite
        }

        UIRefreshControl.appearance().tintColor = .purple

        UINavigationBar.appearance().tintColor = .purple
        UINavigationBar.appearance().titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.black,
            NSAttributedString.Key.font: HedvigFonts.circularStdBook!.withSize(16)
        ]

        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = .purple

        UIBarButtonItem.appearance().setTitleTextAttributes(
            [
                NSAttributedString.Key.font: HedvigFonts.circularStdBook!.withSize(16)
            ],
            for: .normal
        )

        UIBarButtonItem.appearance().setTitleTextAttributes(
            [
                NSAttributedString.Key.font: HedvigFonts.circularStdBook!.withSize(16)
            ],
            for: .highlighted
        )

        if #available(iOS 11.0, *) {
            UINavigationBar.appearance().largeTitleTextAttributes = [
                NSAttributedString.Key.foregroundColor: UIColor.black,
                NSAttributedString.Key.font: HedvigFonts.circularStdBold!.withSize(30)
            ]
        }

        current = .custom
    }

    static let custom = DefaultStyling(
        text: .default,
        field: FieldStyle(
            text: .default,
            placeholder: .default,
            disabled: .default,
            cursorColor: .green
        ),
        detailText: .default,
        titleSubtitle: .default,
        button: .default,
        barButton: .default,
        switch: .default,
        segmentedControl: .default,
        sectionGrouped: .default,
        sectionPlain: .sectionPlain,
        formGrouped: .default,
        formPlain: .default,
        sectionBackground: .default,
        sectionBackgroundSelected: .default,
        scrollView: FormScrollView.self,
        plainTableView: ListTableView.self,
        groupedTableView: FormTableView.self,
        collectionView: UICollectionView.self
    )
}

final class FormScrollView: UIScrollView {}
final class FormTableView: UITableView {}
final class ListTableView: UITableView {}