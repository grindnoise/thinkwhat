//
//  FeedbackView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 12.10.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class FeedbackView: UIView {

    // MARK: - Public properties
    weak var viewInput: (UIViewController & FeedbackViewInput)?
    
    
    
    // MARK: - Private properties
    private var observers: [NSKeyValueObservation] = []
    private var subscriptions = Set<AnyCancellable>()
    private var tasks: [Task<Void, Never>?] = []
    //Logic
    private var state: ButtonState = .Send
    //UI
    private let padding: CGFloat = 16
    private lazy var textView: UITextView = {
        let instance = UITextView()
        instance.contentInset = UIEdgeInsets.uniform(size: 10)
        instance.backgroundColor = .secondarySystemBackground
        instance.font = UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .body)
        instance.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
        instance.publisher(for: \.bounds)
            .sink { rect in
                instance.cornerRadius = rect.width * 0.05
            }
            .store(in: &subscriptions)
        
        return instance
    }()
    private lazy var actionButton: UIButton = {
        let instance = UIButton()
        
        instance.addTarget(self, action: #selector(self.send), for: .touchUpInside)
        if #available(iOS 15, *) {
            let attrString = AttributedString(state.rawValue.localized.uppercased(), attributes: AttributeContainer([
                NSAttributedString.Key.font: UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .title2) as Any,
                NSAttributedString.Key.foregroundColor: UIColor.white
            ]))
            var config = UIButton.Configuration.filled()
            config.attributedTitle = attrString
            config.baseBackgroundColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
            config.image = UIImage(systemName: "paperplane.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .large))
            config.imagePlacement = .trailing
            config.imagePadding = 8.0
            config.contentInsets.leading = 20
            config.contentInsets.trailing = 20
            config.buttonSize = .large

            instance.configuration = config
        } else {
            let attrString = NSMutableAttributedString(string: state.rawValue.localized.uppercased(), attributes: [
                NSAttributedString.Key.font: UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .title2) as Any,
                NSAttributedString.Key.foregroundColor: UIColor.white
            ])
            instance.titleEdgeInsets.left = 20
            instance.titleEdgeInsets.right = 20
            instance.setImage(UIImage(systemName: "paperplane.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .large)), for: .normal)
            instance.imageView?.tintColor = .white
            instance.imageEdgeInsets.left = 8
//            instance.imageEdgeInsets.right = 8
            instance.setAttributedTitle(attrString, for: .normal)
            instance.semanticContentAttribute = .forceRightToLeft
            instance.backgroundColor = K_COLOR_RED//traitCollection.userInterfaceStyle == .dark ? .systemBlue : .systemRed

            let constraint = instance.widthAnchor.constraint(equalToConstant: state.rawValue.localized.uppercased().width(withConstrainedHeight: instance.bounds.height, font: UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .title2)!))
            constraint.identifier = "width"
            constraint.isActive = true
        }
        
        observers.append(instance.observe(\UIButton.bounds, options: .new) { [weak self] view, change in
            guard let self = self,
                  let newValue = change.newValue
            else { return }
            
            view.cornerRadius = newValue.height/2.25
            
            guard let constraint = view.getConstraint(identifier: "width") else { return }
            self.setNeedsLayout()
            constraint.constant = self.state.rawValue.localized.uppercased().width(withConstrainedHeight: instance.bounds.height, font: UIFont.scaledFont(fontName: Fonts.OpenSans.Bold.rawValue, forTextStyle: .title2)!) + 40 + (view.imageView?.bounds.width ?? 0) + 60
            self.layoutIfNeeded()
        })

        return instance
    }()
    private lazy var bottomContainer: UIView = {
        let instance = UIView()
        instance.backgroundColor = .clear
        instance.addSubview(actionButton)
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            actionButton.topAnchor.constraint(equalTo: instance.topAnchor),
            actionButton.bottomAnchor.constraint(equalTo: instance.bottomAnchor),
            actionButton.centerXAnchor.constraint(equalTo: instance.centerXAnchor),
        ])
        
        return instance
    }()
    
    private lazy var stack: UIStackView = {
        let instance = UIStackView(arrangedSubviews: [textView, bottomContainer])
        instance.axis = .vertical
        instance.spacing = padding
        
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
        
        setupUI()
        setTasks()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    // MARK: - Overriden methods
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        textView.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
        
        if #available(iOS 15, *) {
            guard !actionButton.configuration.isNil else { return }
            actionButton.configuration?.baseBackgroundColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
        } else {
            actionButton.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : .systemRed
        }
        
        //Set dynamic font size
        guard previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory else { return }
    }
}

