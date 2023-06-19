//
//  StartViewController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 14.04.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit
import L10n_swift

class StartViewController: UIViewController {
  
  
  // MARK: - Public properties
  var controllerOutput: StartControllerOutput?
  var controllerInput: StartControllerInput?
  
  // MARK: - Destructor
  deinit {
#if DEBUG
    print("\(String(describing: type(of: self))).\(#function)")
#endif
  }
  
  // MARK: - Private properties
  private var currentLaguage: String = ""
  
  // MARK: - Overridden Methods
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let view = StartView()
    let model = StartModel()
    
    self.controllerOutput = view
    self.controllerOutput?
      .viewInput = self
    self.controllerInput = model
    self.controllerInput?
      .modelOutput = self
    
    self.view = view as UIView
    
    setupUI()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    controllerOutput?.didAppear()
  }
}

extension StartViewController: StartViewInput {
  func nextScene() {
    let backItem = UIBarButtonItem()
    backItem.title = ""
    navigationItem.backBarButtonItem = backItem
    navigationController?.delegate = appDelegate.transitionCoordinator
    navigationController?.pushViewController(SignInViewController(), animated: true)
    navigationController?.delegate = nil
  }
}

extension StartViewController: StartModelOutput {
  
}

private extension StartViewController {
  @MainActor
  func setupUI() {
    func menu() -> UIMenu {
      let items = L10n.supportedLanguages.map {
        UIAction(title: Locale(identifier: $0).localizedString(forLanguageCode: $0)!.capitalized,
                 image: nil,
                 identifier: .init($0),
                 discoverabilityTitle: nil,
                 attributes: .init(),
                 state: currentLaguage == $0 ? .on : .off,
                 handler: { [weak self] in
          guard let self = self else { return }
          
          Bundle.setLanguageAndPublish($0.identifier.rawValue, in: Bundle(for: Self.self))
          self.setupUI()
        })
      }
      
      return UIMenu(title: "",//"publications_per".localized,
                    image: nil,
                    identifier: nil,
                    options: .init(),
                    children: items)
    }
    
    currentLaguage = L10n.shared.language
    setNavigationBarTintColor(.label)
    navigationItem.rightBarButtonItem = UIBarButtonItem(title: nil,
                                                        image: UIImage(systemName: "globe",
                                                                       withConfiguration: UIImage.SymbolConfiguration(textStyle: .headline,
                                                                                                                      scale: .large)),
                                                        primaryAction: nil,
                                                        menu: menu())

  }
}
