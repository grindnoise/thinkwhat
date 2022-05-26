//
//  PollCreationView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 26.05.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class PollCreationView: UIView {
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
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
        setupUI()
        setObservers()
    }
    
    override func layoutSubviews() {
        
    }
    
    // MARK: - Properties
    weak var viewInput: PollCreationViewInput?
    private var newInstance: Survey?
    
    // MARK: - UI Properties
    var fontSize: CGFloat = .zero
    private var color: UIColor = .systemGray
    private var pollTitleObserver: NSKeyValueObservation?
    private var pollDescriptionObserver: NSKeyValueObservation?
    private var pollQuestionObserver: NSKeyValueObservation?
    private var pollURLObserver: NSKeyValueObservation?
    private var pollImagesObserver: NSKeyValueObservation?
    private var pollChoicesObserver: NSKeyValueObservation?
    
    // MARK: - IB outlets
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollContentView: UIView!
    
    ///Topic
    @IBOutlet weak var topicView: UIView!
    @IBOutlet weak var topicStaticLabel: ArcLabel!
    @IBOutlet weak var topicLabel: ArcLabel!
    @IBOutlet weak var topicButton: CircleButton! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
            topicButton.addGestureRecognizer(tap)
//            topicButton.icon.alpha = 0
            topicButton.state = .On
            topicButton.color = color
            topicButton.text = "РАЗДЕЛ"
            topicButton.category = .QuestionMark
        }
    }
    
    ///Options
    @IBOutlet weak var optionsView: UIView!
    @IBOutlet weak var optionsStaticLabel: ArcLabel!
    @IBOutlet weak var optionsLabel: ArcLabel!
    @IBOutlet weak var optionsButton: CircleButton! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
            optionsButton.addGestureRecognizer(tap)
//            optionsButton.icon.alpha = 0
            optionsButton.state = .On
            optionsButton.color = color
            optionsButton.text = "РАЗДЕЛ"
            optionsButton.category = .QuestionMark
        }
    }
    
    ///Poll title
    @IBOutlet weak var pollTitleView: UIView!
    @IBOutlet weak var pollTitleStaticLabel: ArcLabel!
    @IBOutlet weak var pollTitleButton: CircleButton! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
            pollTitleButton.addGestureRecognizer(tap)
//            optionsButton.icon.alpha = 0
            pollTitleButton.state = .On
            pollTitleButton.color = color
            pollTitleButton.text = "РАЗДЕЛ"
            pollTitleButton.category = .QuestionMark
        }
    }
    @IBOutlet weak var pollTitleBg: UIView!
    @IBOutlet weak var pollTitleTextView: UITextView! {
        didSet {
            pollTitleTextView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .systemBackground
        }
    }
    
    ///Poll description
    @IBOutlet weak var pollDescriptionView: UIView!
    @IBOutlet weak var pollDescriptionStaticLabel: ArcLabel!
    @IBOutlet weak var pollDescriptionButton: CircleButton! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
            pollDescriptionButton.addGestureRecognizer(tap)
//            optionsButton.icon.alpha = 0
            pollDescriptionButton.state = .On
            pollDescriptionButton.color = color
            pollDescriptionButton.text = "РАЗДЕЛ"
            pollDescriptionButton.category = .QuestionMark
        }
    }
    @IBOutlet weak var pollDescriptionBg: UIView!
    @IBOutlet weak var pollDescriptionTextView: UITextView! {
        didSet {
            pollDescriptionTextView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .systemBackground
        }
    }

    ///Poll question
    @IBOutlet weak var pollQuestionView: UIView!
    @IBOutlet weak var pollQuestionStaticLabel: ArcLabel!
    @IBOutlet weak var pollQuestionButton: CircleButton! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
            pollQuestionButton.addGestureRecognizer(tap)
