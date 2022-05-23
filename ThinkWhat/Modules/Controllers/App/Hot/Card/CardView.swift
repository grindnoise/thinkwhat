//
//  CardView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 18.03.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class CardView: UIView, HotCard {

    deinit {
        print("CardView deinit")
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
    
    init(frame: CGRect, survey: Survey, delegate: CallbackObservable?) {
        self.survey = survey
        super.init(frame: frame)
        commonInit()
        self.callbackDelegate = delegate
        self.titleLabel.text = survey.title
        self.user.text = survey.owner.firstName
        if survey.owner.lastName.count > 0 {
            self.user.text! += "\n\(survey.owner.lastName)"
        }
        let paragraph = NSMutableParagraphStyle()
        
        if #available(iOS 15.0, *) {
            paragraph.usesDefaultHyphenation = true
        } else {
            paragraph.hyphenationFactor = 1
        }
        
        let attributedText = NSMutableAttributedString(string: survey.description, attributes: [NSAttributedString.Key.paragraphStyle : paragraph])
        attributedText.addAttributes(StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Regular, size: 17), foregroundColor: .label, backgroundColor: .clear), range: survey.description.fullRange())
        self.descriptionTextView.attributedText = attributedText
        setupUI()
        setObservers()
    }
    
    private func commonInit() {
        guard let contentView = self.fromNib() else { fatalError("View could not load from nib") }
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(contentView)
    }
    
    private func setObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateUI), name: Notifications.Surveys.Completed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateUI), name: Notifications.Surveys.Views, object: nil)
    }
    
    private func setupUI() {
        voteButton.layer.cornerRadius = voteButton.frame.height/2.25
        var rating = min(Double(survey.votesTotal)*5/Double(survey.views), 5)//.rounded(toPlaces: 1)
        if rating < 0.5 {
            rating = 0
        }
        stars.rating = rating
        stars.color = survey.topic.tagColor
        ratingLabel.text = String(format: "%.1f", rating)
        favoriteLabel.text = "\(survey.likes)"
        viewsLabel.text = "\(survey.views)"
        let categoryString = NSMutableAttributedString()
        categoryString.append(NSAttributedString(string: "\(survey.topic.title.uppercased())", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: 11), foregroundColor: traitCollection.userInterfaceStyle == .light ? survey.topic.tagColor : .white, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        categoryString.append(NSAttributedString(string: " / ", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Regular, size: 12), foregroundColor: traitCollection.userInterfaceStyle == .light ? survey.topic.tagColor : .white, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        categoryString.append(NSAttributedString(string: "\(survey.topic.parent!.title.uppercased())  ", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Semibold, size: 11), foregroundColor: traitCollection.userInterfaceStyle == .light ? survey.topic.tagColor : .white, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        topic.attributedText = categoryString
        icon.iconColor = traitCollection.userInterfaceStyle == .light ? survey.topic.tagColor : .systemBlue
        icon.category = Icon.Category(rawValue: survey.topic.id) ?? .Null
        viewsIcon.iconColor = traitCollection.userInterfaceStyle == .light ? .black : .systemBlue
        voteButton.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : self.survey.topic.tagColor
        avatar.lightColor = survey.topic.tagColor
        guard let image = survey.owner.image else {
            //TODO: - Download
            Task {
                 let image = try await survey.owner.downloadImageAsync()
                Animations.onImageLoaded(imageView: avatar.imageView, image: image)
            }
            return
        }
        avatar.imageView.image = image
        
        
//        descriptionTextView.text = survey.description
//        descriptionTextView.layoutManager.usesDefaultHyphenation = true
    }
    
    @objc
    private func updateUI() {
        favoriteLabel.text = "\(survey.likes)"
        viewsLabel.text = "\(survey.views)"
    }
        
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        watchIcon.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : .black
        switch traitCollection.userInterfaceStyle {
        case .dark:
            self.background.backgroundColor = .secondarySystemBackground
            self.voteButton.backgroundColor = .systemBlue
            let categoryString = NSMutableAttributedString()
            categoryString.append(NSAttributedString(string: "\(survey.topic.title.uppercased())", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: 11), foregroundColor: .white, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
            categoryString.append(NSAttributedString(string: " / ", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Regular, size: 12), foregroundColor: .white, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
            categoryString.append(NSAttributedString(string: "\(survey.topic.parent!.title.uppercased())  ", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Semibold, size: 11), foregroundColor: .white, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
            self.topic.attributedText = categoryString
            self.icon.setIconColor(.systemBlue)
            self.viewsIcon.setIconColor(.systemBlue)
            self.layer.shadowOpacity = 0

        default:
            self.background.backgroundColor = .systemBackground
            self.voteButton.backgroundColor = self.survey.topic.tagColor
            let categoryString = NSMutableAttributedString()
            categoryString.append(NSAttributedString(string: "\(survey.topic.title.uppercased())", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: 11), foregroundColor: survey.topic.tagColor, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
            categoryString.append(NSAttributedString(string: " / ", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Regular, size: 12), foregroundColor: survey.topic.tagColor, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
            categoryString.append(NSAttributedString(string: "\(survey.topic.parent!.title.uppercased())  ", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Semibold, size: 11), foregroundColor: survey.topic.tagColor, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
            self.topic.attributedText = categoryString
            self.icon.setIconColor(survey.topic.tagColor)
            self.viewsIcon.setIconColor(.black)
            self.layer.shadowOpacity = 1
        }
    }
    
    // MARK: - IB outlets
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var background: UIView! {
        didSet {
            background.backgroundColor = UIColor { traitCollection in
                switch traitCollection.userInterfaceStyle {
                case .dark:
                    return .secondarySystemBackground
                default:
                    return .systemBackground
                }
            }
        }
    }
    @IBOutlet weak var icon: Icon! {
        didSet {
            icon.scaleMultiplicator = 1.2
            icon.backgroundColor = .clear
        }
    }
    @IBOutlet weak var avatar: Avatar! {
        didSet {
            avatar.backgroundColor = .clear
        }
    }
    @IBOutlet weak var topic: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var voteButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var stars: StarView! {
        didSet {
            stars.color = survey.topic.tagColor
            stars.backgroundColor = .clear
        }
    }
    @IBOutlet weak var ratingLabel: UILabel! {
        didSet {
            ratingLabel.backgroundColor = .clear
        }
    }
    @IBOutlet weak var viewsIcon: Icon! {
        didSet {
            viewsIcon.iconColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : .black
            viewsIcon.scaleMultiplicator = 1.4
            viewsIcon.backgroundColor = .clear
            viewsIcon.category = .Eye
        }
    }
    @IBOutlet weak var favoriteLabel: UILabel! {
        didSet {
            favoriteLabel.backgroundColor = .clear
        }
    }
    @IBOutlet weak var watchIcon: UIImageView! {
        didSet {
            watchIcon.backgroundColor = .clear
            watchIcon.image = ImageSigns.binocularsFilled.image
            watchIcon.contentMode = .scaleAspectFit
            watchIcon.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : .black
        }
    }
    @IBOutlet weak var viewsLabel: UILabel! {
        didSet {
            viewsLabel.backgroundColor = .clear
        }
    }
    @IBOutlet weak var user: UILabel! {
        didSet {
            user.backgroundColor = .clear
        }
    }
    
    // MARK: - IB actions
    @IBAction func buttonTapped(_ sender: UIButton) {
        if sender == voteButton {
            callbackDelegate?.callbackReceived(survey)
//            sender.accessibilityIdentifier = "Vote"
        } else {
            sender.accessibilityIdentifier = "Reject"
        }
        callbackDelegate?.callbackReceived(sender as AnyObject)
    }
    
    // MARK: - Properties
    weak var callbackDelegate: CallbackObservable?
    var survey: Survey!
}
