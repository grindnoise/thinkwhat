//
//  UserStatsCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 25.01.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine
import FlagKit
import L10n_swift

class UserSettingsCityCell: UICollectionViewListCell {

  // MARK: - Public properties
  public weak var userprofile: Userprofile! {
    didSet {
      setupUI()
      userprofile.cityFetchPublisher
        .receive(on: DispatchQueue.main)
        .mapError { error -> AppError in
          switch error {
          case is APIError:
            return AppError.server
          default:
            return AppError.server
          }
        }
        .sink { [weak self] completion in
          guard let self = self else { return }
          
          switch completion {
          case .failure(let error):
            self.isSearching = false
            let banner = NewBanner(contentView: TextBannerContent(image: UIImage(systemName: "exclamationmark.triangle.fill")!,
                                                                  icon: Icon.init(category: .Logo,
                                                                                  scaleMultiplicator: 1.5,
                                                                                  iconColor: .systemRed),
                                                                  text: error.localizedDescription,
                                                                  tintColor: .clear,
                                                                  fontName: Fonts.Rubik.Regular,
                                                                  textStyle: .headline,
                                                                  textAlignment: .natural),
                                   contentPadding: UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8),
                                   isModal: false,
                                   useContentViewHeight: true,
                                   shouldDismissAfter: 2)
            banner.didDisappearPublisher
              .sink { _ in banner.removeFromSuperview() }
              .store(in: &self.subscriptions)
          case .finished:
#if DEBUG
            print("finished")
#endif
          }
        } receiveValue: { [weak self] result in
          guard let self = self else { return }

          self.processResults(result)
        }
        .store(in: &subscriptions)

      guard let city = userprofile.city else { return }

      self.city = city
    }
  }
  public weak var city: City! {
    didSet {
      guard oldValue != city else { return }

      ///Set user's default
      userprofile.cityId = city.geonameId
      
      toggleFlag(on: true)
      setLocationText()
    }
  }
  ///`Publishers`
  public let citySelectionPublisher = PassthroughSubject<City, Never>()
  public var cityFetchPublisher = CurrentValueSubject<String?, Never>(nil)
  @Published public private(set) var scrollPublisher: CGPoint?
  ///`UI`
  public var color: UIColor = .gray {
    didSet {
      guard oldValue != color else { return }
      
      textField.indicator.color = color
    }
  }
  public var padding: CGFloat = 8 //{
//    didSet {
//      updateUI()
//    }
//  }
  public var insets: UIEdgeInsets? //{
//    didSet {
//      updateUI()
//    }
//  }



  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  ///`Logic`
