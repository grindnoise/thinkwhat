//
//  SubsciptionsView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 10.03.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class SubsciptionsView: UIView {
    
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
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(contentView)
        setupUI()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
//        ///Add shadow
//        cardShadow.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.6).cgColor
//        cardShadow.layer.shadowPath = UIBezierPath(roundedRect: cardShadow.bounds, cornerRadius: cardShadow.frame.width * 0.05).cgPath
//        cardShadow.layer.shouldRasterize = true
//        cardShadow.layer.rasterizationScale = UIScreen.main.scale
//        cardShadow.layer.shadowRadius = 7
//        cardShadow.layer.shadowOffset = .zero
//        cardShadow.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1

    }
    
    // MARK: - Properties
    weak var viewInput: SubsciptionsViewInput?
    private var isSetupCompleted = false
    private var isCollectionViewSetupCompleted = false
    private var shadowPath: CGPath!
    private let reuseIdentifier = "voter"
    private var needsAnimation = true
    private var isRevealed = false
    
    // MARK: - IB outlets
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var upperContainer: UIView! {
        didSet {
            upperContainer.backgroundColor = .systemBackground
//            upperContainer.alpha = 0
        }
    }
//    @IBOutlet weak var usersView: UIView!
//    @IBOutlet weak var usersWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var bottomContainer: UIView!
    @IBOutlet weak var card: UIView! {
        didSet {
            card.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .systemBackground
        }
    }
    @IBOutlet weak var cardShadow: UIView!
    @IBOutlet weak var upperContainerHeightConstraint: NSLayoutConstraint! {
        didSet {
            upperContainerHeightConstraint.constant = 0
        }
    }
    @IBOutlet weak var subscribers: UIButton! {
        didSet {
            subscribers.setTitle("subscribers".localized.uppercased(), for: .normal)
        }
    }
    @IBAction func subscribersTapped(_ sender: UIButton) {
        viewInput?.onSubscribersTapped()
    }
    @IBOutlet weak var more: UIButton! {
        didSet {
            more.setAttributedTitle(NSAttributedString(string: "more".localized, attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Semibold, size: frame.width * 0.08), foregroundColor: .label, backgroundColor: .clear) as [NSAttributedString.Key : Any]), for: .normal)
        }
    }
    @IBAction func moreTapped(_ sender: UIButton) {
        viewInput?.onSubscpitionsTapped()
    }
}

// MARK: - Controller Output
extension SubsciptionsView: SubsciptionsControllerOutput {
    func onWillAppear() {
        if #available(iOS 14, *) {
            guard let v = card.subviews.filter({ $0.isKind(of: SurveysCollection.self) }).first as? SurveysCollection else { return }
            v.deselect()
        } else {
            guard let v = card.subviews.filter({ $0.isKind(of: SurveyTable.self) }).first as? SurveyTable else { return }
            v.deselect()
        }
    }
    
    
    func onError() {
        showBanner(bannerDelegate: self, text: AppError.server.localizedDescription, imageContent: ImageSigns.exclamationMark, shouldDismissAfter: 1)
    }
    
    
//    func onSubscriptionsUpdated() {
//        if #available(iOS 14, *) {
//            viewInput
//        } else {
//            // Fallback on earlier versions
//        }
//    }
    
    func onSubscribedForUpdated() {
        collectionView.reloadData()
    }
    
    func onDidLoad() {}
    
    
    func onDidLayout() {
        guard !isSetupCompleted else { return }
        isSetupCompleted = true
        ///Add shadow
        transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        alpha = 0
        cardShadow.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.6).cgColor
        shadowPath = UIBezierPath(roundedRect: cardShadow.bounds, cornerRadius: cardShadow.frame.width * 0.05).cgPath
        cardShadow.layer.shadowPath = shadowPath
        cardShadow.layer.shadowRadius = 7
        cardShadow.layer.shadowOffset = .zero
        cardShadow.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
        UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseInOut) {
            self.alpha = 1
            self.transform = .identity
        } completion: { _ in }
    }
    
    func onUpperContainerShown(_ reveal: Bool) {
        isRevealed = reveal
        let cardBlur: UIView = {
            guard let v = self.card.subviews.filter({ $0.accessibilityIdentifier == "cardBlur" }).first else {
                let v = UIView(frame: card.bounds)
                v.backgroundColor = .black.withAlphaComponent(0.5)
                v.alpha = 0
                card.addSubview(v)
                v.accessibilityIdentifier = "cardBlur"
                v.isUserInteractionEnabled = true
                v.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.hideMenu)))
                return v
            }
            return v
        }()
        let menuBlur: UIVisualEffectView =  {
            guard let v = self.upperContainer.subviews.filter({ $0.accessibilityIdentifier == "menuBlur" }).first as? UIVisualEffectView else {
                let blur = UIVisualEffectView(effect: UIBlurEffect(style: .prominent))
                blur.frame = upperContainer.bounds
//                upperContainer.addSubview(blur)
                blur.addEquallyTo(to: upperContainer)
                blur.setNeedsLayout()
                blur.layoutIfNeeded()
                blur.accessibilityIdentifier = "menuBlur"
                blur.isUserInteractionEnabled = false
                return blur
            }
            return v
        }()

        cardBlur.alpha = reveal ? 0 : 1
        menuBlur.effect = !reveal ? nil : UIBlurEffect(style: .prominent)
        if !reveal {
            menuBlur.setNeedsLayout()
            menuBlur.layoutIfNeeded()
        }
        
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.17, delay: 0,
                                                       options: [.curveLinear],
                                                       animations: {
            cardBlur.alpha = !reveal ? 0 : 1
            menuBlur.effect = reveal ? nil : UIBlurEffect(style: .prominent)
            self.setNeedsLayout()
            self.upperContainerHeightConstraint.constant += reveal ? self.frame.height * 0.15 : -self.upperContainerHeightConstraint.constant
            self.layoutIfNeeded()
            self.upperContainer.subviews.forEach {
                $0.alpha = reveal ? 1 : 0
            }
//            self.upperContainer.alpha = reveal ? 1 : 0
        })
        {
            [weak self] _ in
            guard !self.isNil else { return }
            self!.setFlowLayout()
            guard !reveal else { return }
        }
    }
}

