//
//  SurveyCreationView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 25.05.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class SurveyCreationView: UIView, SurveyCreationOutput {
    
    deinit {
#if DEBUG
        print("SurveyCreationView deinit")
#endif
    }
    
    func onDidLoad() {
        destinationPoint = (viewInput?.tabBarHeight ?? 0) + UIApplication.shared.windows.first!.safeAreaInsets.bottom + (deviceType == .iPhoneSE ? 20 : 0)
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
    }
    
    private func setupUI() {
        setNeedsLayout()
        layoutIfNeeded()
        setText()
        guard let constraint = actionButton.getAllConstraints().filter({ $0.identifier == "bottom" }).first else {
            return
        }
        constraint.constant = 0
    }
    
    private func setText() {
        let ratingString = NSMutableAttributedString()
        let pollString = NSMutableAttributedString()
        let infoString = NSMutableAttributedString()
        
        guard isRatingSelected.isNil else {
            ratingString.append(NSAttributedString(string: "rating".localized.uppercased(), attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: isRatingSelected! ? StringAttributes.Fonts.Style.Bold : StringAttributes.Fonts.Style.Semibold, size: ratingLabel.bounds.width * 0.1), foregroundColor: isRatingSelected! ? traitCollection.userInterfaceStyle == .dark ? .white : .black : .secondaryLabel, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
            UIView.transition(with: ratingLabel, duration: 0.2) {
                self.ratingLabel.attributedText = ratingString
            }
            
            pollString.append(NSAttributedString(string: "poll".localized.uppercased(), attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: !isRatingSelected! ? StringAttributes.Fonts.Style.Bold : StringAttributes.Fonts.Style.Semibold, size: ratingLabel.bounds.width * 0.1), foregroundColor: !isRatingSelected! ? traitCollection.userInterfaceStyle == .dark ? .white : .black : .secondaryLabel, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
            UIView.transition(with: ratingLabel, duration: 0.2) {
                self.pollLabel.attributedText = pollString
            }
            return
        }
        ratingString.append(NSAttributedString(string: "rating".localized.uppercased(), attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Semibold, size: ratingLabel.bounds.width * 0.1), foregroundColor: .secondaryLabel, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        ratingLabel.attributedText = ratingString
        
        pollString.append(NSAttributedString(string: "poll".localized.uppercased(), attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Semibold, size: ratingLabel.bounds.width * 0.1), foregroundColor: .secondaryLabel, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        pollLabel.attributedText = pollString
        
        infoString.append(NSAttributedString(string: "poll_rating_difference".localized.uppercased(), attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Semibold, size: ratingLabel.bounds.width * 0.075), foregroundColor: traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        info.setAttributedTitle(infoString, for: .normal)
    }
    
    @objc
    private func handleTap(recognizer: UITapGestureRecognizer) {
        if recognizer.state == .ended, let icon = recognizer.view as? Icon {
            let selectedIcon: Icon! = icon == ratingIcon ? ratingIcon : pollIcon
            let deselectedIcon: Icon! = icon != ratingIcon ? ratingIcon : pollIcon
            
            if isRatingSelected != nil, (isRatingSelected! && icon == ratingIcon) || (!isRatingSelected! && icon == pollIcon) {
                return
            }
            
            let enableAnim  = Animations.get(property: .FillColor,
                                             fromValue: selectedIcon.iconColor.cgColor,
                                             toValue:  traitCollection.userInterfaceStyle == .dark ? UIColor.systemBlue.cgColor : K_COLOR_RED.cgColor,
                                             duration: 0.3,
                                             timingFunction: CAMediaTimingFunctionName.easeInEaseOut,
                                             delegate: nil,
                                             isRemovedOnCompletion: true)
            let disableAnim = Animations.get(property: .FillColor,
                                             fromValue: deselectedIcon.iconColor.cgColor,//K_COLOR_RED.cgColor,
                                             toValue: UIColor.systemGray.cgColor,
                                             duration: 0.3,
                                             timingFunction: CAMediaTimingFunctionName.easeInEaseOut,
                                             delegate: nil,
                                             isRemovedOnCompletion: true)
            
            selectedIcon.icon.add(enableAnim, forKey: nil)
            (selectedIcon.icon as! CAShapeLayer).fillColor = traitCollection.userInterfaceStyle == .dark ? UIColor.systemBlue.cgColor : K_COLOR_RED.cgColor
            if !isFirstSelection {
                deselectedIcon.icon.add(disableAnim, forKey: nil)
                (deselectedIcon.icon as! CAShapeLayer).fillColor = UIColor.systemGray.cgColor
            }
            
            
            UIView.animate(
                withDuration: 0.3,
                delay: 0,
                usingSpringWithDamping: 0.55,
                initialSpringVelocity: 2.5,
                options: [.curveEaseInOut],
                animations: {
                    selectedIcon.superview!.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            }) { _ in }
            if !isFirstSelection {
                deselectedIcon.icon.add(disableAnim, forKey: nil)
                UIView.animate(withDuration: 0.15, delay: 0, options: [.curveEaseInOut], animations: {
                    deselectedIcon.superview!.transform = .identity
                })
            }
         
            isFirstSelection = false
            isRatingSelected = icon == ratingIcon ? true : false
            setText()
            self.actionButton.cornerRadius = self.actionButton.frame.height / 2.25
//            setObservers()
        }
    }
    
//    private func setObservers() {
//        let buttonHandler = { (button: UIButton, change: NSKeyValueObservedChange<CGRect>) in
//            self.actionButton.cornerRadius = self.actionButton.frame.height / 2.25
//        }
//        buttonObserver = actionButton.observe(\UIButton.bounds, options: [NSKeyValueObservingOptions.new], changeHandler: buttonHandler)
//    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setText()
        actionButton.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
        //        info.setTitleColor(.systemRed, for: .normal)
        if !isRatingSelected.isNil {
        ratingIcon.setIconColor(isRatingSelected! ? traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED : .systemGray)
            pollIcon.setIconColor(!isRatingSelected! ? traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED : .systemGray)}
    }

    // MARK: - Properties
    weak var viewInput: SurveyCreationViewInput?
    private var isFirstSelection = true {
        didSet {
            if oldValue != isFirstSelection {
                guard let constraint = actionButton.getAllConstraints().filter({ $0.identifier == "bottom" }).first else {
                    return
                }
                UIView.animate(
                    withDuration: 0.3,
                    delay: 0,
                    usingSpringWithDamping: 0.7,
                    initialSpringVelocity: 2.5,
                    options: [.curveEaseInOut],
                    animations: {
                        self.setNeedsLayout()
                        constraint.constant = self.destinationPoint
                        self.layoutIfNeeded()
                }) { _ in }
            }
        }
    }
    private var isRatingSelected: Bool?
    private var destinationPoint: CGFloat = 0
    private var buttonObserver: NSKeyValueObservation?
    
    @IBOutlet weak var actionButton: UIButton! {
        didSet {
            actionButton.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
            actionButton.setTitle("continueButton".localized.uppercased(), for: .normal)
        }
    }
    @IBAction func actionButtonTapped(_ sender: Any) {
        viewInput?.onNext(isRatingSelected! ? .Ranking : .Poll)
    }
    @IBOutlet weak var stack: UIStackView!
    @IBOutlet weak var ratingLabel: ArcLabel!
    @IBOutlet weak var ratingIcon: Icon! {
        didSet {
            ratingIcon.backgroundColor = UIColor.clear
            ratingIcon.iconColor       = .systemGray//UIColor.lightGray.withAlphaComponent(0.75)
            ratingIcon.category        = .Rating
            ratingIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap(recognizer:))))
        }
    }
    @IBOutlet weak var pollLabel: ArcLabel!
    @IBOutlet weak var pollIcon: Icon! {
        didSet {
            pollIcon.backgroundColor = UIColor.clear
            pollIcon.iconColor       = .systemGray//UIColor.lightGray.withAlphaComponent(0.75)
            pollIcon.scaleMultiplicator     = 2.65
            pollIcon.category        = .Poll
            pollIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap(recognizer:))))
        }
    }
    @IBOutlet weak var rating: UIView!
    @IBOutlet weak var poll: UIView!
    // MARK: - Properties
    
    
    // MARK: - IB outlets
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var info: UIButton! {
        didSet {
//            info.setImage(ImageSigns.infoСircle.image, for: .normal)
            info.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
        }
    }
    @IBAction func infoTapped(_ sender: Any) {
        let banner = Popup(frame: UIScreen.main.bounds, callbackDelegate: nil, bannerDelegate: self, heightScaleFactor: deviceType == .iPhoneSE ? 0.8 : 0.6)
//        banner.accessibilityIdentifier = "claim"
        banner.present(subview: UIView(), shouldDismissAfter: 2)
    }
}

extension SurveyCreationView: BannerObservable {
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

//extension SurveyCreationView: CallbackObservable {
//    func callbackReceived(_ sender: Any) {
//
//    }
//}