//  private var selectedCity: City? = nil {
//    didSet {
//      guard let selectedCity = selectedCity else { return }
//
//      citySelectionPublisher.send(selectedCity)
//      endEditing(true)
//    }
//  }
  private var isSearching = false {
    didSet {
      switch isSearching {
      case true:
        textField.showLoadingIndicator()
      default:
        textField.stopLoadingIndicator()
      }
    }
  }
  ///**UI**
  private lazy var hintButton: UIButton = {
    let instance = UIButton()
    instance.setImage(UIImage(systemName: "questionmark",
                              withConfiguration: UIImage.SymbolConfiguration(scale: .small)),
                      for: .normal)
    instance.tintColor = .secondaryLabel
    instance.addTarget(self, action: #selector(self.hintTapped), for: .touchUpInside)
    instance.alpha = 0

    return instance
  }()
//  private lazy var background: UIView = {
//    let instance = UIView()
//    instance.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
//    instance.publisher(for: \.bounds, options: .new)
//      .sink { instance.cornerRadius = $0.width*0.025 }
//      .store(in: &subscriptions)
//    stack.place(inside: instance,
//                insets: .uniform(size: padding),
//                bottomPriority: .defaultLow)
//
//    return instance
//  }()
  private lazy var stack: UIStackView = {
    let headerStack = UIStackView(arrangedSubviews: [
      headerImage,
      headerLabel,
      UIView.opaque(),
//      hintButton
    ])
    headerStack.axis = .horizontal
      headerStack.spacing = padding/2

    let leftSpacer = UIView.opaque()
    leftSpacer.widthAnchor.constraint(equalToConstant: userprofile.isCurrent ? 8 : 0).isActive = true
//    let rightSpacer = UIView.opaque()
//    rightSpacer.widthAnchor.constraint(equalToConstant: 8).isActive = true
    
    let contentStack = UIStackView(arrangedSubviews: [
      leftSpacer,
      textField,
//      UIView.opaque(),
      countryFlag,
//      rightSpacer
    ])
    contentStack.axis = .horizontal
    contentStack.accessibilityIdentifier = "contentStack"

    let instance = UIStackView(arrangedSubviews: [
      headerStack,
      contentStack
    ])
    instance.axis = .vertical
    instance.spacing = padding
//    contentStack.backgroundColor = .secondarySystemFill
    contentStack.backgroundColor = userprofile.isCurrent ? Colors.textField(color: .white, traitCollection: traitCollection) : .clear
    contentStack.publisher(for: \.bounds, options: .new)
      .sink { contentStack.cornerRadius = $0.width*0.025 }
      .store(in: &subscriptions)

    return instance
  }()
  private lazy var headerImage: UIImageView = {
    let instance = UIImageView(image: UIImage(systemName: "location.fill",
                                              withConfiguration: UIImage.SymbolConfiguration(scale: .medium)))
    instance.tintColor = Colors.cellHeader
    instance.contentMode = .scaleAspectFit
//    instance.widthAnchor.constraint(equalTo: instance.heightAnchor).isActive = true
    instance.heightAnchor.constraint(equalToConstant: "T".height(withConstrainedWidth: 100, font: headerLabel.font)).isActive = true
    
    return instance
  }()
  private lazy var headerLabel: UILabel = {
    let instance = UILabel()
    instance.textColor = Colors.cellHeader
    instance.text = "location".localized.uppercased()
    instance.font = Fonts.cellHeader

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
    instance.contentMode = .center
    instance.alpha = .zero
//    instance.heightAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 1/1).isActive = true

    return instance
  }()
  private lazy var textField: SearchInsetTextField = {
    let instance = SearchInsetTextField()
    instance.insets = UIEdgeInsets(top: 8,
                                   left: 0,
                                   bottom: 8,
                                   right: 0)
    instance.isUserInteractionEnabled = userprofile.isCurrent ? true : false
    instance.font = UIFont.scaledFont(fontName: Fonts.Rubik.Regular, forTextStyle: .body)
    instance.indicator.color = color
    instance.spellCheckingType = .no
    instance.autocorrectionType = .no
    instance.attributedPlaceholder = NSAttributedString(string: "city_placeholder".localized, attributes: [
      NSAttributedString.Key.font : UIFont.scaledFont(fontName: Fonts.Rubik.Regular, forTextStyle: .headline) as Any,
      NSAttributedString.Key.foregroundColor: UIColor.secondaryLabel
    ])
    instance.forceNoFiltering = true
    instance.theme.font = UIFont.scaledFont(fontName: Fonts.Rubik.Regular, forTextStyle: .subheadline)!
//    instance.theme.bgColor = userprofile.isCurrent ? traitCollection.userInterfaceStyle != .dark ? .tertiarySystemBackground : .secondarySystemBackground : .clear
    instance.theme.bgColor = traitCollection.userInterfaceStyle != .dark ? .tertiarySystemBackground : .secondarySystemBackground
    instance.theme.borderColor = .clear
    instance.theme.fontColor = .label
    instance.theme.subtitleFontColor = .secondaryLabel
    instance.theme.cellHeight = "test".height(withConstrainedWidth: 100, font: instance.theme.font)*2
    instance.selectionPublisher
      .receive(on: DispatchQueue.main)
      .sink { [weak self] in
        guard let self = self,
              let selected = $0.attachment as? City
        else { return }
        
        self.citySelectionPublisher.send(selected)
        self.city = selected
        _ = instance.resignFirstResponder()
      }
      .store(in: &subscriptions)
    instance.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
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
  override init(frame: CGRect) { super.init(frame: frame) }

  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }


  // MARK: - Overriden methods
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)