//            optionsButton.icon.alpha = 0
            pollQuestionButton.state = .On
            pollQuestionButton.color = color
            pollQuestionButton.text = "РАЗДЕЛ"
            pollQuestionButton.category = .QuestionMark
        }
    }
    @IBOutlet weak var pollQuestionBg: UIView!
    @IBOutlet weak var pollQuestionTextView: UITextView! {
        didSet {
            pollQuestionTextView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .systemBackground
        }
    }
    
    ///Poll URL
    @IBOutlet weak var pollURLView: UIView!
    @IBOutlet weak var pollURLStaticLabel: ArcLabel!
    @IBOutlet weak var pollURLButton: CircleButton! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
            pollURLButton.addGestureRecognizer(tap)
//            optionsButton.icon.alpha = 0
            pollURLButton.state = .On
            pollURLButton.color = color
            pollURLButton.text = "РАЗДЕЛ"
            pollURLButton.category = .QuestionMark
        }
    }
    @IBOutlet weak var pollURLBg: UIView!
    @IBOutlet weak var pollURLContainerView: UIView! {
        didSet {
            pollURLContainerView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .systemBackground
        }
    }
    
    ///Poll images
    @IBOutlet weak var pollImagesView: UIView!
    @IBOutlet weak var pollImagesStaticLabel: ArcLabel!
    @IBOutlet weak var pollImagesButton: CircleButton! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
            pollImagesButton.addGestureRecognizer(tap)
//            optionsButton.icon.alpha = 0
            pollImagesButton.state = .On
            pollImagesButton.color = color
            pollImagesButton.text = "РАЗДЕЛ"
            pollImagesButton.category = .QuestionMark
        }
    }
    @IBOutlet weak var pollImagesBg: UIView!
    @IBOutlet weak var pollImagesContainerView: UIView! {
        didSet {
            pollImagesContainerView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .systemBackground
        }
    }
    
    ///Poll description
    @IBOutlet weak var pollChoicesView: UIView!
    @IBOutlet weak var pollChoicesStaticLabel: ArcLabel!
    @IBOutlet weak var pollChoicesButton: CircleButton! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
            pollChoicesButton.addGestureRecognizer(tap)
//            optionsButton.icon.alpha = 0
            pollChoicesButton.state = .On
            pollChoicesButton.color = color
            pollChoicesButton.text = "РАЗДЕЛ"
            pollChoicesButton.category = .QuestionMark
        }
    }
    @IBOutlet weak var pollChoicesBg: UIView!
    @IBOutlet weak var pollChoicesContainerView: UIView! {
        didSet {
            pollChoicesContainerView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .systemBackground
        }
    }
    
    ///Limits
    @IBOutlet weak var limitsView: UIView!
    @IBOutlet weak var limitsStaticLabel: ArcLabel!
    @IBOutlet weak var limitsLabel: ArcLabel!
    @IBOutlet weak var limitsButton: CircleButton! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
            limitsButton.addGestureRecognizer(tap)
//            limitsButton.icon.alpha = 0
            limitsButton.state = .On
            limitsButton.color = color
            limitsButton.text = "РАЗДЕЛ"
            limitsButton.category = .QuestionMark
        }
    }
    
    ///Comments
    @IBOutlet weak var commentsView: UIView!
    @IBOutlet weak var commentsStaticLabel: ArcLabel!
    @IBOutlet weak var commentsLabel: ArcLabel!
    @IBOutlet weak var commentsButton: CircleButton! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
            commentsButton.addGestureRecognizer(tap)
//            topicButton.icon.alpha = 0
            commentsButton.state = .On
            commentsButton.color = color
            commentsButton.text = "РАЗДЕЛ"
            commentsButton.category = .QuestionMark
        }
    }
    
    ///Hot option
    @IBOutlet weak var hotOptionView: UIView!
    @IBOutlet weak var hotOptionStaticLabel: ArcLabel!
    @IBOutlet weak var hotOptionLabel: ArcLabel!
    @IBOutlet weak var hotOptionButton: CircleButton! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
            hotOptionButton.addGestureRecognizer(tap)
