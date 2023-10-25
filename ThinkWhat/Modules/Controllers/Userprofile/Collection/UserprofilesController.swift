//
//  UserprofilesController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 22.09.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class UserprofilesController: UIViewController, TintColorable {
  
  enum GridItemSize: CGFloat {
    case half = 0.5
    case third = 0.33333
    case quarter = 0.25
  }
  
  // MARK: - Overridden properties
  
  
  
  // MARK: - Public properties
  var controllerOutput: UserprofilesControllerOutput?
  var controllerInput: UserprofilesControllerInput?
  //UI
  public var tintColor: UIColor
  //Logic
  public private(set) var mode: Enums.UserprofilesViewMode
  public private(set) var userprofile: Userprofile?
  public private(set) var answer: Answer?
  
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  //Logic
  private var selectedItems: [Userprofile] = []
  //UI
  private let padding: CGFloat = 8
  private var gridItemSize: UserprofilesController.GridItemSize = .third {
    didSet {
      guard oldValue != gridItemSize else { return }
      
      self.controllerOutput?.gridItemSizePublisher.send(gridItemSize)
      
      guard let button = navigationItem.rightBarButtonItem else { return }
      
      button.menu = prepareMenu()
    }
  }
  private lazy var titleView: TagCapsule = {
    var image: UIImage?
    var iconCategory: Icon.Category?
    var user: Userprofile?
    var text: String = ""
    
    switch mode {
    case .Subscribers, .Subscriptions:
      if let userprofile = userprofile {
        if userprofile.isCurrent {
          image = UIImage(systemName: "person.2.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .small))
          text = (mode == .Subscribers ? "my_subscribers" : "my_subscriptions").localized.uppercased()
        } else {
          user = userprofile
          text = (mode == .Subscribers ? "subscribers" : "subscribed_for").localized.uppercased()
        }
      }
    case .Voters:
      if let answer = answer,  let topic = answer.survey?.topic {
        
        let maxChars = 12
        text = answer.description.count > maxChars ? answer.description.prefix(maxChars).trimmingCharacters(in: .whitespacesAndNewlines).uppercased() + "..." : answer.description.uppercased()
        
        image = UIImage(systemName: "\(answer.order+1).circle.fill")
      }
    }
    
    let instance = TagCapsule(text: text,
                              padding: padding/2,
                              textPadding: .init(top: padding/1.5, left: 0, bottom: padding/1.5, right: padding),
                              color: tintColor,
                              font: UIFont(name: Fonts.Rubik.Medium, size: 14)!,
                              isShadowed: false,
                              iconCategory: iconCategory,
                              image: image,
                              userprofile: user)
//    let instance = TagCapsule(text: "profile".localized.uppercased(),
//               padding: padding/2,
//               textPadding: .init(top: padding/1.5, left: 0, bottom: padding/1.5, right: padding),
//               color: tintColor,
//               font: UIFont(name: Fonts.Rubik.Medium, size: 14)!,
//               isShadowed: false,
//               image: UIImage(systemName: "person.fill"))
//    instance.heightAnchor.constraint(equalToConstant: "T".height(withConstrainedWidth: 100, font: instance.font) + padding).isActive = true
    
    return instance
  }()
  
  // MARK: - Deinitialization
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
  init(mode: Enums.UserprofilesViewMode, userprofile: Userprofile, color: UIColor = .label) {
    self.mode = mode
    self.userprofile = userprofile
    self.tintColor = color
    
    super.init(nibName: nil, bundle: nil)
    
    setupUI()
    setTasks()
  }
  
  init(mode: Enums.UserprofilesViewMode, answer: Answer) {
    self.mode = .Voters
    self.answer = answer
    self.tintColor = Constants.UI.Colors.getColor(forId: answer.order)
    
    super.init(nibName: nil, bundle: nil)
    
    setupUI()
    setTasks()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  
  // MARK: - Public methods
  
  
  
  // MARK: - Overridden methods
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let view = UserprofilesView()
    let model = UserprofilesModel()
    
    self.controllerInput = model
    self.controllerInput?
      .modelOutput = self
    self.controllerOutput = view
    self.controllerOutput?
      .viewInput = self
    
    self.view = view as UIView
    
    setupUI()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    navigationController?.setBarShadow(on: traitCollection.userInterfaceStyle != .dark)
    navigationController?.navigationBar.alpha = 1
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    navigationController?.setBarShadow(on: true)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    navigationController?.setToolbarHidden(true, animated: true)
  }
  
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    
    navigationController?.setBarShadow(on: traitCollection.userInterfaceStyle != .dark)
  }
}

