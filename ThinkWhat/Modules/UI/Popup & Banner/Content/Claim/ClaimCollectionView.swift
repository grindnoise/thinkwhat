//
//  ClaimCollectionView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 17.08.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class ClaimCollectionView: UICollectionView {
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
