//
//  CurrentUserCityCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 14.09.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class CurrentUserCityCell: UICollectionViewListCell {
    
    // MARK: - Public properties
    public var cityTitle: String = "" {
        didSet {
            guard cityTitle != oldValue else { return }

            textField.text = cityTitle
        }
    }
    //Publishers
    public let citySelectionPublisher = CurrentValueSubject<City?, Never>(nil)
    public let cityFetchPublisher = CurrentValueSubject<String?, Never>(nil)
    
    
    // MARK: - Private properties
    private var observers: [NSKeyValueObservation] = []
    private var subscriptions = Set<AnyCancellable>()
    private var tasks: [Task<Void, Never>?] = []
    private var city: City? = nil {
        didSet {
            guard let city = city else { return }
            
            citySelectionPublisher.send(city)
            endEditing(true)
        }
    }
    //UI
    private let padding: CGFloat = 8
    private lazy var textField: UnderlinedSearchTextField = {
        let instance = UnderlinedSearchTextField()
        instance.text = cityTitle
        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .headline)
        instance.indicator.color = UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return .label
            default:
                return K_COLOR_RED
            }
        }
        instance.spellCheckingType = .no
        instance.autocorrectionType = .no
        instance.attributedPlaceholder = NSAttributedString(string: "city_placeholder".localized, attributes: [
            NSAttributedString.Key.font : UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .headline) as Any,
            NSAttributedString.Key.foregroundColor: UIColor.secondaryLabel
        ])
        instance.theme.font = UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .subheadline)!
        instance.theme.bgColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
        instance.theme.borderColor = .clear
        instance.theme.fontColor = .label
        instance.theme.subtitleFontColor = .secondaryLabel
        instance.theme.cellHeight = "test".height(withConstrainedWidth: 100, font: instance.theme.font)*2
        instance.itemSelectionHandler = { [weak self] item, itemPosition in
            guard let self = self else { return }
            
            instance.text = item[itemPosition].title
            
            guard let city = item[itemPosition].attachment as? City else { return }
            
            self.city = city
        }
        instance.addTarget(self, action: #selector(self.handleIO(_:)), for: .editingChanged)
        instance.delegate = self
        
        return instance
    }()
    
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
        setTasks()
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private methods
    private func setupUI() {
        contentView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground.withAlphaComponent(0.35) : .secondarySystemBackground.withAlphaComponent(0.7)
        clipsToBounds = true
        
        contentView.addSubview(textField)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        textField.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            textField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
            textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
        ])
        
        let constraint = textField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding)
        constraint.priority = .defaultLow
        constraint.isActive = true
    }
    
    private func setTasks() {
        //Cities fetch result
        tasks.append( Task {@MainActor [weak self] in
            for await notification in NotificationCenter.default.notifications(for: Notifications.Cities.FetchResult) {
                guard let self = self,
                      let cities = notification.object as? [City]
                else { return }

//                await MainActor.run {
                    self.processResults(cities)
//                }
            }
        })
        
        //Cities fetch error
        tasks.append( Task {@MainActor [weak self] in
            for await _ in NotificationCenter.default.notifications(for: Notifications.Cities.FetchError) {
                guard let self = self else { return }

//                await MainActor.run {
                    self.textField.stopLoadingIndicator()
                    showBanner(bannerDelegate: self, text: AppError.server.localizedDescription.localized, content: UIImageView(image: UIImage(systemName: "exclamationmark.triangle.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .small))), color: UIColor.white, textColor: .white, dismissAfter: 0.75, backgroundColor: UIColor.systemRed, shadowed: true)
//                }
            }
        })
    }
    
    @objc
    private func handleIO(_ instance: UnderlinedSearchTextField) {
        guard let text = instance.text, text.count >= 4 else { return }
        
        instance.showLoadingIndicator()
        cityFetchPublisher.send(text)
//        instance.isUserInteractionEnabled = false
    }
    
    private func processResults(_ cities: [City]) {
        let items: [SearchTextFieldItem] = cities.map { return SearchTextFieldItem(title: $0.name,
                                                                                   subtitle: "\(String(describing: $0.regionName)), \(String(describing: $0.countryName))",
                                                                                   image: nil,
                                                                                   attachment: $0)}
        textField.filterItems(items)
        textField.stopLoadingIndicator()
        textField.isUserInteractionEnabled = true
    }
    
    // MARK: - Public methods
    
    // MARK: - Overriden methods
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
        contentView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground.withAlphaComponent(0.35) : .secondarySystemBackground.withAlphaComponent(0.7)
    }
}

extension CurrentUserCityCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard !self.textField.isSpinning else { return false }
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let city = city else {
            textField.text = cityTitle
            return
        }

        textField.text = city.name
    }
}

extension CurrentUserCityCell: BannerObservable {
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
