//
//  ClaimPopupContent.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 17.08.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine
import CoreData

class ClaimPopupContent: UIView {
    
    private enum ButtonState: String {
        case Send = "sendButton"
        case Sending = "sending"
        case Close = "continueButton"
    }
    
    // MARK: - Public properties
    public var claimSubject = CurrentValueSubject<Claim?, Never>(nil)
    
    // MARK: - Private properties
    private var observers: [NSKeyValueObservation] = []
    private var subscriptions = Set<AnyCancellable>()
    private var tasks: [Task<Void, Never>?] = []
    private weak var parent: Popup?
    private weak var surveyReference: SurveyReference?
    private weak var callbackDelegate: CallbackObservable?
    private lazy var collectionView: ClaimCollectionView = {
        let instance = ClaimCollectionView()
        
        instance.claimSubject
            .filter { !$0.isNil }
            .map {
                return $0
            }
            .assign(to: &self.$item)
        
        observers.append(instance.observe(\ClaimCollectionView.contentSize, options: .new) { [weak self] view, change in
            guard let self = self,
                  let newValue = change.newValue
            else { return }
            
//            print(newValue.height + self.topContainer.bounds.height + self.bottomContainer.bounds.height)
            
            self.parent?.onContainerHeightChange(newValue.height +
                                                 self.topContainer.bounds.height +
                                                 self.bottomContainer.bounds.height +
                                                 self.verticalStackView.spacing * CGFloat(self.verticalStackView.arrangedSubviews.count - 1))
        })
        
        return instance
    }()
    private var state: ButtonState = .Send
    private lazy var label: UILabel = {
        let instance = UILabel()
        instance.alpha = 0
        instance.numberOfLines = 0
        instance.textAlignment = .center
        instance.addEquallyTo(to: middleContainer)
        
        let textContent_1 = "claim_sent".localized + "\n" + "\n"
        let textContent_2 = "thanks_for_feedback".localized
        let paragraph = NSMutableParagraphStyle()
        
        if #available(iOS 15.0, *) {
            paragraph.usesDefaultHyphenation = true
        } else {
            paragraph.hyphenationFactor = 1
        }
        paragraph.alignment = .center
        