extension FeedbackView: FeedbackControllerOutput {}

private extension FeedbackView {
    func setupUI() {
        backgroundColor = .systemBackground
        
        addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        textView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: padding),
            stack.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: padding),
            stack.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -padding),
            textView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.35),
        ])
        
        let touch = UITapGestureRecognizer(target: self, action:#selector(self.hideKeyboard))
        addGestureRecognizer(touch)
    }
    
    func setTasks() {
        tasks.append(Task { @MainActor [weak self] in
            for await _ in NotificationCenter.default.notifications(for: Notifications.System.FeedbackSent) {
                guard let self = self else { return }

                self.onSuccessCallback()
            }
        })
        //Error
        tasks.append(Task { @MainActor [weak self] in
            for await _ in NotificationCenter.default.notifications(for: Notifications.System.FeedbackFailure) {
                guard let self = self else { return }

                self.onFailureCallback()
            }
        })
    }
    
    func onSuccessCallback() {
        state = .Back
        actionButton.isUserInteractionEnabled = true
        
        textView.isEditable = false
        
        showBanner(bannerDelegate: self, text: "feedback_sent".localized,
                   content: UIImageView(image: UIImage(systemName: "envelope.fill",
                                                       withConfiguration: UIImage.SymbolConfiguration(scale: .small))),
                   color: UIColor.white,
                   textColor: .white,
                   dismissAfter: 0.75,
                   backgroundColor: UIColor.systemGreen,
                   shadowed: true)
        
        if #available(iOS 15, *) {
            guard !actionButton.configuration.isNil else { return }
            
            let attrString = AttributedString(state.rawValue.localized.uppercased(), attributes: AttributeContainer([
                NSAttributedString.Key.font: UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .title2) as Any,
                NSAttributedString.Key.foregroundColor: UIColor.white
            ]))
            self.actionButton.configuration!.showsActivityIndicator = false
            self.actionButton.configuration!.imagePlacement = .leading
            UIView.transition(with: self.actionButton, duration: 0.15, options: .transitionCrossDissolve) {
                self.actionButton.configuration!.attributedTitle = attrString
                self.actionButton.configuration!.image = UIImage(systemName: "arrow.counterclockwise", withConfiguration: UIImage.SymbolConfiguration(weight: .bold))
            }
        } else {
            guard let indicator = actionButton.getSubview(type: UIActivityIndicatorView.self, identifier: "indicator") else { return }
            
            UIView.animate(withDuration: 0.25) {
                indicator.alpha = 0
            } completion: { _ in
                indicator.removeFromSuperview()
                let attrString = NSMutableAttributedString(string: self.state.rawValue.localized.uppercased(), attributes: [
                    NSAttributedString.Key.font: UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .title2) as Any,
                    NSAttributedString.Key.foregroundColor: UIColor.white
                ])
//                self.actionButton.semanticContentAttribute = .forceLeftToRight
                self.actionButton.titleEdgeInsets.left = 20
                self.actionButton.titleEdgeInsets.right = 20
                self.actionButton.setImage(UIImage(systemName: "arrow.backward", withConfiguration: UIImage.SymbolConfiguration(weight: .bold)), for: .normal)
                self.actionButton.imageView?.tintColor = .white
                self.actionButton.imageEdgeInsets.left = 8
                self.actionButton.setAttributedTitle(attrString, for: .normal)
                self.actionButton.semanticContentAttribute = .forceRightToLeft
            }
        }
    }

    func onFailureCallback() {
        state = .Send
        actionButton.isUserInteractionEnabled = true
        
        showBanner(bannerDelegate: self, text: AppError.server.localizedDescription.localized,
                   content: UIImageView(image: UIImage(systemName: "exclamationmark.triangle.fill",
                                                       withConfiguration: UIImage.SymbolConfiguration(scale: .small))),
                   color: UIColor.white,
                   textColor: .white,
                   dismissAfter: 0.75,
                   backgroundColor: UIColor.systemRed,
                   shadowed: true)
        
        if #available(iOS 15, *) {
            guard !actionButton.configuration.isNil else { return }
            
            let attrString = AttributedString(state.rawValue.localized.uppercased(), attributes: AttributeContainer([
                NSAttributedString.Key.font: UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .title2) as Any,
                NSAttributedString.Key.foregroundColor: UIColor.white
            ]))
            self.actionButton.configuration!.showsActivityIndicator = false
            UIView.transition(with: self.actionButton, duration: 0.15, options: .transitionCrossDissolve) {
                self.actionButton.configuration!.attributedTitle = attrString
                self.actionButton.setImage(UIImage(systemName: "paperplane.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .large)), for: .normal)
            }
        } else {
            guard let indicator = actionButton.getSubview(type: UIActivityIndicatorView.self, identifier: "indicator") else { return }
            
            UIView.animate(withDuration: 0.2) {
                indicator.alpha = 0
            } completion: { _ in
                indicator.removeFromSuperview()
                let attrString = NSMutableAttributedString(string: self.state.rawValue.localized.uppercased(), attributes: [
                    NSAttributedString.Key.font: UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .title2) as Any,
                    NSAttributedString.Key.foregroundColor: UIColor.white
                ])
                self.actionButton.titleEdgeInsets.left = 20
                self.actionButton.titleEdgeInsets.right = 20
                self.actionButton.setImage(UIImage(systemName: "paperplane.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .large)), for: .normal)
                self.actionButton.imageView?.tintColor = .white
                self.actionButton.imageEdgeInsets.left = 8
                self.actionButton.setAttributedTitle(attrString, for: .normal)
                self.actionButton.semanticContentAttribute = .forceRightToLeft
            }
        }
    }
    
    @objc
    private func send() {
        
        endEditing(true)
        
        switch state {
        case .Send:
            
            state = .Sending
            viewInput?.sendFeedback(textView.text)
            actionButton.isUserInteractionEnabled = false
            
            if #available(iOS 15, *) {
                if !actionButton.configuration.isNil {
                    let attrString = AttributedString(state.rawValue.localized.uppercased(), attributes: AttributeContainer([
                        NSAttributedString.Key.font: UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .title2) as Any,
                        NSAttributedString.Key.foregroundColor: UIColor.white
                    ]))
                    UIView.transition(with: actionButton, duration: 0.15, options: .transitionCrossDissolve) {
                        self.actionButton.configuration!.attributedTitle = attrString
                    }
                    actionButton.configuration!.showsActivityIndicator = true
                    //                delayAsync(delay: 2) { [weak self] in
                    //                    self?.onSuccessCallback()
                    //                }
                }
            } else {
                actionButton.setImage(UIImage(), for: .normal)
                actionButton.setAttributedTitle(nil, for: .normal)
                let indicator = UIActivityIndicatorView(frame: CGRect(origin: .zero,
                                                                      size: CGSize(width: actionButton.frame.height,
                                                                                   height: actionButton.frame.height)))
                indicator.alpha = 0
                indicator.layoutCentered(in: actionButton)
                indicator.startAnimating()
                indicator.color = .white
                indicator.accessibilityIdentifier = "indicator"
                UIView.animate(withDuration: 0.2) { indicator.alpha = 1 }
                
                //        delayAsync(delay: 2) { [weak self] in
                ////            self?.onSuccessCallback()
                //            self?.onFailureCallback()
                //        }
            }
        case .Back:
            viewInput?.navigationController?.popViewController(animated: true)
        default:
            print("")
        }
    }
    
    @objc
    func hideKeyboard() {
        endEditing(true)
    }
}

extension FeedbackView: BannerObservable {
    func onBannerWillAppear(_ sender: Any) {}
    
    func onBannerWillDisappear(_ sender: Any) {}
    
    func onBannerDidAppear(_ sender: Any) {}
    
    func onBannerDidDisappear(_ sender: Any) {
        if let banner = sender as? Banner {
            banner.removeFromSuperview()
        } else if let banner = sender as? Popup {
            banner.removeFromSuperview()
        }
    }
}