private extension UserprofilesController {
  //    func setNavigationBarAppearance(largeTitleColor: UIColor, smallTitleColor: UIColor) {
  //        guard let navigationBar = navigationController?.navigationBar else { return }
  //
  //        let appearance = UINavigationBarAppearance()
  //        appearance.configureWithOpaqueBackground()
  //        appearance.largeTitleTextAttributes = [
  //            .foregroundColor: largeTitleColor,
  //            .font: UIFont.scaledFont(fontName: Fonts.Bold, forTextStyle: .largeTitle) as Any
  //        ]
  //        appearance.titleTextAttributes = [
  //            .foregroundColor: smallTitleColor,
  //            .font: UIFont.scaledFont(fontName: Fonts.Bold, forTextStyle: .title3) as Any
  //        ]
  //        appearance.shadowColor = nil
  //
  //        switch mode {
  //        case .Voters:
  //            guard let topic = topic else { return }
  //
  //            appearance.backgroundColor = topic.tagColor
  //            navigationBar.tintColor = .white
  //            navigationBar.barTintColor = .white
  //        default:
  //            navigationBar.tintColor = .label
  //            navigationBar.barTintColor = .label
  //        }
  //
  //        navigationBar.standardAppearance = appearance
  //        navigationBar.scrollEdgeAppearance = appearance
  //        navigationBar.prefersLargeTitles = true
  //
  //        if #available(iOS 15.0, *) {
  //            navigationBar.compactScrollEdgeAppearance = appearance
  //        }
  //    }
  
  func setToolBar() {
    navigationController?.isToolbarHidden = true
    
    //        navigationController?.toolbar.isTranslucent = true
    //        navigationController?.toolbar.backgroundColor = .tertiarySystemBackground
    //        navigationController?.toolbar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
    //        navigationController?.toolbar.superview?.backgroundColor = .tertiarySystemBackground
    ////        let doneButton = UIBarButtonItem(title: "Готово", style: .done, target: nil, action: #selector(self.dateSelected))
    ////        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    ////        toolBar.items = [space, doneButton]
    //        navigationController?.toolbar.barStyle = .default
    
    let cancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelSelection))
    let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    let delete = UIBarButtonItem(title: "delete".localized, style: .plain, target: self, action: #selector(deleteItems))
    delete.accessibilityIdentifier = "delete"
    delete.tintColor = .secondaryLabel
    toolbarItems = [cancel, spacer, delete]
    edgesForExtendedLayout = []
    
    //        let appearance = UIToolbarAppearance()
    //        appearance.configureWithOpaqueBackground()
    //
    ////        navigationController?.toolbar.tintColor = .black
    //        navigationController?.toolbar.standardAppearance = appearance
    //        if #available(iOS 15.0, *) {
    //            navigationController?.toolbar.scrollEdgeAppearance = appearance
    //        }
  }
  
  func setupUI() {
    guard let navigationBar = navigationController?.navigationBar else { return }
    
    let appearance = UINavigationBarAppearance()
    appearance.configureWithOpaqueBackground()
    appearance.largeTitleTextAttributes = [
      .foregroundColor: tintColor,
      .font: UIFont.scaledFont(fontName: Fonts.Bold, forTextStyle: .largeTitle) as Any
    ]
    appearance.titleTextAttributes = [
      .foregroundColor: tintColor,
      .font: UIFont.scaledFont(fontName: Fonts.Bold, forTextStyle: .title3) as Any
    ]
    appearance.shadowColor = nil
    
    navigationBar.standardAppearance = appearance
    navigationBar.scrollEdgeAppearance = appearance
    navigationBar.prefersLargeTitles = false
    
    if #available(iOS 15.0, *) {
      navigationBar.compactScrollEdgeAppearance = appearance
    }
    
    navigationItem.titleView = titleView
    
    navigationBar.tintColor = tintColor
