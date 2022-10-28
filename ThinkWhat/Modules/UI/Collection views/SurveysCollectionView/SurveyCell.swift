//
//  SubscriptionCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 17.07.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class SurveyCell: UICollectionViewListCell {
    
    // MARK: - Public properties
    public weak var item: SurveyReference! {
        didSet {
            guard let item = item else { return }
            
            //            self.updatePublisher.send(self.item)
            
            //            Timer
            //                .publish(every: 1, on: .main, in: .common)
            //                .autoconnect()
            //                .sink { [weak self] seconds in
            //                    guard let self = self else { return }
            //
            //                    self.updatePublisher.send(self.item)
            //                }
            //                .store(in: &subscriptions)
            
            
            //            sourcePublisher.send(Date())
            
            Timer
                .publish(every: 3, on: .current, in: .common)
                .autoconnect()
    //            .delay(for: .seconds(2), scheduler: DispatchQueue.main)
                .sink { [weak self] seconds in
                    guard let self = self,
                          let item = self.item,
                          item.isHot,
                          let destinationCategory = self.icon.category != .Hot ? .Hot : Icon.Category(rawValue: item.topic.id) ?? Icon.Category.Null as? Icon.Category,
                          let destinationColor = self.icon.category != .Hot ? UIColor.systemRed : UIColor.white as? UIColor,
                          let destinationPath = (self.icon.getLayer(destinationCategory) as? CAShapeLayer)?.path,
                          let shapeLayer = self.icon.icon as? CAShapeLayer
                    else { return }

                    let _ = UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.75, delay: 0) {
                        self.icon.backgroundColor = destinationCategory == .Hot ? .clear : self.item.topic.tagColor
                    }

                    let pathAnim = Animations.get(property: .Path,
                                                  fromValue: shapeLayer.path as Any,
                                                  toValue: destinationPath,
                                                  duration: 0.35,
                                                  delay: 0,
                                                  repeatCount: 0,
                                                  autoreverses: false,
                                                  timingFunction: CAMediaTimingFunctionName.easeIn,
                                                  delegate: self,
                                                  isRemovedOnCompletion: false,
                                                  completionBlocks:
                                                    [{ [weak self] in
                        guard let self = self else { return }
                        self.icon.category = destinationCategory
                    }])
                    shapeLayer.add(pathAnim, forKey: nil)
                    shapeLayer.path = destinationPath



                    let colorAnim = Animations.get(property: .FillColor,
                                                   fromValue: self.icon.iconColor.cgColor as Any,
                                                   toValue: destinationColor.cgColor as Any,
                                                   duration: 0.35,
                                                   delay: 0,
                                                   repeatCount: 0,
                                                   autoreverses: false,
                                                   timingFunction: CAMediaTimingFunctionName.easeIn,
                                                   delegate: nil,
                                                   isRemovedOnCompletion: false)
                    self.icon.icon.add(colorAnim, forKey: nil)
                    self.icon.iconColor = destinationColor
                }
                .store(in: &subscriptions)

            menuButton.showsMenuAsPrimaryAction = true
            menuButton.menu = prepareMenu()
            
            if !item.media.isNil {
                verticalStack.insertArrangedSubview(imageContainer, at: 1)
                if let image = item.media?.image {
                    imageView.image = image
                } else {
                    imageContainer.startShimmering()
                    Task { [weak self] in
                        
                        guard let self = self else { return }
                        
                        do {
                            let image = try await item.media?.downloadImageAsync()
                            await MainActor.run {
                                self.imageView.image = image
                                self.imageContainer.stopShimmering()
                            }
                        } catch {
#if DEBUG
                            error.printLocalized(class: type(of: self), functionName: #function)
#endif
                        }
                    }
                }
            } else {
                verticalStack.insertArrangedSubview(descriptionLabel, at: 1)
            }
            
            defer {
                setProgress()
                refreshConstraints()
                setColors()
            }
            titleLabel.text = item.title
            descriptionLabel.text = item.truncatedDescription
            ratingLabel.text = String(describing: item.rating)
            viewsLabel.text = String(describing: item.views.roundedWithAbbreviations)
            dateLabel.text = item.startDate.timeAgoDisplay()
            topicLabel.text = item.topic.localized.uppercased()
            
            if item.isAnonymous {
                avatar.userprofile = Userprofile.anonymous
            } else {
                avatar.addInteraction(UIContextMenuInteraction(delegate: self))
                avatar.userprofile = item.owner
                firstnameLabel.text = item.owner.firstNameSingleWord
                lastnameLabel.text = item.owner.lastNameSingleWord
            }
            
            icon.backgroundColor = self.item.topic.tagColor//traitCollection.userInterfaceStyle == .dark ? .systemBlue : item.topic.tagColor
            icon.category = Icon.Category(rawValue: item.topic.id) ?? .Null
            
            if item.isComplete {
                titleLabel.textColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .systemGray
                descriptionLabel.textColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .systemGray
                if !topicHorizontalStackView.arrangedSubviews.contains(progressView) {
                    topicHorizontalStackView.insertArrangedSubview(progressView, at: 1)
                }
            } else {
                if item.isOwn {
                    if !topicHorizontalStackView.arrangedSubviews.contains(progressView) {
                        topicHorizontalStackView.insertArrangedSubview(progressView, at: 1)
                    }
                }
                titleLabel.textColor = .label
                descriptionLabel.textColor = .label
            }
            
            commentsLabel.text = String(describing: item.commentsTotal.roundedWithAbbreviations)
            commentsView.alpha = item.commentsTotal == 0 ? 0 : 1
            commentsLabel.alpha = item.commentsTotal == 0 ? 0 : 1
            
            if let label = progressView.getSubview(type: UILabel.self, identifier: "progressLabel") {
                label.text = String(describing: item.progress) + "%"
            }
            if let progress = progressView.getSubview(type: UIView.self, identifier: "progress") {
                progress.backgroundColor = self.item.topic.tagColor//traitCollection.userInterfaceStyle == .dark ? .systemBlue : item.topic.tagColor
            }
            
            topicLabel.backgroundColor = self.item.topic.tagColor//traitCollection.userInterfaceStyle == .dark ? .systemBlue : item.topic.tagColor
            
            var marksStackView: UIStackView!
            if let instance = self.topicHorizontalStackView.arrangedSubviews.filter({ $0.accessibilityIdentifier == "marksStackView" }).first as? UIStackView {
                marksStackView = instance
            } else {
                let stackView = UIStackView()
                stackView.clipsToBounds = false
                stackView.spacing = 2
                stackView.backgroundColor = .clear//traitCollection.userInterfaceStyle == .dark ? .systemBlue : item.topic.tagColor
                stackView.accessibilityIdentifier = "marksStackView"
                stackView.publisher(for: \.bounds, options: .new)
                    .sink { rect in
                        
                        stackView.cornerRadius = rect.height/2.25
                    }
                    .store(in: &self.subscriptions)
                
                self.topicHorizontalStackView.addArrangedSubview(stackView)
                marksStackView = stackView
            }
            marksStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
            
            if item.isOwn {
                let container = UIView()
                container.backgroundColor = .clear
                container.accessibilityIdentifier = "isOwn"
                container.widthAnchor.constraint(equalTo: container.heightAnchor, multiplier: 1/1).isActive = true
                
                let instance = UIImageView(image: UIImage(systemName: "figure.wave"))
                instance.tintColor = item.topic.tagColor//traitCollection.userInterfaceStyle == .dark ? .systemBlue : item.topic.tagColor
                instance.contentMode = .scaleAspectFit
                instance.addEquallyTo(to: container)
                marksStackView.addArrangedSubview(container)
            } else if item.isComplete {
                let container = UIView()
                container.backgroundColor = .clear
                container.accessibilityIdentifier = "isComplete"
                container.widthAnchor.constraint(equalTo: container.heightAnchor, multiplier: 1/1).isActive = true
                
                let instance = UIImageView(image: UIImage(systemName: "checkmark.seal.fill",
                                                          withConfiguration: UIImage.SymbolConfiguration(pointSize: marksStackView.frame.height, weight: .semibold, scale: .medium)))
                instance.contentMode = .center
                instance.tintColor = traitCollection.userInterfaceStyle == .dark ? .white : item.topic.tagColor
                instance.contentMode = .scaleAspectFit
                instance.addEquallyTo(to: container)
                marksStackView.addArrangedSubview(container)
            }
            if item.isFavorite {
                let container = UIView()
                container.backgroundColor = .clear
                container.accessibilityIdentifier = "isFavorite"
                container.widthAnchor.constraint(equalTo: container.heightAnchor, multiplier: 1/1).isActive = true
                
                let instance = UIImageView(image: UIImage(systemName: "binoculars.fill"))
                instance.tintColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
                instance.contentMode = .scaleAspectFit
                instance.addEquallyTo(to: container)
                marksStackView.addArrangedSubview(container)
            }
            
            if titleLabel.getConstraint(identifier: "height").isNil, descriptionLabel.getConstraint(identifier: "height").isNil, topicView.getConstraint(identifier: "height").isNil {
                let constraint = titleLabel.heightAnchor.constraint(equalToConstant: 300)
                constraint.identifier = "height"
                constraint.isActive = true
                let constraint_2 = descriptionLabel.heightAnchor.constraint(equalToConstant: 15)
                constraint_2.identifier = "height"
                constraint_2.isActive = true
                let constraint_3 = topicView.heightAnchor.constraint(equalToConstant: 25)
                constraint_3.identifier = "height"
                constraint_3.isActive = true
                
                setNeedsLayout()
                layoutIfNeeded()
            }
        }
    }
    //    public var updatePublisher = PassthroughSubject<SurveyReference, Never>()
    public private(set) var watchSubject = CurrentValueSubject<SurveyReference?, Never>(nil)
    public private(set) var claimSubject = CurrentValueSubject<SurveyReference?, Never>(nil)
    public private(set) var shareSubject = CurrentValueSubject<SurveyReference?, Never>(nil)
    public private(set) var profileTapPublisher = CurrentValueSubject<Userprofile?, Never>(nil)
    public private(set) var subscribePublisher = CurrentValueSubject<Userprofile?, Never>(nil)
    public private(set) var unsubscribePublisher = CurrentValueSubject<Userprofile?, Never>(nil)
    //UI
    public private(set) lazy var avatar: Avatar = {
        let instance = Avatar(isShadowed: true)
        instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1/1).isActive = true
        instance.isUserInteractionEnabled = true
        instance.tapPublisher
            .sink { [weak self]  in
                guard let self = self,
                      let userprofile = $0,
                      userprofile != Userprofile.anonymous
                else { return }
                
                
                self.profileTapPublisher.send(userprofile)
            }
            .store(in: &subscriptions)
        
        return instance
    }()
    
    
    
    // MARK: - Private properties
    private var observers: [NSKeyValueObservation] = []
    public var subscriptions = Set<AnyCancellable>()
    private var tasks: [Task<Void, Never>?] = []
