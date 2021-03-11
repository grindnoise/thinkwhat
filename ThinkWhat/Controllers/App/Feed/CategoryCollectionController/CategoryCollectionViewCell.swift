//
//  CategoryCollectionViewCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 21.08.2020.
//  Copyright © 2020 Pavel Bukharov. All rights reserved.
//

import UIKit

class CategoryCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var icon: SurveyCategoryIcon!
    @IBOutlet weak var total: UILabel!
    var childColor: UIColor?
    var category: SurveyCategory! {
        didSet {
            icon.tagColor = childColor ?? category.tagColor
            icon.categoryID = SurveyCategoryIcon.CategoryID(rawValue: category.ID) ?? .Null
            title.attributedText = NSAttributedString(string: "\(category.title.uppercased())", attributes: StringAttributes.getAttributes(font: StringAttributes.getFont(name: StringAttributes.Fonts.Style.Semibold, size: 10), foregroundColor: .darkGray, backgroundColor: .clear))
            total.attributedText = NSAttributedString(string: "\(category.total)", attributes: StringAttributes.getAttributes(font: StringAttributes.getFont(name: StringAttributes.Fonts.Style.Regular, size: 9), foregroundColor: .lightGray, backgroundColor: .clear))
        }
    }
    var selectionMode = false
    
    override var isSelected: Bool {
        didSet {
            if selectionMode {
                UIView.animate(withDuration: 0.15, delay: 0, options: [.curveEaseOut], animations: {
                    self.contentView.backgroundColor = self.isSelected ? self.category.tagColor?.withAlphaComponent(0.2) ?? K_COLOR_RED.withAlphaComponent(0.2) : .white
                })
//                if isSelected {
//                    let anim = animateTransformScale(fromValue: 1, toValue: 1.1, duration: 0.12, repeatCount: 0, autoreverses: true, timingFunction: CAMediaTimingFunctionName.easeInEaseOut.rawValue,  delegate: nil)
//                    layer.add(anim, forKey: nil)
//                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
}
