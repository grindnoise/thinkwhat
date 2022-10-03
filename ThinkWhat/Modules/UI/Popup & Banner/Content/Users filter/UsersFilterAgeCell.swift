//
//  UsersFilterAgeCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 27.09.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine
import TTRangeSlider

class UsersFilterAgeCell: UICollectionViewCell {
    
    // MARK: - Overridden properties
    
    
    
    // MARK: - Public properties
    public var selectedMinAge: Int = 18 {
        didSet {
            setupSlider()
        }
    }
    public var selectedMaxAge: Int = 99 {
        didSet {
            setupSlider()
        }
    }
    //Subsribers
    public var minAgeSubscriber = PassthroughSubject<Int?, Never>()
    public var maxAgeSubscriber = PassthroughSubject<Int?, Never>()
    //Publishers
    public var agePublisher = CurrentValueSubject<[Int: Int]?, Never>(nil)
    
    
    // MARK: - Private properties
    private var observers: [NSKeyValueObservation] = []
    private var subscriptions = Set<AnyCancellable>()
    private var tasks: [Task<Void, Never>?] = []
    
    //Logic
    private let minAge = 18
    private let maxAge = 99
    
    
    //UI
    private let padding: CGFloat = 8
    private lazy var rangeSlider: TTRangeSlider = {
        let instance = TTRangeSlider()
        instance.hideLabels = false
        instance.handleColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
        instance.tintColorBetweenHandles = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
        instance.lineBorderWidth = 16
        instance.lineHeight = 2
        instance.tintColor = .systemGray
        instance.lineBorderColor = .systemGray
//        instance.handleDiameter = 24
        instance.selectedHandleDiameterMultiplier = 1.3
        instance.maxLabelFont = UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .caption1)
        instance.minLabelFont = UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .caption1)
        instance.minValue = 18
        instance.maxValue = 99
        instance.addTarget(self, action: #selector(self.onValueChanged(sender:)), for: .valueChanged)
        instance.publisher(for: \.bounds, options: .new)
            .sink { rect in
                instance.handleDiameter = rect.height * 0.5
            }
            .store(in: &subscriptions)
        
        return instance
    }()
    private lazy var label: UILabel = {
       let instance = UILabel()
        instance.text = "age".localized.capitalized
        instance.textColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
        instance.textAlignment = .left
        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .headline)
//        instance.publisher(for: \.bounds, options: .new)
//            .sink { [weak self] rect in
//                guard let self = self,
//                      instance.getConstraint(identifier: "height").isNil,
//                      let text = instance.text
//                else { return }
//
//                let constraint = instance.heightAnchor.constraint(equalToConstant: text.height(withConstrainedWidth: 300, font: instance.font) + 10)
//                constraint.identifier = "height"
//                constraint.isActive = true
//            }
//            .store(in: &subscriptions)
        
        return instance
    }()
    private lazy var horizontalStack: UIStackView = {
       let instance = UIStackView(arrangedSubviews: [label, rangeSlider])
        instance.axis = .horizontal
        instance.spacing = 8
        instance.clipsToBounds = false
        instance.layer.masksToBounds = false
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.widthAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 0.25)
        ])
        
        return instance
    }()
    
    // MARK: - Deinitialization
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
        super.init(frame: .zero)
        
        setupUI()
        setTasks()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    // MARK: - Public methods
    
    
    
    // MARK: - Overridden methods
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        label.textColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
        rangeSlider.handleColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
        rangeSlider.tintColorBetweenHandles = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED.withAlphaComponent(0.6)
    }
}

private extension UsersFilterAgeCell {

    @objc
    func onValueChanged(sender: TTRangeSlider) {
        agePublisher.send([Int(sender.selectedMinimum): Int(sender.selectedMaximum)])
    }
    
    func setupUI() {
        contentView.backgroundColor = .clear
        clipsToBounds = false
        
        contentView.addSubview(horizontalStack)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        horizontalStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            horizontalStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
            horizontalStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding*2),
            horizontalStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            horizontalStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding)
        ])
        
//        let constraint = verticalStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding)
//        constraint.priority = .defaultLow
//        constraint.isActive = true
    }
    
    func setTasks() {
//        tasks.append( Task {@MainActor [weak self] in
//            for await notification in NotificationCenter.default.notifications(for: <# notification #>) {
//                guard let self = self else { return }
//
//
//            }
//        })
    }
    
    func setupSlider() {
        rangeSlider.selectedMinimum = Float(selectedMinAge)
        rangeSlider.selectedMaximum = Float(selectedMaxAge)
    }
}

