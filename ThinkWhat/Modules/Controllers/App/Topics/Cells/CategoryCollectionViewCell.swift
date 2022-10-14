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
    
    @IBOutlet weak var title: ArcLabel!
    @IBOutlet weak var count: ArcLabel!
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
    private var fontSize: CGFloat = .zero
    private var showCount = true {
        didSet {
            guard oldValue != showCount else { return }
            count.alpha = showCount ? 1 : 0
        }
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected != oldValue {
                if selectionMode {
                    if !isSelected {
                        UIView.animate(withDuration: 0.15, delay: 0, options: [.curveEaseInOut], animations: {
                            self.transform = .identity
                            self.backgroundColor = .clear
                        })
                    } else {
                        UIView.animate(
                            withDuration: 0.3,
                            delay: 0,
                            usingSpringWithDamping: 0.55,
                            initialSpringVelocity: 2.5,
                            options: [.curveEaseInOut],
                            animations: {
                                self.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                                self.backgroundColor = self.category.tagColor.withAlphaComponent(0.2)
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
    
    public func setupUI(_ showCount: Bool = true, _ textScale: CGFloat = 0.11) {
        setObservers()
        guard !isSetupComplete else { return }
        self.showCount = showCount
        isSetupComplete = true
        setNeedsLayout()
        layoutIfNeeded()
        fontSize = bounds.width * textScale
        setText()
    }

    private func setObservers() {
        let names = [Notifications.Surveys.Claim,
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
//        if fontSize == .zero { fontSize = bounds.width * 0.09 }
        
        ///Topic
        let titleString = NSMutableAttributedString()
        titleString.append(NSAttributedString(string: category.localized.uppercased(), attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: fontSize), foregroundColor: traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : category.tagColor, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        title.attributedText = titleString
        
        let countString = NSMutableAttributedString()
        countString.append(NSAttributedString(string: String(describing: category.visibleCount.roundedWithAbbreviations), attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: fontSize), foregroundColor: traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : category.tagColor, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        count.attributedText = countString
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
