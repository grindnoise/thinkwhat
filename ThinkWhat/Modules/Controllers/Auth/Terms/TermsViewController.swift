//
//  TermsViewController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 26.04.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class TermsViewController: UIViewController {
  
  // MARK: - Public properties
  var controllerOutput: TermsControllerOutput?
  var controllerInput: TermsControllerInput?
  
  
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  ///**UI**
  public private(set) lazy var logoStack: UIStackView = {
    let logoIcon: Icon = {
      let instance = Icon(category: Icon.Category.Logo)
      instance.accessibilityIdentifier = "logoIcon"
      instance.iconColor = Colors.main
      instance.isRounded = false
      instance.clipsToBounds = false
      instance.scaleMultiplicator = 1.2
      instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1/1).isActive = true
      instance.heightAnchor.constraint(equalToConstant: NavigationController.Constants.NavBarHeightSmallState * 0.65).isActive = true
      
      return instance
    }()
    let logoText: Icon = {
      let instance = Icon(category: Icon.Category.LogoText)
      instance.accessibilityIdentifier = "logoText"
      instance.iconColor = Colors.main
      instance.isRounded = false
      instance.clipsToBounds = false
      instance.scaleMultiplicator = 1.1
      instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 4.8).isActive = true
      
      return instance
    }()
    
    let instance = UIStackView(arrangedSubviews: [
      logoIcon,
      logoText
    ])
//    instance.alpha = 0
    instance.axis = .horizontal
    instance.spacing = 0
    instance.clipsToBounds = false
    
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
  
  
  
  // MARK: - Overridden Methods
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let view = TermsView()
    let model = TermsModel()
    
    self.controllerOutput = view
    self.controllerOutput?
      .viewInput = self
    self.controllerInput = model
    self.controllerInput?
      .modelOutput = self
    
    self.view = view as UIView
    
    setupUI()
    controllerInput?.getTermsConditionsURL()
  }
}

extension TermsViewController: TermsViewInput {
  func onAccept() {
    let backItem = UIBarButtonItem()
    backItem.title = ""
    navigationItem.backBarButtonItem = backItem
//    guard let userprofile = Userprofiles.shared.current,
//          let wasEdited = userprofile.wasEdited
//    else { return }
//
//    navigationController?.navigationBar.backItem?.title = ""
//    guard wasEdited else {
      navigationController?.pushViewController(ProfileCreationViewController(), animated: true)
//      return
//    }
//
//    controllerOutput?.animateTransitionToApp {
//      appDelegate.window?.rootViewController = MainController()
//    }
  }
}

extension TermsViewController: TermsModelOutput {
  func onTermsConditionsURLReceived(_ url: URL) {
      controllerOutput?.getTermsConditionsURL(url)
  }
}

private extension TermsViewController {
  @MainActor
  func setupUI() {
    navigationController?.setNavigationBarHidden(false, animated: false)
//    setNavigationBarTintColor(Colors.main)
    fillNavigationBar()
//    navigationItem.titleView = logoStack
    guard let navBar = navigationController?.navigationBar else { return }
    
    logoStack.placeInCenter(of: navBar)
  }
}
