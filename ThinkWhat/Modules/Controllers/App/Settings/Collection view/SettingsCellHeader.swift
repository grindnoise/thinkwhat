//
//  SettingsCellHeader.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 15.09.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class SettingsCellHeader: UICollectionReusableView {
    // MARK: - Public properties
    public var title: String = "" {
        didSet {
            guard !title.isEmpty else { return }
            
            headerLabel.text = title.localized.uppercased()
            
            guard let constraint = headerLabel.getConstraint(identifier: "width") else { return }
            
            constraint.constant = headerLabel.text!.width(withConstrainedHeight: 100, font: headerLabel.font)
        }
    }
    public var isBadgeEnabled = false {
        didSet {
            guard oldValue != isBadgeEnabled else { return }
            
//            badge.transform = oldValue ? .identity : CGAffineTransform(scaleX: 0.5, y: 0.5)
            
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.15, delay: 0, animations: { [weak self] in
                guard let self = self else { return }
                
                self.badge.transform = self.isBadgeEnabled ? .identity : CGAffineTransform(scaleX: 0.5, y: 0.5)
                self.badge.alpha = self.isBadgeEnabled ? 1 : 0
            }) { _ in }
        }
    }
    
    // MARK: - Private properties
    private var observers: [NSKeyValueObservation] = []
    private var subscriptions = Set<AnyCancellable>()
    private var tasks: [Task<Void, Never>?] = []
    //UI
    private let padding: CGFloat = 4
    private lazy var headerLabel: UILabel = {
        let instance = UILabel()
        instance.textColor = .secondaryLabel
        instance.text = title.localized.uppercased()
        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .subheadline)
        
        let constraint = instance.widthAnchor.constraint(equalToConstant: instance.text!.width(withConstrainedHeight: 100, font: instance.font))
        constraint.identifier = "width"
        constraint.isActive = true

        return instance
    }()
    private lazy var badge: UIImageView = {
        let instance = UIImageView()
        instance.backgroundColor = .clear
        instance.heightAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 1/1).isActive = true
        instance.contentMode = .center
        instance.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
        
        instance.transform = isBadgeEnabled ? .identity : CGAffineTransform(scaleX: 0.5, y: 0.5)
        instance.alpha = isBadgeEnabled ? 1 : 0
        
        instance.publisher(for: \.bounds, options: .new)
            .sink { rect in
                instance.setImage(UIImage(systemName: "circlebadge.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: rect.height*0.5))!)
            }
            .store(in: &subscriptions)

        return instance
    }()
    private lazy var headerContainer: UIView = {
        let instance = UIView()
        instance.backgroundColor = .clear
        
        let horizontalStack = UIStackView(arrangedSubviews: [headerLabel, badge])
        horizontalStack.axis = .horizontal
        horizontalStack.spacing = 0
        
        instance.addSubview(horizontalStack)
        horizontalStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            horizontalStack.leadingAnchor.constraint(equalTo: instance.leadingAnchor, constant: 16),
            horizontalStack.topAnchor.constraint(equalTo: instance.topAnchor),
            horizontalStack.bottomAnchor.constraint(equalTo: instance.bottomAnchor),
        ])
        
        return instance
    }()
    
    // MARK: - Destructor
    deinit {
        observers.forEach { $0.invalidate() }
        tasks.forEach { $0?.cancel() }
        subscriptions.forEach { $0.cancel() }
        NotificationCenter.default.removeObserver(self)
#if DEBUG
        print("\(String(describing: type(of: self))).\(#function)")
#endif
    }
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setTasks()
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private methods
    private func setupUI() {
        backgroundColor = .clear
        clipsToBounds = true
        
        addSubview(headerContainer)
        headerContainer.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            headerContainer.topAnchor.constraint(equalTo: topAnchor, constant: padding),
            headerContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            headerContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            headerContainer.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding),
        ])
//
//        let constraint = genderButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding)
//        constraint.priority = .defaultLow
//        constraint.identifier = "bottomAnchor"
//        constraint.isActive = true
    }
    
    private func setTasks() {
        
    }
    
}