// MARK: - UI Setup
extension SubsciptionsView {
    private func setupUI() {
        collectionView.register(UINib(nibName: "VoterCell", bundle: Bundle.main), forCellWithReuseIdentifier: reuseIdentifier)
        card.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .systemBackground
        card.layer.masksToBounds = true
        card.layer.cornerRadius = card.frame.width * 0.05
        alpha = 0
        setText()
        if #available(iOS 14, *)  {
            let list = SurveysCollection(delegate: self)//(frame: card.bounds)
            list.addEquallyTo(to: card)
        } else {
            let list = SurveyTable(delegate: self)
            list.addEquallyTo(to: card)
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        cardShadow.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
        card.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .systemBackground
        setText()
//        guard let v = self.card.subviews.filter({ $0.accessibilityIdentifier == "cardBlur" }).first as? UIVisualEffectView, isRevealed else { return }
//                v.effect = UIBlurEffect(style: self.traitCollection.userInterfaceStyle == .dark ? .dark : .light)
    }
    
    private func setText() {
        guard !more.isNil, !subscribers.isNil else { return }
        more.setAttributedText(text: "more".localized.uppercased(),
                               font: Fonts.Semibold,
                               width: bounds.width,
                               widthDivisor: 0.0325,
                               lightColor: K_COLOR_RED,
                               style: traitCollection.userInterfaceStyle)
        subscribers.setAttributedText(text: "subscribers".localized.uppercased(),
                                      font: Fonts.Semibold,
                                      width: bounds.width,
                                      widthDivisor: 0.0325,
                                      lightColor: K_COLOR_RED,
                                      style: traitCollection.userInterfaceStyle)
    }
    
    private func setFlowLayout() {
        guard !isCollectionViewSetupCompleted else { return }
        isCollectionViewSetupCompleted = true
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: collectionView.bounds.height, height: collectionView.bounds.height)
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumInteritemSpacing = 0.0
        collectionView.collectionViewLayout = flowLayout
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    @objc
    private func hideMenu() {
        viewInput?.toggleBarButton()
    }
}

extension SubsciptionsView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewInput?.userprofiles.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? VoterCell,
           let userprofile = viewInput?.userprofiles[indexPath.row] as? Userprofile {
            cell.setupUI(callbackDelegate: self, userprofile: userprofile, mode: .FirstnameLastname, lightColor: K_COLOR_RED)
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard needsAnimation else { return }
        cell.alpha = 0
        cell.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        UIView.animate(withDuration: 0.15, delay: 0.04 * Double(indexPath.row)) {
            cell.alpha = 1
            cell.transform = .identity
        }
        needsAnimation = (collectionView.visibleCells.count < (indexPath.row + 1))
    }
}

extension SubsciptionsView: CallbackObservable {
    func callbackReceived(_ sender: Any) {
        if let instance = sender as? SurveyReference {
            viewInput?.onSurveyTapped(instance)
        } else if #available(iOS 14, *) {
            if sender is SurveysCollection || sender is SurveyTable {
                viewInput?.onDataSourceUpdate()
            }
        }
    }
}

extension SubsciptionsView: BannerObservable {
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

