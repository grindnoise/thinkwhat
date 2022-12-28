//
//  ListView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 11.03.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class ListView: UIView {
    
    // MARK: - Public properties
    public let subscribePublisher = CurrentValueSubject<[Userprofile]?, Never>(nil)
    public let unsubscribePublisher = CurrentValueSubject<[Userprofile]?, Never>(nil)
    public let userprofilePublisher = CurrentValueSubject<[Userprofile]?, Never>(nil)
    public weak var viewInput: (ListViewInput & TintColorable)? {
        didSet {
            guard let viewInput = viewInput else { return }
            
            setTitle(category: viewInput.category, animated: false)
            collectionView.color = viewInput.tintColor
            
            if #available(iOS 15, *) {
                if !periodButton.configuration.isNil {
                    periodButton.configuration?.imageColorTransformer = UIConfigurationColorTransformer { _ in return viewInput.tintColor }
                }
            } else {
                periodButton.imageView?.tintColor = viewInput.tintColor
                periodButton.tintColor = viewInput.tintColor
            }
        }
    }
    
    
    
    // MARK: - Private properties
    private var observers: [NSKeyValueObservation] = []
    private var subscriptions = Set<AnyCancellable>()
    private var tasks: [Task<Void, Never>?] = []
    //UI
    private var isDateFilterHidden = false {
        didSet {
            guard oldValue != isDateFilterHidden else { return }
            
            toggleDateFilter(on: !isDateFilterHidden)
        }
    }
    private lazy var filterView: UIView = {
       let instance = UIView()
        instance.backgroundColor = .clear
        
        let stack = UIStackView(arrangedSubviews: [
            titleLabel,
            periodButton
        ])
        stack.axis = .horizontal
        stack.spacing = 4
        
        instance.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
//            stack.topAnchor.constraint(equalTo: instance.topAnchor),
            stack.centerXAnchor.constraint(equalTo: instance.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: instance.centerYAnchor),
//            stack.bottomAnchor.constraint(equalTo: instance.bottomAnchor)
        ])
        
        return instance
    }()
    private lazy var titleLabel: UILabel = {
       let instance = UILabel()
        instance.numberOfLines = 1
        instance.textAlignment = .center
        instance.numberOfLines = 1
        instance.textColor = .label//traitCollection.userInterfaceStyle == .dark ? .label : .darkGray
        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Bold.rawValue, forTextStyle: .title3)
        instance.adjustsFontSizeToFitWidth = true
        