//            topicButton.icon.alpha = 0
            hotOptionButton.state = .On
            hotOptionButton.color = color
            hotOptionButton.text = "РАЗДЕЛ"
            hotOptionButton.category = .QuestionMark
        }
    }
}

// MARK: - Controller Output
extension PollCreationView: PollCreationControllerOutput {
    func onNextStage(_ stage: PollCreationController.Stage) {
        switch stage {
        case .Topic:
            topicButton.present(completionBlocks: [
                { [weak self] in guard let self = self else { return }; self.topicButton.state = .On},
                { [weak self] in guard let self = self else { return }; let banner = Popup(frame: UIScreen.main.bounds, callbackDelegate: nil, bannerDelegate: self, heightScaleFactor: deviceType == .iPhoneSE ? 0.8 : 0.6)
//                    banner.accessibilityIdentifier = "claim"
                    banner.present(subview: UIView(), shouldDismissAfter: 2)}
            ])
            topicView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
            UIView.animate(withDuration: 0.2) {
                self.topicView.alpha = 1
            }
            
            UIView.animate(
                withDuration: 0.3,
                delay: 0,
                usingSpringWithDamping: 0.55,
                initialSpringVelocity: 2.5,
                options: [.curveEaseInOut],
                animations: {
                    self.topicView.transform = .identity
                }) { _ in }
        default:
            fatalError()
        }
        
    }
    
    
    // Implement methods
    
}