//    private lazy var eventEmitter: EventEmitter = {
//        return EventEmitter()
//    }()
    private var animTask: Task<Void, Never>?
    private lazy var titleLabel: UILabel = {
        let instance = UILabel()
        instance.textAlignment = .left
        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Bold.rawValue, forTextStyle: .title1)
        instance.numberOfLines = 0
        instance.lineBreakMode = .byTruncatingTail
        instance.textColor = .label
        instance.publisher(for: \.bounds, options: .new)
            .sink { [weak self] rect in
                
                guard let self = self,
                      let item = self.item,
                      let constraint = instance.getAllConstraints().filter({$0.identifier == "height"}).first else { return }
                
                let height = self.item.title.height(withConstrainedWidth: rect.width, font: instance.font)
                
                guard height != constraint.constant else { return }
                
                self.setNeedsLayout()
                constraint.constant = height
                self.layoutIfNeeded()
            }
            .store(in: &subscriptions)
        
        return instance
    }()
    private lazy var descriptionLabel: UILabel = {
        let instance = UILabel()
        instance.textAlignment = .left
        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .callout)
        instance.numberOfLines = 0
        instance.lineBreakMode = .byTruncatingTail
        instance.textColor = .label
        instance.publisher(for: \.bounds, options: .new)
            .sink { [weak self] rect in
                
                guard let self = self,
                      let item = self.item,
                      let constraint = instance.getAllConstraints().filter({$0.identifier == "height"}).first else { return }
                
                let height = self.item.title.height(withConstrainedWidth: rect.width, font: instance.font)
                
                guard height != constraint.constant else { return }
                
                self.setNeedsLayout()
                constraint.constant = height
                self.layoutIfNeeded()
            }
            .store(in: &subscriptions)
        
        return instance
    }()
    private lazy var ratingView: UIImageView = {
        let instance = UIImageView(image: UIImage(systemName: "star.fill", withConfiguration: UIImage.SymbolConfiguration(textStyle: UIFont.TextStyle.caption2, scale: .medium)))
        instance.tintColor = Colors.Tags.HoneyYellow
        instance.contentMode = .center
        return instance
    }()
    @MainActor private lazy var ratingLabel: UILabel = {
        let instance = UILabel()
        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .caption2)
        instance.textAlignment = .center
        instance.textColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
        instance.publisher(for: \.bounds, options: .new)
            .sink { [weak self] rect in
                
                guard let self = self,
                      let text = instance.text,
                      let constraint = instance.getAllConstraints().filter({$0.identifier == "height"}).first else { return }
                
                self.setNeedsLayout()
                constraint.constant = text.height(withConstrainedWidth: rect.width, font: instance.font) * 1.5
                self.layoutIfNeeded()
            }
            .store(in: &subscriptions)
        
        return instance
    }()
    private lazy var viewsView: UIImageView = {
        let instance = UIImageView(image: UIImage(systemName: "eye.fill", withConfiguration: UIImage.SymbolConfiguration(textStyle: UIFont.TextStyle.caption2, scale: .medium)))
        instance.tintColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
        instance.contentMode = .center
        return instance
    }()
    private lazy var commentsView: UIImageView = {
        let instance = UIImageView(image: UIImage(systemName: "bubble.right.fill", withConfiguration: UIImage.SymbolConfiguration(textStyle: UIFont.TextStyle.caption2, scale: .medium)))
        instance.tintColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
        instance.contentMode = .center
        
        return instance
    }()
    @MainActor private lazy var commentsLabel: UILabel = {
        let instance = UILabel()
        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .caption2)
        instance.textAlignment = .center
        instance.textColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
        return instance
    }()
    private lazy var dateLabel: InsetLabel = {
        let instance = InsetLabel()
        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .caption2)
        instance.textAlignment = .left
        instance.insets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
        instance.textColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
        
        return instance
    }()
    private lazy var topicLabel: InsetLabel = {
        let instance = InsetLabel()
        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Bold.rawValue, forTextStyle: .footnote)
        instance.textAlignment = .center
        instance.insets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
        instance.textColor = .white
        instance.publisher(for: \.bounds, options: .new)
            .sink { [weak self] rect in
                
                guard let self = self,
                      let constraint = self.topicView.getConstraint(identifier: "height") else { return }
                
                let height = self.item.topic.localized.height(withConstrainedWidth: rect.width, font: instance.font)
                let width = self.item.topic.localized.width(withConstrainedHeight: height, font: instance.font)
                
                self.setNeedsLayout()
                if let constraint_2 = instance.getAllConstraints().filter({ $0.identifier == "width"}).first {
                    constraint_2.constant = width + instance.insets.right*2.5 + instance.insets.left*2.5
                } else {
                    let constraint_2 = instance.widthAnchor.constraint(equalToConstant: width + instance.insets.right*2.5 + instance.insets.left*2.5)
                    constraint_2.identifier = "width"
                    constraint_2.isActive = true
                }
                //            constraint_2.constant = newValue.width + 8
                constraint.constant = height// + 4
                self.layoutIfNeeded()
                instance.cornerRadius = rect.height/2.25
            }
            .store(in: &subscriptions)
        
        return instance
    }()
    private lazy var progressView: UIView = {
        let instance = UIView()
        instance.backgroundColor = .systemGray4
        instance.accessibilityIdentifier = "progressView"
        
        let constraint = instance.widthAnchor.constraint(equalToConstant: 30)
        constraint.identifier = "width"
        constraint.priority = .defaultHigh
        constraint.isActive = true
        
        instance.publisher(for: \.bounds, options: .new)
            .sink {rect in
                
                instance.cornerRadius = rect.height/2.25
            }
            .store(in: &subscriptions)
        
        let subview = UIView()
        instance.addSubview(subview)
        subview.accessibilityIdentifier = "progress"
        subview.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            subview.leadingAnchor.constraint(equalTo: instance.leadingAnchor),
            subview.topAnchor.constraint(equalTo: instance.topAnchor),
            subview.bottomAnchor.constraint(equalTo: instance.bottomAnchor),
        ])
        
        let constraint_2 = subview.widthAnchor.constraint(equalToConstant: 30)
        constraint_2.identifier = "width"
        constraint_2.isActive = true
        
        let label = InsetLabel()
        label.accessibilityIdentifier = "progressLabel"
        label.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Bold.rawValue, forTextStyle: .footnote)
        label.textAlignment = .center
        label.textColor = .white
        label.insets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 6)
        label.publisher(for: \.bounds, options: .new)
            .sink { [weak self] rect in
                
                guard let self = self,
                      let item = self.item,
                      let constraint = self.progressView.getAllConstraints().filter({ $0.identifier == "width" }).first,
                      let progressIndicator = self.progressView.getSubview(type: UIView.self, identifier: "progress"),
                      let constraint_2 = progressIndicator.getConstraint(identifier: "width") else { return }
                
                //            guard view.bounds.size != newValue.size else { return }
                
                self.setNeedsLayout()
                constraint.constant = "100%".width(withConstrainedHeight: rect.height, font: label.font) + label.insets.left + label.insets.right
                constraint_2.constant = constraint.constant * CGFloat(item.progress)/100
                self.layoutIfNeeded()
                
                label.cornerRadius = rect.height/2.25
            }
            .store(in: &subscriptions)
        
        label.addEquallyTo(to: instance)
        
        return instance
    }()
    private lazy var icon: Icon = {
        let instance = Icon(category: Icon.Category.Anon)
        instance.iconColor = .white
        instance.isRounded = true
        instance.scaleMultiplicator = 1.7
        instance.heightAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 1/1).isActive = true
        
        instance.publisher(for: \.bounds, options: .new)
            .sink { rect in
                
                instance.cornerRadius = rect.width/3.25
            }
            .store(in: &subscriptions)
        
        return instance
    }()
    @MainActor private lazy var viewsLabel: UILabel = {
        let instance = UILabel()
        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .caption2)
        instance.textAlignment = .center
        instance.textColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
        return instance
    }()
    private lazy var imageView: UIImageView = {
        let instance = UIImageView()
        instance.clipsToBounds = true
        instance.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
        instance.translatesAutoresizingMaskIntoConstraints = false
        instance.heightAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 9/16).isActive = true
        instance.contentMode = .scaleAspectFill
        
        return instance
    }()
    private lazy var imageContainer: Shimmer = {
        let instance = Shimmer()
        instance.backgroundColor = .clear
        instance.translatesAutoresizingMaskIntoConstraints = false
        instance.addSubview(imageView)
        instance.clipsToBounds = false
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: instance.leadingAnchor, constant: -padding),
            imageView.trailingAnchor.constraint(equalTo: instance.trailingAnchor, constant: padding),
            imageView.topAnchor.constraint(equalTo: instance.topAnchor, constant: padding*0),
            imageView.bottomAnchor.constraint(equalTo: instance.bottomAnchor, constant: -padding*0),
        ])
        
        return instance
    }()
    private lazy var statsView: UIView = {
        let instance = UIView()
        instance.accessibilityIdentifier = "statsView"
        instance.backgroundColor = .clear
        instance.addSubview(statsStack)
        
        let constraint = instance.heightAnchor.constraint(equalToConstant: 20)
        constraint.identifier = "height"
        constraint.isActive = true
        
        
        statsStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            statsStack.leadingAnchor.constraint(equalTo: instance.leadingAnchor),
            statsStack.topAnchor.constraint(equalTo: instance.topAnchor),
            statsStack.bottomAnchor.constraint(equalTo: instance.bottomAnchor),
        ])
        return instance
    }()
    private lazy var menuButton: UIButton = {
        let instance = UIButton()
        instance.setImage(UIImage(systemName: "ellipsis", withConfiguration: UIImage.SymbolConfiguration(pointSize: instance.bounds.width, weight: UIImage.SymbolWeight.regular, scale: .large)), for: .normal)
        instance.tintColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
        instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1/1).isActive = true
        instance.addTarget(self, action: #selector(self.handleTap), for: .touchUpInside)
        
        return instance
    }()
    private lazy var userView: UIView = {
        let instance = UIView()
        instance.clipsToBounds = false
        instance.backgroundColor = .clear
        instance.accessibilityIdentifier = "userView"
        instance.translatesAutoresizingMaskIntoConstraints = false
        instance.addSubview(firstnameLabel)
        instance.addSubview(lastnameLabel)
        avatar.addEquallyTo(to: instance)
        
        firstnameLabel.translatesAutoresizingMaskIntoConstraints = false
        lastnameLabel.translatesAutoresizingMaskIntoConstraints = false
        avatar.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            firstnameLabel.centerYAnchor.constraint(equalTo: lastnameLabel.centerYAnchor),
            firstnameLabel.centerXAnchor.constraint(equalTo: lastnameLabel.centerXAnchor),
            firstnameLabel.widthAnchor.constraint(equalTo: lastnameLabel.widthAnchor),
            lastnameLabel.centerXAnchor.constraint(equalTo: avatar.centerXAnchor),
            lastnameLabel.centerYAnchor.constraint(equalTo: avatar.centerYAnchor),
            lastnameLabel.widthAnchor.constraint(equalTo: avatar.widthAnchor, multiplier: 1.625),
        ])
        
        return instance
    }()
    private lazy var firstnameLabel: ArcLabel = {
        let instance = ArcLabel()
        instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1/1).isActive = true
        instance.font = UIFont(name: Fonts.Semibold, size: 9)//UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .caption2)
        instance.textAlignment = .center
        instance.text = ""
        instance.textColor = traitCollection.userInterfaceStyle == .dark ? .white : .darkGray
        instance.accessibilityIdentifier = "firstnameLabel"
        return instance
    }()
    private lazy var lastnameLabel: ArcLabel = {
        let instance = ArcLabel()
        instance.angle = 4.7
        instance.clockwise = false
        instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1/1).isActive = true
        instance.font = UIFont(name: Fonts.Semibold, size: 9)//UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .caption2)
        instance.textAlignment = .center
        instance.text = ""
        instance.textColor = traitCollection.userInterfaceStyle == .dark ? .white : .darkGray
        instance.accessibilityIdentifier = "lastnameLabel"
        
        return instance
    }()
    private lazy var topicView: UIView = {
        let instance = UIView()
        instance.accessibilityIdentifier = "topicView"
        instance.backgroundColor = .clear
        instance.addSubview(topicHorizontalStackView)
        topicHorizontalStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topicHorizontalStackView.leadingAnchor.constraint(equalTo: instance.leadingAnchor),
            topicHorizontalStackView.topAnchor.constraint(equalTo: instance.topAnchor),
            topicHorizontalStackView.bottomAnchor.constraint(equalTo: instance.bottomAnchor),
        ])
        
        return instance
    }()
    //Stacks
    private lazy var topicHorizontalStackView: UIStackView = {
        let instance = UIStackView(arrangedSubviews: [topicLabel])//, progressView])//, dateLabel])
        instance.clipsToBounds = false
        instance.alignment = .center
        instance.spacing = 4
        
        return instance
    }()
    private lazy var topicVerticalStackView: UIStackView = {
        let instance = UIStackView(arrangedSubviews: [topicView, dateLabel])
        instance.axis = .vertical
        instance.spacing = 2
        //        instance.distribution = .fillEqually
        instance.accessibilityIdentifier = "topicVerticalStackView"
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.heightAnchor.constraint(equalTo: topicView.heightAnchor).isActive = true
        
        return instance
    }()
    private lazy var headerTitleHorizontalStackView: UIStackView = {
        let instance = UIStackView(arrangedSubviews: [icon, topicVerticalStackView, userView])
        instance.accessibilityIdentifier = "headerTitleHorizontalStackView"
        instance.axis = .horizontal
        instance.spacing = 4
        
        //        userView.translatesAutoresizingMaskIntoConstraints = false
        //        userView.heightAnchor.constraint(equalTo: icon.heightAnchor).isActive = true
        
        return instance
    }()
    private lazy var headerStack: UIStackView = {
        let instance = UIStackView(arrangedSubviews: [headerTitleHorizontalStackView, titleLabel])
        instance.accessibilityIdentifier = "headerTitleVerticalStack"
        instance.axis = .vertical
        instance.spacing = 16
        return instance
    }()
    private lazy var statsStack: UIStackView = {
        let ratingStack = UIStackView(arrangedSubviews: [ratingView, ratingLabel])
        //        ratingView.heightAnchor.constraint(equalTo: ratingLabel.heightAnchor, multiplier: 1.5).isActive = true
        ratingStack.spacing = 2
        
        let viewsStack = UIStackView(arrangedSubviews: [viewsView, viewsLabel])
        viewsStack.spacing = 2
        
        let commentsStack = UIStackView(arrangedSubviews: [commentsView, commentsLabel])
        commentsStack.spacing = 2
        
        let instance = UIStackView(arrangedSubviews: [ratingStack, viewsStack, commentsStack])
        instance.spacing = 6
        
        return instance
    }()
    private lazy var verticalStack: UIStackView = {
        let instance = UIStackView(arrangedSubviews: [headerStack, bottomStackView])//[subHorizontalStack, descriptionLabel, statsView])
        instance.axis = .vertical
        //        instance.alignment = .leading
        instance.accessibilityIdentifier = "verticalStack"
        instance.spacing = 16
        //        instance.clipsToBounds = false
        return instance
    }()
    private lazy var bottomStackView: UIStackView = {
        let instance = UIStackView(arrangedSubviews: [statsView, menuButton])
        instance.axis = .horizontal
        instance.accessibilityIdentifier = "bottomStackView"
        instance.spacing = 0
        
        return instance
    }()
    private let padding: CGFloat = 8
    private var constraint: NSLayoutConstraint!
    
    
    
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
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    // MARK: - Overriden methods
//    override func updateConstraints() {
//        super.updateConstraints()
//
////        separatorLayoutGuide.leadingAnchor.constraint(equalTo: ratingView.trailingAnchor, constant: 10).isActive = true
////        separatorLayoutGuide.trailingAnchor.constraint(equalTo: trailingAnchor, constant: .greatestFiniteMagnitude).isActive = true
//        separatorLayoutGuide.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
//        separatorLayoutGuide.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
////        separatorLayoutGuide.heightAnchor.constraint(equalToConstant: 10).isActive = true
//    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        var config = UIBackgroundConfiguration.listPlainCell()
        config.backgroundColor = self.traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .systemBackground
        backgroundConfiguration = config
        
        menuButton.tintColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
        if icon.category != .Hot {
            icon.backgroundColor = self.item.topic.tagColor//traitCollection.userInterfaceStyle == .dark ? .systemBlue : item.topic.tagColor
        }
        progressView.getSubview(type: UIView.self, identifier: "progress")?.backgroundColor = item.topic.tagColor//traitCollection.userInterfaceStyle == .dark ? .systemBlue : item.topic.tagColor
        viewsView.tintColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
        commentsView.tintColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
