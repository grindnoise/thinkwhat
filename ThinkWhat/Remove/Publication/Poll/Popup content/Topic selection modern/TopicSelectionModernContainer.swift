//
//  TopicSelectionModernContainer.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 05.06.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class TopicSelectionModernContainer: UIView {
    
    // MARK: - Initialization
    init(isModal: Bool, callbackDelegate: CallbackObservable) {
        super.init(frame: .zero)
        self.callbackDelegate = callbackDelegate
        self.isCancelEnabled = !isModal
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
        if #available(iOS 14, *) {
            TopicSelectionModernCollectionView(callbackDelegate: self).addEquallyTo(to: collectionContainer)
        }
        setObservers()
        setupUI()
    }
    
    private func setupUI() {
        setText()
        guard !isCancelEnabled else { return }
        stackView.removeArrangedSubview(cancel)
        cancel.alpha = 0
        let outerColor = UIColor.clear.cgColor
        let innerColor = traitCollection.userInterfaceStyle == .dark ? UIColor.secondarySystemBackground.cgColor : UIColor.white.cgColor
        
        hMaskLayer = CAGradientLayer()// layer];
        hMaskLayer.colors = [outerColor, innerColor,innerColor,outerColor]
        hMaskLayer.locations = [0.0, 0.1, 0.9, 1.0]
        hMaskLayer.frame = contentView.frame;
        hMaskLayer.startPoint = CGPoint(x: 0, y: 0.5);
        hMaskLayer.endPoint = CGPoint(x: 1.0, y: 0.5);
//        contentView.layer.mask = hMaskLayer
    }
    
    private func setObservers() {
//        observers.append(buttonsContainer.observe(\UIView.bounds, options: [NSKeyValueObservingOptions.new]) { [weak self] (view: UIView, change: NSKeyValueObservedChange<CGRect>) in
//            guard let self = self,
//                  let constraint = self.buttonsContainer.getAllConstraints().filter({ $0.identifier == "height" }).first else { return }
//            self.setNeedsLayout()
//            constraint.constant = 0
//            self.layoutIfNeeded()
//        })
    }
    
    private func setText() {
        let fontSize: CGFloat = title.bounds.height * 0.3
        let paragraph = NSMutableParagraphStyle()
        if #available(iOS 15.0, *) {
            paragraph.usesDefaultHyphenation = true
        } else {
            paragraph.hyphenationFactor = 1
        }
        paragraph.alignment = .center
        
        let topicTitleString = NSMutableAttributedString()
        topicTitleString.append(NSAttributedString(string: "choose_topic".localized, attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: fontSize), foregroundColor: .label, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        title.attributedText = topicTitleString
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        cancel.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : .systemGray
        confirm.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
        let outerColor = UIColor.clear.cgColor
        let innerColor = traitCollection.userInterfaceStyle == .dark ? UIColor.secondarySystemBackground.cgColor : UIColor.white.cgColor
        hMaskLayer.colors = [outerColor, innerColor,innerColor,outerColor]
    }
    
    @objc
    private func handleTap(_ recognizer: UITapGestureRecognizer) {
        if let v = recognizer.view {
            if v === confirm {
                callbackDelegate?.callbackReceived(topic as Any)
            } else {
                callbackDelegate?.callbackReceived("exit" as Any)
            }
        }
    }
    
    // MARK: - IB outlets
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var collectionContainer: UIView!
    @IBOutlet weak var buttonsContainer: UIView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var cancel: UIImageView! {
        didSet {
            cancel.isUserInteractionEnabled = true
            cancel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:))))
            cancel.tintColor = isCancelEnabled ? traitCollection.userInterfaceStyle == .dark ? .systemBlue : .systemGray : .secondaryLabel
        }
    }
    @IBOutlet weak var confirm: UIImageView! {
        didSet {
            confirm.isUserInteractionEnabled = true
            confirm.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:))))
            confirm.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
        }
    }
    
    // MARK: - Properties
    private var isCancelEnabled = true
    private weak var callbackDelegate: CallbackObservable?
    private var hMaskLayer: CAGradientLayer!
    private var topic: Topic? {
        didSet {
            guard oldValue.isNil, !topic.isNil else { return }
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut) {
                guard let constraint = self.buttonsContainer.getAllConstraints().filter({ $0.identifier == "height" }).first else { return }
                self.setNeedsLayout()
                constraint.constant = self.title.frame.height
                self.layoutIfNeeded()
            }
        }
    }
    private var observers: [NSKeyValueObservation] = []
}

extension TopicSelectionModernContainer: CallbackObservable {
    func callbackReceived(_ sender: Any) {
        if let instance = sender as? Topic {
            topic = instance
        }
    }
}
