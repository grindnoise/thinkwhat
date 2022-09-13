//
//  LargeCard.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 23.05.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class LargeCard: UIView, HotCard {

    deinit {
        print("LargeCard deinit")
    }
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    init(frame: CGRect = .zero, survey: Survey, delegate: CallbackObservable?) {
        self.survey = survey
        self.callbackDelegate = delegate
        super.init(frame: frame)
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
    
    private func setObservers() {
        let names = [Notifications.Surveys.Completed,
                     Notifications.Surveys.Views]
        names.forEach { NotificationCenter.default.addObserver(self, selector: #selector(self.setStats), name: $0, object: nil) }
    }
    
    private func setupUI() {
        guard !survey.isNil else { fatalError("survey.isNil") }
        setNeedsLayout()
        layoutIfNeeded()
        setTitle()
        setStats()
        topicIcon.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : survey.topic.tagColor
        topicIcon.iconColor = .white
        topicIcon.category = Icon.Category(rawValue: survey.topic.id) ?? .Null
        avatar.lightColor = survey.topic.tagColor
        vote.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : survey.topic.tagColor
        claim.tintColor = .systemGray
        reject.tintColor = .systemGray
        
        if let constraint = topContainer.getAllConstraints().filter({ $0.identifier == "topContainer"}).first {
            let constant = topContainer.bounds.height
            topContainer.removeConstraint(constraint)
            constraint.isActive = false
            topContainer.heightAnchor.constraint(equalToConstant: constant).isActive = true
            topContainer.layoutIfNeeded()
        }
        
        if !survey.media.isEmpty, let media = survey.mediaWithImageURLs.filter({ $0.order == 0}).first {
            if let image = media.image {
                slide.image = image//survey!.images![index]?.keys.first
                slide.progressIndicatorView.alpha = 0
            } else if let url = media.imageURL {
                API.shared.downloadImage(url: url) { progress in
                    self.slide.progressIndicatorView.progress = progress
                } completion: { result in
                    switch result {
                    case .success(let image):
                        media.image = image
                        self.slide.image = image
                        self.slide.progressIndicatorView.reveal()
                    case .failure(let error):
#if DEBUG
                        print(error.localizedDescription)
#endif
                    }
                }
            }
        } else if let constraint = slide.getAllConstraints().filter({ $0.identifier == "aspectRatio" }).first {
            slide.removeConstraint(constraint)
            slide.heightAnchor.constraint(equalToConstant: 0).isActive = true
        }
        
        guard let image = survey.owner.image else {
            Task {
                do {
                    let data = try await survey.owner.downloadImageAsync()
                    await MainActor.run { avatar.image = data}
                } catch {}
            }
            return
        }
        avatar.image = image
    }
    
    private func setTitle() {
        guard !survey.isNil else { return }
        let fontSize: CGFloat = topicTitle.bounds.width * 0.1
        let topicTitleString = NSMutableAttributedString()
        topicTitleString.append(NSAttributedString(string: "\(survey.topic.title.uppercased())", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: fontSize), foregroundColor: traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : survey.topic.tagColor, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        topicTitle.attributedText = topicTitleString
        
        let topicSubtitleString = NSMutableAttributedString()
        topicSubtitleString.append(NSAttributedString(string: "\(survey.topic.parent!.title.uppercased())", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: fontSize), foregroundColor: traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : survey.topic.tagColor, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        topicSubtitle.attributedText = topicSubtitleString
        
        let firstNameString = NSMutableAttributedString()
        firstNameString.append(NSAttributedString(string: "\(survey.owner.firstNameSingleWord.uppercased())", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: fontSize), foregroundColor: traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : survey.topic.tagColor, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        firstName.attributedText = firstNameString
        
        let lastNameString = NSMutableAttributedString()
        lastNameString.append(NSAttributedString(string: "\(survey.owner.lastNameSingleWord.uppercased())", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: fontSize), foregroundColor: traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : survey.topic.tagColor, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        lastName.attributedText = lastNameString
        
        let titleString = NSMutableAttributedString()
        titleString.append(NSAttributedString(string: "\(survey.title)", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: titleLabel.bounds.width * 0.1), foregroundColor: .label, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        titleLabel.attributedText = titleString
        
        let paragraph = NSMutableParagraphStyle()
        if #available(iOS 15.0, *) {
            paragraph.usesDefaultHyphenation = true
        } else {
            paragraph.hyphenationFactor = 1
        }
        paragraph.alignment = .center
        let string = survey.description
        let descriptionString = NSMutableAttributedString(string: string, attributes: [NSAttributedString.Key.paragraphStyle : paragraph])
        descriptionString.addAttributes(StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Regular, size: titleLabel.bounds.width * 0.05), foregroundColor: .label, backgroundColor: .clear) as [NSAttributedString.Key : Any], range: string.fullRange())
        descriptionLabel.attributedText = descriptionString
        descriptionLabel.textAlignment = .left
        
//        let descriptionString = NSMutableAttributedString()
//        descriptionString.append(NSAttributedString(string: "\(survey.description)", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Regular, size: titleLabel.bounds.width * 0.05), foregroundColor: .label, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
//        descriptionLabel.attributedText = descriptionString
    }
    
    @objc
    private func setStats() {
        guard !survey.isNil else { return }
        let fontSize: CGFloat = topicTitle.bounds.width * 0.08
        let ratingString = NSMutableAttributedString()
        ratingString.append(NSAttributedString(string: "\(survey.rating)", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Semibold, size: fontSize), foregroundColor: traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        ratingLabel.attributedText = ratingString
        
        let viewsString = NSMutableAttributedString()
        viewsString.append(NSAttributedString(string: "\(survey.views)", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Semibold, size: fontSize), foregroundColor: traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        viewsLabel.attributedText = viewsString

    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        background.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .systemBackground
        setTitle()
        topicIcon.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : survey.topic.tagColor
        layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
        vote.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : survey.topic.tagColor
//        backgroundImage.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemGray : survey.topic.tagColor
        reject.tintColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
        claim.tintColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
    }
    
    @objc
    func onNext() {
        callbackDelegate?.callbackReceived("next" as Any)
    }
    
    @objc
    func onVote() {
        callbackDelegate?.callbackReceived(survey as Any)
    }
    
    @objc
    func onClaim() {
        callbackDelegate?.callbackReceived("claim" as Any)
    }
    
    // MARK: - Properties
    var survey: Survey!
    weak var callbackDelegate: CallbackObservable?
    
    // MARK: - IB outlets
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var background: UIView! {
        didSet {
            background.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .systemBackground
        }
    }
    @IBOutlet weak var topicTitle: ArcLabel!
    @IBOutlet weak var topicSubtitle: ArcLabel!
    @IBOutlet weak var firstName: ArcLabel!
    @IBOutlet weak var lastName: ArcLabel!
    @IBOutlet weak var topicIcon: Icon! {
        didSet {
//            topicIcon.scaleMultiplicator = 1.2
//            topicIcon.isRounded = false
            topicIcon.layer.masksToBounds = false
            topicIcon.backgroundColor = .clear
        }
    }
    @IBOutlet weak var avatar: delAvatar! {
        didSet {
            avatar.backgroundColor = .clear
        }
    }
    @IBOutlet weak var ratingView: UIImageView! {
        didSet {
            ratingView.tintColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
        }
    }
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var viewsView: UIImageView! {
        didSet {
            viewsView.tintColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
        }
    }
    @IBOutlet weak var viewsLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var slide: CircularIndicatorImageView! {
        didSet {
            slide.color = survey.topic.tagColor
            slide.contentMode = .scaleAspectFill
            slide.backgroundColor = .secondarySystemBackground
            slide.cornerRadius = slide.frame.width * 0.05
        }
    }
    @IBOutlet weak var claim: UIImageView! {
        didSet {
            claim.tintColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
            claim.isUserInteractionEnabled = true
            claim.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onClaim)))
        }
    }
    @IBOutlet weak var vote: UIImageView! {
        didSet {
            vote.isUserInteractionEnabled = true
            vote.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onVote)))
            vote.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : survey.topic.tagColor
        }
    }
    @IBOutlet weak var reject: UIImageView! {
        didSet {
            reject.tintColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
            reject.isUserInteractionEnabled = true
            reject.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onNext)))
        }
    }
    @IBOutlet weak var topContainer: UIView!
    //    @IBOutlet weak var backgroundImage: UIImageView! {
    //        didSet {
    //            backgroundImage.alpha = 0.025
    //        }
    //    }
}