//        commentsView.tintColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
        topicLabel.backgroundColor = self.item.topic.tagColor//traitCollection.userInterfaceStyle == .dark ? .systemBlue : item.topic.tagColor
//        descriptionLabel.textColor = traitCollection.userInterfaceStyle == .dark ? .label : .darkGray
        dateLabel.textColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
//        descriptionLabel.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : item.topic.tagColor.withAlphaComponent(0.075)
        firstnameLabel.textColor = traitCollection.userInterfaceStyle == .dark ? .white : .darkGray
        lastnameLabel.textColor = traitCollection.userInterfaceStyle == .dark ? .white : .darkGray
        
        
        if !item.isNil {
            if item.isComplete {
                titleLabel.textColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .systemGray
                descriptionLabel.textColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .systemGray
            } else {
                titleLabel.textColor = .label
                descriptionLabel.textColor = .label
            }
        }
        
        if let stackView = topicHorizontalStackView.arrangedSubviews.filter({ $0.accessibilityIdentifier == "marksStackView" }).first as? UIStackView {
            stackView.arrangedSubviews.forEach { [weak self] in
                guard let self = self,
                      let identifier = $0.accessibilityIdentifier else { return }
                if identifier == "isHot" {
//                    $0.get(all: UIImageView.self).first?.tintColor = traitCollection.userInterfaceStyle == .dark ? .white : .systemRed
                } else if identifier == "isComplete" {
//                    $0.get(all: UIImageView.self).first?.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : .systemGreen
                    $0.get(all: UIImageView.self).first?.tintColor = self.item.topic.tagColor//traitCollection.userInterfaceStyle == .dark ? .systemBlue : self.item.topic.tagColor
                } else if identifier == "isFavorite" {
                    $0.get(all: UIImageView.self).first?.tintColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
                } else if identifier == "isOwn" {
                    //                    $0.get(all: UIImageView.self).first?.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : .systemGreen
                    $0.get(all: UIImageView.self).first?.tintColor = self.item.topic.tagColor//traitCollection.userInterfaceStyle == .dark ? .systemBlue : self.item.topic.tagColor
                }
            }
        }
        
        //Set dynamic font size
        guard previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory else { return }
        
        titleLabel.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Bold.rawValue,
                                            forTextStyle: .title1)
        ratingLabel.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue,
                                            forTextStyle: .caption2)
        viewsLabel.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue,
                                            forTextStyle: .caption2)
        commentsLabel.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue,
                                            forTextStyle: .caption2)
        descriptionLabel.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue,
                                            forTextStyle: .callout)
        topicLabel.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Bold.rawValue,
                                            forTextStyle: .footnote)
