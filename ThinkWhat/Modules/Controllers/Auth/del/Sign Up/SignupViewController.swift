//
//  SignupViewController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 26.01.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
//import ReCaptcha
import SwiftyJSON
import Alamofire
//import FBSDKLoginKit
import SwiftyVK

class SignupViewController: UIViewController {

    deinit {
        print("SignupViewController deinit")
    }
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.setHidesBackButton(true, animated: false)
        let model = SignupModel()
               
        self.controllerOutput = view as? SignupView
        self.controllerOutput?
            .viewInput = self
        self.controllerInput = model
        self.controllerInput?
            .modelOutput = self
//        recaptcha?.configureWebView { [weak self] webview in
//            webview.frame = self?.view.bounds ?? CGRect.zero
//        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        controllerOutput?.onDidDisappear()
    }
    
//    func validate(completion: @escaping(Result<Bool,Error>)->()) {
//        recaptcha?.validate(on: view) { [weak self] (result: ReCaptchaResult) in
//            switch result {
//            case .token:
//                completion(.success(true))
//            case .error(let error):
//                completion(.failure(error.localizedDescription))
//            }
//        }
//    }

    // MARK: - Properties
    var controllerOutput: SignupControllerOutput?
    var controllerInput: SignupControllerInput?
//    let recaptcha = try? ReCaptcha()
//    private var reCAPTCHAViewModel: ReCAPTCHAViewModel?
}

// MARK: - View Input
extension SignupViewController: SignupViewInput {
    func onLogin() {
//        if let nav = navigationController as? CustomNavigationController {
//            nav.transitionStyle = .Default
////            nav.duration = 0.5
//        }
        let backItem = UIBarButtonItem()
            backItem.title = ""
            navigationItem.backBarButtonItem = backItem
        navigationController?
            .pushViewController(LoginViewController(),
                                animated: true)
    }
    
    func onSignupSuccess() {
//        if let nav = navigationController as? CustomNavigationController {
//            nav.transitionStyle = .Default
////            nav.duration = 0.5
//        }
        let backItem = UIBarButtonItem()
            backItem.title = ""
            navigationItem.backBarButtonItem = backItem
        navigationController?
            .pushViewController(ConditionsViewController(),
                                animated: true)
    }
    
    func onCaptchaValidation(completion: @escaping(Result<Bool,Error>)->()) {
//        validate{ completion($0) }
    }
    
    func onSignup(username: String, email: String, password: String, completion: @escaping (Result<Bool, Error>) -> ()) {
//        recaptcha?.stop()
        API.shared.auth.signUp(email: email, password: password, username: username) { completion($0) }
    }
    
    func checkCredentials(username: String, email: String, completion: @escaping (Result<Bool, Error>) -> ()) {
        API.shared.isUsernameEmailAvailable(email: email, username: username) { result in
            switch result {
            case .success(let exists):
                completion(.success(exists))
            case .failure(let error):
                completion(.failure(error.localizedDescription))
            }
        }
    }
    
