//
//  SurveyFilterItem.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 23.08.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

/// Use as an item identifier in `SurveyFiltersCollectionView`
class SurveyFilterItem: Hashable {
  func hash(into hasher: inout Hasher) {
    hasher.combine(text)
    hasher.combine(image)
  }
  
  static func == (lhs: SurveyFilterItem, rhs: SurveyFilterItem) -> Bool {
    lhs.text == rhs.text &&
    lhs.image == rhs.image
  }
  
  // MARK: - Public properties
  ///**Publishers**
  public let periodPublisher = PassthroughSubject<Enums.Period, Never>()
  public let topicPublisher = PassthroughSubject<Topic, Never>()
  public let userprofilePublisher = PassthroughSubject<Userprofile, Never>()
  public let compatibilityPublisher = PassthroughSubject<TopicCompatibility, Never>()
  @Published public private(set) var isFilterEnabled: Bool
  @Published public private(set) var main: Enums.SurveyFilterMode
  @Published public private(set) var additional: Enums.SurveyAdditionalFilterMode
  @Published public private(set) var menu: UIMenu?
  public var period: Enums.Period? {
    didSet {
      guard let period = period, oldValue != period else { return }
  
      periodPublisher.send(period)
      menu = updateMenu()
    }
  }
  public var compatibility: TopicCompatibility? {
    didSet {
      guard let compatibility = compatibility, oldValue != compatibility else { return }
  
      compatibilityPublisher.send(compatibility)
    }
  }
  public var topic: Topic? {
    didSet {
      guard let topic = topic, oldValue != topic else { return }
  
      topicPublisher.send(topic)
    }
  }
  public var userprofile: Userprofile? {
    didSet {
      guard let userprofile = userprofile, oldValue != userprofile else { return }
  
      userprofilePublisher.send(userprofile)
    }
  }
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  /// **Logic**
  private var text = ""
  private var image: UIImage?
  private var periodThreshold: Enums.Period?// = .unlimited
  
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
  init(main: Enums.SurveyFilterMode,
       additional: Enums.SurveyAdditionalFilterMode,
       isFilterEnabled: Bool = false,
       text: String,
       image: UIImage? = nil,
       period: Enums.Period? = nil,
       periodThreshold: Enums.Period = .unlimited) {
    self.main = main
    self.additional = additional
    self.isFilterEnabled = isFilterEnabled
    self.text = text
    self.image = image
    self.periodThreshold = periodThreshold
    self.period = period ?? periodThreshold
  }
  
  // MARK: - Public methods
  public func getText() -> String { text }
  public func getImage() -> UIImage? { image }
  public func getMenu() -> UIMenu? {
    guard additional == .period, let periodThreshold = periodThreshold else { return nil }
    guard menu.isNil else { return menu! }
    
    var actions: [UIAction] = []
    
    for element in Enums.Period.allCases {
      guard element.rawValue <= periodThreshold.rawValue else { continue }
      
      actions.append(.init(title: element.description.localized.lowercased(),
                           image: nil,
                           identifier: nil,
                           discoverabilityTitle: nil,
                           attributes: .init(),
                           state: period == element ? .on : .off,
                           handler: { [weak self] _ in
        guard let self = self else { return }
        
        self.period = element
      }))
    }
    
    return UIMenu(title: "",
                  image: nil,
                  identifier: nil,
                  options: .init(),
                  children: actions)
  }
  public func setDisabled() { if isFilterEnabled { isFilterEnabled = false } }
  public func setEnabled() { if !isFilterEnabled { isFilterEnabled = true } }
  
  // MARK: - Private methods
  public func updateMenu() -> UIMenu? {
    guard let periodThreshold = periodThreshold else { return nil }
    
    var actions: [UIAction] = []
    
    for element in Enums.Period.allCases {
      guard element.rawValue <= periodThreshold.rawValue else { continue }
      
      actions.append(.init(title: element.description.localized.lowercased(),
                           image: nil,
                           identifier: nil,
                           discoverabilityTitle: nil,
                           attributes: .init(),
                           state: period == element ? .on : .off,
                           handler: { [weak self] _ in
        guard let self = self else { return }
        
        self.period = element
      }))
    }
    
    return UIMenu(title: "",
                  image: nil,
                  identifier: nil,
                  options: .init(),
                  children: actions)
  }
}