//        firstnameLabel.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue,
//                                                forTextStyle: .caption2)
//        lastnameLabel.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue,
//                                               forTextStyle: .caption2)
        dateLabel.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue,
                                               forTextStyle: .caption2)
        
        if let label = progressView.getSubview(type: UILabel.self, identifier: "progressLabel") {
            label.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Bold.rawValue, forTextStyle: .footnote)
        }

        
        guard let constraint_1 = titleLabel.getConstraint(identifier: "height"),
              let constraint_2 = statsView.getConstraint(identifier: "height"),
              let constraint_3 = descriptionLabel.getConstraint(identifier: "height"),
              let constraint_4 = topicView.getConstraint(identifier: "height"),
//              let constraint_5 = progressView.getConstraint(identifier: "width"),
              let item = item
        else { return }
        
        setNeedsLayout()
        constraint_1.constant = item.title.height(withConstrainedWidth: titleLabel.bounds.width,
                                                  font: titleLabel.font)
        constraint_2.constant = String(describing: item.rating).height(withConstrainedWidth: ratingLabel.bounds.width,
                                                                       font: ratingLabel.font)
        constraint_3.constant = item.truncatedDescription.height(withConstrainedWidth: ratingLabel.bounds.width,
                                                                       font: ratingLabel.font)
        constraint_4.constant = item.topic.localized.height(withConstrainedWidth: ratingLabel.bounds.width,
                                                                       font: ratingLabel.font)
        layoutIfNeeded()
        topicLabel.frame.origin = .zero
    }
    
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
//        tasks.forEach { $0?.cancel() }
        subscriptions.forEach { $0.cancel() }

        //Reset publishers
        watchSubject = CurrentValueSubject<SurveyReference?, Never>(nil)
        claimSubject = CurrentValueSubject<SurveyReference?, Never>(nil)
        shareSubject = CurrentValueSubject<SurveyReference?, Never>(nil)
        profileTapPublisher = CurrentValueSubject<Userprofile?, Never>(nil)
        subscribePublisher = CurrentValueSubject<Userprofile?, Never>(nil)
        unsubscribePublisher = CurrentValueSubject<Userprofile?, Never>(nil)
        
