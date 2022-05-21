//
//  CurrentUserProfileView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 18.05.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class CurrentUserProfileView: UIView {
    
    // MARK: - Initialization
    init(frame: CGRect, callbackDelegate: CallbackObservable) {
        super.init(frame: frame)
        commonInit()
        self.callbackDelegate = callbackDelegate
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
        setupUI()
        setObservers()
    }
    
    var observer: NSKeyValueObservation?
    var buttonObserver: NSKeyValueObservation?
    
    private func setupUI() {
        collectionView.delegate = self
        collectionView.dataSource = self
        setLabels()
        setStats()
        setSocialButtons()
        
        if deviceType == .iPhone11ProMax ||
            deviceType == .iPhone13ProMax ||
//            deviceType == .unrecognized ||
            deviceType == .iPhone13ProMax {
            stackView.heightAnchor.constraint(equalTo: avatar.heightAnchor, multiplier: 0.3).isActive = true
        } else if deviceType == .iPhoneSE {
            stackView.heightAnchor.constraint(equalTo: avatar.heightAnchor, multiplier: 0.25).isActive = true
        } else {
            stackView.heightAnchor.constraint(equalTo: avatar.heightAnchor, multiplier: 0.275).isActive = true
        }
    }
    
    private func setLabels() {
        guard let currentUser = Userprofiles.shared.current else { return }
        
        let attributedText = NSMutableAttributedString()
        
        var nameMultiplier: CGFloat = 0.13
        var infoMultiplier: CGFloat = 0.08
        var titlesMultiplier: CGFloat = 0.045
        
        if deviceType == .iPhoneSE {
            nameMultiplier = 0.095
            infoMultiplier = 0.06
            titlesMultiplier = 0.04
        } else if deviceType == .iPhone11ProMax ||
                    deviceType == .iPhone13ProMax ||
//                                        deviceType == .unrecognized ||
                    deviceType == .iPhone13ProMax {
            nameMultiplier = 0.13
        } else {
            nameMultiplier = 0.12
            infoMultiplier = 0.08
        }
        
        attributedText.append(NSAttributedString(string: "\(currentUser.firstNameSingleWord)" + (!currentUser.lastNameSingleWord.isEmpty ? "\n\(currentUser.lastNameSingleWord)" : ""), attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Semibold, size: name.frame.width * nameMultiplier), foregroundColor: .label, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        attributedText.append(NSAttributedString(string: "\n\(currentUser.age), \(currentUser.gender.rawValue.localized.lowercased())" + (!currentUser.cityTitle.isNil ? ", \(currentUser.cityTitle!)" : ""), attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Regular, size: name.frame.width * infoMultiplier), foregroundColor: .secondaryLabel, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        name.attributedText = attributedText
        
        let preferencesText = NSMutableAttributedString()
        preferencesText.append(NSAttributedString(string: "preferences".localized, attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Regular, size: preferences.frame.width * titlesMultiplier), foregroundColor: .secondaryLabel, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        preferences.attributedText = preferencesText
        
        let balanceText = NSMutableAttributedString()
        balanceText.append(NSAttributedString(string: "my_balance".localized, attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Regular, size: preferences.frame.width * titlesMultiplier), foregroundColor: .secondaryLabel, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        balanceTitle.attributedText = balanceText
    }
    
    private func setStats() {
        guard let currentUser = Userprofiles.shared.current else { return }
        
        var balance_1_Multiplier: CGFloat = 0.08
        var balance_2_Multiplier: CGFloat = 0.07
        
        if deviceType == .iPhoneSE {
            balance_1_Multiplier = 0.06
            balance_2_Multiplier = 0.05
        }
        
        let publicationsText = NSMutableAttributedString()
        publicationsText.append(NSAttributedString(string: "publications".localized.lowercased(), attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Regular, size: UIScreen.main.bounds.width * 0.035), foregroundColor: .secondaryLabel, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        publicationsText.append(NSAttributedString(string: "\n\(currentUser.publicationsTotal)", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Semibold, size: UIScreen.main.bounds.width * 0.035), foregroundColor: .label, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        publications.attributedText = publicationsText
        
        let completedText = NSMutableAttributedString()
        completedText.append(NSAttributedString(string: "completed".localized.lowercased(), attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Regular, size: UIScreen.main.bounds.width * 0.035), foregroundColor: .secondaryLabel, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        completedText.append(NSAttributedString(string: "\n\(currentUser.completeTotal)", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Semibold, size: UIScreen.main.bounds.width * 0.035), foregroundColor: .label, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        completed.attributedText = completedText
        
        let subscribersText = NSMutableAttributedString()
        subscribersText.append(NSAttributedString(string: "subscribers".localized.lowercased(), attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Regular, size: UIScreen.main.bounds.width * 0.035), foregroundColor: .secondaryLabel, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        subscribersText.append(NSAttributedString(string: "\n\(currentUser.subscribersTotal)", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Semibold, size: UIScreen.main.bounds.width * 0.035), foregroundColor: .label, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        subscribers.attributedText = subscribersText
        
        let balanceText = NSMutableAttributedString()
        balanceText.append(NSAttributedString(string: "\(currentUser.balance)", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: UIScreen.main.bounds.width * balance_1_Multiplier), foregroundColor: .label, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        balanceText.append(NSAttributedString(string: " " + "points".localized.lowercased(), attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Semibold, size: UIScreen.main.bounds.width * balance_2_Multiplier), foregroundColor: .secondaryLabel, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        balance.attributedText = balanceText
    }
    
    private func setSocialButtons() {
        guard let currentUser = Userprofiles.shared.current else { return }
        if currentUser.facebookURL != nil {
            let icon = FacebookLogo(frame: .zero)
            icon.accessibilityIdentifier = "facebook"
            icon.isOpaque = false
//            stackView.addArrangedSubview(icon)
            icon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleSocial(recognizer:))))
            socialButtons.append(icon)
        }
        if currentUser.instagramURL != nil {
            let icon = InstagramLogo(frame: .zero)
            icon.accessibilityIdentifier = "instagram"
            icon.isOpaque = false
            icon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleSocial(recognizer:))))
//            stackView.addArrangedSubview(icon)
        }
        if currentUser.tiktokURL != nil {
            let icon = TikTokLogo(frame: .zero)
            icon.accessibilityIdentifier = "tiktok"
            icon.isOpaque = false
            icon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleSocial(recognizer:))))
            socialButtons.append(icon)
//            stackView.addArrangedSubview(icon)
        }
        if currentUser.vkURL != nil {
            let icon = VKLogo(frame: .zero)
            icon.accessibilityIdentifier = "vk"
            icon.isOpaque = false
            icon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleSocial(recognizer:))))
            socialButtons.append(icon)
//            stackView.addArrangedSubview(icon)
        }
    }
    
    private func setObservers() {
        let names = [Notifications.System.UpdateStats]
        names.forEach { NotificationCenter.default.addObserver(self, selector: #selector(self.updateStats), name: $0, object: nil) }
        
        let handler = { (collectionView: UICollectionView, change: NSKeyValueObservedChange<CGSize>) in
            guard self.collectionView.frame.height != change.newValue?.height else { return }
            if let contentSize = change.newValue {
                UIView.animate(withDuration: 0.2) {
                    self.collectionView.setNeedsLayout()
                    if let constraint = self.collectionView.constraints.filter({ $0.identifier == "test" }).first {
                        self.collectionView.removeConstraint(constraint)
                    }
                    let constr = self.collectionView.heightAnchor.constraint(equalToConstant: contentSize.height)
                    constr.identifier = "test"
                    constr.isActive = true
                    self.collectionView.layoutIfNeeded()
                }
            }
        }
        observer = collectionView.observe(\UICollectionView.contentSize, options: [NSKeyValueObservingOptions.new], changeHandler: handler)
        
        
        let buttonHandler = { (button: UIButton, change: NSKeyValueObservedChange<CGRect>) in
            self.votesButton.cornerRadius = self.votesButton.frame.height / 2.25
        }
        buttonObserver = votesButton.observe(\UIButton.bounds, options: [NSKeyValueObservingOptions.new], changeHandler: buttonHandler)
        
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        votesButton.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
    }
    
    @objc
    private func updateStats() {
        setStats()
        collectionView.reloadData()
//        collectionView.collectionViewLayout.collectionViewContentSize
    }
    
//    override class func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
////        if let observedObject = object as? UICollectionView where observedObject == self.collectionView {
//            print(change)
////        }
//    }
    
    @objc
    private func handleSocial(recognizer: UITapGestureRecognizer) {
        if recognizer.state == .ended, let sender = recognizer.view {
            
            if sender.accessibilityIdentifier == "facebook", !Userprofiles.shared.current.isNil, let url = Userprofiles.shared.current!.facebookURL {
                callbackDelegate?.callbackReceived(url)
            } else if sender.accessibilityIdentifier == "vk", !Userprofiles.shared.current.isNil, let url = Userprofiles.shared.current!.vkURL {
                callbackDelegate?.callbackReceived(url)
            } else if sender.accessibilityIdentifier == "tiktok", !Userprofiles.shared.current.isNil, let url = Userprofiles.shared.current!.tiktokURL {
                callbackDelegate?.callbackReceived(url)
            } else if sender.accessibilityIdentifier == "instagram", !Userprofiles.shared.current.isNil, let url = Userprofiles.shared.current!.instagramURL {
                callbackDelegate?.callbackReceived(url)
            }
            callbackDelegate?.callbackReceived(sender.accessibilityIdentifier as Any)
        }
    }
    
    

    // MARK: - IB outlets
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var avatar: Avatar! {
        didSet {
            avatar.backgroundColor = .clear
//            avatar.darkColor = .clear
//            avatar.lightColor = .clear
            avatar.setImage(UIImage(named: "user")!)
        }
    }
    @IBOutlet weak var name: UILabel! {
        didSet {
            name.numberOfLines = 0
        }
    }
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var labelsStackView: UIStackView!
    @IBOutlet weak var publications: UILabel!
    @IBOutlet weak var completed: UILabel!
    @IBOutlet weak var subscribers: UILabel!
    @IBOutlet weak var preferences: UILabel!
    @IBOutlet weak var balanceTitle: UILabel!
    @IBOutlet weak var balance: UILabel!
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.register(UINib(nibName: "InterestCollectionCell", bundle: Bundle.main), forCellWithReuseIdentifier: "category")
//            collectionView.delegate = self
//            collectionView.dataSource = self
            columnLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
            collectionView.collectionViewLayout = columnLayout
            let constr = collectionView.heightAnchor.constraint(equalToConstant: 100)
            constr.identifier = "test"
            constr.isActive = true
        }
    }
    @IBOutlet weak var collectionViewLayout: UICollectionViewFlowLayout! {
        didSet {
            collectionViewLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        }
    }
    @IBOutlet weak var votesButton: UIButton! {
        didSet {
            votesButton.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
            votesButton.setTitle("top_up".localized.uppercased(), for: .normal)
        }
    }
    @IBAction func getVotes(_ sender: Any) {
    }
    
    
    // MARK: - Properties
    private var socialButtons: [UIView] = [] {
        didSet {
            guard let instance = socialButtons.last, !oldValue.contains(instance) else { return }
            stackView.addArrangedSubview(instance)
            stackView.constraints.last?.isActive = false
            stackView.widthAnchor.constraint(equalTo: stackView.heightAnchor, multiplier: CGFloat(stackView.arrangedSubviews.count)).isActive = true
        }
    }
    private weak var callbackDelegate: CallbackObservable?
    private let columnLayout = CustomViewFlowLayout()
    private let sectionInsets = UIEdgeInsets(top: 3.0, left: 3.0, bottom: 3.0, right: 3.0)
    private let itemsPerRow: CGFloat = 3
    override var frame: CGRect {
        didSet {
            guard !votesButton.isNil else { return }
            votesButton.cornerRadius = votesButton.frame.height / 2.25
        }
    }
}

