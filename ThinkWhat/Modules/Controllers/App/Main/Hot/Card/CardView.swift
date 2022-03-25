//
//  CardView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 18.03.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class CardView: UIView {

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
    
    init(frame: CGRect, survey: Survey, delegate: CallbackDelegate?) {
        super.init(frame: frame)
        commonInit()
        self.survey = survey
        self.delegate = delegate
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
    }
    
    private func commonInit() {
        guard let contentView = self.fromNib() else { fatalError("View could not load from nib") }
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(contentView)
    }
    
    private func setupUI() {
        voteButton.layer.cornerRadius = voteButton.frame.height/2.25
        stars.rating = Double(survey.totalVotes)*5/Double(survey.views)
        let categoryString = NSMutableAttributedString()
        categoryString.append(NSAttributedString(string: "\(survey!.topic.title.uppercased())", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: 11), foregroundColor: traitCollection.userInterfaceStyle == .light ? survey!.topic.tagColor : .white, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        categoryString.append(NSAttributedString(string: " / ", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Regular, size: 12), foregroundColor: traitCollection.userInterfaceStyle == .light ? survey!.topic.tagColor : .white, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        categoryString.append(NSAttributedString(string: "\(survey!.topic.parent!.title.uppercased())  ", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Semibold, size: 11), foregroundColor: traitCollection.userInterfaceStyle == .light ? survey!.topic.tagColor : .white, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        topic.attributedText = categoryString
        icon.iconColor = traitCollection.userInterfaceStyle == .light ? survey.topic.tagColor : .white
        icon.category = Icon.Category(rawValue: survey.topic.id) ?? .Null
        
        avatar.lightColor = survey!.topic.tagColor
        guard let image = survey!.owner.image else {
            //TODO: - Download
            Task {
                 let image = try await survey.owner.downloadImageAsync()
                onImageLoaded(imageView: avatar.imageView, image: image)
            }
            return
        }
        avatar.imageView.image = image
        
        
//        descriptionTextView.text = survey.description
//        descriptionTextView.layoutManager.usesDefaultHyphenation = true
    }
    
    private func onImageLoaded(imageView: UIImageView, image: UIImage) {
        Task {
            await MainActor.run {
                UIView.transition(with: imageView,
                                  duration: 0.5,
                                  options: .transitionCrossDissolve,
                                  animations: {
                    imageView.image = image
                })
            }
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        switch traitCollection.userInterfaceStyle {
        case .dark:
            self.background.backgroundColor = .secondarySystemBackground
            self.voteButton.backgroundColor = .systemBlue
            let categoryString = NSMutableAttributedString()
            categoryString.append(NSAttributedString(string: "\(survey!.topic.title.uppercased())", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: 11), foregroundColor: .white, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
            categoryString.append(NSAttributedString(string: " / ", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Regular, size: 12), foregroundColor: .white, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
            categoryString.append(NSAttributedString(string: "\(survey!.topic.parent!.title.uppercased())  ", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Semibold, size: 11), foregroundColor: .white, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
            self.topic.attributedText = categoryString
            self.icon.setIconColor(.white)
            self.layer.shadowOpacity = 0
//            self.voteButton.layer.shadowOpacity = 0
        default:
            self.background.backgroundColor = .systemBackground
            self.voteButton.backgroundColor = K_COLOR_RED
            let categoryString = NSMutableAttributedString()
            categoryString.append(NSAttributedString(string: "\(survey!.topic.title.uppercased())", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: 11), foregroundColor: survey!.topic.tagColor, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
            categoryString.append(NSAttributedString(string: " / ", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Regular, size: 12), foregroundColor: survey!.topic.tagColor, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
            categoryString.append(NSAttributedString(string: "\(survey!.topic.parent!.title.uppercased())  ", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Semibold, size: 11), foregroundColor: survey!.topic.tagColor, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
            self.topic.attributedText = categoryString
            self.icon.setIconColor(survey!.topic.tagColor)
            self.layer.shadowOpacity = 1
//            self.voteButton.layer.shadowOpacity = 1
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
    @IBOutlet weak var voteButton: UIButton! {
        didSet {
            voteButton.backgroundColor = UIColor { traitCollection in
                switch traitCollection.userInterfaceStyle {
                case .dark:
                    return .systemBlue
                default:
                    return K_COLOR_RED
                }
            }
        }
    }
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var stars: StarView! {
        didSet {
            stars.backgroundColor = .clear
        }
    }
    @IBOutlet weak var user: UILabel! {
        didSet {
            user.backgroundColor = .clear
        }
    }
    
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        if sender == voteButton {
            sender.accessibilityIdentifier = "Vote"
        } else {
            sender.accessibilityIdentifier = "Reject"
        }
        delegate?.callbackReceived(sender as AnyObject)
    }
    
    // MARK: - Properties
    weak private var delegate: CallbackDelegate?
    var survey: Survey!
//    override var frame: CGRect {
//        didSet {
//
//        }
//    }
//    override var bounds: CGRect {
//        didSet {
//
//        }
//    }
    
}
