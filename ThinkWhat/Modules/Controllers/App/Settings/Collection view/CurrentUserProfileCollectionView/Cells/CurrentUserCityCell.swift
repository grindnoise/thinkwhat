//
//  CurrentUserCityCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 14.09.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class CurrentUserCityCell: UICollectionViewListCell {
    
    // MARK: - Public properties
    public var cityTitle: String = "" {
        didSet {
            guard cityTitle != oldValue else { return }
            
//            cityLabel.text = cityTitle
            textField.text = cityTitle
//            guard let constraint = cityLabel.getConstraint(identifier: "height") else { return }
            
//            setNeedsLayout()
//            constraint.constant = cityTitle.height(withConstrainedWidth: 300, font: cityLabel.font)
//            layoutIfNeeded()
        }
    }
    
    // MARK: - Private properties
    private var observers: [NSKeyValueObservation] = []
    private var subscriptions = Set<AnyCancellable>()
    private var tasks: [Task<Void, Never>?] = []
    //UI
    private let padding: CGFloat = 8
    private lazy var textField: UnderlinedSearchTextField = {
        let instance = UnderlinedSearchTextField()
        instance.text = cityTitle
        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .headline)
        
        return instance
    }()
//    private lazy var cityLabel: UILabel = {
//        let instance = UILabel()
//        instance.textColor = .label
//        instance.text = cityTitle
//        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .headline)
//
//        let constraint = instance.heightAnchor.constraint(equalToConstant: "test".height(withConstrainedWidth: 300, font: instance.font))
//        constraint.identifier = "height"
//        constraint.isActive = true
//
//        return instance
//    }()
    
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
        contentView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground.withAlphaComponent(0.35) : .secondarySystemBackground.withAlphaComponent(0.7)
        clipsToBounds = true
        
        contentView.addSubview(textField)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        textField.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            textField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
            textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
        ])
        
        let constraint = textField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding)
        constraint.priority = .defaultLow
        constraint.isActive = true
        
//        contentView.addSubview(cityLabel)
//        contentView.translatesAutoresizingMaskIntoConstraints = false
//        cityLabel.translatesAutoresizingMaskIntoConstraints = false
//
//        NSLayoutConstraint.activate([
//            contentView.topAnchor.constraint(equalTo: topAnchor),
//            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
//            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
//            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
//            cityLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
//            cityLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
////            cityLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
////            cityLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding),
//        ])
//
//        let constraint = cityLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding)
//        constraint.priority = .defaultLow
//        constraint.isActive = true
    }
    
    private func setTasks() {
//        //First name change
//        tasks.append( Task { [weak self] in
//            for await notification in NotificationCenter.default.notifications(for: Notifications.Userprofiles.FirstNameChanged) {
//                guard let self = self,
//                      let instance = notification.object as? Userprofile,
//                      instance.isCurrent
//                else { return }
//
//                self.setupLabels(animated: true)
//            }
//        })
    }
    
//    override func updateConstraints() {
//        super.updateConstraints()
//    
//        separatorLayoutGuide.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
//        separatorLayoutGuide.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
//    }
    
    // MARK: - Public methods
    public func selectCity() {
        
    }
    
    // MARK: - Overriden methods
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
        contentView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground.withAlphaComponent(0.35) : .secondarySystemBackground.withAlphaComponent(0.7)
    }
}
