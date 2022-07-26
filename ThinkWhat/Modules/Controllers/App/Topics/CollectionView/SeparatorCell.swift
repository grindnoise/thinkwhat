//
//  SeparatorCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 26.07.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class SeparatorCell: UICollectionViewListCell {
    
    override func updateConstraints() {
        super.updateConstraints()
        separatorLayoutGuide.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        separatorLayoutGuide.trailingAnchor.constraint(equalTo: trailingAnchor, constant: .greatestFiniteMagnitude).isActive = true
    }
}
