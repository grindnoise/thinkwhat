//
//  UserStatsCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 25.01.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class UserSettingsCityCell: UICollectionViewListCell {
  
  // MARK: - Public properties
  public weak var userprofile: Userprofile! {
    didSet {
      guard let city = userprofile.city else { return }
      
      self.city = city
    }
  }
  public weak var city: City! {
    didSet {
      guard let localized = city.localized,
            !localized.isEmpty
      else {
        textField.text = city.name
        return
      }
      
      textField.text = localized
    }
  }
  ///`Publishers`
  public let publicationsPublisher = PassthroughSubject<Userprofile, Never>()
  public let commentsPublisher = PassthroughSubject<Userprofile, Never>()
  public let subscribersPublisher = PassthroughSubject<Userprofile, Never>()
  public let citySelectionPublisher = PassthroughSubject<City?, Never>()
  public let cityFetchPublisher = PassthroughSubject<String?, Never>()
  ///`UI`
  public var color: UIColor = .gray
  public var padding: CGFloat = 8 {
    didSet {
      updateUI()
    }
  }
  public var insets: UIEdgeInsets? {
    didSet {
      updateUI()
    }
  }
  
  
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  ///`Logic`
  private var selectedCity: City? = nil {
    didSet {
      guard let selectedCity = selectedCity else { return }
      
      citySelectionPublisher.send(selectedCity)
      endEditing(true)
    }
  }
  ///`UI`
  private lazy var hintButton: UIButton = {
    let instance = UIButton()
    instance.setImage(UIImage(systemName: "questionmark",
                              withConfiguration: UIImage.SymbolConfiguration(scale: .small)),
                      for: .normal)
    instance.tintColor = .secondaryLabel
    instance.addTarget(self, action: #selector(self.hintTapped), for: .touchUpInside)
    
    return instance
  }()
  private lazy var background: UIView = {
    let instance = UIView()
    instance.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
    instance.publisher(for: \.bounds, options: .new)
      .sink { rect in
        instance.cornerRadius = rect.width*0.05
      }
      .store(in: &subscriptions)
    stack.place(inside: instance,
                insets: .uniform(size: padding*2),
                bottomPriority: .defaultLow)
    
    return instance
  }()
  private lazy var stack: UIStackView = {
    let headerStack = UIStackView(arrangedSubviews: [
      label,
      UIView.opaque(),
      hintButton
    ])
    headerStack.axis = .horizontal
    
    let contentStack = UIStackView(arrangedSubviews: [
      textField,
      countryFlag
    ])
    contentStack.axis = .horizontal
    
    let instance = UIStackView(arrangedSubviews: [
      headerStack,
      contentStack
    ])
    instance.axis = .vertical
    instance.spacing = padding*2
    
    return instance
  }()
  private lazy var label: UILabel = {
    let instance = UILabel()
    instance.textColor = .secondaryLabel
    instance.text = "location".localized.uppercased()
    instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .footnote)
    
    let heightConstraint = instance.heightAnchor.constraint(equalToConstant: instance.text!.height(withConstrainedWidth: 1000, font: instance.font))
    heightConstraint.identifier = "height"
    heightConstraint.priority = .defaultHigh
    heightConstraint.isActive = true
    
    instance.publisher(for: \.bounds, options: .new)
      .sink { [weak self] rect in
        guard let self = self,
              let constraint = instance.getConstraint(identifier: "height")
        else { return }
        
        self.setNeedsLayout()
        constraint.constant = instance.text!.height(withConstrainedWidth: 1000, font: instance.font)
        self.layoutIfNeeded()
      }
      .store(in: &subscriptions)
    
    return instance
  }()
  private lazy var countryFlag: UIImageView = {
    let instance = UIImageView()
    instance.heightAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 1/1).isActive = true
    
    return instance
  }()
  private lazy var textField: UnderlinedSearchTextField = {
    let instance = UnderlinedSearchTextField()
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
      
      guard let selectedCity = item[itemPosition].attachment as? City else { return }
      
      self.selectedCity = selectedCity
    }
    instance.addTarget(self, action: #selector(self.handleIO(_:)), for: .editingChanged)
    instance.delegate = self
    
    return instance
  }()
  
  
  
  // MARK: - Destructor
  deinit {
    observers.forEach { $0.invalidate() }
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
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  // MARK: - Overriden methods
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    
    //Set dynamic font size
    guard previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory else { return }
  }
  
  //    override func prepareForReuse() {
  //        super.prepareForReuse()
  //
  //        urlPublisher = CurrentValueSubject<URL?, Never>(nil)
  //        subscriptionPublisher = CurrentValueSubject<Bool?, Never>(nil)
  //        imagePublisher = CurrentValueSubject<UIImage?, Never>(nil)
  //    }
}

private extension UserSettingsCityCell {
  @MainActor
  func setupUI() {
    backgroundColor = .clear
    clipsToBounds = true
    
    background.place(inside: self,
                     insets: .init(top: padding*2, left: padding, bottom: padding*2, right: padding))
  }
  
