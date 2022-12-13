//
//  PollTitleCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 30.06.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class PollTitleCell: UICollectionViewCell {
    
    // MARK: - Public properties
    public weak var item: Survey! {
        didSet {
            guard let item = item else { return }
            
            titleLabel.text = item.title
            ratingLabel.text = String(describing: item.rating)
            viewsLabel.text = String(describing: item.views.roundedWithAbbreviations)
            
            item.reference.viewsPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in
                    guard let self = self else { return }
                    
                    self.viewsLabel.text = $0.roundedWithAbbreviations
                }
                .store(in: &subscriptions)
            
            item.reference.ratingPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in
                    guard let self = self else { return }
                    
                    self.ratingLabel.text = String(describing: $0)
                }
                .store(in: &subscriptions)
            
            updateUI()
        }
    }
    
    // MARK: - Private properties
    private var observers: [NSKeyValueObservation] = []
    private var subscriptions = Set<AnyCancellable>()
    private var tasks: [Task<Void, Never>?] = []
    //UI
    private lazy var titleLabel: UILabel = {
        let instance = UILabel()
        instance.textAlignment = .center
        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Bold.rawValue, forTextStyle: .largeTitle)
        instance.numberOfLines = 0
        
        let constraint = instance.heightAnchor.constraint(equalToConstant: 0)
        constraint.identifier = "height"
        constraint.isActive = true
        
        return instance
    }()
    private let ratingView: UIImageView = {
        let instance = UIImageView(image: UIImage(systemName: "star.fill"))
        instance.tintColor = Colors.Tag.HoneyYellow.rawValue
        instance.contentMode = .scaleAspectFit
        instance.translatesAutoresizingMaskIntoConstraints = false
        instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1.0/1.0).isActive = true
        return instance
    }()
    private lazy var ratingLabel: UILabel = {
        let instance = UILabel()
        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .caption2)
        instance.textAlignment = .center
        instance.textColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
        observers.append(instance.observe(\UILabel.bounds, options: [.new]) {[weak self] view, _ in
            guard let self = self,
                  let text = view.text else { return }
            //            view.font = UIFont(name: Fonts.Regular, size: newValue.height * 0.8)
            guard let constraint = self.bottomView.getAllConstraints().filter({$0.identifier == "height"}).first else { return }
            self.setNeedsLayout()
            constraint.constant = text.height(withConstrainedWidth: view.bounds.width, font: view.font)
            self.layoutIfNeeded()
        })
        return instance
    }()
    @MainActor private lazy var viewsView: UIImageView = {
        let instance = UIImageView(image: UIImage(systemName: "eye.fill"))
        instance.tintColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
        instance.contentMode = .scaleAspectFit
        instance.translatesAutoresizingMaskIntoConstraints = false
        instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1.0/1.0).isActive = true
        return instance
    }()
    @MainActor private lazy var viewsLabel: UILabel = {
        let instance = UILabel()
        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .caption2)
        instance.textAlignment = .center
        instance.textColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
        return instance
    }()
    @MainActor private let bottomView: UIView = {
        let instance = UIView()
        let constraint = instance.heightAnchor.constraint(equalToConstant: 15)
        constraint.identifier = "height"
        constraint.isActive = true
        instance.backgroundColor = .clear
        return instance
    }()
    @MainActor private let bottomView_2: UIView = {
        let instance = UIView()
        let constraint = instance.heightAnchor.constraint(equalToConstant: 40)
        constraint.identifier = "height"
        constraint.isActive = true
        instance.backgroundColor = .clear
        return instance
    }()
    @MainActor private lazy var shareButton: UIImageView = {
        let instance = UIImageView()
        instance.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : .label
        //        instance.addTarget(self, action: #selector(self.handleTap(_:)), for: .touchUpInside)
        instance.image = UIImage(systemName: "square.and.arrow.up")
        //        instance.contentMode = .bottom
        instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1/1).isActive = true
        return instance
    }()
    @MainActor private lazy var claimButton: UIImageView = {
        let instance = UIImageView()
        instance.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : .label
        //        instance.addTarget(self, action: #selector(self.handleTap(_:)), for: .touchUpInside)
        instance.image = UIImage(systemName: "square.and.arrow.up.trianglebadge.exclamationmark")
        //        instance.contentMode = .bottom
        instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1/1).isActive = true
        return instance
    }()
    @MainActor private lazy var horizontalStack: UIStackView = {
        let horizontalStack = UIStackView(arrangedSubviews: [ratingView, ratingLabel, viewsView, viewsLabel])
        horizontalStack.alignment = .center
        horizontalStack.spacing = 4
        return horizontalStack
    }()
    @MainActor private lazy var horizontalStack_2: UIStackView = {
        let horizontalStack = UIStackView(arrangedSubviews: [shareButton, claimButton])
        //        horizontalStack.alignment = .bottom
        horizontalStack.distribution = .fillEqually
        horizontalStack.spacing = 4
        return horizontalStack
    }()
    private lazy var verticalStack: UIStackView = {
        let verticalStack = UIStackView(arrangedSubviews: [titleLabel, bottomView])//, bottomView_2])
        verticalStack.axis = .vertical
        verticalStack.spacing = 4
        return verticalStack
    }()
    private let padding: CGFloat = 50
    private var constraint: NSLayoutConstraint!
    
    
    
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
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    // MARK: - Overriden methods
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        viewsLabel.textColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
        ratingLabel.textColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
        viewsView.tintColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
        
        //Set dynamic font size
        guard previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory else { return }
        
        titleLabel.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Bold.rawValue,
                                            forTextStyle: .largeTitle)
        ratingLabel.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue,
                                             forTextStyle: .caption2)
        viewsLabel.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue,
                                            forTextStyle: .caption2)
        guard let constraint_1 = titleLabel.getAllConstraints().filter({$0.identifier == "height"}).first,
              let constraint_2 = bottomView.getAllConstraints().filter({$0.identifier == "height"}).first,
              let item = item else { return }
        setNeedsLayout()
        constraint_1.constant = item.title.height(withConstrainedWidth: titleLabel.bounds.width,
                                                  font: titleLabel.font)
        constraint_2.constant = String(describing: item.rating).height(withConstrainedWidth: ratingLabel.bounds.width,
                                                                       font: ratingLabel.font)
        layoutIfNeeded()
        
    }
}

