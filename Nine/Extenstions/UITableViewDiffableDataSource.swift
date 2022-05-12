//
//  UITableViewDiffableDataSource.swift
//  Nine
//
//  Created by abc on 9/5/22.
//

import UIKit

extension UITableViewDiffableDataSource where SectionIdentifierType == Section, ItemIdentifierType == Item {

    func loadItems(_ items: [Item], to section: Section = .main) {
        var initialSnapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        initialSnapshot.appendSections([section])
        initialSnapshot.appendItems(items)
        self.apply(initialSnapshot, animatingDifferences: true)
    }

    func reloadItem(_ item: Item) {
        var updatedSnapshot = self.snapshot()
        if updatedSnapshot.indexOfItem(item) != nil {
            updatedSnapshot.reloadItems([item])
            self.apply(updatedSnapshot, animatingDifferences: true)
        }
    }
}
