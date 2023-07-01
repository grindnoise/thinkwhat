//
//  NewAccountViewController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 28.04.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit
import SwiftyJSON
import Combine

class NewAccountViewController: UIViewController {
  
  
  // MARK: - Public properties
  var controllerOutput: NewAccountControllerOutput?
  var controllerInput: NewAccountControllerInput?
  ///**UI**
//  public private(set) lazy var tagCapsule: TagCapsule = { TagCapsule(text: "new_account".localized.uppercased(),
//                                                                     padding: 4,
//                                                                     color: Colors.main,
//                                                                     font: UIFont(name: Fonts.Bold, size: 20)!,
//                                                                     iconCategory: .Logo) }()
  
  
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  
  
  
  
  // MARK: - Destructor
  deinit {
//    tagCapsule.removeFromSuperview()
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
    
    let view = NewAccountView()
    let model = NewAccountModel()
    
    self.controllerOutput = view
    self.controllerOutput?
      .viewInput = self
    self.controllerInput = model
    self.controllerInput?
      .modelOutput = self
    
    self.view = view as UIView
    setupUI()
    setTasks()
  }
  
//  override func viewDidAppear(_ animated: Bool) {
//    super.viewDidAppear(animated)
//
//    delay(seconds: 1) {
//      self.emailConfirmed()
//    }
//  }
  
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    
    fillNavigationBar(with: traitCollection.userInterfaceStyle == .dark ? Colors.darkTheme : .systemBackground)
  }
}

extension NewAccountViewController: NewAccountViewInput {
  func emailConfirmed() {
    
    try? self.controllerInput?.updateUserprofile(parameters: ["is_email_verified": true], image: nil)
    AppData.isEmailVerified = true
    
    let backItem = UIBarButtonItem()
    backItem.title = ""
    navigationItem.backBarButtonItem = backItem
    navigationController?.delegate = appDelegate.transitionCoordinator
    navigationController?.pushViewController(TermsViewController(), animated: true)
    navigationController?.delegate = nil
  }
  
  func sendVerificationCode(_ completion: @escaping (Result<[String : Any], Error>) -> ()) {
    Task {
      do {
        let dict = try await API.shared.auth.sendEmailVerificationCode()
        await MainActor.run {
          completion(.success(dict))
        }
      } catch {
        completion(.failure(error))
      }
    }
  }
//  func sendVerificationCode() {
//    Task {
//      let data = try await API.shared.auth.getEmailConfirmationCode()
//      print(JSON(data))
//    }
//  }
  
  func signup(username: String, email: String, password: String) {
    Task {
      do {
        try await API.shared.auth.signupAsync(email: email,
                                              password: password,
                                              username: username)
        
        ///Login
        try await API.shared.auth.loginAsync(username: username, password: password)
        
        ///Get profile from API
        let json = try JSON(data: try await API.shared.profiles.current(),
                            options: .mutableContainers)
        
        guard let appData = json["app_data"] as? JSON,
              let current = json["current_user"] as? JSON
        else { throw AppError.server }
        
        ///Load necessary data before creating user
        try AppData.loadData(appData)
        
        Userprofiles.shared.current = try JSONDecoder.withDateTimeDecodingStrategyFormatters().decode(Userprofile.self, from: current.rawData())
        await MainActor.run {
          self.controllerOutput?.signupCallback(result: .success(true))
        }
      } catch {
        await MainActor.run {
          self.controllerOutput?.signupCallback(result: .failure(error))
        }
      }
    }
  }
}

extension NewAccountViewController: NewAccountModelOutput {
  
}

private extension NewAccountViewController {
  @MainActor
  func setupUI() {
//    navigationController?.navigationBar.backItem?.title = ""
    navigationController?.setNavigationBarHidden(false, animated: false)
    fillNavigationBar(with: traitCollection.userInterfaceStyle == .dark ? Colors.darkTheme : .systemBackground)
//    navigationItem.titleView = tagCapsule
    
  }
  
  func setTasks() {
    controllerOutput?.nameChecker
      .debounce(for: .seconds(0.75), scheduler: DispatchQueue.main)
      .sink { [weak self] name in
        guard let self = self else { return }
        
        
        Task {
          do {
            let response = try await API.shared.auth.checkUsernameAvailibilty(name)
            
            await MainActor.run {
              self.controllerOutput?.nameCheckerCallback(result: .success(response))
            }
          } catch {
            await MainActor.run {
              self.controllerOutput?.nameCheckerCallback(result: .failure(error))
            }
          }
        }
      }
      .store(in: &subscriptions)
    
    controllerOutput?.mailChecker
      .debounce(for: .seconds(0.75), scheduler: DispatchQueue.main)
      .sink { [weak self] mail in
        guard let self = self else { return }
        
        Task {
          do {
            let response = try await API.shared.auth.checkEmailAvailibilty(mail)
            
            await MainActor.run {
              self.controllerOutput?.mailCheckerCallback(result: .success(response))
            }
          } catch {
            await MainActor.run {
              self.controllerOutput?.mailCheckerCallback(result: .failure(error))
            }
          }
        }
      }
      .store(in: &subscriptions)
  }
}