//        if let viewInput = viewInput {
//            setTitle(category: viewInput.category, animated: false)
//        }
        
        let constraint = instance.widthAnchor.constraint(equalToConstant: 0)
        constraint.identifier = "width"
        constraint.isActive = true
        
        return instance
    }()
    private lazy var periodButton: UIButton = {
        let instance = UIButton()
        instance.titleLabel?.numberOfLines = 1
        instance.showsMenuAsPrimaryAction = true
        instance.menu = prepareMenu()
        
        if #available(iOS 15, *) {
            var config = UIButton.Configuration.filled()
            config.cornerStyle = .medium
            config.image = UIImage(systemName: "chevron.down.square.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .medium))
            config.imagePlacement = .trailing
            config.imagePadding = 4
            config.contentInsets.leading = 4
            config.contentInsets.trailing = 4
            config.contentInsets.top = 0
            config.contentInsets.bottom = 0
            config.title = "per_\(period.rawValue.lowercased())".localized.lowercased()
            config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { [weak self] incoming in
                guard let self = self,
                      let viewInput = self.viewInput
                else { return incoming }
                
                var outcoming = incoming
                outcoming.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .title3)
                outcoming.foregroundColor = viewInput.tintColor//UIColor.secondaryLabel
                return outcoming
            }
//            config.imageColorTransformer = UIConfigurationColorTransformer { [weak self] _ in
//                guard let self = self,
//                      let viewIput = self.viewInput
//                else { return .systemGray }
//
//                return viewIput.tintColor
//            }
            config.buttonSize = .large
            config.baseBackgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
            config.baseForegroundColor = .label

            instance.configuration = config
        } else {
            let attrString = NSMutableAttributedString(string: "Мужчина", attributes: [
                NSAttributedString.Key.font: UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .title3) as Any,
                NSAttributedString.Key.foregroundColor: UIColor.secondaryLabel,
            ])
            instance.setAttributedTitle(attrString, for: .normal)
            instance.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            instance.setImage(UIImage(systemName: "chevron.down.square.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .medium)), for: .normal)
            instance.imageView?.contentMode = .scaleAspectFit
            instance.imageEdgeInsets.left = 10
            instance.imageEdgeInsets.top = 2
            instance.imageEdgeInsets.bottom = 2
            instance.imageEdgeInsets.right = 2
            instance.semanticContentAttribute = .forceRightToLeft
            instance.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground

            let constraint = instance.widthAnchor.constraint(equalToConstant: "Мужчина".width(withConstrainedHeight: instance.bounds.height, font: UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .subheadline)!))
            constraint.identifier = "width"
            constraint.isActive = true
        }
        
        instance.publisher(for: \.bounds, options: .new).sink { rect in
            instance.cornerRadius = rect.height * 0.15
        }.store(in: &subscriptions)
        
        return instance
    }()
    private lazy var collectionView: SurveysCollectionView = {
      let instance = SurveysCollectionView(category: .New,
                                           color: viewInput?.tintColor ?? Colors.System.Red.rawValue)
        
        //Pagination #1
        let paginationPublisher = instance.paginationPublisher
            .debounce(for: .seconds(2), scheduler: DispatchQueue.main)
        
        paginationPublisher
            .sink { [unowned self] in
                guard let source = $0.keys.first,
                      let period = $0.values.first
                else { return }
                
                self.viewInput?.onDataSourceRequest(source: source, dateFilter: period, topic: nil)
            }
            .store(in: &subscriptions)
        
        //Pagination #2
        let paginationByTopicPublisher = instance.paginationByTopicPublisher
            .debounce(for: .seconds(2), scheduler: DispatchQueue.main)
        
        paginationByTopicPublisher
            .sink { [unowned self] in
                guard let topic = $0.keys.first,
                      let period = $0.values.first
                else { return }

                self.viewInput?.onDataSourceRequest(source: .Topic, dateFilter: period, topic: topic)
            }
            .store(in: &subscriptions)
        
        //Refresh #1
        instance.refreshPublisher
            .sink { [unowned self] in
                guard let category = $0.keys.first,
                      let period = $0.values.first
                else { return }
                
                self.viewInput?.onDataSourceRequest(source: category, dateFilter: period, topic: nil)
            }
            .store(in: &subscriptions)
        
        //Refresh #2
        instance.refreshByTopicPublisher
            .sink { [unowned self] in
                guard let topic = $0.keys.first,
                      let period = $0.values.first
                else { return }
                
                self.viewInput?.onDataSourceRequest(source: .Topic, dateFilter: period, topic: topic)
            }
            .store(in: &subscriptions)
        
        //Row selected
        instance.rowPublisher
            .sink { [unowned self] in
                guard let instance = $0
            else { return }
                  
            self.viewInput?.onSurveyTapped(instance)
        }
            .store(in: &subscriptions)
        
        //Update stats (exclude refs)
        instance.updateStatsPublisher
            .sink { [weak self] in
            guard let self = self,
                  let instances = $0
            else { return }
                  
            self.viewInput?.updateSurveyStats(instances)
        }
            .store(in: &subscriptions)
        
        //Add to watch list
        instance.watchSubject.sink {
            print($0)
        } receiveValue: { [weak self] in
            guard let self = self,
                let value = $0
            else { return }
            
            self.viewInput?.addFavorite(value)
        }.store(in: &self.subscriptions)
        
        instance.shareSubject
            .sink { [weak self] in
                guard let self = self,
                      let value = $0
                else { return }
                
                self.viewInput?.share(value)
            }
            .store(in: &self.subscriptions)
        
        instance.claimSubject
            .sink { [weak self] in
                guard let self = self,
                      let surveyReference = $0
                else { return }
                
                let banner = Popup()
                let claimContent = ClaimPopupContent(parent: banner, surveyReference: surveyReference)
                
                claimContent.claimPublisher
                    .sink { [weak self] in
                        guard let self = self else { return }
                        
                        self.viewInput?.claim(surveyReference: surveyReference, claim: $0)
                    }
                    .store(in: &self.subscriptions)
                
                banner.present(content: claimContent)
                banner.didDisappearPublisher
                    .sink { _ in banner.removeFromSuperview() }
                    .store(in: &self.subscriptions)
            }
            .store(in: &self.subscriptions)
        
        instance.userprofilePublisher
            .sink { [weak self] in
                guard let self = self,
                      let userprofile = $0
                else { return }
                
                self.viewInput?.openUserprofile(userprofile)
            }
            .store(in: &self.subscriptions)
        
        instance.settingsTapPublisher
            .sink { [weak self] in
                guard let self = self,
                      !$0.isNil
                else { return }
                
                self.viewInput?.openSettings()
            }
            .store(in: &self.subscriptions)
        
        instance.subscribePublisher
            .sink { [weak self] in
                guard let self = self,
                      let userprofile = $0
                else { return }
                
                self.viewInput?.subscribe(to: userprofile)
            }
            .store(in: &self.subscriptions)
        
        instance.unsubscribePublisher
            .sink { [weak self] in
                guard let self = self,
                      let userprofile = $0
                else { return }
                
                self.viewInput?.unsubscribe(from: userprofile)
            }
            .store(in: &self.subscriptions)
        
        instance.scrollPublisher
            .sink { [weak self] in
                guard let self = self else { return }
                
                self.isDateFilterHidden = $0
//                self.toggleDateFilter(on: !$0)
            }
            .store(in: &subscriptions)
        
        return instance
    }()
