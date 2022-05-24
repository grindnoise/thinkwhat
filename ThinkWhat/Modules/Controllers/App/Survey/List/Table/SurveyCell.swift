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
//                     Notifications.Surveys.UpdateFavorite,
                     Notifications.Surveys.SetFavorite,
                     Notifications.Surveys.UnsetFavorite,
                     Notifications.Surveys.UpdateHotSurveys]
        names.forEach { NotificationCenter.default.addObserver(self, selector: #selector(self.forceUpdate), name: $0, object: nil) }
        
        guard !isSetupComplete else { return }
        isSetupComplete = true
        setNeedsLayout()
        layoutIfNeeded()
        titleFontSize = frame.height * (deviceType == .iPhoneSE ? 0.15 : 0.17)
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
        hotSpacer.constant = surveyReference.isHot ? 4 : 0
        hotIcon.alpha = surveyReference.isHot ? 1 : 0
        watch.alpha = surveyReference.isFavorite ? 1 : 0
        watch.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : surveyReference.topic.tagColor
        
        contentView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .systemBackground
        setText()
        progress.setupUI(foregroundColor: traitCollection.userInterfaceStyle == .dark ? .systemBlue : surveyReference.topic.tagColor, progress: CGFloat(surveyReference.progress)/CGFloat(100), lineWidthFactor: 0.3, showPercentSign: false)
        hotIconWidth.constant = surveyReference.isHot ? hotIcon.frame.height : 0
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        guard !surveyReference.isNil else { return }
        setText()
        topicIcon.iconColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : surveyReference.topic.tagColor
        topicIcon.setIconColor(traitCollection.userInterfaceStyle == .dark ? .systemBlue : surveyReference.topic.tagColor)
        contentView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .systemBackground
        votesLimitIcon.tintColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
        viewsIcon.tintColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
        mark.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : surveyReference.topic.tagColor
        watch.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : surveyReference.topic.tagColor
        hotIcon.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : .systemRed
    }
    
    private func setObservers() {
        let names = [Notifications.Surveys.Completed]
        names.forEach { NotificationCenter.default.addObserver(self, selector: #selector(self.onCompletion), name: $0, object: nil) }
    }
    
    @objc
    private func onCompletion() {
        
    }
    
    private func setText() {
        guard !surveyReference.isNil else { return }
        let paragraph = NSMutableParagraphStyle()
        if #available(iOS 15.0, *) {
            paragraph.usesDefaultHyphenation = true
        } else {
            paragraph.hyphenationFactor = 1
        }
        paragraph.alignment = .center
        let string = surveyReference.title
        let titleAttrString = NSMutableAttributedString(string: string, attributes: [NSAttributedString.Key.paragraphStyle : paragraph])
        titleAttrString.addAttributes(StringAttributes.getAttributes(font: StringAttributes.font(name: surveyReference.isComplete ? StringAttributes.Fonts.Style.Light : StringAttributes.Fonts.Style.Semibold, size: titleFontSize), foregroundColor: .label, backgroundColor: .clear) as [NSAttributedString.Key : Any], range: string.fullRange())
        titleLabel.attributedText = titleAttrString
        titleLabel.textAlignment = .left
        
        let topicAttrString = NSMutableAttributedString()
        topicAttrString.append(NSAttributedString(string: "\(surveyReference.topic.title.uppercased())", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: topicFontSize), foregroundColor: traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : surveyReference.topic.tagColor, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        topicAttrString.append(NSAttributedString(string: " / ", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Regular, size: topicFontSize), foregroundColor: traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : surveyReference.topic.tagColor, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        topicAttrString.append(NSAttributedString(string: "\(surveyReference.topic.parent!.title.uppercased())", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Semibold, size: topicFontSize), foregroundColor: traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : surveyReference.topic.tagColor, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        topicLabel.attributedText = topicAttrString
        
        let limitsAttrString = NSMutableAttributedString()
        limitsAttrString.append(NSAttributedString(string: "\(String(describing: surveyReference.votesLimit.roundedWithAbbreviations))", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Semibold, size: lowerLabelsFontSize), foregroundColor: .secondaryLabel, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        votesLimitLabel.attributedText = limitsAttrString
        
        let viewsAttrString = NSMutableAttributedString()
        viewsAttrString.append(NSAttributedString(string: "\(String(describing: surveyReference.views.roundedWithAbbreviations))", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Semibold, size: lowerLabelsFontSize), foregroundColor: .secondaryLabel, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        viewsLabel.attributedText = viewsAttrString
        
        let firstNameString = NSMutableAttributedString()
        firstNameString.append(NSAttributedString(string: "\(surveyReference.owner.firstNameSingleWord.uppercased())", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: topicFontSize), foregroundColor: traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : surveyReference.topic.tagColor, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        firstName.attributedText = firstNameString
        
        let lastNameString = NSMutableAttributedString()
        lastNameString.append(NSAttributedString(string: "\(surveyReference.owner.lastNameSingleWord.uppercased())", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: topicFontSize), foregroundColor: traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : surveyReference.topic.tagColor, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        lastName.attributedText = lastNameString
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
    @IBOutlet weak var firstName: ArcLabel!
    @IBOutlet weak var lastName: ArcLabel!
    @IBOutlet weak var mark: UIImageView! {
        didSet {
            mark.contentMode = .scaleAspectFit
            mark.image = ImageSigns.checkmarkSealFilled.image
        }
    }
    @IBOutlet weak var watch: UIImageView! {
        didSet {
            watch.contentMode = .scaleAspectFill
            watch.image = ImageSigns.binocularsFilled.image
        }
    }
    @IBOutlet weak var hotIconWidth: NSLayoutConstraint!
    @IBOutlet weak var hotSpacer: NSLayoutConstraint!
}
