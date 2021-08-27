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
    @IBOutlet weak var constraint: NSLayoutConstraint!
    var childColor: UIColor?
    var category: SurveyCategory! {
        didSet {
            icon.backgroundColor = childColor ?? category.tagColor
            icon.category = SurveyCategoryIcon.Category(rawValue: category.ID) ?? .Null
            title.attributedText = NSAttributedString(string: "\(category.title.uppercased())", attributes: StringAttributes.getAttributes(font: StringAttributes.getFont(name: StringAttributes.Fonts.Style.Semibold, size: 10), foregroundColor: .darkGray, backgroundColor: .clear))
            total.attributedText = NSAttributedString(string: "\(category.total)", attributes: StringAttributes.getAttributes(font: StringAttributes.getFont(name: StringAttributes.Fonts.Style.Regular, size: 9), foregroundColor: .lightGray, backgroundColor: .clear))
        }
    }
    var selectionMode = false
    
    override var isSelected: Bool {
        didSet {
            if isSelected != oldValue {
                if selectionMode {
                    if !isSelected {
                        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut], animations: {
                            self.icon.transform = .identity
                            self.icon.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
                        })
                    } else {
                        UIView.animate(
                            withDuration: 0.3,
                            delay: 0,
                            usingSpringWithDamping: 0.7,
                            initialSpringVelocity: 0.3,
                            options: [.curveEaseInOut],
                            animations: {
                                self.icon.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
                                self.icon.backgroundColor = self.category.tagColor
                        }) { _ in }
//                        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseOut], animations: {
//                            self.icon.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
//                            self.icon.backgroundColor = self.category.tagColor
//                        })
                    }
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
}

//extension CategoryCollectionViewCell: CAAnimationDelegate {
//    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
//        if let completionBlocks = anim.value(forKey: "circleLayerAnimCompletionBlocks") as? [Closure] {
//            completionBlocks.map{ $0() }
//        } else if let preserveLayer = anim.value(forKey: "preserveLayer") as? CAShapeLayer {
//            print("")
//        } else if let removeLayer = anim.value(forKey: "removeLayer") as? CAShapeLayer {
//            print("")
//        }
//    }
//}