// MARK: - UI Setup
extension PollCreationView {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        pollTitleBg.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
        pollTitleTextView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .systemBackground
    }
    
    private func setupUI() {
        setNeedsLayout()
        layoutIfNeeded()
        setText()
        setupInputViews()
        
        scrollContentView.subviews.forEach {
            $0.alpha = 0
            if let circle = $0 as? CircleButton { circle.state = .Off }
        }
    }
    
    private func setObservers() {
        pollTitleObserver = pollTitleBg.observe(\UIView.bounds, options: [NSKeyValueObservingOptions.new]) { (view: UIView, change: NSKeyValueObservedChange<CGRect>) in
            self.pollTitleBg.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.6).cgColor
            self.pollTitleBg.layer.shadowPath = UIBezierPath(roundedRect: self.pollTitleBg.bounds,
                                                             cornerRadius: self.pollTitleBg.frame.width * 0.05).cgPath
            self.pollTitleBg.layer.shadowRadius = 7
            self.pollTitleBg.layer.shadowOffset = .zero
        }
        pollDescriptionObserver = pollDescriptionBg.observe(\UIView.bounds, options: [NSKeyValueObservingOptions.new]) { (view: UIView, change: NSKeyValueObservedChange<CGRect>) in
            self.pollDescriptionBg.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.6).cgColor
            self.pollDescriptionBg.layer.shadowPath = UIBezierPath(roundedRect: self.pollDescriptionBg.bounds,
                                                             cornerRadius: self.pollDescriptionBg.frame.width * 0.05).cgPath
            self.pollDescriptionBg.layer.shadowRadius = 7
            self.pollDescriptionBg.layer.shadowOffset = .zero
        }
        pollQuestionObserver = pollQuestionBg.observe(\UIView.bounds, options: [NSKeyValueObservingOptions.new]) { (view: UIView, change: NSKeyValueObservedChange<CGRect>) in
            self.pollQuestionBg.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.6).cgColor
            self.pollQuestionBg.layer.shadowPath = UIBezierPath(roundedRect: self.pollQuestionBg.bounds,
                                                             cornerRadius: self.pollQuestionBg.frame.width * 0.05).cgPath
            self.pollQuestionBg.layer.shadowRadius = 7
            self.pollQuestionBg.layer.shadowOffset = .zero
        }
        pollURLObserver = pollURLBg.observe(\UIView.bounds, options: [NSKeyValueObservingOptions.new]) { (view: UIView, change: NSKeyValueObservedChange<CGRect>) in
            self.pollURLBg.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.6).cgColor
            self.pollURLBg.layer.shadowPath = UIBezierPath(roundedRect: self.pollURLBg.bounds,
                                                             cornerRadius: self.pollURLBg.frame.width * 0.05).cgPath
            self.pollURLBg.layer.shadowRadius = 7
            self.pollURLBg.layer.shadowOffset = .zero
        }
        pollImagesObserver = pollImagesBg.observe(\UIView.bounds, options: [NSKeyValueObservingOptions.new]) { (view: UIView, change: NSKeyValueObservedChange<CGRect>) in
            self.pollImagesBg.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.6).cgColor
            self.pollImagesBg.layer.shadowPath = UIBezierPath(roundedRect: self.pollImagesBg.bounds,
                                                             cornerRadius: self.pollImagesBg.frame.width * 0.05).cgPath
            self.pollImagesBg.layer.shadowRadius = 7
            self.pollImagesBg.layer.shadowOffset = .zero
        }
        pollChoicesObserver = pollChoicesBg.observe(\UIView.bounds, options: [NSKeyValueObservingOptions.new]) { (view: UIView, change: NSKeyValueObservedChange<CGRect>) in
            self.pollChoicesBg.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.6).cgColor
            self.pollChoicesBg.layer.shadowPath = UIBezierPath(roundedRect: self.pollChoicesBg.bounds,
                                                             cornerRadius: self.pollChoicesBg.frame.width * 0.05).cgPath
            self.pollChoicesBg.layer.shadowRadius = 7
            self.pollChoicesBg.layer.shadowOffset = .zero
        }
    }
    
    private func setupInputViews() {
        pollTitleTextView.layer.masksToBounds = true
        pollTitleTextView.layer.cornerRadius = pollTitleTextView.frame.width * 0.05
        pollTitleBg.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
        
        pollDescriptionTextView.layer.masksToBounds = true
        pollDescriptionTextView.layer.cornerRadius = pollDescriptionTextView.frame.width * 0.05
        pollDescriptionBg.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
        
        pollQuestionTextView.layer.masksToBounds = true
        pollQuestionTextView.layer.cornerRadius = pollQuestionTextView.frame.width * 0.05
        pollQuestionBg.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
        
        pollURLContainerView.layer.masksToBounds = true
        pollURLContainerView.layer.cornerRadius = pollURLContainerView.frame.width * 0.05
        pollURLBg.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
        
        pollImagesContainerView.layer.masksToBounds = true
        pollImagesContainerView.layer.cornerRadius = pollImagesContainerView.frame.width * 0.05
        pollImagesBg.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
        
        pollChoicesContainerView.layer.masksToBounds = true
        pollChoicesContainerView.layer.cornerRadius = pollChoicesContainerView.frame.width * 0.05
        pollChoicesBg.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
        
    }
    
    @objc
    private func setText() {
        if fontSize == .zero { fontSize = topicStaticLabel.bounds.width * 0.1 }
        
        ///Topic
        let topicStaticString = NSMutableAttributedString()
        topicStaticString.append(NSAttributedString(string: "topic".localized.uppercased(), attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: fontSize), foregroundColor: traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : color, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        topicStaticLabel.attributedText = topicStaticString
        
        let topicString = NSMutableAttributedString()
        topicString.append(NSAttributedString(string: "topic".localized.uppercased(), attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: fontSize), foregroundColor: traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : color, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        topicLabel.attributedText = topicString
        
        ///Options
        let optionsStaticString = NSMutableAttributedString()
        optionsStaticString.append(NSAttributedString(string: "options".localized.uppercased(), attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: fontSize), foregroundColor: traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : color, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        optionsStaticLabel.attributedText = optionsStaticString
        
        let optionsString = NSMutableAttributedString()
        optionsString.append(NSAttributedString(string: "options".localized.uppercased(), attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: fontSize), foregroundColor: traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : color, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        optionsLabel.attributedText = optionsString
        
        ///Poll title
        let pollTitleStaticString = NSMutableAttributedString()
        pollTitleStaticString.append(NSAttributedString(string: "poll_title".localized.uppercased(), attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: fontSize), foregroundColor: traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : color, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        pollTitleStaticLabel.attributedText = pollTitleStaticString
        
        ///Poll description
        let pollDescriptionStaticString = NSMutableAttributedString()
        pollDescriptionStaticString.append(NSAttributedString(string: "poll_description".localized.uppercased(), attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: fontSize), foregroundColor: traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : color, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        pollDescriptionStaticLabel.attributedText = pollDescriptionStaticString
        
        ///Poll Question
        let pollQuestionStaticString = NSMutableAttributedString()
        pollQuestionStaticString.append(NSAttributedString(string: "poll_question".localized.uppercased(), attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: fontSize), foregroundColor: traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : color, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        pollQuestionStaticLabel.attributedText = pollQuestionStaticString
        
        ///Poll URL
        let pollURLStaticString = NSMutableAttributedString()
        pollURLStaticString.append(NSAttributedString(string: "url".localized.uppercased(), attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: fontSize), foregroundColor: traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : color, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        pollURLStaticLabel.attributedText = pollURLStaticString
        
        ///Poll URL
        let pollImagesStaticString = NSMutableAttributedString()
        pollImagesStaticString.append(NSAttributedString(string: "images".localized.uppercased(), attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: fontSize), foregroundColor: traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : color, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        pollImagesStaticLabel.attributedText = pollImagesStaticString
        
        ///Poll choices
        let pollChoicesStaticString = NSMutableAttributedString()
        pollChoicesStaticString.append(NSAttributedString(string: "poll_choices".localized.uppercased(), attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: fontSize), foregroundColor: traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : color, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        pollChoicesStaticLabel.attributedText = pollChoicesStaticString
        
        ///Commenta
        let commentsStaticString = NSMutableAttributedString()
        commentsStaticString.append(NSAttributedString(string: "comments".localized.uppercased(), attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: fontSize), foregroundColor: traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : color, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        commentsStaticLabel.attributedText = commentsStaticString
        
        let commentsString = NSMutableAttributedString()
        commentsString.append(NSAttributedString(string: "comments".localized.uppercased(), attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: fontSize), foregroundColor: traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : color, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        commentsLabel.attributedText = commentsString
        
        ///Limits
        let limitsStaticString = NSMutableAttributedString()
        limitsStaticString.append(NSAttributedString(string: "voters_limit".localized.uppercased(), attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: fontSize), foregroundColor: traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : color, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        limitsStaticLabel.attributedText = limitsStaticString
        
        let limitsString = NSMutableAttributedString()
        limitsString.append(NSAttributedString(string: "voters_limit".localized.uppercased(), attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: fontSize), foregroundColor: traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : color, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        limitsLabel.attributedText = limitsString
        
        ///Hot start
        let hotOptionStaticString = NSMutableAttributedString()
        hotOptionStaticString.append(NSAttributedString(string: "hot_option".localized.uppercased(), attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: fontSize), foregroundColor: traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : color, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        hotOptionStaticLabel.attributedText = hotOptionStaticString
        
        let hotOptionString = NSMutableAttributedString()
        hotOptionString.append(NSAttributedString(string: "hot_option".localized.uppercased(), attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: fontSize), foregroundColor: traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : color, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        hotOptionLabel.attributedText = hotOptionString
    }
    
    @objc
    private func handleTap(_ recognizer: UITapGestureRecognizer) {
        print("Tap")
    }
}

extension PollCreationView: BannerObservable {
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
