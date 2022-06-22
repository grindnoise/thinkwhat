//
//  OptionSelection.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 30.05.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class OptionSelection: UIView {
    
    // MARK: - Initialization
    init(isModal: Bool, option: PollCreationController.Option, callbackDelegate: CallbackObservable) {
        super.init(frame: .zero)
        self.callbackDelegate = callbackDelegate
        self.isCancelEnabled = !isModal
        self.option = option
        commonInit()
    }
    
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
        setObservers()
        setupUI()
    }
    
    private func setupUI() {
        setText()
        guard !isCancelEnabled else { return }
        stackView.removeArrangedSubview(cancel)
        cancel.alpha = 0
        switch option {
        case .Anon:
            scrollView.scrollRectToVisible(anon.superview!.frame, animated: true)
        case .Private:
            scrollView.scrollRectToVisible(privacy.superview!.frame, animated: true)
        default:
            scrollView.scrollRectToVisible(ordinary.superview!.frame, animated: true)
        }
        let outerColor = UIColor.clear.cgColor
        let innerColor = traitCollection.userInterfaceStyle == .dark ? UIColor.secondarySystemBackground.cgColor : UIColor.white.cgColor
        
        hMaskLayer = CAGradientLayer()// layer];
        // without specifying startPoint and endPoint, we get a vertical gradient
        hMaskLayer.colors = [outerColor, innerColor,innerColor,outerColor]
        hMaskLayer.locations = [0.0, 0.1, 0.9, 1.0]
        hMaskLayer.frame = contentView.frame;
//        hMaskLayer.anchorPoint = .zero;
        hMaskLayer.startPoint = CGPoint(x: 0, y: 0.5);
        hMaskLayer.endPoint = CGPoint(x: 1.0, y: 0.5);
        // you must add the mask to the root view, not the scrollView, otherwise
        //  the masks will move as the user scrolls!
//        self.layer.addSublayer(hMaskLayer)
        contentView.layer.mask = hMaskLayer
    }
    
    private func setObservers() {
        boundsObserver = contentView.observe(\UIView.bounds, options: [NSKeyValueObservingOptions.new]) { [weak self] (view, change) in
            guard let self = self, !self.hMaskLayer.isNil else { return }
            self.hMaskLayer.frame = self.contentView.frame
            guard !self.scrollView.isNil, !self.anon.isNil, !self.privacy.isNil, !self.ordinary.isNil else { return }
            switch self.option {
            case .Anon:
                self.scrollView.scrollRectToVisible(self.anon.superview!.frame, animated: true)
            case .Private:
                self.scrollView.scrollRectToVisible(self.privacy.superview!.frame, animated: true)
            default:
                self.scrollView.scrollRectToVisible(self.ordinary.superview!.frame, animated: true)
            }
        }
    }
    
    private func setText() {
        let fontSize: CGFloat = title.bounds.height * 0.3
//        let paragraph = NSMutableParagraphStyle()
//        if #available(iOS 15.0, *) {
//            paragraph.usesDefaultHyphenation = true
//        } else {
//            paragraph.hyphenationFactor = 1
//        }
//        paragraph.alignment = .center
        
        let topicTitleString = NSMutableAttributedString()
        topicTitleString.append(NSAttributedString(string: "choose_option".localized, attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: fontSize), foregroundColor: .label, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        title.attributedText = topicTitleString
        
        let anonString = NSMutableAttributedString()
        anonString.append(NSAttributedString(string: "anon_option".localized.uppercased(), attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: anonTitle.bounds.width * 0.06), foregroundColor: .label/*color*/, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        anonTitle.attributedText = anonString
        
        let anonDescriptionString = NSAttributedString(string: "anon_description".localized, attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Light, size: anonTitle.bounds.width * 0.07), foregroundColor: .label, backgroundColor: .clear) as [NSAttributedString.Key : Any])
        anonDescription.attributedText = anonDescriptionString
        anonDescription.textAlignment = .center
        
        let defaultString = NSMutableAttributedString()
        defaultString.append(NSAttributedString(string: "default_option".localized.uppercased(), attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: anonTitle.bounds.width * 0.06), foregroundColor: .label/*color*/, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        ordinaryTitle.attributedText = defaultString
        
        let ordinaryDescriptionString = NSMutableAttributedString(string: "default_description".localized, attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Light, size: anonTitle.bounds.width * 0.07), foregroundColor: .label, backgroundColor: .clear) as [NSAttributedString.Key : Any])
        ordinaryDescription.attributedText = ordinaryDescriptionString
        ordinaryDescription.textAlignment = .center
        
        let privacyString = NSMutableAttributedString()
        privacyString.append(NSAttributedString(string: "private_option".localized.uppercased(), attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: anonTitle.bounds.width * 0.06), foregroundColor: .label/*color*/, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        privacyTitle.attributedText = privacyString
        
        let privateDescriptionString = NSMutableAttributedString(string: "private_description".localized, attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Light, size: anonTitle.bounds.width * 0.07), foregroundColor: .label, backgroundColor: .clear) as [NSAttributedString.Key : Any])
        privacyDescription.attributedText = privateDescriptionString
        privacyDescription.textAlignment = .center
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        cancel.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : .systemGray
        confirm.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
        let outerColor = UIColor.clear.cgColor
        let innerColor = traitCollection.userInterfaceStyle == .dark ? UIColor.secondarySystemBackground.cgColor : UIColor.white.cgColor
        hMaskLayer.colors = [outerColor, innerColor,innerColor,outerColor]
        anonIcon.setIconColor(traitCollection.userInterfaceStyle == .dark ? .white : .label)
        privacyIcon.setIconColor(traitCollection.userInterfaceStyle == .dark ? .white : .label)
        ordinaryIcon.setIconColor(traitCollection.userInterfaceStyle == .dark ? .white : .label)
    }
    
    @objc
    private func handleTap(_ recognizer: UITapGestureRecognizer) {
        if let v = recognizer.view {
            if v === confirm {
                callbackDelegate?.callbackReceived(option as Any)
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        let touch = touches.first
        guard let location = touch?.location(in: optionsStackView) else { return }
        
        if ordinary.superview!.frame.contains(location) {
            scrollView.isUserInteractionEnabled = false
            scrollView.scrollRectToVisible(ordinary.superview!.frame, animated: true)
            delay(seconds: 0.35) {
                self.scrollView.isUserInteractionEnabled = true
            }
        } else if anon.superview!.frame.contains(location) {
            scrollView.isUserInteractionEnabled = false
            scrollView.scrollRectToVisible(anon.superview!.frame, animated: true)
            delay(seconds: 0.35) {
                self.scrollView.isUserInteractionEnabled = true
            }
        } else if privacy.superview!.frame.contains(location) {
            scrollView.isUserInteractionEnabled = false
            scrollView.scrollRectToVisible(privacy.superview!.frame, animated: true)
            delay(seconds: 0.35) {
                self.scrollView.isUserInteractionEnabled = true
            }
        }
    }
    
    // MARK: - IB outlets
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.isPagingEnabled = true
            scrollView.delegate = self
        }
    }
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var optionsStackView: UIStackView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var cancel: UIImageView! {
        didSet {
            cancel.isUserInteractionEnabled = true
            cancel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:))))
            cancel.tintColor = isCancelEnabled ? traitCollection.userInterfaceStyle == .dark ? .systemBlue : .systemGray : .secondaryLabel
        }
    }
    @IBOutlet weak var confirm: UIImageView! {
        didSet {
            confirm.isUserInteractionEnabled = true
            confirm.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:))))
            confirm.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
        }
    }
    @IBOutlet weak var anon: UIView!
    @IBOutlet weak var anonConstraint: NSLayoutConstraint!
    @IBOutlet weak var anonIcon: Icon! {
        didSet {
            anonIcon.iconColor = traitCollection.userInterfaceStyle == .dark ? .white : .black
            anonIcon.category = .Anon
            anonIcon.isRounded = false
        }
    }
    @IBOutlet weak var anonTitle: ArcLabel!
    @IBOutlet weak var anonDescription: UILabel!
    @IBOutlet weak var ordinary: UIView!
    @IBOutlet weak var ordinaryTitle: ArcLabel!
    @IBOutlet weak var ordinaryDescription: UILabel!
    @IBOutlet weak var ordinaryConstraint: NSLayoutConstraint!
    @IBOutlet weak var ordinaryIcon: Icon! {
        didSet {
            ordinaryIcon.iconColor = traitCollection.userInterfaceStyle == .dark ? .white : .black
            ordinaryIcon.category = .Unlocked
            ordinaryIcon.isRounded = false
        }
    }
    @IBOutlet weak var privacy: UIView!
    @IBOutlet weak var privacyTitle: ArcLabel!
    @IBOutlet weak var privacyDescription: UILabel!
    @IBOutlet weak var privacyConstraint: NSLayoutConstraint!
    @IBOutlet weak var privacyIcon: Icon! {
        didSet {
            privacyIcon.iconColor = traitCollection.userInterfaceStyle == .dark ? .white : .black
            privacyIcon.category = .Locked
            privacyIcon.isRounded = false
        }
    }
