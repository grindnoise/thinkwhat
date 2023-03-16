//
//  VoteCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 08.07.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
//import Combine

class VotesCell: UICollectionViewCell {
    
    // MARK: - Public properties
//    public var color: UIColor! = .clear {
//        didSet {
////            guard !color.isNil else { return }
//            button.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
//        }
//    }
    public weak var answer: Answer?
//    public lazy var colorSubscriber: ColorSubscriber = {
//        let instance = ColorSubscriber()
//        let color = instance.receive()
//
//        return instance
//    }()
    var color: UIColor = .clear {
        didSet {
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.2, delay: 0) { [weak self] in
                guard let self = self else { return }
                self.button.backgroundColor = self.color
            }
        }
    }
    weak var callbackDelegate: CallbackObservable?
    
    // MARK: - Private properties
    private lazy var button: UIButton = {
        let instance = UIButton()
        instance.tintColor = .white
        instance.addTarget(self, action: #selector(self.handleTap), for: .touchUpInside)
        instance.setTitle("vote".localized.uppercased(), for: .normal)
        instance.backgroundColor = color
        instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 4/1).isActive = true
        
        observers.append(instance.observe(\UIButton.bounds, options: [.new]) { view, change in
            guard let value = change.newValue else { return }
            view.cornerRadius = value.height / 2.25
        })
        
        return instance
    }()
    private var observers: [NSKeyValueObservation] = []
    private let padding: CGFloat = 0
    
    // MARK: - Destructor
    deinit {
        observers.forEach { $0.invalidate() }
        NotificationCenter.default.removeObserver(self)
#if DEBUG
        print("\(String(describing: type(of: self))).\(#function)")
#endif
    }


    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func commonInit() {
        setObservers()
        setupUI()
    }

    // MARK: - UI methods
    private func setupUI() {
        backgroundColor = .clear
        clipsToBounds = true
        
        contentView.addSubview(button)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            button.topAnchor.constraint(equalTo: contentView.topAnchor),
            button.heightAnchor.constraint(equalToConstant: 50),
            button.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
        ])
        
        let constraint = contentView.bottomAnchor.constraint(equalTo: button.bottomAnchor, constant: 50)
        constraint.priority = .defaultLow
        constraint.isActive = true
    }
    
    private func setObservers() {
        
    }
    
//    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
//        super.traitCollectionDidChange(previousTraitCollection)
//        button.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
//    }

    @objc
    private func handleTap() {
        guard !answer.isNil else { return }
        callbackDelegate?.callbackReceived(answer as Any)
        button.setTitle("", for: .normal)
        let indicator = UIActivityIndicatorView(frame: CGRect(origin: .zero,
                                                              size: CGSize(width: button.frame.height,
                                                                           height: button.frame.height)))
        indicator.alpha = 0
        indicator.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        indicator.layoutCentered(in: button)
        indicator.startAnimating()
        indicator.color = .white
        UIView.animate(withDuration: 0.2) {
            indicator.alpha = 1
            indicator.transform = .identity
        }
        isUserInteractionEnabled = false
    }
}