//    private lazy var featheredView: UIView = {
//        let instance = UIView()
//        instance.accessibilityIdentifier = "feathered"
//        instance.layer.masksToBounds = true
//        instance.backgroundColor = .clear
//        instance.addEquallyTo(to: background)
//        observers.append(instance.observe(\UIView.bounds, options: .new) { [weak self] view, change in
//            guard let self = self, let newValue = change.newValue, newValue.size != self.featheredLayer.bounds.size else { return }
//            self.featheredLayer.frame = newValue
//        })
//        collectionView.addEquallyTo(to: instance)
//        return instance
//    }()
//    private lazy var featheredLayer: CAGradientLayer = {
//        let instance = CAGradientLayer()
//        let outerColor = UIColor.clear.cgColor
////        let innerColor = traitCollection.userInterfaceStyle == .dark ? UIColor.bl.cgColor : UIColor.secondarySystemBackground.cgColor
//        let innerColor = traitCollection.userInterfaceStyle == .dark ? UIColor.black.cgColor : UIColor.white.cgColor
//        instance.colors = [outerColor, innerColor, innerColor, outerColor]
//        instance.locations = [0.0, 0.0075, 0.985, 1.0]
//        instance.frame = frame
//        return instance
//    }()
//    private var hMaskLayer: CAGradientLayer!
    private lazy var shadowView: UIView = {
        let instance = UIView()
        instance.layer.masksToBounds = false
        instance.clipsToBounds = false
        instance.backgroundColor = .clear
        instance.accessibilityIdentifier = "shadow"
        instance.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
        instance.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        instance.layer.shadowRadius = 5
        instance.layer.shadowOffset = .zero
        instance.publisher(for: \.bounds)
            .receive(on: DispatchQueue.main)
            .filter { $0 != .zero }
            .sink { instance.layer.shadowPath = UIBezierPath(roundedRect: $0, cornerRadius: $0.width*0.05).cgPath }
            .store(in: &subscriptions)
        background.addEquallyTo(to: instance)
        
        return instance
    }()
    private lazy var background: UIView = {
        let instance = UIView()
        instance.accessibilityIdentifier = "bg"
        instance.layer.masksToBounds = false
        instance.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .black : .secondarySystemBackground
        observers.append(instance.observe(\UIView.bounds, options: .new) { view, change in
            guard let value = change.newValue else { return }
            view.cornerRadius = value.width * 0.05
        })
        
        collectionView.addEquallyTo(to: instance)
        
        return instance
    }()
    private lazy var filterViewHeight: CGFloat = .zero
    //Logic
    private var period: Period = .AllTime {
        didSet {
            guard oldValue != period,
                  let category = viewInput?.category
            else { return }
            
            collectionView.period = period
            
            periodButton.menu = prepareMenu()
            setTitle(category: category, animated: true)
        }
    }
    
    
    
    // MARK: - IB outlets
    @IBOutlet var contentView: UIView!
    
    
    
    // MARK: - Destructor
    deinit {
        observers.forEach { $0.invalidate() }
        tasks.forEach { $0?.cancel() }
        subscriptions.forEach { $0.cancel() }
        NotificationCenter.default.removeObserver(self)
#if DEBUG
        print("\(String(describing: type(of: self))).\(#function)")
#endif
    }
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupUI()
    }
    
    
    
    // MARK: - Overridden methods
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        shadowView.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
//        titleLabel.textColor = traitCollection.userInterfaceStyle == .dark ? .label : .darkGray
        background.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .black : .secondarySystemBackground
        if #available(iOS 15, *) {
            periodButton.configuration?.baseBackgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
        } else {
            periodButton.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
        }
    }
}

