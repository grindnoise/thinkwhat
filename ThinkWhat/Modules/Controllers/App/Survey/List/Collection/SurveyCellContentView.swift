//
//  SurveyCollectionCellView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 28.04.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

@available(iOS 14.0, *)
class SurveyCellContentView: UIView, UIContentView {
    
    init(configuration: SurveyCollectionCellConfiguration) {
        super.init(frame: .zero)
        commonInit()
        setupUI()
        apply(configuration: configuration)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setText()
        topicIcon.iconColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : currentConfiguration.color!
        topicIcon.setIconColor(traitCollection.userInterfaceStyle == .dark ? .systemBlue : currentConfiguration.color!)
        contentView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .systemBackground
        votesLimitIcon.tintColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
        viewsIcon.tintColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
        mark.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : currentConfiguration.color!
        watch.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : currentConfiguration.color!
        hotIcon.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : .systemRed
    }
    
    private var topicFontSize: CGFloat = 0
    private var lowerLabelsFontSize: CGFloat = 0
    private var titleFontSize: CGFloat = 0
    
    private var currentConfiguration: SurveyCollectionCellConfiguration!
    var configuration: UIContentConfiguration {
        get {
            currentConfiguration
        }
        set {
            guard let newConfiguration = newValue as? SurveyCollectionCellConfiguration else {
                return
            }
            apply(configuration: newConfiguration)
        }
    }
    override var frame: CGRect {
        didSet {
            guard !progress.isNil, !currentConfiguration.isNil else { return }
            progress.setupUI(foregroundColor: traitCollection.userInterfaceStyle == .dark ? .systemBlue : currentConfiguration.color!, progress: CGFloat(currentConfiguration.progress)/CGFloat(100), lineWidthFactor: 0.3, showPercentSign: false)
            hotIconWidth.constant = currentConfiguration!.isHot! ? hotIcon.frame.height : 0
            hotSpacer.constant = currentConfiguration!.isHot! ? 4 : 0
        }
    }
    
    // MARK: - IB outlets
    @IBOutlet var contentView: UIView!
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
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
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
    //    @IBOutlet weak var labelWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var hotSpacer: NSLayoutConstraint!
    @IBOutlet weak var height: NSLayoutConstraint! {
        didSet {
            height.constant = deviceType == .iPhoneSE ? 120 : 130
        }
    }
}

@available(iOS 14.0, *)
private extension SurveyCellContentView {
    func apply(configuration: SurveyCollectionCellConfiguration) {
        // Only apply configuration if new configuration and current configuration are not the same
        guard currentConfiguration != configuration else {
            return
        }
        
        // Replace current configuration with new configuration
        currentConfiguration = configuration
        
//        setNeedsLayout()
//        layoutIfNeeded()
        setText()
        
        topicIcon.iconColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : currentConfiguration.color!
        topicIcon.category = currentConfiguration.icon!
        mark.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : currentConfiguration.color
        mark.alpha = currentConfiguration.isComplete! ? 1 : 0
        progress.alpha = currentConfiguration.isComplete! ? 1 : 0
        
        
        avatar.lightColor = currentConfiguration.isAnonymous! ? .black : currentConfiguration.color!
        if avatar.image.isNil, !currentConfiguration.avatar.isNil {
            avatar.image = currentConfiguration.avatar!
        }
        hotIcon.alpha = currentConfiguration.isHot! ? 1 : 0
        watch.alpha = currentConfiguration.isFavorite! ? 1 : 0
        watch.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : currentConfiguration.color!
    }
    
    
    private func setupUI() {
        titleFontSize = heightConstraint.constant * (deviceType == .iPhoneSE ? 0.13 : 0.16)
        lowerLabelsFontSize = votesLimitLabel.frame.height * 0.83
        topicFontSize = heightConstraint.constant * 0.07
        contentView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .systemBackground
    }
    
    private func setText() {
        guard !currentConfiguration.isNil else { return }
        
        let paragraph = NSMutableParagraphStyle()
        if #available(iOS 15.0, *) {
            paragraph.usesDefaultHyphenation = true
        } else {
            paragraph.hyphenationFactor = 1
        }
        paragraph.alignment = .center
        let string = currentConfiguration.title!
        let titleAttrString = NSMutableAttributedString(string: string, attributes: [NSAttributedString.Key.paragraphStyle : paragraph])
        titleAttrString.addAttributes(StringAttributes.getAttributes(font: StringAttributes.font(name: currentConfiguration.isComplete ? StringAttributes.Fonts.Style.Light : StringAttributes.Fonts.Style.Semibold, size: titleFontSize), foregroundColor: .label, backgroundColor: .clear) as [NSAttributedString.Key : Any], range: string.fullRange())
//        titleAttrString.append(NSAttributedString(string: string, attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Semibold, size: titleFontSize), foregroundColor: currentConfiguration.isComplete! ? .secondaryLabel : .label, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        titleLabel.attributedText = titleAttrString
//        guard titleLabel.numberOfTotatLines > 1 else { return }
        titleLabel.textAlignment = .left
        
//        let titleAttrString = NSMutableAttributedString()
//        titleAttrString.append(NSAttributedString(string: currentConfiguration.title!, attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Semibold, size: titleFontSize), foregroundColor: currentConfiguration.isComplete! ? .secondaryLabel : .label, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
//        titleLabel.attributedText = titleAttrString
        
        let topicAttrString = NSMutableAttributedString()
        topicAttrString.append(NSAttributedString(string: "\(currentConfiguration.titleTopic!.uppercased())", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: topicFontSize), foregroundColor: traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : currentConfiguration.color!, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        topicAttrString.append(NSAttributedString(string: " / ", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Regular, size: topicFontSize), foregroundColor: traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : currentConfiguration.color!, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        topicAttrString.append(NSAttributedString(string: "\(currentConfiguration.titleTopicParent!.uppercased())", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Semibold, size: topicFontSize), foregroundColor: traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : currentConfiguration.color!, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        topicLabel.attributedText = topicAttrString
        
        let limitsAttrString = NSMutableAttributedString()
        limitsAttrString.append(NSAttributedString(string: "\(String(describing: currentConfiguration.votesLimit!.roundedWithAbbreviations))", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Semibold, size: lowerLabelsFontSize), foregroundColor: .secondaryLabel, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        votesLimitLabel.attributedText = limitsAttrString
        
        let viewsAttrString = NSMutableAttributedString()
        viewsAttrString.append(NSAttributedString(string: "\(String(describing: currentConfiguration.views!.roundedWithAbbreviations))", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Semibold, size: lowerLabelsFontSize), foregroundColor: .secondaryLabel, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        viewsLabel.attributedText = viewsAttrString
        
        
        let firstNameString = NSMutableAttributedString()
        firstNameString.append(NSAttributedString(string: "\(currentConfiguration.firstName.uppercased())", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: topicFontSize), foregroundColor: traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : currentConfiguration.color, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        firstName.attributedText = firstNameString
        
        let lastNameString = NSMutableAttributedString()
        lastNameString.append(NSAttributedString(string: "\(currentConfiguration.lastName.uppercased())", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: topicFontSize), foregroundColor: traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : currentConfiguration.color, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        lastName.attributedText = lastNameString
    }
}