//        eventEmitter.task?.cancel()
        animTask?.cancel()
        
        icon.backgroundColor = self.item.topic.tagColor//traitCollection.userInterfaceStyle == .dark ? .systemBlue : item.topic.tagColor
        icon.setIconColor(.white)
        
        firstnameLabel.text = ""
        lastnameLabel.text = ""
        avatar.clearImage()
        item = nil
        verticalStack.removeArrangedSubview(descriptionLabel)
        verticalStack.removeArrangedSubview(imageContainer)
        descriptionLabel.removeFromSuperview()
        imageContainer.removeFromSuperview()
        topicHorizontalStackView.removeArrangedSubview(progressView)
        progressView.removeFromSuperview()
    }
    
    override func updateConfiguration(using state: UICellConfigurationState) {
        super.updateConfiguration(using: state)
        
        var config = UIBackgroundConfiguration.listPlainCell()
        config.backgroundColor = self.traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .systemBackground
        backgroundConfiguration = config
    }
}

private extension SurveyCell {
    func commonInit() {
        setTasks()
        setupUI()
    }

    func setupUI() {
        backgroundColor = .clear
        clipsToBounds = true

        contentView.addSubview(verticalStack)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        verticalStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            verticalStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding*2),
            verticalStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            verticalStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
//            horizontalStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding/2),
//            userView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.175)
        ])
        
        constraint = statsView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding)
        constraint.priority = .defaultLow
        constraint.isActive = true
        
    }
    
    func setTasks() {

            tasks.append(Task { [weak self] in
                for await notification in NotificationCenter.default.notifications(for: Notifications.Surveys.Views) {
                    await MainActor.run {
                        guard let self = self,
                              let item = self.item,
                              let object = notification.object as? SurveyReference,
                              item === object
                        else { return }
                        self.viewsLabel.text = String(describing: item.views.roundedWithAbbreviations)
                    }
                }
            })
        
            tasks.append(Task { [weak self] in
                for await notification in NotificationCenter.default.notifications(for: Notifications.Surveys.Rating) {
                    await MainActor.run {
                        guard let self = self,
                              let item = self.item,
                              let object = notification.object as? SurveyReference,
                              item === object
                        else { return }
                        self.ratingLabel.text = String(describing: String(describing: item.rating))
                    }
                }
            })
        
            tasks.append(Task { [weak self] in
                for await notification in NotificationCenter.default.notifications(for: Notifications.Surveys.SwitchFavorite) {
                    await MainActor.run {
                        guard let self = self,
                              let item = self.item,
                              let object = notification.object as? SurveyReference,
                              item === object
                        else { return }

                        self.menuButton.menu = self.prepareMenu()

                        switch item.isFavorite {
                        case true:
                            var stackView: UIStackView!
                            if let _stackView = self.topicHorizontalStackView.get(all: UIStackView.self).filter({ $0.accessibilityIdentifier == "marksStackView" }).first {
                                stackView = _stackView
                            } else {
                                stackView = UIStackView()
                                stackView.spacing = 2
                                stackView.backgroundColor = .clear
                                stackView.accessibilityIdentifier = "marksStackView"
                                stackView.publisher(for: \.bounds, options: .new)
                                    .sink { rect in
                                        
                                        stackView.cornerRadius = rect.height/2.25
                                    }
                                    .store(in: &self.subscriptions)
                                
                                self.topicHorizontalStackView.addArrangedSubview(stackView)
                            }
                            guard stackView.arrangedSubviews.filter({ $0.accessibilityIdentifier == "isFavorite"}).isEmpty else { return }
                            let container = UIView()
                            container.backgroundColor = .clear
                            container.accessibilityIdentifier = "isFavorite"
                            container.widthAnchor.constraint(equalTo: container.heightAnchor, multiplier: 1/1).isActive = true
                            
                            let instance = UIImageView(image: UIImage(systemName: "binoculars.fill"))
                            instance.tintColor = self.traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
                            instance.contentMode = .scaleAspectFit
                            instance.addEquallyTo(to: container)
                            stackView.insertArrangedSubview(container,
                                                            at: stackView.arrangedSubviews.isEmpty ? 0 : stackView.arrangedSubviews.count > 1 ? stackView.arrangedSubviews.count-1 : stackView.arrangedSubviews.count)
                        case false:
                            guard let stackView = self.topicHorizontalStackView.get(all: UIStackView.self).filter({ $0.accessibilityIdentifier == "marksStackView" }).first,
                                  let mark = stackView.get(all: UIView.self).filter({ $0.accessibilityIdentifier == "isFavorite" }).first else { return }
                            stackView.removeArrangedSubview(mark)
                            mark.removeFromSuperview()
                        }
                    }
                }
            })
            tasks.append(Task { [weak self] in
                for await notification in NotificationCenter.default.notifications(for: Notifications.Surveys.Completed) {
                    await MainActor.run {
                        
                        guard let self = self,
                              let item = self.item,
                              let object = notification.object as? SurveyReference,
                              item === object
                        else { return }

                        self.menuButton.menu = self.prepareMenu()
                        switch item.isComplete {
                        case true:
                            self.titleLabel.textColor = self.traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .systemGray
                            self.descriptionLabel.textColor = self.traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .systemGray
                            self.topicHorizontalStackView.insertArrangedSubview(self.progressView, at: 1)

                            var stackView: UIStackView!
                            if let _stackView = self.topicHorizontalStackView.getSubview(type: UIStackView.self, identifier: "marksStackView") {
                                stackView = _stackView
                            } else {
                                stackView = UIStackView()
                                stackView.spacing = 2
                                stackView.backgroundColor = .clear
                                stackView.accessibilityIdentifier = "marksStackView"
                                stackView.publisher(for: \.bounds, options: .new)
                                    .sink { rect in
                                        
                                        stackView.cornerRadius = rect.height/2.25
                                }
                                    .store(in: &self.subscriptions)
                                
                                self.topicHorizontalStackView.addArrangedSubview(stackView)
                            }
                            guard stackView.arrangedSubviews.filter({ $0.accessibilityIdentifier == "isComplete"}).isEmpty else { return }
                            let container = UIView()
                            container.backgroundColor = .clear
                            container.accessibilityIdentifier = "isComplete"
                            container.widthAnchor.constraint(equalTo: container.heightAnchor, multiplier: 1/1).isActive = true



                            let instance = UIImageView(image: UIImage(systemName: "checkmark.seal.fill"))
                            instance.contentMode = .center
                            instance.tintColor = self.traitCollection.userInterfaceStyle == .dark ? .white : self.item.topic.tagColor
                            instance.contentMode = .scaleAspectFit
                            instance.addEquallyTo(to: container)
                            stackView.insertArrangedSubview(container, at: 0)
                            
                            instance.publisher(for: \.bounds, options: .new)
                                .sink { rect in
                                    
                                    instance.cornerRadius = rect.height/2
                                    let largeConfig = UIImage.SymbolConfiguration(pointSize: rect.height * 1.9, weight: .semibold, scale: .medium)
                                    let image = UIImage(systemName: "checkmark.seal.fill", withConfiguration: largeConfig)
                                    instance.image = image
                                }
                                .store(in: &self.subscriptions)
                            
                        case false:
                            guard let stackView = self.topicHorizontalStackView.get(all: UIStackView.self).filter({ $0.accessibilityIdentifier == "marksStackView" }).first,
                                  let mark = stackView.get(all: UIView.self).filter({ $0.accessibilityIdentifier == "isComplete" }).first else { return }
                            stackView.removeArrangedSubview(mark)
                            mark.removeFromSuperview()
                        }
                    }
                }
            })

            tasks.append(Task { [weak self] in
                for await notification in NotificationCenter.default.notifications(for: Notifications.Surveys.Progress) {
                    await MainActor.run {
                        guard let self = self,
                              let item = self.item,
                              let object = notification.object as? SurveyReference,
                              item === object,
                              let progressIndicator = self.progressView.getSubview(type: UIView.self, identifier: "progress"),
                              let progressLabel = self.progressView.getSubview(type: UIView.self, identifier: "progressLabel") as? UILabel,
                              let constraint = progressIndicator.getConstraint(identifier: "width")
                        else { return }

                        progressLabel.text = String(describing: item.progress) + "%"
                        let _ = UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.2, delay: 0) {
                            self.progressView.setNeedsLayout()
                            constraint.constant = constraint.constant * CGFloat(item.progress)/100
                            self.progressView.layoutIfNeeded()
                        }
                    }
                }
            })

        tasks.append(Task { [weak self] in
            for await notification in NotificationCenter.default.notifications(for: Notifications.Surveys.CommentsTotal) {
                await MainActor.run {
                    guard let self = self,
                          let item = self.item,
                          let object = notification.object as? SurveyReference,
                          item === object
                    else { return }
                    
                    self.commentsView.alpha = 1
                    self.commentsLabel.alpha = 1
                    self.commentsLabel.text = String(describing: item.commentsTotal.roundedWithAbbreviations)
                }
            }
        })
    }
    
    func setProgress() {
        
        guard let progressIndicator = self.progressView.getSubview(type: UIView.self, identifier: "progress"),
              let progressLabel = self.progressView.getSubview(type: UIView.self, identifier: "progressLabel") as? UILabel,
              let constraint = progressIndicator.getConstraint(identifier: "width")
        else { return }
        
        progressLabel.text = String(describing: item.progress) + "%"
        self.progressView.setNeedsLayout()
        constraint.constant = constraint.constant * CGFloat(item.progress)/100
        self.progressView.layoutIfNeeded()
    }
    
    func setColors() {
        
        guard let stackView = topicHorizontalStackView.arrangedSubviews.filter({ $0.accessibilityIdentifier == "marksStackView" }).first as? UIStackView else { return }
        stackView.arrangedSubviews.forEach { [weak self] in
            guard let self = self,
                  let identifier = $0.accessibilityIdentifier else { return }
            if identifier == "isHot" {
//                $0.get(all: UIImageView.self).first?.tintColor = traitCollection.userInterfaceStyle == .dark ? .white : .systemRed
            } else if identifier == "isComplete" {
                //                    $0.get(all: UIImageView.self).first?.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : .systemGreen
                $0.get(all: UIImageView.self).first?.tintColor = self.item.topic.tagColor//traitCollection.userInterfaceStyle == .dark ? .systemBlue : self.item.topic.tagColor
            } else if identifier == "isFavorite" {
                $0.get(all: UIImageView.self).first?.tintColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
            } else if identifier == "isOwn" {
                //                    $0.get(all: UIImageView.self).first?.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : .systemGreen
                $0.get(all: UIImageView.self).first?.tintColor = self.item.topic.tagColor//traitCollection.userInterfaceStyle == .dark ? .systemBlue : self.item.topic.tagColor
            }
        }
    }
    
    func refreshConstraints() {
        
        guard let constraint = titleLabel.getAllConstraints().filter({$0.identifier == "height"}).first,
              let constraint_2 = descriptionLabel.getAllConstraints().filter({$0.identifier == "height"}).first,
              let constraint_3 = topicLabel.getAllConstraints().filter({ $0.identifier == "width"}).first
        else { return }
        
        let height = item.title.height(withConstrainedWidth: titleLabel.bounds.width, font: titleLabel.font)
        let height_2 = item.truncatedDescription.height(withConstrainedWidth: descriptionLabel.bounds.width, font: descriptionLabel.font)
        let width = item.topic.localized.width(withConstrainedHeight: topicLabel.bounds.height, font: topicLabel.font)
//        guard height != constraint.constant else { return }
        setNeedsLayout()
        constraint.constant = height
        constraint_2.constant = height_2
        constraint_3.constant = width + topicLabel.insets.right*2.5 + topicLabel.insets.left*2.5
        layoutIfNeeded()
        topicHorizontalStackView.updateConstraints()
        topicLabel.frame.origin = .zero
//        avatar.imageView.image = UIImage(systemName: "face.smiling.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: avatar.bounds.size.height*0.5, weight: .regular, scale: .medium))
    }
    
    @objc
    func updateViewsCount(notification: Notification) {
        guard let item = item else { return }
        viewsLabel.text = String(describing: item.views.roundedWithAbbreviations)
    }
    
    @objc
    func switchFavorite(notification: Notification) {
        guard let item = item else { return }
        ratingLabel.text = String(describing: item.rating)
    }
    
    @objc
    func setCompleted(notification: Notification) {
        guard let item = item else { return }
        ratingLabel.text = String(describing: item.rating)
    }
    
    @objc
    func switchHot(notification: Notification) {
        guard let item = item else { return }
        ratingLabel.text = String(describing: item.rating)
    }
    
    @objc
    func handleTap() {
//        menuButton.showsMenuAsPrimaryAction = true
//        menuButton.menu = menu
    }
    
    func prepareMenu() -> UIMenu {
        let shareAction : UIAction = .init(title: "share".localized, image: UIImage(systemName: "square.and.arrow.up", withConfiguration: UIImage.SymbolConfiguration(textStyle: .headline, scale: .large)), identifier: nil, discoverabilityTitle: nil, attributes: .init(), state: .off, handler: { [weak self] action in
            guard let self = self,
                  let instance = self.item
            else { return }

            self.shareSubject.send(instance)
        })
        
        let watchAction : UIAction = .init(title: item.isFavorite ? "don't_watch".localized : "watch".localized, image: UIImage(systemName: "binoculars.fill"), identifier: nil, discoverabilityTitle: nil, attributes: .init(), state: .off, handler: { [weak self] action in
            guard let self = self,
                  let instance = self.item
            else { return }
            
            self.watchSubject.send(instance)
        })
        watchAction.accessibilityIdentifier = "watch"

        
        let claimAction : UIAction = .init(title: "make_claim".localized, image: UIImage(systemName: "exclamationmark.triangle.fill"), identifier: nil, discoverabilityTitle: nil, attributes: .destructive, state: .off, handler: { [weak self] action in
            guard let self = self,
                  let instance = self.item
            else { return }
            
            self.claimSubject.send(instance)
        })
        
        var actions: [UIAction] = []//[claimAction, watchAction, shareAction]
        
        if !item.isOwn {
            actions.append(claimAction)
            actions.append(watchAction)
        }
        actions.append(shareAction)
        
        return UIMenu(title: "", image: nil, identifier: nil, options: .displayInline, children: actions)
    }
    
    func userprofileContextMenuActions(for userprofile: Userprofile) -> UIMenu {
        var actions: [UIAction]!

        let subscribe: UIAction = .init(title: "subscribe".localized.capitalized,
                                     image: UIImage(systemName: "hand.point.left.fill",
                                                    withConfiguration: UIImage.SymbolConfiguration(scale: .large)),
                                     identifier: nil,
                                     discoverabilityTitle: nil,
                                      attributes: .init(),
                                      state: .off,
                                      handler: { [weak self] _ in
            guard let self = self else { return }

            self.subscribePublisher.send(userprofile)
        })

        let unsubscribe: UIAction = .init(title: "unsubscribe".localized,
                                           image: UIImage(systemName: "hand.raised.slash.fill",
                                                          withConfiguration: UIImage.SymbolConfiguration(scale: .large)),
                                           identifier: nil,
                                           discoverabilityTitle: nil,
                                           attributes: .destructive,
                                           state: .off,
                                           handler: { [weak self] _ in
            guard let self = self else { return }

            self.unsubscribePublisher.send(userprofile)
        })

        let profile: UIAction = .init(title: "profile".localized,
                                           image: UIImage(systemName: "person.fill",
                                                          withConfiguration: UIImage.SymbolConfiguration(scale: .large)),
                                           identifier: nil,
                                           discoverabilityTitle: nil,
                                           attributes: .init(),
                                           state: .off,
                                           handler: { [weak self] _ in
            guard let self = self else { return }

            self.profileTapPublisher.send(userprofile)
        })

        actions = [profile]
        if userprofile.subscribedAt {
            actions.append(unsubscribe)
        } else {
            actions.append(subscribe)
        }


        return UIMenu(title: "", image: nil, identifier: nil, options: .init(), children: actions)
    }
}