//    switch mode {
//    case .Subscribers, .Subscriptions:
//      if let userprofile = userprofile, !userprofile.isCurrent {
//        navigationItem.titleView = topicView
//      }
//    case .Voters:
//      guard let answer = answer else { return }
//
//      let imageView = UIImageView(image: UIImage(systemName: "\(answer.order+1).circle.fill",
//                                                 withConfiguration: UIImage.SymbolConfiguration(pointSize: navigationBar.frame.height * 0.75)))
//      imageView.contentMode = .center
//      imageView.tintColor = Colors.getColor(forId: answer.order)
//      imageView.isUserInteractionEnabled = true
//      imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleGesture(recognizer:))))
//      navigationItem.titleView = imageView
//      navigationBar.tintColor = tintColor
//    }
    
    setBarButtons()
  }
  
//  func setNavigationBarAppearance(largeTitleColor: UIColor, smallTitleColor: UIColor) {
//
//    guard let navigationBar = navigationController?.navigationBar else { return }
//
//    let appearance = UINavigationBarAppearance()
//    appearance.configureWithOpaqueBackground()
//    appearance.largeTitleTextAttributes = [
//      .foregroundColor: tintColor,//largeTitleColor,
//      .font: UIFont.scaledFont(fontName: Fonts.Bold, forTextStyle: .largeTitle) as Any
//    ]
//    appearance.titleTextAttributes = [
//      .foregroundColor: tintColor,//smallTitleColor,
//      .font: UIFont.scaledFont(fontName: Fonts.Bold, forTextStyle: .title3) as Any
//    ]
//    appearance.shadowColor = nil
//
//    //        switch mode {
//    //        case .Voters:
//    //            appearance.backgroundColor = color
//    //            navigationBar.tintColor = .white
//    //            navigationBar.barTintColor = .white
//    //        default:
//    //            setNavigationBarTintColor(tintColor)
//    //        }
//
//    navigationBar.standardAppearance = appearance
//    navigationBar.scrollEdgeAppearance = appearance
//    navigationBar.prefersLargeTitles = false//true
//
//    if #available(iOS 15.0, *) {
//      navigationBar.compactScrollEdgeAppearance = appearance
//    }
//  }
  
  func prepareMenu() -> UIMenu {
    let filter: UIAction = .init(title: "filter".localized.capitalized,
                                 image: UIImage(systemName: "slider.horizontal.3", withConfiguration: UIImage.SymbolConfiguration(scale: .large)),
                                 identifier: nil,
                                 discoverabilityTitle: nil,
                                 attributes: .init(),
                                 state: .off,
                                 handler: { [weak self] _ in
      guard let self = self else { return }
      
      self.controllerOutput?.filter()
    })
    
    let delete: UIAction = .init(title: "select".localized.capitalized,
                                 image: UIImage(systemName: "person.fill.checkmark", withConfiguration: UIImage.SymbolConfiguration(scale: .large)),
                                 identifier: nil,
                                 discoverabilityTitle: nil,
                                 attributes: .init(),
                                 state: .off,
                                 handler: { [weak self] _ in
      guard let self = self else { return }
      
      self.controllerOutput?.setEditingMode(true)
      self.navigationController?.setToolbarHidden(false, animated: true)
    })
    
    //        let removeSubscribers: UIAction = .init(title: "remove_subscribers".localized.capitalized,
    //                                     image: UIImage(systemName: "person.fill.badge.plus", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold)),
    //                                     identifier: nil,
    //                                     discoverabilityTitle: nil,
    //                                     attributes: .init(),
    //                                     state: .off,
    //                                     handler: { [weak self] _ in
    //            guard let self = self else { return }
    //
    //            self.controllerOutput?.editingMode()
    //        })
    
    
    let half: UIAction = .init(title: "1/2",
                               image: UIImage(systemName: "square.grid.2x2.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .large)),
                               identifier: nil,
                               discoverabilityTitle: nil,
                               attributes: .init(),
                               state: gridItemSize == .half ? .on : .off,
                               handler: { [weak self] _ in
      guard let self = self else { return }
      
      self.gridItemSize = .half
    })
    
    let third: UIAction = .init(title: "1/3",
                                image: UIImage(systemName: "square.grid.3x3.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .large)),
                                identifier: nil,
                                discoverabilityTitle: nil,
                                attributes: .init(),
                                state: gridItemSize == .third ? .on : .off,
                                handler: { [weak self] _ in
      guard let self = self else { return }
      
      self.gridItemSize = .third
    })
    
    let quarter: UIAction = .init(title: "1/4",
                                  image: UIImage(systemName: "square.grid.4x3.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .large)),
                                  identifier: nil,
                                  discoverabilityTitle: nil,
                                  attributes: .init(),
                                  state: gridItemSize == .quarter ? .on : .off,
                                  handler: { [weak self] _ in
      guard let self = self else { return }
      
      self.gridItemSize = .quarter
    })
    
    var imageName: String = ""
    
    switch gridItemSize {
    case.half:
      imageName = "square.grid.2x2.fill"
    case.third:
      imageName = "square.grid.3x3.fill"
    case.quarter:
      imageName = "square.grid.4x3.fill"
    }
    
    let inlineMenu = UIMenu(title: "appearance".localized,
                            image: UIImage(systemName: imageName,
                                           withConfiguration: UIImage.SymbolConfiguration(weight: .semibold)),
                            identifier: nil,
                            options: .init(),
                            children: [half, third, quarter])
    var children: [UIMenuElement] = []
    children.append(filter)
    if let userprofile = userprofile {
      if mode == .Subscriptions, !userprofile.subscriptions.isEmpty {
        children.append(delete)
      } else if mode == .Subscribers, !userprofile.subscribers.isEmpty {
        children.append(delete)
      }
    }
    children.append(inlineMenu)
    
    return UIMenu(title: "", children: children)
  }
  
  func setBarButtons() {
    switch mode {
    case .Subscribers, .Subscriptions:
      print("")
//      guard let userprofile = userprofile else { return }
//
//      let avatar = Avatar(userprofile: userprofile)
//      avatar.heightAnchor.constraint(equalToConstant: 40).isActive = true
//      avatar.tapPublisher
//        .sink { [weak self] _ in
//          guard let self = self else { return }
//
//          let banner = NewBanner(contentView: UserBannerContentView(mode: .Username,
//                                                                      userprofile: userprofile),
//                                 contentPadding: UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8),
//                                 isModal: false,
//                                 useContentViewHeight: true,
//                                 shouldDismissAfter: 1)
//          banner.didDisappearPublisher
//            .sink { _ in banner.removeFromSuperview() }
//            .store(in: &self.subscriptions)
//        }
//        .store(in: &subscriptions)
//      navigationItem.setRightBarButton(UIBarButtonItem(customView: avatar), animated: false)
    case .Voters:
      let action = UIAction() { [weak self] _ in
        guard let self = self else { return }
        
        self.controllerOutput?.filter()
      }
      
      let button = UIBarButtonItem(title: nil,
                                   image: UIImage(systemName: "slider.horizontal.3", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold)),
                                   primaryAction: action,
                                   menu: nil)

      navigationItem.setRightBarButton(button, animated: true)
    }
  }
  
  func setTasks() {
    //        tasks.append( Task {@MainActor [weak self] in
    //            for await notification in NotificationCenter.default.notifications(for: <# notification #>) {
    //                guard let self = self else { return }
    //
    //
    //            }
    //        })
  }
  
  @objc
  func cancelSelection() {
    guard let toolbar = navigationController?.toolbar,
          let items = toolbar.items,
          let delete = items.filter { $0.accessibilityIdentifier == "delete" }.first
    else { return }
    
    navigationController?.setToolbarHidden(true, animated: true)
    controllerOutput?.setEditingMode(false)
    selectedItems.removeAll()
    delete.title = "delete".localized
    delete.tintColor = .secondaryLabel
  }
  
  @objc
  func deleteItems() {
    navigationController?.setToolbarHidden(true, animated: true)
    controllerOutput?.setEditingMode(false)
    if mode == .Subscriptions {
      controllerInput?.unsubscribe(from: selectedItems)
//    } else if mode == .Subscribers {
//      controllerInput?.removeSubscribers(selectedItems)
    }
    selectedItems.removeAll()
  }
  
  @objc
  func handleTap(recognizer: UITapGestureRecognizer) {
    if let answer = answer {
      let attributedText = NSMutableAttributedString(string: answer.description,
                                                     attributes: [
                                                      .font: UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .headline) as Any,
                                                     ])
      attributedText.append(.init(string: "\n\n" + "votes".localized.uppercased() + ": \(answer.totalVotes)",
                                  attributes: [
                                    .font: UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .footnote) as Any,
                                    .foregroundColor: UIColor.secondaryLabel as Any
                                  ]))
      
      let banner = NewBanner(contentView: TextBannerContent(image:  UIImage(systemName: "\(answer.order+1).circle.fill")!,
                                                            text: "",
                                                            attributedText: attributedText,
                                                            textColor: .label,
                                                            tintColor: tintColor),
                             contentPadding: UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8),
                             isModal: false,
                             useContentViewHeight: true,
                             shouldDismissAfter: 2)
      banner.didDisappearPublisher
        .sink { _ in banner.removeFromSuperview() }
        .store(in: &self.subscriptions)
    }
  }
}

