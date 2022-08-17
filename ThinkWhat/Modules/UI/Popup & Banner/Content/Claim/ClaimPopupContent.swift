//
//  ClaimPopupContent.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 17.08.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine
//struct ClaimItem: Hashable {
//    let id = UUID()
//    var claim: Claim
//}

class ClaimPopupContent: UIView {
    
    // MARK: - Private properties
    private var observers: [NSKeyValueObservation] = []
    private var subscriptions = Set<AnyCancellable>()
    private var tasks: [Task<Void, Never>?] = []
    private weak var parent: Popup?
    private weak var surveyReference: SurveyReference?
    private weak var callbackDelegate: CallbackObservable?
    private lazy var collectionView: ClaimCollectionView = {
        let instance = ClaimCollectionView()
        instance.backgroundColor = .systemGray
        
        return instance
    }()
    private lazy var verticalStackView: UIStackView = {
        let instance = UIStackView(arrangedSubviews: [topContainer, collectionView, bottomContainer])
        instance.axis = .vertical
        instance.spacing = 16
        
        topContainer.translatesAutoresizingMaskIntoConstraints = false
        bottomContainer.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            topContainer.heightAnchor.constraint(equalToConstant: 70),
            bottomContainer.heightAnchor.constraint(equalToConstant: 50),
        ])
        
        return instance
    }()
    
    // MARK: - UI properties
    private lazy var icon: Icon = {
        let instance = Icon()
        instance.backgroundColor = .clear
        instance.isRounded = false
        instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1/1).isActive = true
        instance.scaleMultiplicator = 0.8
        instance.iconColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : .systemRed
        instance.category = .Caution
        
        return instance
    }()
    private lazy var closeButton: UIButton = {
        let instance = UIButton()
        instance.backgroundColor = .clear
        instance.imageView?.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : .systemGray
//        instance.imageView?.contentMode = .scaleAspectFit
        instance.addTarget(self, action: #selector(self.close), for: .touchUpInside)
        instance.heightAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 1/1).isActive = true
        
        observers.append(instance.observe(\UIButton.bounds, options: .new) { view, change in
            guard let newValue = change.newValue else { return }
            
            view.setImage(UIImage(systemName: "xmark", withConfiguration: UIImage.SymbolConfiguration(pointSize: newValue.height * 0.65, weight: .bold)), for: .normal)
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
            closeButton.widthAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 0.1),
            icon.topAnchor.constraint(equalTo: instance.topAnchor),
            icon.bottomAnchor.constraint(equalTo: instance.bottomAnchor),
            icon.centerXAnchor.constraint(equalTo: instance.centerXAnchor),
            
        ])
        
        return instance
    }()
    private lazy var actionButton: UIButton = {
        let instance = UIButton()
        
        instance.addTarget(self, action: #selector(self.send), for: .touchUpInside)
//        if #available(iOS 15, *) {
//            let attrString = AttributedString("sendButton".localized.uppercased(), attributes: AttributeContainer([
//                NSAttributedString.Key.font: UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .title2) as Any,
//                NSAttributedString.Key.foregroundColor: UIColor.white
//            ]))
//            var config = UIButton.Configuration.filled()
//            config.attributedTitle = attrString
//            config.baseBackgroundColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : .systemRed
//            config.image = UIImage(systemName: "paperplane.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .large))
//            config.imagePlacement = .trailing
//            config.imagePadding = 8.0
//            config.contentInsets.leading = 20
//            config.contentInsets.trailing = 20
//
//            instance.configuration = config
//        } else {
            let attrString = NSMutableAttributedString(string: "sendButton".localized.uppercased(), attributes: [
                NSAttributedString.Key.font: UIFont.scaledFont(fontName: Fonts.OpenSans.Bold.rawValue, forTextStyle: .title2) as Any,
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
            instance.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : .systemRed

            let constraint = instance.widthAnchor.constraint(equalToConstant: "sendButton".localized.uppercased().width(withConstrainedHeight: instance.bounds.height, font: UIFont.scaledFont(fontName: Fonts.OpenSans.Bold.rawValue, forTextStyle: .title2)!))
            constraint.identifier = "width"
            constraint.isActive = true
//        }
        
        observers.append(instance.observe(\UIButton.bounds, options: .new) { [weak self] view, change in
            guard let self = self,
                  let newValue = change.newValue
            else { return }
            
            view.cornerRadius = newValue.height/2.25
            
            guard let constraint = view.getConstraint(identifier: "width") else { return }
            self.setNeedsLayout()
            constraint.constant = "sendButton".localized.uppercased().width(withConstrainedHeight: instance.bounds.height, font: UIFont.scaledFont(fontName: Fonts.OpenSans.Bold.rawValue, forTextStyle: .title2)!) + 40 + (view.imageView?.bounds.width ?? 0) + 40
            self.layoutIfNeeded()
        })
        
//        instance.translatesAutoresizingMaskIntoConstraints = false
        
        
//        let constraint =
        
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
        if #available(iOS 15, *) {
            delayAsync(delay: 2) { [weak self] in
                guard let self = self,
                      !self.actionButton.configuration.isNil
                else { return }
                
                let attrString = AttributedString("continueButton".localized.uppercased(), attributes: AttributeContainer([
                    NSAttributedString.Key.font: UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .title2) as Any,
                    NSAttributedString.Key.foregroundColor: UIColor.white
                ]))
                UIView.transition(with: self.actionButton, duration: 0.15, options: .transitionCrossDissolve) {
                    self.actionButton.configuration!.attributedTitle = attrString
                }
                self.actionButton.configuration!.showsActivityIndicator = false
                self.actionButton.configuration?.image = nil
            }
            
        } else {
            
        }
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
    
    private func setTasks() {
        tasks.append(Task { @MainActor [weak self] in
            for await notification in NotificationCenter.default.notifications(for: Notifications.Surveys.Claim) {
                guard let self = self,
                      let instance = notification.object as? SurveyReference,
                      self.surveyReference == instance
                else { return }

                fatalError()
            }
        })
    }
    
    @objc
    private func close() {
        parent?.dismiss()
    }
    
    @objc
    private func send() {
        actionButton.isUserInteractionEnabled = false
        if #available(iOS 15, *) {
            if !actionButton.configuration.isNil {
                let attrString = AttributedString("SENDING", attributes: AttributeContainer([
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
            }
        } else {
            
        }
    }

    
    // MARK: - Public methods
    public func onChildHeightChange(_ height: CGFloat) {
//        parent?.onContainerHeightChange(height + title.bounds.height*2)
    }
    
    // MARK: - Overriden methods
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        
        //Set dynamic font size
        guard previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory else { return }
        
        closeButton.imageView?.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : .systemGray
        icon.setIconColor(traitCollection.userInterfaceStyle == .dark ? .systemBlue : .systemRed)
        actionButton.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : .systemRed
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


