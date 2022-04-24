//
//  SubsciptionsView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 10.03.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class SubsciptionsView: UIView {
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        guard let contentView = self.fromNib() else { fatalError("View could not load from nib") }
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(contentView)
        setupUI()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        ///Add shadow
        cardShadow.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.6).cgColor
        cardShadow.layer.shadowPath = UIBezierPath(roundedRect: cardShadow.bounds, cornerRadius: cardShadow.frame.width * 0.05).cgPath
        cardShadow.layer.shouldRasterize = true
        cardShadow.layer.rasterizationScale = UIScreen.main.scale
        cardShadow.layer.shadowRadius = 7
        cardShadow.layer.shadowOffset = .zero
        cardShadow.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1

    }
    
    // MARK: - Properties
    weak var viewInput: SubsciptionsViewInput?
    private var isSetupCompleted = false
    weak var tabBarController: UITabBarController? {
        return parentController?.tabBarController
    }
    weak var navigationController: UINavigationController? {
        return parentController?.navigationController
    }
    
    // MARK: - IB outlets
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var upperContainer: UIView!
    @IBOutlet weak var bottomContainer: UIView!
    @IBOutlet weak var card: UIView!
    @IBOutlet weak var cardShadow: UIView!
    @IBOutlet weak var upperContainerHeightConstraint: NSLayoutConstraint!
}

// MARK: - Controller Output
extension SubsciptionsView: SubsciptionsControllerOutput {
    
    func onDidLayout() {
//        ///Add shadow
//        cardShadow.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.6).cgColor
//        cardShadow.layer.shadowPath = UIBezierPath(roundedRect: cardShadow.bounds, cornerRadius: cardShadow.frame.width * 0.05).cgPath
//        cardShadow.layer.shadowRadius = 7
//        cardShadow.layer.shadowOffset = .zero
//        cardShadow.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
    }
    
    func onUpperContainerShown(_ reveal: Bool) {
        UIView.animate(withDuration: 0.2,
                       delay: 0,
                       options: .curveEaseInOut) {
            self.setNeedsLayout()
            self.upperContainerHeightConstraint.constant += reveal ? self.frame.height * 0.15 : -self.upperContainerHeightConstraint.constant
            self.layoutIfNeeded()
        } completion: { _ in }
    }
}

// MARK: - UI Setup
extension SubsciptionsView {
    private func setupUI() {
        card.layer.masksToBounds = true
        card.layer.cornerRadius = card.frame.width * 0.05
//        ///Add shadow
//        let indent: CGFloat = 10
//        let origin = navigationController.isNil ? frame.origin : CGPoint(x: indent + frame.origin.x + frame.size.width,
//                                                                         y: indent + navigationController!.navigationBar.frame.height + statusBarFrame.height)
//        let size = tabBarController.isNil ? frame.size : CGSize(width: frame.size.width - indent*2,
//                                                                height: frame.size.height - (tabBarController!.tabBar.isHidden ? 0 : tabBarController!.tabBar.frame.height) - origin.y - indent)
//        let rect = CGRect(origin: .zero, size: size)
//
//        cardShadow.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.6).cgColor
//        cardShadow.layer.shadowPath = UIBezierPath(roundedRect: rect, cornerRadius: cardShadow.frame.width * 0.05).cgPath
//        cardShadow.layer.shadowRadius = 7
//        cardShadow.layer.shadowOffset = .zero
//        cardShadow.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
    }
}