extension SurveyCell: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag, let completionBlocks = anim.value(forKey: "completionBlocks") as? [Closure] {
            completionBlocks.forEach{ $0() }
        }
    }
}

extension SurveyCell: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        
        if let sender = interaction.view as? Avatar,
            let userprofile = sender.userprofile,
            userprofile != Userprofiles.shared.current {
            
            return UIContextMenuConfiguration(
                identifier: nil,
                previewProvider: { AvatarPreviewController.init(userprofile: userprofile) },
                actionProvider: { [unowned self] _ in self.userprofileContextMenuActions(for: userprofile) })
        }
        return nil
    }
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, willDisplayMenuFor configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionAnimating?) {
        
//        animator?.addCompletion {
//            print("addCompletion")
//        }
        
        guard let window = UIApplication.shared.delegate?.window,
              let instance = window!.viewByClassName(className: "_UIPlatterSoftShadowView")
        else { return }
        
        instance.isHidden = true
    }
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configuration: UIContextMenuConfiguration, highlightPreviewForItemWithIdentifier identifier: NSCopying) -> UITargetedPreview? {
        
        if let sender = interaction.view as? Avatar {
            let parameters = UIPreviewParameters()
            parameters.backgroundColor = .clear
            parameters.visiblePath = UIBezierPath(ovalIn: sender.bounds)
            
            return UITargetedPreview(view: sender, parameters: parameters)
        }
        
        return nil
    }
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        if animator.previewViewController is AvatarPreviewController {
            profileTapPublisher.send(item.owner)
        }
    }
}

