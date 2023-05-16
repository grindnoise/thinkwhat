//
//  PasswordResetViewController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 15.05.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit

class PasswordResetViewController: UIViewController {
  
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
  
  // MARK: - Public properties
  var controllerOutput: PasswordResetControllerOutput?
  var controllerInput: PasswordResetControllerInput?
  
  
  // MARK: - Destructor
  deinit {
#if DEBUG
    print("\(String(describing: type(of: self))).\(#function)")
#endif
  }
  
  // MARK: - Overridden Methods
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let view = PasswordResetView()
    let model = PasswordResetModel()
    
    self.controllerOutput = view
    self.controllerOutput?
      .viewInput = self
    self.controllerInput = model
    self.controllerInput?
      .modelOutput = self
    
    self.view = view as UIView
    setupUI()
  }
}

extension PasswordResetViewController: PasswordResetViewInput {
  func sendResetLink(_ mail: String) {
    controllerInput?.sendResetLink(mail)
  }
}

extension PasswordResetViewController: PasswordResetModelOutput {
  func callback(_ result: Result<Bool, Error>) {
    controllerOutput?.callback(result)
  }
}

private extension PasswordResetViewController {
  @MainActor
  func setupUI() {
    navigationController?.setNavigationBarHidden(false, animated: false)
    fillNavigationBar()
    
    navigationItem.titleView = logoStack
    
//    guard let navBar = navigationController?.navigationBar else { return }
//
//    logoStack.placeInCenter(of: navBar)
  }
}
