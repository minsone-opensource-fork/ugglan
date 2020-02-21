//
//  KeyGearListCollection.swift
//  test
//
//  Created by Sam Pettersson on 2020-01-27.
//

import Apollo
import Flow
import Form
import Foundation
import UIKit

struct KeyGearListCollection {
    @Inject var client: ApolloClient

    enum Effect {
        case add, row(id: String)
    }
}

typealias KeyGearListCollectionRow = Either<KeyGearListItem, ReusableSignalViewable<KeyGearAddButton, Void>>

extension KeyGearListCollection: Viewable {
    func materialize(events _: ViewableEvents) -> (UICollectionView, Signal<Effect>) {
        let bag = DisposeBag()
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(horizontalInset: 15, verticalInset: 0)
        layout.headerReferenceSize = CGSize(width: 100, height: 300)

        let addButton = ReusableSignalViewable(viewable: KeyGearAddButton())

        let collectionKit = CollectionKit<EmptySection, KeyGearListCollectionRow>(
            table: Table(rows: []),
            layout: layout
        )
        collectionKit.view.backgroundColor = .primaryBackground

        let header = TabHeader(
            image: Asset.keyGearOverviewHeader.image,
            title: String(key: .KEY_GEAR_START_EMPTY_HEADLINE),
            description: String(key: .KEY_GEAR_START_EMPTY_BODY)
        )
        
        bag += collectionKit.registerViewForSupplementaryElement(
            kind: UICollectionView.elementKindSectionHeader
        ) { _ in
            header
        }

        bag += collectionKit.delegate.sizeForItemAt.set { _ -> CGSize in
            CGSize(width: collectionKit.view.frame.width / 2 - 20, height: 120)
        }

        bag += client.watch(query: KeyGearItemsQuery()).map { $0.data?.keyGearItems }.onValue { items in
            guard let items = items, !items.isEmpty else {
                collectionKit.table = Table(rows: [.make(addButton)])
                return
            }

            var rows: [KeyGearListCollectionRow] = items.compactMap { $0 }.map { item in
                let photo = item.photos.first
                return .make(KeyGearListItem(
                    id: item.id,
                    imageUrl: URL(string: photo?.file.preSignedUrl),
                    name: item.name ?? "",
                    wasAddedAutomatically: item.physicalReferenceHash != nil,
                    category: item.category
                ))
            }

            rows.insert(.make(addButton), at: 0)

            collectionKit.table = Table(rows: rows)
        }

        return (collectionKit.view, Signal { callback in
            bag += addButton.onValue { _ in
                callback(.add)
            }

            bag += collectionKit.onValueDisposePrevious { table -> Disposable? in
                let bag = DisposeBag()

                bag += table.signal().onValue { value in
                    switch value {
                    case let .left(row):
                        bag += row.onValue { _ in
                            callback(.row(id: row.id))
                        }
                    case .right:
                        break
                    }
                }

                return bag
            }

            return bag
        })
    }
}