extension CurrentUserProfileView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Userprofiles.shared.current?.topPublicationCategories?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let currentUser = Userprofiles.shared.current, let categories = currentUser.sortedTopPublicationCategories, !categories.isEmpty  else { return UICollectionViewCell() }
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "category", for: indexPath) as? InterestCollectionCell {
            guard let dict = categories[indexPath.row] as? [Topic: Int], let category = dict.first?.key else { return UICollectionViewCell() }
            let attrString = NSMutableAttributedString()
            attrString.append(NSAttributedString(string: category.title.uppercased(), attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Semibold, size: collectionView.frame.width * 0.0325), foregroundColor: .white, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
            attrString.append(NSAttributedString(string: "/", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Regular, size: collectionView.frame.width * 0.0325), foregroundColor: .white, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
            attrString.append(NSAttributedString(string: category.parent!.title.uppercased(),
                                                 attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Regular, size: collectionView.frame.width * 0.0325), foregroundColor: .white, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
            cell.categoryLabel.attributedText = attrString
            cell.categoryLabel.backgroundColor = category.tagColor
            cell.categoryLabel.cornerRadiusMultipler = 2.5
            cell.categoryLabel.textAlignment = .center
            return cell
        }
        return UICollectionViewCell()
    }
    
//    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        self.collectionView.heightAnchor.constraint(equalToConstant: collectionView.collectionViewLayout.collectionViewContentSize.height).isActive = true
//    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return false
    }
}