//    background.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
    
    if let contentStack = stack.arrangedSubviews.filter({ $0.accessibilityIdentifier == "contentStack"}).first {
      contentStack.backgroundColor = userprofile.isCurrent ? Colors.textField(color: .white, traitCollection: traitCollection) : .clear
    }
    
    //Set dynamic font size
    guard previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory else { return }
  }

  override func prepareForReuse() {
    super.prepareForReuse()

    cityFetchPublisher = CurrentValueSubject<String?, Never>(nil)
//    subscriptionPublisher = CurrentValueSubject<Bool?, Never>(nil)
//    imagePublisher = CurrentValueSubject<UIImage?, Never>(nil)
  }
}

private extension UserSettingsCityCell {
  @MainActor
  func setupUI() {
    backgroundColor = .clear
    clipsToBounds = true
    
    stack.place(inside: self,
                insets: insets ?? .uniform(size: padding),
                bottomPriority: .defaultLow)
    //    background.place(inside: self,
    //                     insets: .init(top: padding*2, left: padding, bottom: padding*2, right: padding))
    
    setNeedsLayout()
    layoutIfNeeded()
    
    guard let contentStack = stack.arrangedSubviews.filter({ $0.accessibilityIdentifier == "contentStack"}).first else { return }
    
    countryFlag.translatesAutoresizingMaskIntoConstraints = false
    let constraint = countryFlag.widthAnchor.constraint(equalToConstant: contentStack.bounds.height)
    countryFlag.heightAnchor.constraint(equalToConstant: contentStack.bounds.height).isActive = true
    constraint.identifier = "width"
    constraint.isActive = true
  }

  @MainActor
  func updateUI() {
//    background.removeFromSuperview()
//
//    guard let insets = insets else {
//      background.place(inside: self,
//                       insets: .uniform(size: padding))
//      return
//    }
//    background.place(inside: self,
//                     insets: insets)
  }

