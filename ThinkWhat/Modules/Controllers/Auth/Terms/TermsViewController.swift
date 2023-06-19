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
  private var willMoveToParent = false
  ///**UI**
  public private(set) lazy var logoStack: UIStackView = {
//    let logoIcon: Icon = {
//      let instance = Icon(category: Icon.Category.Logo)
//      instance.accessibilityIdentifier = "logoIcon"
//      instance.iconColor = Colors.main
//      instance.isRounded = false
//      instance.clipsToBounds = false
//      instance.scaleMultiplicator = 1.2
//      instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1/1).isActive = true
//      instance.heightAnchor.constraint(equalToConstant: NavigationController.Constants.NavBarHeightSmallState * 0.65).isActive = true
//
//      return instance
//    }()
//    let logoText: Icon = {
//      let instance = Icon(category: Icon.Category.LogoText)
//      instance.accessibilityIdentifier = "logoText"
//      instance.iconColor = Colors.main
//      instance.isRounded = false
//      instance.clipsToBounds = false
//      instance.scaleMultiplicator = 1.1
//      instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 4.8).isActive = true
//
//      return instance
//    }()
    
    let logoIcon = Logo()
    let opaque = UIView.opaque()
    

      
//      .placeInCenter(of: opaque,
//                         topInset: NavigationController.Constants.NavBarHeightSmallState * 0.15,
//                         bottomInset: NavigationController.Constants.NavBarHeightSmallState * 0.15)
    
    logoIcon.translatesAutoresizingMaskIntoConstraints = false
    logoIcon.heightAnchor.constraint(equalToConstant: NavigationController.Constants.NavBarHeightSmallState * 0.7).isActive = true
    opaque.translatesAutoresizingMaskIntoConstraints = false
    LogoText().place(inside: opaque, insets: UIEdgeInsets(top: NavigationController.Constants.NavBarHeightSmallState * 0.175, left: 0, bottom: NavigationController.Constants.NavBarHeightSmallState * 0.175, right: 0))
    
    let instance = UIStackView(arrangedSubviews: [
      logoIcon,
      opaque
    ])

    instance.axis = .horizontal
    instance.spacing = 8
    
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
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    guard willMoveToParent,
          let constraint = logoStack.getConstraint(identifier: "centerYAnchor"),
          let navigationBar = navigationController?.navigationBar
    else { return }
    
    KeychainService.deleteData()
    
    navigationBar.setNeedsLayout()
    UIView.animate(withDuration: 0.1, animations: {
      constraint.constant = -100
      navigationBar.layoutIfNeeded()
    }) { [weak self] _ in
      guard let self = self else { return }
      
      self.logoStack.removeFromSuperview()
    }
  }
  
  override func willMove(toParent parent: UIViewController?) {
    super.willMove(toParent: parent)
    
    willMoveToParent = parent.isNil ? true : false
  }
}

extension TermsViewController: TermsViewInput {
  func onAccept() {
    UserDefaults.App.hasReadTermsOfUse = true
    let backItem = UIBarButtonItem()
    backItem.title = ""
    navigationItem.backBarButtonItem = backItem
    
    guard let userprofile = Userprofiles.shared.current,
          let wasEdited = userprofile.wasEdited
    else { return }

//    guard wasEdited else {
      navigationController?.pushViewController(ProfileCreationViewController(), animated: true)
//      return
//    }
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