extension UserprofilesController: UserprofilesViewInput {
//  func removeSubscribers(_ userprofiles: [Userprofile]) {
//    controllerInput?.removeSubscribers(userprofiles)
//  }
  
  func onSelection(_ userprofiles: [Userprofile]) {
    guard let toolbar = navigationController?.toolbar,
          let items = toolbar.items,
          let delete = items.filter({ $0.accessibilityIdentifier == "delete" }).first
    else { return }
    
    selectedItems = userprofiles
    
    if userprofiles.isEmpty {
      delete.title = "delete".localized
      delete.tintColor = .secondaryLabel
    } else {
      delete.title = "delete".localized + " (\(userprofiles.count))"
      delete.tintColor = .systemRed
    }
  }
  
  func subscribe(at: [Userprofile]) {
    controllerInput?.subscribe(at: at)
  }
  
  func unsubscribe(from: [Userprofile]) {
    controllerInput?.unsubscribe(from: from)
  }
  
  func loadVoters(for answer: Answer) {
    controllerInput?.loadVoters(for: answer)
  }
  
  func loadUsers(for userprofile: Userprofile, mode: Enums.UserprofilesViewMode) {
    controllerInput?.loadUsers(for: userprofile, mode: mode)
  }
  
  func onUserprofileTap(_ userprofile: Userprofile) {
    let backItem = UIBarButtonItem()
    backItem.title = ""
    
    navigationItem.backBarButtonItem = backItem
    navigationController?.pushViewController(UserprofileController(userprofile: userprofile, color: tintColor), animated: true)
    tabBarController?.setTabBarVisible(visible: false, animated: true)
  }
}

extension UserprofilesController: UserprofilesModelOutput {
  // Implement methods
}
