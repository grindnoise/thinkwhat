//
//  CommentHeaderCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 08.08.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class CommentHeaderCell: UICollectionReusableView {
    
    // MARK: - Override
//    override var isSelected: Bool { didSet { updateAppearance() }}
        
    // MARK: - Public properties
    public var callback: (() -> ())?//Closure?//(() -> Void)?
    
    // MARK: - Private properties
    private var observers: [NSKeyValueObservation] = []
    private lazy var label: InsetLabel = {
        let instance = InsetLabel()
        instance.isUserInteractionEnabled = true
        instance.insets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        instance.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onTap)))
        let font = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .footnote)
        
        let attrString = NSMutableAttributedString(string: "add_comment".localized, attributes: [
            NSAttributedString.Key.font: font as Any,
            NSAttributedString.Key.foregroundColor: UIColor.secondaryLabel
        ])
        
        instance.attributedText = attrString
        instance.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
        instance.heightAnchor.constraint(equalToConstant: "add_comment".height(withConstrainedWidth: 100, font: font!) + instance.insets.top*2).isActive = true
        
        observers.append(instance.observe(\InsetLabel.bounds, options: .new) { view, change in
            guard let newValue = change.newValue else { return }
            
            view.cornerRadius = newValue.size.height/2.25
            guard view.insets == .zero else { return }
            view.insets = UIEdgeInsets(top: view.insets.top,
                                       left: newValue.size.height/2.25,
                                       bottom: view.insets.top,
                                       right: newValue.size.height/2.25)
        })
        
        return instance
    }()
    
    // MARK: - Destructor
    deinit {
        observers.forEach { $0.invalidate() }
//        tasks.forEach { $0.cancel() }
//        subscriptions.forEach { $0?.cancel() }
        NotificationCenter.default.removeObserver(self)
#if DEBUG
        print("\(String(describing: type(of: self))).\(#function)")
#endif
    }

    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private methods
    private func setupUI() {
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
//            label.heightAnchor.constraint(equalToConstant: 40),
            label.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            label.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor, constant: 8),
        ])
        
        let constraint = bottomAnchor.constraint(equalTo: label.bottomAnchor, constant: 8)
        constraint.priority = .defaultLow
        constraint.isActive = true
    }
    
    @objc
    private func onTap() {
        callback?()
    }
}
