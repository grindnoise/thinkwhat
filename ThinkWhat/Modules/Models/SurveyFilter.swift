//
//  SurveyFilter.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 21.08.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

struct SurveyFilter {
  var all: Bool?
  var period: Enums.Period?
  var anonymous: Bool?
  var discussed: Bool?
  var completed: Bool?
  var notCompleted: Bool?
}


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
  @Published public private(set) var isFilterEnabled: Bool
  @Published public private(set) var mode: Enums.SurveyFilterMode
  @Published public private(set) var menu: UIMenu?
  @Published public private(set) var period: Enums.Period? {
    didSet {
      guard oldValue != period else { return }
      
      menu = updateMenu()
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
  init(mode: Enums.SurveyFilterMode,
       isFilterEnabled: Bool = false,
       text: String,
       image: UIImage? = nil,
       periodThreshold: Enums.Period = .unlimited) {
    self.mode = mode
    self.isFilterEnabled = isFilterEnabled
    self.text = text
    self.image = image
    self.periodThreshold = periodThreshold
    self.period = periodThreshold
  }
  
  // MARK: - Public methods
  public func getText() -> String { text }
  public func getImage() -> UIImage? { image }
  public func getMenu() -> UIMenu? {
    guard mode == .period, let periodThreshold = periodThreshold else { return nil }
    guard menu.isNil else { return menu! }
    
    var actions: [UIAction] = []
    
    for element in Enums.Period.allCases {
      guard element.rawValue <= periodThreshold.rawValue else { continue }
      
      actions.append(.init(title: "filter_per_\(element.description)".localized.lowercased(),
                           image: nil,
                           identifier: nil,
                           discoverabilityTitle: nil,
                           attributes: .init(),
                           state: period == periodThreshold ? .on : .off,
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
  public func setDisabled() { isFilterEnabled = false }
  public func setEnabled() { isFilterEnabled = true }
  
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