// MARK: - Private
private extension PollTitleCell {
    @MainActor
    func setupUI() {
        backgroundColor = .clear
        clipsToBounds = true
        
        bottomView.addSubview(horizontalStack)
        //        bottomView_2.addSubview(horizontalStack_2)
        horizontalStack.translatesAutoresizingMaskIntoConstraints = false
        //        horizontalStack_2.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            horizontalStack.heightAnchor.constraint(equalTo: bottomView.heightAnchor),
            horizontalStack.centerXAnchor.constraint(equalTo: bottomView.centerXAnchor),
            horizontalStack.centerYAnchor.constraint(equalTo: bottomView.centerYAnchor),
            //                    horizontalStack_2.heightAnchor.constraint(equalTo: bottomView_2.heightAnchor),
            //                    horizontalStack_2.centerXAnchor.constraint(equalTo: bottomView_2.centerXAnchor),
            //                    horizontalStack_2.centerYAnchor.constraint(equalTo: bottomView_2.centerYAnchor),
        ])
        contentView.addSubview(verticalStack)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        verticalStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            verticalStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
            verticalStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            verticalStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])
        
        //        constraint = bottomView_2.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding)
        constraint = bottomView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -50)
        constraint.priority = .defaultLow
        constraint.isActive = true
        
    }
    
    @MainActor
    func updateUI() {
        guard let constraint = titleLabel.getConstraint(identifier: "height") else { return }
        
        setNeedsLayout()
        constraint.constant = item.title.height(withConstrainedWidth: titleLabel.bounds.width, font: titleLabel.font)
        layoutIfNeeded()
    }
}
