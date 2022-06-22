//
//  CommentsSelection.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 17.06.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class CommentsSelection: UIView {
    
    // MARK: - Initialization
    init(option: PollCreationController.Comments, callbackDelegate: CallbackObservable) {
        super.init(frame: .zero)
        self.callbackDelegate = callbackDelegate
        self.option = option
        commonInit()
    }
    
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
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        setObservers()
        setupUI()
    }
    
    private func setupUI() {
//        setText()
    }
    
    private func setObservers() {
        observers.append(contentView.observe(\UIView.bounds, options: [NSKeyValueObservingOptions.new]) { [weak self ] (view, change) in
            guard let self = self else { return }
            self.setText()
        })
    }
    
    private func setText() {
        let titleString = NSMutableAttributedString()
        titleString.append(NSAttributedString(string: "comments".localized, attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: title.bounds.height * 0.4), foregroundColor: .label, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        title.attributedText = titleString
        
        let onString = NSMutableAttributedString()
        onString.append(NSAttributedString(string: "are_on".localized.uppercased(), attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: onTitle.bounds.width * 0.06), foregroundColor: isOn ? .label : .secondaryLabel, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        onTitle.attributedText = onString
        
        let offString = NSMutableAttributedString()
        offString.append(NSAttributedString(string: "are_off".localized.uppercased(), attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: offTitle.bounds.width * 0.06), foregroundColor: !isOn ? .label : .secondaryLabel, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        offTitle.attributedText = offString
        
        let description = NSMutableAttributedString()
        description.append(NSAttributedString(string: option == .On ? "comments_on_description".localized : "comments_off_description".localized, attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Light, size: descriptionLabel.bounds.width * 0.05), foregroundColor: .label, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        descriptionLabel.attributedText = description
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        confirm.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
//        onIcon.setIconColor(traitCollection.userInterfaceStyle == .dark ? .white : .label)
//        offIcon.setIconColor(traitCollection.userInterfaceStyle == .dark ? .white : .label)
    }
    
    @objc
    private func handleTap(recognizer: UITapGestureRecognizer) {
        if recognizer.state == .ended {
            guard let v = recognizer.view else { return }
            if let icon = v as? Icon {
                let selectedIcon: Icon! = icon == onIcon ? onIcon : offIcon
                let deselectedIcon: Icon! = icon != onIcon ? onIcon : offIcon
                
                if isOn && icon == onIcon || !isOn && icon == offIcon {
                    return
                }
                
                let enableAnim  = Animations.get(property: .FillColor,
                                                 fromValue: selectedIcon.iconColor.cgColor,
                                                 toValue: traitCollection.userInterfaceStyle == .dark ? UIColor.systemBlue.cgColor : UIColor.label.cgColor,
                                                 duration: 0.3,
                                                 timingFunction: CAMediaTimingFunctionName.easeInEaseOut,
                                                 delegate: nil,
                                                 isRemovedOnCompletion: true)
                let disableAnim = Animations.get(property: .FillColor,
                                                 fromValue: deselectedIcon.iconColor.cgColor,//K_COLOR_RED.cgColor,
                                                 toValue: UIColor.systemGray.cgColor,
                                                 duration: 0.3,
                                                 timingFunction: CAMediaTimingFunctionName.easeInEaseOut,
                                                 delegate: nil,
                                                 isRemovedOnCompletion: true)
                
                selectedIcon.icon.add(enableAnim, forKey: nil)
                (selectedIcon.icon as! CAShapeLayer).fillColor = traitCollection.userInterfaceStyle == .dark ? UIColor.systemBlue.cgColor : UIColor.label.cgColor
                deselectedIcon.icon.add(disableAnim, forKey: nil)
                (deselectedIcon.icon as! CAShapeLayer).fillColor = UIColor.systemGray.cgColor
                
                UIView.animate(
                    withDuration: 0.3,
                    delay: 0,
                    usingSpringWithDamping: 0.55,
                    initialSpringVelocity: 2.5,
                    options: [.curveEaseInOut],
                    animations: {
                        selectedIcon.superview!.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                    }) { _ in }
                option = option == .On ? .Off : .On
                //                if !isFirstSelection {
                deselectedIcon.icon.add(disableAnim, forKey: nil)
                UIView.animate(withDuration: 0.15, delay: 0, options: [.curveEaseInOut], animations: {
                    deselectedIcon.superview!.transform = .identity
                })
                setText()
                //                }
                //                isFirstSelection = false
            } else if v == confirm {
                callbackDelegate?.callbackReceived(option as Any)
            }
        }
    }
    
    // MARK: - IB outlets
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var confirm: UIImageView! {
        didSet {
            confirm.isUserInteractionEnabled = true
            confirm.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap(recognizer:))))
            confirm.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
        }
    }
    @IBOutlet weak var onIcon: Icon! {
        didSet {
            onIcon.iconColor = isOn ? (traitCollection.userInterfaceStyle == .dark ? UIColor.systemBlue : UIColor.label) : .systemGray
            onIcon.category = .Comments
            onIcon.isRounded = false
            onIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap(recognizer:))))
            onIcon.superview!.transform = isOn ? CGAffineTransform(scaleX: 1.3, y: 1.3) : .identity
        }
    }
    @IBOutlet weak var onTitle: ArcLabel!
    @IBOutlet weak var offIcon: Icon! {
        didSet {
            offIcon.iconColor = !isOn ? (traitCollection.userInterfaceStyle == .dark ? UIColor.systemBlue : UIColor.label) : .systemGray
            offIcon.category = .CommentsDisabled
            offIcon.isRounded = false
            offIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap(recognizer:))))
            offIcon.superview!.transform = !isOn ? CGAffineTransform(scaleX: 1.3, y: 1.3) : .identity
        }
    }
    @IBOutlet weak var offTitle: ArcLabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    // MARK: - Properties
    private var isOn: Bool {
        get {
            return option == .On ? true : false
        }
    }
    private var isFirstSelection = true
    private var option: PollCreationController.Comments = .On {
        didSet {
            UIView.transition(with: descriptionLabel, duration: 0.2, options: .transitionCrossDissolve) {
                self.setText()
            } completion: { _ in }
        }
    }
    private weak var callbackDelegate: CallbackObservable?
    private var observers: [NSKeyValueObservation] = []
}
