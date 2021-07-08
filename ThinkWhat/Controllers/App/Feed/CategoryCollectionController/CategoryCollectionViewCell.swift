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
            icon.backgroundColor = childColor ?? category.tagColor!
            icon.category = SurveyCategoryIcon.Category(rawValue: category.ID) ?? .Null
            title.attributedText = NSAttributedString(string: "\(category.title.uppercased())", attributes: StringAttributes.getAttributes(font: StringAttributes.getFont(name: StringAttributes.Fonts.Style.Semibold, size: 10), foregroundColor: .darkGray, backgroundColor: .clear))
            total.attributedText = NSAttributedString(string: "\(category.total)", attributes: StringAttributes.getAttributes(font: StringAttributes.getFont(name: StringAttributes.Fonts.Style.Regular, size: 9), foregroundColor: .lightGray, backgroundColor: .clear))
        }
    }
    var selectionMode = false
    
    override var isSelected: Bool {
        didSet {
            if selectionMode {
                var oval: CAShapeLayer!
                if let existingLayer = layer.sublayers?.filter({ $0 is CAShapeLayer }).first as? CAShapeLayer {
                    oval = existingLayer
                } else {
                    oval = CAShapeLayer()
                    oval.path = UIBezierPath(ovalIn: CGRect(origin: center, size: .zero)).cgPath
                    oval.fillColor = category.tagColor?.withAlphaComponent(0.2).cgColor ?? K_COLOR_RED.withAlphaComponent(0.2).cgColor
                    layer.insertSublayer(oval, at: 0)
                }
                contentView.animateCircleLayer(shapeLayer: oval, reveal: self.isSelected, duration: 0.3, completionBlocks: [], completionDelegate: nil)
                
                
                //                UIView.animate(withDuration: 0.15, delay: 0, options: [.curveEaseOut], animations: {
                //                    self.contentView.backgroundColor = self.isSelected ? self.category.tagColor?.withAlphaComponent(0.2) ?? K_COLOR_RED.withAlphaComponent(0.2) : .white
                //                })
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
