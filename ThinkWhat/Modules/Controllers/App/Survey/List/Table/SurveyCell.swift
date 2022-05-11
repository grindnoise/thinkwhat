//
//  SurveyCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 11.05.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class SurveyCell: UITableViewCell {

    public func setupUI() {
        let names = [Notifications.Surveys.Completed,
                     Notifications.Surveys.Views,
                     Notifications.Surveys.UpdateFavorite,
                     Notifications.Surveys.UpdateHotSurveys]
        names.forEach { NotificationCenter.default.addObserver(self, selector: #selector(self.forceUpdate), name: $0, object: nil) }
        
        guard !isSetupComplete else { return }
        isSetupComplete = true
        setNeedsLayout()
        layoutIfNeeded()
        titleFontSize = frame.height * 0.17
        lowerLabelsFontSize = votesLimitLabel.frame.height * 0.85
        topicFontSize = frame.height * 0.08
//        surveyReference = _surveyReference
    }
    
    @objc
    private func forceUpdate() {
        topicIcon.iconColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : surveyReference.topic.tagColor
        topicIcon.category = Icon.Category(rawValue: surveyReference.topic.id) ?? .Null
        mark.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : surveyReference.topic.tagColor
        mark.alpha = surveyReference.isComplete ? 1 : 0
        progress.alpha = surveyReference.isComplete ? 1 : 0
        avatar.lightColor = surveyReference.isAnonymous ? .black : surveyReference.topic.tagColor
        if surveyReference.isAnonymous {
            avatar.imageView.image = UIImage(named: "anon")
        } else if !surveyReference.owner.image.isNil {
            avatar.imageView.image = surveyReference.owner.image
        } else {
            avatar.imageView.image = UIImage(named: "user")
            if !surveyReference.owner.imageURL.isNil {
                Task {
                    let image = try await surveyReference.owner.downloadImageAsync()
                    await MainActor.run {
                        Animations.onImageLoaded(imageView: avatar.imageView, image: image)
                    }
                }
            }
        }
        hotIcon.alpha = surveyReference.isHot ? 1 : 0

        let watchIcon: UIImageView = stackView.arrangedSubviews.filter({ $0.accessibilityIdentifier == "watch" }).first as? UIImageView ?? {
            let v = UIImageView(frame: .zero)
            v.contentMode = .scaleAspectFill
            v.image = ImageSigns.binocularsFilled.image
            v.tintColor = mark.tintColor
            v.accessibilityIdentifier = "watch"
            return v
        }()
        switch surveyReference.isFavorite {
        case true:
            watchIcon.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : surveyReference.topic.tagColor
            stackView.addArrangedSubview(watchIcon)
            stackViewSigns.append(watchIcon)
        case false:
            watchIcon.removeFromSuperview()
            stackViewSigns.remove(object: watchIcon)
        default:
            print("")
        }
        
        contentView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .systemBackground
        setText()
        progress.setupUI(foregroundColor: traitCollection.userInterfaceStyle == .dark ? .systemBlue : surveyReference.topic.tagColor, progress: CGFloat(surveyReference.progress)/CGFloat(100), lineWidthFactor: 0.3, showPercentSign: false)
        hotIconWidth.constant = surveyReference.isHot ? hotIcon.frame.height : 0
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        guard !surveyReference.isNil else { return }
        setText()
        topicIcon.iconColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : surveyReference.topic.tagColor
        topicIcon.setIconColor(traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : surveyReference.topic.tagColor)
        contentView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .systemBackground
        votesLimitIcon.tintColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
        viewsIcon.tintColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
        mark.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : surveyReference.topic.tagColor
        hotIcon.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : .systemRed
        stackViewSigns.forEach {
            if $0.accessibilityIdentifier == "watch" {
                $0.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : surveyReference.topic.tagColor
            }
        }
    }
    
    private func setText() {
        guard !surveyReference.isNil else { return }
        let titleAttrString = NSMutableAttributedString()
        titleAttrString.append(NSAttributedString(string: surveyReference.title, attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Semibold, size: titleFontSize), foregroundColor: .label, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        titleLabel.attributedText = titleAttrString
        
        let topicAttrString = NSMutableAttributedString()
        topicAttrString.append(NSAttributedString(string: "\(surveyReference.topic.title.uppercased())", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: topicFontSize), foregroundColor: traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : surveyReference.topic.tagColor, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        topicAttrString.append(NSAttributedString(string: " / ", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Regular, size: topicFontSize), foregroundColor: traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : surveyReference.topic.tagColor, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        topicAttrString.append(NSAttributedString(string: "\(surveyReference.topic.parent!.title.uppercased())", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Semibold, size: topicFontSize), foregroundColor: traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : surveyReference.topic.tagColor, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        topicLabel.attributedText = topicAttrString
        
        let limitsAttrString = NSMutableAttributedString()
        limitsAttrString.append(NSAttributedString(string: "\(String(describing: surveyReference.votesLimit))", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Semibold, size: lowerLabelsFontSize), foregroundColor: .secondaryLabel, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        votesLimitLabel.attributedText = limitsAttrString
        
        let viewsAttrString = NSMutableAttributedString()
        viewsAttrString.append(NSAttributedString(string: "\(String(describing: surveyReference.views))", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Semibold, size: lowerLabelsFontSize), foregroundColor: .secondaryLabel, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        viewsLabel.attributedText = viewsAttrString
        
        userCredentials.numberOfLines = 2
        userCredentials.textAlignment = .center
        let userText = "\(surveyReference.owner.firstName)" + (!surveyReference.owner.lastName.isEmpty ? "\n\(surveyReference.owner.lastName)" : "")
        let userAttrString = NSMutableAttributedString()
        userAttrString.append(NSAttributedString(string: userText, attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Regular, size: lowerLabelsFontSize), foregroundColor: .label, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        userCredentials.attributedText = userAttrString
    }
    
    private var isSetupComplete = false
    var surveyReference: SurveyReference! {
        didSet {
            forceUpdate()
        }
    }
    private var topicFontSize: CGFloat = 0
    private var lowerLabelsFontSize: CGFloat = 0
    private var titleFontSize: CGFloat = 0
    private var stackViewSigns: [UIView] = [] {
        didSet {
            stackViewWidthConstraint.constant = stackView.frame.height * CGFloat(stackView.arrangedSubviews.count)
        }
    }
    
//    override var frame: CGRect {
//        didSet {
//            guard !progress.isNil, !surveyReference.isNil else { return }
//            progress.setupUI(foregroundColor: traitCollection.userInterfaceStyle == .dark ? .systemBlue : surveyReference.topic.tagColor, progress: CGFloat(surveyReference.progress)/CGFloat(100), lineWidthFactor: 0.3, showPercentSign: false)
//            hotIconWidth.constant = surveyReference.isHot ? hotIcon.frame.height : 0
//        }
//    }
    
    // MARK: - IB outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var topicIcon: Icon! {
        didSet {
            topicIcon.scaleMultiplicator = 1.2
            topicIcon.isRounded = false
            topicIcon.backgroundColor = .clear
        }
    }
    @IBOutlet weak var topicLabel: UILabel!
    @IBOutlet weak var progress: ProgressCircle! {
        didSet {
            progress.backgroundColor = .clear
        }
    }
    @IBOutlet weak var votesLimitIcon: UIImageView! {
        didSet {
            votesLimitIcon.tintColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
            votesLimitIcon.contentMode = .scaleAspectFit
            votesLimitIcon.image = ImageSigns.speedometer.image
        }
    }
    @IBOutlet weak var votesLimitLabel: UILabel!
    @IBOutlet weak var viewsIcon: UIImageView! {
        didSet {
            viewsIcon.tintColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
            viewsIcon.contentMode = .scaleAspectFit
            viewsIcon.image = ImageSigns.eyeFilled.image
        }
    }
    @IBOutlet weak var viewsLabel: UILabel!
    @IBOutlet weak var avatar: Avatar! {
        didSet {
            avatar.backgroundColor = .clear
        }
    }
    @IBOutlet weak var hotIcon: UIImageView! {
        didSet {
            hotIcon.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : .systemRed
            hotIcon.contentMode = .center
            hotIcon.image = ImageSigns.flameFilled.image
        }
    }
    @IBOutlet weak var userCredentials: UILabel!
//    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var mark: UIImageView! {
        didSet {
            mark.contentMode = .scaleAspectFit
            mark.image = ImageSigns.checkmarkSealFilled.image
        }
    }
    @IBOutlet weak var stackView: UIStackView! {
        didSet {
            stackView.distribution = .fillEqually
            stackView.spacing = 4
        }
    }
    @IBOutlet weak var stackViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var hotIconWidth: NSLayoutConstraint!
    
}