private extension ListView {
    @MainActor
    func setupUI() {
        guard let contentView = self.fromNib() else { fatalError("View could not load from nib") }
        
        addSubview(contentView)
        contentView.addSubview(filterView)
        contentView.addSubview(shadowView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        filterView.translatesAutoresizingMaskIntoConstraints = false
        shadowView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
//            filterView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 20),
            filterView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 8),
            filterView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -8),
//            shadowView.topAnchor.constraint(equalTo: filterView.bottomAnchor, constant: 10),
//            shadowView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 10),
//            shadowView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -10),
//            shadowView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -10),
        ])
        
        let shadowLeading = shadowView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 8)
        shadowLeading.identifier = "leading"
        shadowLeading.isActive = true
        
        let shadowTrailing = shadowView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -8)
        shadowTrailing.identifier = "trailing"
        shadowTrailing.isActive = true
        
        let shadowBottom = shadowView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -8)
        shadowBottom.identifier = "bottom"
        shadowBottom.isActive = true
        
        let topConstraint_1 = filterView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16)
        topConstraint_1.identifier = "top_1"
        topConstraint_1.priority = .defaultHigh
        topConstraint_1.isActive = true
        
        let topConstraint_2 = shadowView.topAnchor.constraint(equalTo: filterView.bottomAnchor, constant: 16)
        topConstraint_2.identifier = "top"
        topConstraint_2.isActive = true
        
        setNeedsLayout()
        layoutIfNeeded()
        filterViewHeight = periodButton.bounds.height
        let constraint = filterView.heightAnchor.constraint(equalToConstant: filterViewHeight)
        constraint.identifier = "height"
        constraint.isActive = true
    }
    
    @MainActor
    func setTitle(category: Survey.SurveyCategory, animated: Bool = true) {
        guard let constraint = titleLabel.getConstraint(identifier: "width") else { return }
        
        var text = ""
        
        switch category {
        case .New: text =  "new".localized
        case .Top: text = "top".localized
        case .Favorite: text = "watching".localized
        case .Own: text = "own".localized
        default: print("")
        }
        
//        let attrString = NSMutableAttributedString(string: text,
//                                                   attributes: [
//                                                    .font: UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .title3) as Any
//                                                   ])
//        attrString.append(NSAttributedString(string: " " + "per".localized.lowercased() + " ",
//                                             attributes: [
//                                                .font: UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .title3) as Any
//                                             ]))
//
//        text += " " + "per".localized.lowercased() + " " //+ "publications".localized.lowercased() + " "
        let constant = text.width(withConstrainedHeight: 100, font: titleLabel.font)
        setNeedsLayout()
        
        guard animated else {
//            titleLabel.attributedText = attrString
            titleLabel.text = text
            constraint.constant = constant
            layoutIfNeeded()
            
            return
        }
        
        UIView.transition(with: titleLabel,
                          duration: 0.15,
                          options: .transitionCrossDissolve) { [weak self] in
            guard let self = self else { return }
            
            constraint.constant = constant
            self.titleLabel.text = text//titleLabel.attributedText = attrString
            self.layoutIfNeeded()
        }
        
        let buttonText = "per_\(period.rawValue.lowercased())".localized.lowercased()
        
        if #available(iOS 15, *) {
            if !periodButton.configuration.isNil {
                periodButton.configuration?.title = buttonText
            }
        } else {
            let attrString = NSMutableAttributedString(string: buttonText,
                                                       attributes: [
                                                        NSAttributedString.Key.font: UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .title3) as Any,
                                                        NSAttributedString.Key.foregroundColor: UIColor.secondaryLabel,
                                                       ])
            periodButton.setAttributedTitle(attrString, for: .normal)
            //            periodButton.setTitle("per_\(period.rawValue.lowercased())".localized.lowercased(), for: .normal)
            guard let constraint = periodButton.getConstraint(identifier: "width") else { return }
            
            setNeedsLayout()
            UIView.animate(withDuration: 0.15, delay: 0) { [weak self] in
                guard let self = self else { return }
                
                constraint.constant = buttonText.width(withConstrainedHeight: 100,
                                                       font: UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .title3)!)
                self.layoutIfNeeded()
            }
        }
    }
    
    @MainActor
    func prepareMenu(zeroSubscriptions: Bool = false) -> UIMenu {
        let perDay: UIAction = .init(title: "per_\(Period.PerDay.rawValue)".localized.lowercased(),
                                     image: nil,
                                     identifier: nil,
                                     discoverabilityTitle: nil,
                                     attributes: .init(),
                                     state: period == .PerDay ? .on : .off,
                                     handler: { [weak self] _ in
            guard let self = self else { return }
            
            self.period = .PerDay
        })
        
        let perWeek: UIAction = .init(title: "per_\(Period.PerWeek.rawValue)".localized.lowercased(),
                                      image: nil,
                                      identifier: nil,
                                      discoverabilityTitle: nil,
                                      attributes: .init(),
                                      state: period == .PerWeek ? .on : .off,
                                      handler: { [weak self] _ in
            guard let self = self else { return }
            
            self.period = .PerWeek
        })
        
        let perMonth: UIAction = .init(title: "per_\(Period.PerMonth.rawValue)".localized.lowercased(),
                                       image: nil,
                                       identifier: nil,
                                       discoverabilityTitle: nil,
                                       attributes: .init(),
                                       state: period == .PerMonth ? .on : .off,
                                       handler: { [weak self] _ in
            guard let self = self else { return }
            
            self.period = .PerMonth
        })
        
        let allTime: UIAction = .init(title: "per_\(Period.AllTime.rawValue)".localized.lowercased(),
                                      image: nil,
                                      identifier: nil,
                                      discoverabilityTitle: nil,
                                      attributes: .init(),
                                      state: period == .AllTime ? .on : .off,
                                      handler: { [weak self] _ in
            guard let self = self else { return }
            
            self.period = .AllTime
        })
        
        return UIMenu(title: "",//"publications_per".localized,
                      image: nil,
                      identifier: nil,
                      options: .init(),
                      children: [
                        perDay,
                        perWeek,
                        perMonth,
                        allTime
                      ])
    }
    
    @MainActor
    func toggleDateFilter(on: Bool) {
        print(on)
        guard let heightConstraint = filterView.getConstraint(identifier: "height"),
              let constraint1 = filterView.getConstraint(identifier: "top_1"),
              let constraint2 = filterView.getConstraint(identifier: "top")
        else { return }

        setNeedsLayout()
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut) { [weak self] in
            guard let self = self else { return }

            self.filterView.alpha = on ? 1 : 0
            self.filterView.transform = on ? .identity : CGAffineTransform(scaleX: 0.75, y: 0.75)
            constraint1.constant = on ? 16 : 0
            constraint2.constant = on ? 16 : 8
            heightConstraint.constant = on ? self.filterViewHeight : 0
            self.layoutIfNeeded()
        }
    }
}

// MARK: - Controller Output
extension ListView: ListControllerOutput {
//    func setPeriod(_ period: Period) {
//        collectionView.period = period
//    }
    func onRequestCompleted(_ result: Result<Bool, Error>) {
        collectionView.endRefreshing()
    }
    
    func onDataSourceChanged() {
        guard let category = viewInput?.category else { return }
        
        setTitle(category: category, animated: true)
        toggleDateFilter(on: true)
        collectionView.category = category
    }
}

//extension ListView: CallbackObservable {
//    func callbackReceived(_ sender: Any) {
//
//    }
//}

extension ListView: BannerObservable {
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
