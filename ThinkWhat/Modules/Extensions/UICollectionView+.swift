//
//  UICollectionView+.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 12.07.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

extension UICollectionView {
    func reconfigureCell(at indexPath: IndexPath) {
        let visibleIndexPaths = self.indexPathsForVisibleItems
        let foundIndexPath = visibleIndexPaths.first { $0 == indexPath }

        if let foundIndexPath = foundIndexPath {
            let cell = self.cellForItem(at: foundIndexPath)
            // get model that corresponds to index path
            // reconfigure the cell using the model
        }
    }
}

extension UICollectionViewDiffableDataSource {
    /// Reapplies the current snapshot to the data source, animating the differences.
    /// - Parameters:
    ///   - completion: A closure to be called on completion of reapplying the snapshot.
    func refresh(animatingDifferences: Bool = true, completion: (() -> Void)? = nil) {
        self.apply(self.snapshot(), animatingDifferences: animatingDifferences, completion: completion)
    }
}