        let attributedString = NSMutableAttributedString()
        attributedString.append(NSAttributedString(string: textContent_1,
                                                   attributes: [
                                                    NSAttributedString.Key.font: UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .title1) as Any,
                                                    NSAttributedString.Key.foregroundColor: UIColor.label,
                                                   ] as [NSAttributedString.Key : Any]))
        
        attributedString.append(NSAttributedString(string: textContent_2,
                                                   attributes: [
                                                    NSAttributedString.Key.font: UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .title2) as Any,
                                                    NSAttributedString.Key.foregroundColor: UIColor.label,
                                                   ] as [NSAttributedString.Key : Any]))
        instance.attributedText = attributedString
        
        return instance
    }()
    @Published private var item: Claim?
    
    // MARK: - UI properties
    private lazy var verticalStackView: UIStackView = {
        let instance = UIStackView(arrangedSubviews: [topContainer, middleContainer, bottomContainer])
        instance.axis = .vertical
        instance.spacing = 16
        
        topContainer.translatesAutoresizingMaskIntoConstraints = false
        bottomContainer.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            topContainer.heightAnchor.constraint(equalToConstant: 80),
            bottomContainer.heightAnchor.constraint(equalToConstant: 50),
        ])
        
        return instance
    }()
    private lazy var icon: Icon = {
        let instance = Icon()
        instance.backgroundColor = .clear
        instance.isRounded = false
        instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1/1).isActive = true
        instance.scaleMultiplicator = 0.8
        instance.iconColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : .systemRed
        instance.category = .ExclamationMark
        
        return instance
    }()
    private lazy var closeButton: UIButton = {
        let instance = UIButton()
        instance.backgroundColor = .clear
        instance.imageView?.tintColor = .secondaryLabel// traitCollection.userInterfaceStyle == .dark ? .systemBlue : .secondaryLabel
//        instance.imageView?.contentMode = .scaleAspectFit
        instance.addTarget(self, action: #selector(self.close), for: .touchUpInside)
        instance.heightAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 1/1).isActive = true
        
        observers.append(instance.observe(\UIButton.bounds, options: .new) { view, change in
            guard let newValue = change.newValue else { return }
            
            view.setImage(UIImage(systemName: "xmark", withConfiguration: UIImage.SymbolConfiguration(pointSize: newValue.height, weight: .bold)), for: .normal)
        })
        
        return instance
    }()
    private lazy var topContainer: UIView = {
        let instance = UIView()
        instance.backgroundColor = .clear
        instance.addSubview(closeButton)
        instance.addSubview(icon)
        icon.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: instance.topAnchor),
            closeButton.trailingAnchor.constraint(equalTo: instance.trailingAnchor),
            closeButton.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 0.25),
            icon.topAnchor.constraint(equalTo: closeButton.bottomAnchor),
            icon.bottomAnchor.constraint(equalTo: instance.bottomAnchor),
            icon.centerXAnchor.constraint(equalTo: instance.centerXAnchor),
        ])
        
        return instance
    }()
    private lazy var middleContainer: UIView = {
        let instance = UIView()
        instance.backgroundColor = .clear
        collectionView.addEquallyTo(to: instance)
//        instance.addSubview(collectionView)
//        collectionView.translatesAutoresizingMaskIntoConstraints = false
//
//        NSLayoutConstraint.activate([
//            collectionView.topAnchor.constraint(equalTo: instance.topAnchor),
//            collectionView.leadingAnchor.constraint(equalTo: instance.trailingAnchor),
//            collectionView.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 0.25),
//            icon.topAnchor.constraint(equalTo: closeButton.bottomAnchor),
//            icon.bottomAnchor.constraint(equalTo: instance.bottomAnchor),
//            icon.centerXAnchor.constraint(equalTo: instance.centerXAnchor),
//        ])
        
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
            config.baseBackgroundColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : .systemRed
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
            instance.backgroundColor = .secondaryLabel//traitCollection.userInterfaceStyle == .dark ? .systemBlue : .systemRed

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
    init(callbackDelegate: CallbackObservable, parent: Popup?, surveyReference: SurveyReference?) {
        super.init(frame: .zero)
        self.callbackDelegate = callbackDelegate
        self.surveyReference = surveyReference
        self.parent = parent
        setupUI()
        setTasks()
        setSubscriptions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        fatalError("init(frame:) has not been implemented")
    }
    
    // MARK: - Private methods
    private func setupUI() {
        verticalStackView.addEquallyTo(to: self)
    }
    
    private func setSubscriptions() {
        $item.sink { [weak self] in
            guard let self = self,
                  !$0.isNil
            else { return }
            
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.2, delay: 0) {
                self.actionButton.backgroundColor = self.traitCollection.userInterfaceStyle == .dark ? .systemBlue : .systemRed
            }
        }.store(in: &subscriptions)
    }
    
    private func setTasks() {
        tasks.append(Task { @MainActor [weak self] in
            for await notification in NotificationCenter.default.notifications(for: Notifications.Surveys.Claim) {
                guard let self = self,
                      let instance = notification.object as? SurveyReference,
                      self.surveyReference == instance
                else { return }

                self.onSuccessCallback()
            }
        })
        //Error
        tasks.append(Task { @MainActor [weak self] in
            for await notification in NotificationCenter.default.notifications(for: Notifications.Surveys.ClaimFailure) {
                guard let self = self,
                      let instance = notification.object as? SurveyReference,
                      self.surveyReference == instance
                else { return }

                self.onFailureCallback()
            }
        })
        tasks.append(Task { @MainActor [weak self] in
            for await notification in NotificationCenter.default.notifications(for: Notifications.Comments.Claim) {
                guard let self = self,
                      let instance = notification.object as? Comment,
                      instance.survey?.reference == self.surveyReference
                else { return }

                self.onSuccessCallback()
            }
        })
        tasks.append( Task { @MainActor [weak self] in
            for await notification in NotificationCenter.default.notifications(for: Notifications.Comments.ClaimFailure) {
                guard let self = self,
                      let instance = notification.object as? Comment,
                      instance.survey?.reference == self.surveyReference
                else { return }
                
                self.onFailureCallback()
            }
        })
    }
    
    @objc
    private func close() {
        parent?.dismiss()
    }
    
    @objc
    private func send() {
        guard !item.isNil else { return }
        guard state != .Close else {
            parent?.dismiss()
            return 
        }
        state = .Sending
        
        actionButton.isUserInteractionEnabled = false
        claimSubject.send(item!)
        claimSubject.send(completion: .finished)
        
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
                //                let transformer = UIConfigurationTextAttributesTransformer { incoming in
                //                    var outgoing = incoming
                //                        outgoing.foregroundColor = UIColor.black
                //                        outgoing.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .title2)
                //                    return outgoing
                //                }
                //                actionButton.configuration!.titleTextAttributesTransformer = transformer
                
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
    }
    
    private func onSuccessCallback() {
        state = .Close
        actionButton.isUserInteractionEnabled = true
        
        //Path animation
        let pathAnim = Animations.get(property: .Path, fromValue: (self.icon.icon as! CAShapeLayer).path!, toValue: (self.icon.getLayer(.Letter) as! CAShapeLayer).path!, duration: 0.5, delay: 0, repeatCount: 0, autoreverses: false, timingFunction: CAMediaTimingFunctionName.easeInEaseOut, delegate: nil, isRemovedOnCompletion: false)
        self.icon.icon.add(pathAnim, forKey: nil)
        
        self.parent?.resize(400, animationDuration: 0.7)
        
        //Hide close btn
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0, animations: { [weak self] in
            guard let self = self else { return }
            
            self.collectionView.alpha = 0
            self.closeButton.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            self.closeButton.alpha = 0
        }) { _ in
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.4, delay: 0) { [weak self] in
                guard let self = self else { return }
                
                self.label.alpha = 1
            }
        }
        
        if #available(iOS 15, *) {
            guard !actionButton.configuration.isNil else { return }
            
            let attrString = AttributedString(state.rawValue.localized.uppercased(), attributes: AttributeContainer([
                NSAttributedString.Key.font: UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .title2) as Any,
                NSAttributedString.Key.foregroundColor: UIColor.white
            ]))
            self.actionButton.configuration!.showsActivityIndicator = false
            UIView.transition(with: self.actionButton, duration: 0.15, options: .transitionCrossDissolve) {
                self.actionButton.configuration!.attributedTitle = attrString
                self.actionButton.configuration!.image = UIImage(systemName: "arrow.forward", withConfiguration: UIImage.SymbolConfiguration(weight: .bold))
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

    private func onFailureCallback() {
        state = .Send
        actionButton.isUserInteractionEnabled = true
        
        showBanner(bannerDelegate: self, text: "", content: PlainBannerContent(text: AppError.server.localizedDescription.localized, imageContent: ImageSigns.exclamationMark, color: .systemRed), isModal: false, dismissAfter: 1)
        
//        let banner = Banner(frame: UIScreen.main.bounds, callbackDelegate: nil, bannerDelegate: self)
//        banner.present(content: PlainBannerContent(text: AppError.server.localizedDescription.localized, imageContent: ImageSigns.exclamationMark, color: .systemRed), isModal: false, dismissAfter: 1)
        
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
    
    // MARK: - Public methods
    public func onChildHeightChange(_ height: CGFloat) {
//        parent?.onContainerHeightChange(height + title.bounds.height*2)
    }
    
    // MARK: - Overriden methods
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
//        closeButton.imageView?.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : .systemGray
        icon.setIconColor(traitCollection.userInterfaceStyle == .dark ? .systemBlue : .systemRed)
        
        if #available(iOS 15, *) {
            guard !actionButton.configuration.isNil else { return }
            actionButton.configuration?.baseBackgroundColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : .systemRed
        } else {
            actionButton.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : .systemRed
        }
        
        //Set dynamic font size
        guard previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory else { return }
        
        
//        titleLabel.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Bold.rawValue,
//                                            forTextStyle: .title1)
//        ratingLabel.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue,
//                                            forTextStyle: .caption2)
//        viewsLabel.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue,
//                                            forTextStyle: .caption2)
//        commentsLabel.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue,
//                                            forTextStyle: .caption2)
//        descriptionLabel.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue,
//                                            forTextStyle: .callout)
//        topicLabel.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Bold.rawValue,
//                                            forTextStyle: .footnote)
////        firstnameLabel.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue,
////                                                forTextStyle: .caption2)
////        lastnameLabel.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue,
////                                               forTextStyle: .caption2)
//        dateLabel.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue,
//                                               forTextStyle: .caption2)
//
//        if let label = progressView.getSubview(type: UILabel.self, identifier: "progressLabel") {
//            label.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Bold.rawValue, forTextStyle: .footnote)
//        }
//
//
//        guard let constraint_1 = titleLabel.getConstraint(identifier: "height"),
//              let constraint_2 = statsView.getConstraint(identifier: "height"),
//              let constraint_3 = descriptionLabel.getConstraint(identifier: "height"),
//              let constraint_4 = topicView.getConstraint(identifier: "height"),
////              let constraint_5 = progressView.getConstraint(identifier: "width"),
//              let item = item
//        else { return }
//
//        setNeedsLayout()
//        constraint_1.constant = item.title.height(withConstrainedWidth: titleLabel.bounds.width,
//                                                  font: titleLabel.font)
//        constraint_2.constant = String(describing: item.rating).height(withConstrainedWidth: ratingLabel.bounds.width,
//                                                                       font: ratingLabel.font)
//        constraint_3.constant = item.truncatedDescription.height(withConstrainedWidth: ratingLabel.bounds.width,
//                                                                       font: ratingLabel.font)
//        constraint_4.constant = item.topic.title.height(withConstrainedWidth: ratingLabel.bounds.width,
//                                                                       font: ratingLabel.font)
//        layoutIfNeeded()
//        topicLabel.frame.origin = .zero
    }
}


extension ClaimPopupContent: BannerObservable {
    func onBannerWillAppear(_ sender: Any) {}
    
    func onBannerWillDisappear(_ sender: Any) {}
    
    func onBannerDidAppear(_ sender: Any) {}
    
    func onBannerDidDisappear(_ sender: Any) {
        if let banner = sender as? Banner {
            banner.removeFromSuperview()
        } else if let popup = sender as? Popup {
            popup.removeFromSuperview()
        }
    }
}
