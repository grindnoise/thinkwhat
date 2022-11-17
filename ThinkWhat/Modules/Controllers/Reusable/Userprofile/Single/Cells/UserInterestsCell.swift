//
//  UserInterestsCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 03.11.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class UserInterestsCell: UICollectionViewListCell {
    
    // MARK: - Public properties
    public weak var userprofile: Userprofile! {
        didSet {
            guard let userprofile = userprofile else { return }
            
            collectionView.userprofile = userprofile
        }
    }
    //Publishers
    public let topicPublisher = PassthroughSubject<Topic, Never>()
    
    
    
    // MARK: - Private properties
    private var observers: [NSKeyValueObservation] = []
    private var subscriptions = Set<AnyCancellable>()
    private var tasks: [Task<Void, Never>?] = []
    //UI
    private let padding: CGFloat = 16
    private lazy var background: UIView = {
       let instance = UIView()
        instance.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
        instance.publisher(for: \.bounds, options: .new)
            .sink { rect in
                instance.cornerRadius = rect.width*0.05
            }
            .store(in: &subscriptions)
        stack.place(inside: instance,
                    insets: .uniform(size: padding),
                    bottomPriority: .defaultLow)
        
        return instance
    }()
    private lazy var stack: UIStackView = {
        let instance = UIStackView(arrangedSubviews: [
            label,
            collectionView
        ])
        instance.axis = .vertical
        instance.spacing = 8
        
        return instance
    }()
    private lazy var label: UILabel = {
        let instance = UILabel()
        instance.textColor = .secondaryLabel
        instance.text = "interests".localized.uppercased()
        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .footnote)
        
        let heightConstraint = instance.heightAnchor.constraint(equalToConstant: instance.text!.height(withConstrainedWidth: 1000, font: instance.font))
        heightConstraint.identifier = "height"
        heightConstraint.priority = .defaultHigh
        heightConstraint.isActive = true
        
        instance.publisher(for: \.bounds, options: .new)
            .sink { [weak self] rect in
                guard let self = self,
                      let constraint = instance.getConstraint(identifier: "height")
                else { return }
                
                self.setNeedsLayout()
                constraint.constant = instance.text!.height(withConstrainedWidth: 1000, font: instance.font)
                self.layoutIfNeeded()
            }
            .store(in: &subscriptions)

        return instance
    }()
    private lazy var collectionView: InterestsCollectionView = {
        let instance = InterestsCollectionView()
        instance.backgroundColor = .clear
        
        let constraint = instance.heightAnchor.constraint(equalToConstant: 100)
        constraint.priority = .defaultHigh
        constraint.identifier = "height"
        constraint.isActive = true
        
        instance.publisher(for: \.contentSize, options: .new)
            .sink { [weak self] rect in
                guard let self = self,
                      let constraint = instance.getConstraint(identifier: "height")
                else { return }
                
                self.setNeedsLayout()
                constraint.constant = rect.height
                self.layoutIfNeeded()
            }
            .store(in: &subscriptions)

        instance.interestPublisher
            .sink { [weak self] in
                guard let self = self,
                      let topic = $0
                else { return }
                
                self.topicPublisher.send(topic)
            }
            .store(in: &subscriptions)
        
//        let stack = UIStackView(arrangedSubviews: [tiktokIcon, tiktokTextField, tiktokButton])
//        stack.axis = .horizontal
//        stack.spacing = 8
//
//        instance.addSubview(stack)
//        stack.translatesAutoresizingMaskIntoConstraints = false
//
//        NSLayoutConstraint.activate([
//            stack.leadingAnchor.constraint(equalTo: instance.leadingAnchor, constant: 0),
//            stack.trailingAnchor.constraint(equalTo: instance.trailingAnchor, constant: -0),
//            stack.topAnchor.constraint(equalTo: instance.topAnchor),
//            stack.bottomAnchor.constraint(equalTo: instance.bottomAnchor),
//        ])
        
        return instance
    }()
    
    
    // MARK: - Destructor
    deinit {
        observers.forEach { $0.invalidate() }
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
        
        //Set dynamic font size
        guard previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory else { return }
        
    }
    
//    override func prepareForReuse() {
//        super.prepareForReuse()
//
//        urlPublisher = CurrentValueSubject<URL?, Never>(nil)
//        subscriptionPublisher = CurrentValueSubject<Bool?, Never>(nil)
//        imagePublisher = CurrentValueSubject<UIImage?, Never>(nil)
//    }
}

private extension UserInterestsCell {
    @MainActor
    func setupUI() {
        backgroundColor = .clear
        clipsToBounds = true
        
        background.place(inside: self,
                         insets: .uniform(size: padding))
//        contentView.addSubview(stack)
//        contentView.translatesAutoresizingMaskIntoConstraints = false
//        stack.translatesAutoresizingMaskIntoConstraints = false
//
//        NSLayoutConstraint.activate([
//            contentView.topAnchor.constraint(equalTo: topAnchor),
//            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
//            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
//            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
//            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
//            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
//            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
//        ])
//
//        let constraint = stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
//        constraint.priority = .defaultLow
//        constraint.identifier = "bottomAnchor"
//        constraint.isActive = true
    }
}

