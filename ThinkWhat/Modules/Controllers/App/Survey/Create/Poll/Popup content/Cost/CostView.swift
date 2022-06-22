//
//  CostView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 22.06.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

struct CostItem: Hashable {
    let id = UUID()
    var title: String
    var cost: Int
}

class CostView: UIView {
    
    // MARK: - Initialization
    init(callbackDelegate: CallbackObservable, controller: PollCreationViewInput?, poll: Survey?) {
        super.init(frame: .zero)
        self.callbackDelegate   = callbackDelegate
        self.controller         = controller
        self.poll               = poll
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
        guard !poll.isNil else {
            stackView.removeArrangedSubview(confirm)
            confirm.alpha = 0
            return
        }
        stackView.removeArrangedSubview(cancel)
        cancel.alpha = 0
    }
    
    private func setObservers() {
        observers.append(observe(\CostView.bounds, options: [NSKeyValueObservingOptions.new]) { [weak self] (view, change) in
            guard let self = self else { return }
            self.setText()
        })
    }
    
    private func setText() {
        let titleString = NSMutableAttributedString()
        titleString.append(NSAttributedString(string: "cost".localized, attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: title.bounds.height * 0.4), foregroundColor: .label, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        title.attributedText = titleString
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        confirm.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
        cancel.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : .systemGray
    }
    
    @objc
    private func handleTap(recognizer: UITapGestureRecognizer) {
        if recognizer.state == .ended {
            guard let v = recognizer.view else { return }
            if v == confirm {
//                controller?.post(poll)
            } else if v == cancel {
                callbackDelegate?.callbackReceived("exit")
            }
        }
    }
    
    // MARK: - IB outlets
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var collectionContainer: UIView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var confirm: UIImageView! {
        didSet {
            confirm.isUserInteractionEnabled = true
            confirm.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap(recognizer:))))
            confirm.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
        }
    }
    @IBOutlet weak var cancel: UIImageView! {
        didSet {
            cancel.isUserInteractionEnabled = true
            cancel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap(recognizer:))))
            cancel.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : .label
        }
    }
    
    // MARK: - Properties
    private weak var callbackDelegate: CallbackObservable?
    private weak var controller: PollCreationViewInput?
    private weak var collectionView: UICollectionView?
    private var observers: [NSKeyValueObservation] = []
    private var poll: Survey?
}