    func onProviderAuth(provider: AuthProvider, timeout seconds: Double) async throws {
//        try await TimeoutTask(seconds: seconds) {
            func providerLogout() {
                switch provider {
                case .VK:
                    VKWorker.logout()
//                case .Facebook:
//                    FBWorker.logout()
                case .Google:
                    GoogleWorker.logout()
                default:
#if DEBUG
                    fatalError("Not implemented")
#endif
                }
            }
            
            var providerImage: UIImage?
            func getProviderToken() async throws -> String {
                switch provider {
                case .VK:
                    VKWorker.wakeUp()
                    guard let providerToken = try await VKWorker.authorizeAsync().get() else { throw "VK token not available" }
                    return providerToken
//                case .Facebook:
//                    FBWorker.wakeUp()
//                    guard let providerToken = try await FBWorker.authorizeAsync(viewController: self).tokenString as? String else { throw "Facebook token not available" }
//                    return providerToken
                case .Google:
//                    guard let providerToken = try await GoogleWorker.authorizeAsync(viewController: self) as? String else { throw "Facebook token not available" }
                    return ""//providerToken
                default:
#if DEBUG
                    fatalError("Not implemented")
#endif
                    throw "Not implemented"
                }
            }
            
            func getProviderData() async throws -> [String: Any] {
                func prepareData(json: JSON) async throws -> [String: Any] {
                    switch provider {
                    case .VK:
                        guard let id = json[1]["user_id"].string,
                              let email = json[1]["email"].string,
                              let firstName = json[0]["first_name"].string,
                              let lastName = json[0]["last_name"].string,
                              let gender = json[0]["sex"].int,
                              let domain = json[0]["domain"].string else {
                                  throw "VK json serialization failure"
                              }
                        let birthDate = json[0]["bdate"].string
                        if let pictureURL = json[0]["photo_400_orig"].string, let url = URL(string: pictureURL) {
                            do {
                                providerImage = try await API.shared.system.downloadImageAsync(from: url)
                                return VKWorker.prepareDjangoData(id: id,
                                                                  firstName: firstName,
                                                                  lastName: lastName,
                                                                  email: email,
                                                                  gender: gender,
                                                                  domain: domain,
                                                                  birthDate: birthDate,
                                                                  image: providerImage)
                            } catch {
                                return VKWorker.prepareDjangoData(id: id,
                                                                  firstName: firstName,
                                                                  lastName: lastName,
                                                                  email: email,
                                                                  gender: gender,
                                                                  domain: domain,
                                                                  birthDate: birthDate)
                            }
                        } else {
                            return VKWorker.prepareDjangoData(id: id,
                                                              firstName: firstName,
                                                              lastName: lastName,
                                                              email: email,
                                                              gender: gender,
                                                              domain: domain,
                                                              birthDate: birthDate)
                        }
//                    case .Facebook:
//                        guard let id = json["id"].string,
//                              let email = json["email"].string,
//                              let firstName = json["first_name"].string,
//                              let lastName = json["last_name"].string else {
//                                  throw "VK json serialization failure"
//                              }
//                        if let pictureURL = json["picture"]["data"]["url"].string, let url = URL(string: pictureURL) {
//                            do {
//                                providerImage = try await API.shared.system.downloadImageAsync(from: url)
//                                return FBWorker.prepareDjangoData(id: id,
//                                                                  firstName: firstName,
//                                                                  lastName: lastName,
//                                                                  email: email,
//                                                                  image: providerImage)
//                            } catch {
//                                return FBWorker.prepareDjangoData(id: id,
//                                                                  firstName: firstName,
//                                                                  lastName: lastName,
//                                                                  email: email)
//                            }
//                        } else {
//                            return FBWorker.prepareDjangoData(id: id,
//                                                              firstName: firstName,
//                                                              lastName: lastName,
//                                                              email: email)
//                        }
                    default:
                        throw "Not implemented"
                    }
                }
                
                do {
                    switch provider {
                    case .VK:
                        let json = try await VKWorker.accountInfoAsync()
                        return try await prepareData(json: json)
//                    case .Facebook:
//                        let json = try await FBWorker.accountInfoAsync()
//                        return try await prepareData(json: json)
                    case .Google:
                        var dict = try await GoogleWorker.accountInfoAsync()
                        if let url = dict[DjangoVariables.UserProfile.image] as? URL {
                            do {
                                providerImage = try await API.shared.system.downloadImageAsync(from: url)
                                dict[DjangoVariables.UserProfile.image] = providerImage
                                return dict
                            } catch {
                                return dict
                            }
                        } else {
                            return dict
                        }
                    default:
                        throw "Not implemented"
                    }
                } catch let error {
                    throw error
                }
            }
            
            do {
                ///1. Request provider for an access token
                let providerToken = try await getProviderToken()
                ///Perform animations
                //            await MainActor.run {
                //                controllerOutput?.onProviderControllerDisappear(provider: provider)
                //            }
                ///2. Login into our API
                try await API.shared.auth.loginViaProviderAsync(provider: provider, token: providerToken)
                
                ///3. Get profile from API
              let userData = try await API.shared.profiles.current()
                do {
                    ///4. If Profile was edited by user - no need to get data from provider
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .formatted(.dateTimeFormatter)
                    Userprofiles.shared.current = try decoder.decode(Userprofile.self, from: userData)
                    guard let url = UserDefaults.Profile.imageURL else { return }
                    Userprofiles.shared.current?.image = try await API.shared.system.downloadImageAsync(from: url)
                } catch {
                    ///5. Profile wasn't edited - we need to update it with provider data
                    do {
                        let json = try JSON(data: userData, options: .mutableContainers)
                        guard let id = json["id"].int else { throw "User ID not found" }
//                        UserDefaults.Profile.id = id
                        ///5.1. Get user's profile from provider
                        let providerData = try await getProviderData()
                        ///5.2. Feed data to our API
                        let data = try await API.shared.profiles.updateUserprofileAsync(data: providerData) { progress in
                            print(progress)
                        }
                        ///5.3. Import data
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategyFormatters = [ DateFormatter.ddMMyyyy,
                                                                   DateFormatter.dateTimeFormatter,
                                                                   DateFormatter.dateFormatter ]
                        Userprofiles.shared.current = try decoder.decode(Userprofile.self, from: data)
                        Userprofiles.shared.current?.image = providerImage
#if DEBUG
                        print(Userprofiles.shared.current)
#endif
                        providerLogout()
                    } catch {
                        providerLogout()
                        throw error
                    }
                }
            } catch let error {
#if DEBUG
                print(error.localizedDescription)
#endif
                providerLogout()
                throw error
            }
//        }.value
    }
}

// MARK: - Model Output
extension SignupViewController: SignupModelOutput {
    // Implement methods
}

//extension SignupViewController: ReCAPTCHAViewModelDelegate {
//    func didSolveCAPTCHA(token: String) {
//        print("Token: \(token)")
//    }
//}