  @MainActor
  func updateUI() {
    background.removeFromSuperview()
    
    guard let insets = insets else {
      background.place(inside: self,
                       insets: .uniform(size: padding))
      return
    }
    background.place(inside: self,
                     insets: insets)
  }
  
  @objc
  func hintTapped() {
    let banner = NewBanner(contentView: TextBannerContent(image: UIImage(systemName: "exclamationmark.triangle.fill")!,
                                                          icon: Icon.init(category: .Logo, scaleMultiplicator: 1.5, iconColor: color),
                                                          text: "userprofile_contrib_hint",
                                                          tintColor: .clear,
                                                          fontName: Fonts.Regular,
                                                          textStyle: .headline,
                                                          textAlignment: .natural),
                           contentPadding: UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8),
                           isModal: false,
                           useContentViewHeight: true,
                           shouldDismissAfter: 2)
    banner.didDisappearPublisher
      .sink { _ in banner.removeFromSuperview() }
      .store(in: &self.subscriptions)
  }
  
  @objc
  func handleIO(_ instance: UnderlinedSearchTextField) {
    guard let text = instance.text, text.count >= 4 else { return }
    
    instance.showLoadingIndicator()
    cityFetchPublisher.send(text)
    //        instance.isUserInteractionEnabled = false
  }
  
  func processResults(_ cities: [City]) {
    let items: [SearchTextFieldItem] = cities.map { return SearchTextFieldItem(title: $0.name,
                                                                               subtitle: (!$0.regionName.isNil && !$0.countryName.isNil) ?  "\(String(describing: $0.regionName!)), \(String(describing: $0.countryName!))" : "",
                                                                               image: nil,
                                                                               attachment: $0)}
    textField.filterItems(items)
    textField.stopLoadingIndicator()
    textField.isUserInteractionEnabled = true
  }
}

extension UserSettingsCityCell: UITextFieldDelegate {
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
    guard let selectedCity = selectedCity else {
      textField.text = city.localized ?? city.name
      return
    }
    
    textField.text = selectedCity.name
  }
}