  @objc
  func hintTapped() {
    let banner = NewBanner(contentView: TextBannerContent(image: UIImage(systemName: "exclamationmark.triangle.fill")!,
                                                          icon: Icon.init(category: .Logo, scaleMultiplicator: 1.5, iconColor: color),
                                                          text: "userprofile_contrib_hint",
                                                          tintColor: .clear,
                                                          fontName: Fonts.Rubik.Regular,
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

  func processResults(_ cities: [City]) {
    let items: [SearchTextFieldItem] = cities.map { city in
      return SearchTextFieldItem(title: city.name,
                                 subtitle: "\(String(describing: city.regionName)), \(String(describing: city.countryName))",
//                                 subtitle: (!city.regionName.isEmpty && !city.countryName.isEmpty) ?  "\(String(describing: city.regionName)), \(String(describing: city.countryName))" : "",
                                 image: Flag(countryCode: city.countryCode)?.image(style: .roundedRect),
                                 attachment: city)}
    textField.filterItems(items)
    isSearching = false
    //    textField.isUserInteractionEnabled = true
  }
  
  func setLocationText() {
    textField.stopLoadingIndicator()
    let countryName = countryName(countryCode: city.countryCode)
    textField.text = (city.localizedName.isEmpty ? city.name : city.localizedName) + (countryName.isNil ? "" : ", \(String(describing: countryName!))")
  }
  
  func countryName(countryCode: String) -> String? {
    let current = Locale(identifier: L10n.shared.language)
    return current.localizedString(forRegionCode: countryCode)
  }
  
  func toggleFlag(on: Bool) {
    guard let constraint = countryFlag.getConstraint(identifier: "width") else { return }
    
    guard on, !city.isNil else {
      UIView.animate(withDuration: 0.2,
                     delay: 0,
                     options: .curveEaseInOut,
                     animations: { [weak self] in
        guard let self = self else { return }
        
        self.countryFlag.transform = .init(scaleX: 0.7, y: 0.7)
        self.countryFlag.alpha = 0
      }) { [weak self] _ in
        guard let self = self,
              let constraint = self.countryFlag.getConstraint(identifier: "width")
        else { return }
        
        self.stack.setNeedsLayout()
        constraint.constant = 8
        self.stack.layoutIfNeeded()
      }
      
      return
    }
    
    guard countryFlag.alpha.isZero,
          let contentStack = stack.arrangedSubviews.filter({ $0.accessibilityIdentifier == "contentStack"}).first
    else { return }
    
    countryFlag.image = Flag(countryCode: city.countryCode)?.image(style: .roundedRect)
    self.stack.setNeedsLayout()
    ///Set flag width same as `contentStack` height
    constraint.constant = contentStack.bounds.height
    self.stack.layoutIfNeeded()
    
    UIView.animate(withDuration: 0.2,
                   delay: 0,
                   options: .curveEaseInOut,
                   animations: { [weak self] in
      guard let self = self else { return }
      
      self.countryFlag.transform = .identity
      self.countryFlag.alpha = 1
    })
  }
  
  func checkTextField(_ textField: UITextField) -> Bool {
      if !city.isNil {
        toggleFlag(on: true)
        setLocationText()
        if let recognizer = gestureRecognizers?.first { removeGestureRecognizer(recognizer) }
        textField.resignFirstResponder()
        
        return true
      } else {
        let banner = NewBanner(contentView: TextBannerContent(image: UIImage(systemName: "exclamationmark.triangle.fill")!,
                                                              icon: Icon.init(category: .Logo,
                                                                              scaleMultiplicator: 1.5,
                                                                              iconColor: .systemRed),
                                                              text: "account_location_empty".localized,
                                                              tintColor: .clear,
                                                              fontName: Fonts.Rubik.Regular,
                                                              textStyle: .headline,
                                                              textAlignment: .natural),
                               contentPadding: UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8),
                               isModal: false,
                               useContentViewHeight: true,
                               shouldDismissAfter: 2)
        banner.didDisappearPublisher
          .sink { _ in banner.removeFromSuperview() }
          .store(in: &self.subscriptions)
        
        return false
    }
    
//    if let recognizer = gestureRecognizers?.first { removeGestureRecognizer(recognizer) }
//    textField.resignFirstResponder()
    
//    return true
  }
}

extension UserSettingsCityCell: UITextFieldDelegate {
  func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
    if let recognizers = gestureRecognizers, recognizers.isEmpty {
      let touch = UITapGestureRecognizer(target:self, action:#selector(TopicsController.hideKeyboard))
      addGestureRecognizer(touch)
    }
    
    scrollPublisher = headerLabel.convert(headerLabel.frame.origin, to: self)
    
    return true
  }

  @objc
  func textFieldDidChange(_ textField: UnderlinedSearchTextField) {
    toggleFlag(on: false)
    
    guard !isSearching, let text = textField.text, text.count > 3 else { return }

    isSearching = true
    cityFetchPublisher.send(text)
  }
  
  func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
    isSearching = false
    
    return checkTextField(textField)
  }

  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    isSearching = false
    
    return checkTextField(textField)
  }
//  func textFieldDidEndEditing(_ textField: UITextField) {
//    guard let selectedCity = city else {
//      textField.text = city.localizedName.isEmpty ? city.name : city.localizedName
//      return
//    }
//
//    textField.text = selectedCity.localizedName.isEmpty ? selectedCity.name : selectedCity.localizedName
//  }
}
