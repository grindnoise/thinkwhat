//
//  InterestCollectionCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 01.12.2021.
//  Copyright © 2021 Pavel Bukharov. All rights reserved.
//

import UIKit

class InterestCollectionCell: UICollectionViewCell, CollectionCellAutoLayout {
    var cachedSize: CGSize?

    

    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        return preferredLayoutAttributes(layoutAttributes)
    }
    
    @IBOutlet weak var categoryLabel: InsetLabelDesignable! {
        didSet {
            categoryLabel.leftInset = 6
            categoryLabel.rightInset = 6
            categoryLabel.topInset = 2
            categoryLabel.bottomInset = 2
            categoryLabel.setNeedsDisplay()
//            categoryLabel.sizeToFit()
        }
    }
        override func awakeFromNib() {
             super.awakeFromNib()
    
             contentView.translatesAutoresizingMaskIntoConstraints = false
    
             NSLayoutConstraint.activate([
                 contentView.leftAnchor.constraint(equalTo: leftAnchor),
                 contentView.rightAnchor.constraint(equalTo: rightAnchor),
                 contentView.topAnchor.constraint(equalTo: topAnchor),
                 contentView.bottomAnchor.constraint(equalTo: bottomAnchor)
             ])
         }
}

public protocol CollectionCellAutoLayout: class {
    var cachedSize: CGSize? { get set }
}

class CustomViewFlowLayout: UICollectionViewFlowLayout {
    let cellSpacing: CGFloat = 2

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        self.minimumLineSpacing = 4.0
        self.sectionInset = UIEdgeInsets(top: 0.0, left: 6.0, bottom: 0.0, right: 6.0)
        let attributes = super.layoutAttributesForElements(in: rect)

        var leftMargin = sectionInset.left
        var maxY: CGFloat = -1.0
        attributes?.forEach { layoutAttribute in
            if layoutAttribute.frame.origin.y >= maxY {
                leftMargin = sectionInset.left
            }
            layoutAttribute.frame.origin.x = leftMargin
            leftMargin += layoutAttribute.frame.width + cellSpacing
            maxY = max(layoutAttribute.frame.maxY, maxY)
        }
        return attributes
    }
}
