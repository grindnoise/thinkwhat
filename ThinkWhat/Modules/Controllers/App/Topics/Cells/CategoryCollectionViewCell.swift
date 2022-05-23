//
//  CategoryCollectionViewCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 21.08.2020.
//  Copyright © 2020 Pavel Bukharov. All rights reserved.
//

import UIKit

class CategoryCollectionViewCell: UICollectionViewCell {

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var icon: Icon!
//    @IBOutlet weak var total: UILabel!
    @IBOutlet weak var constraint: NSLayoutConstraint!
    var childColor: UIColor?
    var category: Topic! {
        didSet {
            icon.backgroundColor = childColor ?? category.tagColor
            icon.category = Icon.Category(rawValue: category.id) ?? .Null
            setText()
        }
    }
    var selectionMode = false
    private var isSetupComplete = false
    
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
    
    public func setupUI() {
        setObservers()
        guard !isSetupComplete else { return }
        isSetupComplete = true
        setNeedsLayout()
        layoutIfNeeded()
    }

    private func setObservers() {
        let names = [Notifications.Surveys.Claimed,
//                     Notifications.Surveys.Completed,
                     Notifications.System.UpdateStats,
                     Notifications.Surveys.Rejected]
        names.forEach { NotificationCenter.default.addObserver(self, selector: #selector(self.updateStats), name: $0, object: nil) }
    }
    
    @objc
    private func updateStats() {
        UIView.transition(with: title, duration: 0.3, options: .transitionCrossDissolve, animations: {
            self.setText()
        }) { _ in }
    }
    
    private func setText() {
        let attributedText = NSMutableAttributedString()
        attributedText.append(NSAttributedString(string: "\(category.title.uppercased())", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Regular, size: frame.width * 0.125), foregroundColor: .label, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        attributedText.append(NSAttributedString(string: "\n\(category.visibleCount)", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Semibold, size: frame.width * 0.125), foregroundColor: .secondaryLabel, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        
        title.textAlignment = .center
        title.attributedText = attributedText
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