//    @IBOutlet weak var featheredView: UIView!
    
    // MARK: - Properties
    private var isCancelEnabled = true
    private var option: PollCreationController.Option = .Ordinary
    private weak var callbackDelegate: CallbackObservable?
    private var hMaskLayer: CAGradientLayer!
    private var boundsObserver: NSKeyValueObservation?
    private var pageIndex: Int = 0 {
        didSet {
            if pageIndex == 0 {
                option = .Anon
            } else if pageIndex == 1 {
                option = .Ordinary
            } else if pageIndex == 2 {
                option = .Private
            }
        }
    }
}

extension OptionSelection: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        pageIndex = Int(round(scrollView.contentOffset.x/scrollView.frame.width))
        
        let offsetX = CGFloat(max((scrollView.contentOffset.x + scrollView.contentInset.left), 0.0))
        let anonProgress: CGFloat = min(max(round(offsetX) / anon.frame.width, 0.0), 1.0)
        let anonScaleFactor = max(1 - anonProgress, 0.6)
        anonDescription.alpha = 1 - anonProgress
        anon.alpha = max(1 - anonProgress, 0.5)
        anon.transform = CGAffineTransform(scaleX: anonScaleFactor, y: anonScaleFactor)
        anonDescription.transform = CGAffineTransform(scaleX: 1 - anonProgress, y: 1 - anonProgress)
        anonConstraint.constant = anonProgress * anon.frame.width/2
        
        if offsetX > ordinary.superview!.bounds.width {
            let ordinaryProgress: CGFloat = min(max(round(offsetX - ordinary.superview!.bounds.width) / ordinary.superview!.bounds.width, 0.0), 1.0)
            let ordinaryScaleFactor = max(1 - ordinaryProgress, 0.6)
            ordinary.alpha = max(1 - ordinaryProgress, 0.5)
            ordinaryDescription.alpha = 1 - ordinaryProgress
            ordinary.transform = CGAffineTransform(scaleX: ordinaryScaleFactor, y: ordinaryScaleFactor)
            ordinaryDescription.transform = CGAffineTransform(scaleX: 1 - ordinaryProgress, y: 1 - ordinaryProgress)
            ordinaryConstraint.constant = ordinaryProgress * ordinary.frame.width/2
        } else {
            let ordinaryProgress: CGFloat = min(max(round(offsetX) / ordinary.superview!.bounds.width, 0.0), 1.0)
            let ordinaryScaleFactor = max(ordinaryProgress, 0.6)
            ordinary.alpha = max(ordinaryProgress, 0.5)
            ordinaryDescription.alpha = ordinaryProgress
            ordinary.transform = CGAffineTransform(scaleX: ordinaryScaleFactor, y: ordinaryScaleFactor)
            ordinaryDescription.transform = CGAffineTransform(scaleX: ordinaryProgress, y: ordinaryProgress)
            ordinaryConstraint.constant = -(1 - ordinaryProgress) * ordinary.frame.width/2
        }
        
        let privacyProgress: CGFloat = min(max(round(offsetX - privacy.superview!.bounds.width) / privacy.superview!.bounds.width, 0.0), 1.0)
        let privacyScaleFactor = max(privacyProgress, 0.6)
        privacy.alpha = max(privacyProgress, 0.5)
        privacyDescription.alpha = privacyProgress
        privacy.transform = CGAffineTransform(scaleX: privacyScaleFactor, y: privacyScaleFactor)
        privacyDescription.transform = CGAffineTransform(scaleX: privacyProgress, y: privacyProgress)
        privacyConstraint.constant = -(1 - privacyProgress) * privacy.frame.width/2
    }
}