////  CurrentUserCityCell.swift
////  ThinkWhat
////
////  Created by Pavel Bukharov on 14.09.2022.
////  Copyright © 2022 Pavel Bukharov. All rights reserved.
////
//
//import UIKit
//import Combine
//
//class UserSettingsCityCell: UICollectionViewListCell {
//
//    // MARK: - Public properties
//    public weak var city: City! {
//        didSet {
//            guard let city = city else { return }
//
//            guard let localized = city.localized,
//                  !localized.isEmpty
//            else {
//                textField.text = city.name
//                return
//            }
//            textField.text = localized
//        }
//    }
//    //Publishers
//    public var citySelectionPublisher = CurrentValueSubject<City?, Never>(nil)
//    public var cityFetchPublisher = CurrentValueSubject<String?, Never>(nil)
//    //UI
//    public var color: UIColor = Colors.System.Red.rawValue {
//        didSet {
//            setColors()
//        }
//    }
//
//
//
//    // MARK: - Private properties
//    private var observers: [NSKeyValueObservation] = []
//    private var subscriptions = Set<AnyCancellable>()
//    private var tasks: [Task<Void, Never>?] = []
//    private var selectedCity: City? = nil {
//        didSet {
//            guard let selectedCity = selectedCity else { return }
//
//            citySelectionPublisher.send(selectedCity)
//            endEditing(true)
//        }
//    }
//    //UI
//    private let padding: CGFloat = 8
//    private lazy var textField: UnderlinedSearchTextField = {
//        let instance = UnderlinedSearchTextField()
//        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .headline)
//        instance.indicator.color = UIColor { traitCollection in
//            switch traitCollection.userInterfaceStyle {
//            case .dark:
//                return .label
//            default:
//                return K_COLOR_RED
//            }
//        }
//        instance.spellCheckingType = .no
//        instance.autocorrectionType = .no
//        instance.attributedPlaceholder = NSAttributedString(string: "city_placeholder".localized, attributes: [
//            NSAttributedString.Key.font : UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .headline) as Any,
//            NSAttributedString.Key.foregroundColor: UIColor.secondaryLabel
//        ])
//        instance.theme.font = UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .subheadline)!
//        instance.theme.bgColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
//        instance.theme.borderColor = .clear
//        instance.theme.fontColor = .label
//        instance.theme.subtitleFontColor = .secondaryLabel
//        instance.theme.cellHeight = "test".height(withConstrainedWidth: 100, font: instance.theme.font)*2
//        instance.itemSelectionHandler = { [weak self] item, itemPosition in
//            guard let self = self else { return }
//
//            instance.text = item[itemPosition].title
//
//            guard let selectedCity = item[itemPosition].attachment as? City else { return }
//
//            self.selectedCity = selectedCity
//        }
//        instance.addTarget(self, action: #selector(self.handleIO(_:)), for: .editingChanged)
//        instance.delegate = self
//
//        return instance
//    }()
//
//    // MARK: - Destructor
//    deinit {
//        observers.forEach { $0.invalidate() }
//        tasks.forEach { $0?.cancel() }
//        subscriptions.forEach { $0.cancel() }
//        NotificationCenter.default.removeObserver(self)
//#if DEBUG
//        print("\(String(describing: type(of: self))).\(#function)")
//#endif
//    }
//
//    // MARK: - Initialization
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setTasks()
//        setupUI()
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//
//
//    // MARK: - Overriden methods
//    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
//        super.traitCollectionDidChange(previousTraitCollection)
//
////        tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
//        contentView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground.withAlphaComponent(0.35) : .secondarySystemBackground.withAlphaComponent(0.7)
//    }
//
//    override func prepareForReuse() {
//        super.prepareForReuse()
//
//        citySelectionPublisher = CurrentValueSubject<City?, Never>(nil)
//        cityFetchPublisher = CurrentValueSubject<String?, Never>(nil)
//    }
//}
//
//    // MARK: - Private
//private extension UserSettingsCityCell {
//    @MainActor
//    func setupUI() {
//        contentView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground.withAlphaComponent(0.35) : .secondarySystemBackground.withAlphaComponent(0.7)
//        clipsToBounds = true
//
//        contentView.addSubview(textField)
//        contentView.translatesAutoresizingMaskIntoConstraints = false
//        textField.translatesAutoresizingMaskIntoConstraints = false
//
//        NSLayoutConstraint.activate([
//            contentView.topAnchor.constraint(equalTo: topAnchor),
//            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
//            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
//            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
//            textField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
//            textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
//            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
//        ])
//
//        let constraint = textField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding)
//        constraint.priority = .defaultLow
//        constraint.isActive = true
//    }
//
//    func setTasks() {
//        //Cities fetch result
//        tasks.append( Task {@MainActor [weak self] in
//            for await notification in NotificationCenter.default.notifications(for: Notifications.Cities.FetchResult) {
//                guard let self = self,
//                      let cities = notification.object as? [City]
//                else { return }
//
//                //                await MainActor.run {
//                self.processResults(cities)
//                //                }
//            }
//        })
//
//        //Cities fetch error
//        tasks.append( Task {@MainActor [weak self] in
//            for await _ in NotificationCenter.default.notifications(for: Notifications.Cities.FetchError) {
//                guard let self = self else { return }
//
//                //                await MainActor.run {
//                self.textField.stopLoadingIndicator()
//                showBanner(bannerDelegate: self, text: AppError.server.localizedDescription.localized, content: UIImageView(image: UIImage(systemName: "exclamationmark.triangle.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .small))), color: UIColor.white, textColor: .white, dismissAfter: 0.75, backgroundColor: UIColor.systemRed, shadowed: true)
//                //                }
//            }
//        })
//    }
//
//    @objc
//    func handleIO(_ instance: UnderlinedSearchTextField) {
//        guard let text = instance.text, text.count >= 4 else { return }
//
//        instance.showLoadingIndicator()
//        cityFetchPublisher.send(text)
//        //        instance.isUserInteractionEnabled = false
//    }
//
//    func processResults(_ cities: [City]) {
//        let items: [SearchTextFieldItem] = cities.map { return SearchTextFieldItem(title: $0.name,
//                                                                                   subtitle: (!$0.regionName.isNil && !$0.countryName.isNil) ?  "\(String(describing: $0.regionName!)), \(String(describing: $0.countryName!))" : "",
//                                                                                   image: nil,
//                                                                                   attachment: $0)}
//        textField.filterItems(items)
//        textField.stopLoadingIndicator()
//        textField.isUserInteractionEnabled = true
//    }
//
//    func setColors() {
//        tintColor = color
//        textField.tintColor = color
//        textField.indicator.color = UIColor { traitCollection in
//            switch traitCollection.userInterfaceStyle {
//            case .dark:
//                return .label
//            default:
//                return K_COLOR_RED
//            }
//        }
//    }
//}
//
//extension UserSettingsCityCell: UITextFieldDelegate {
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        guard !self.textField.isSpinning else { return false }
//        return true
//    }
//
//    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
//        return true
//    }
//
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        return true
//    }
//
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        guard let selectedCity = selectedCity else {
//            textField.text = city.localized ?? city.name
//            return
//        }
//
//        textField.text = selectedCity.name
//    }
//}
//
//extension UserSettingsCityCell: BannerObservable {
//    func onBannerWillAppear(_ sender: Any) {}
//
//    func onBannerWillDisappear(_ sender: Any) {}
//
//    func onBannerDidAppear(_ sender: Any) {}
//
//    func onBannerDidDisappear(_ sender: Any) {
//        if let banner = sender as? Banner {
//            banner.removeFromSuperview()
//        } else if let popup = sender as? Popup {
//            popup.removeFromSuperview()
//        }
//    }
//}
