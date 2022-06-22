//
//  CostCollectionView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 22.06.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class CostCollectionView: UICollectionView {
    
    enum Section {
        case main
    }
    
    private weak var dataProvider: PollCreationViewInput?
    private var source: UICollectionViewDiffableDataSource<Section, CostItem>!

    init(dataProvider: PollCreationViewInput?) {
        super.init(frame: .zero, collectionViewLayout: UICollectionViewLayout())
        self.dataProvider = dataProvider
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        
    }
    
}
