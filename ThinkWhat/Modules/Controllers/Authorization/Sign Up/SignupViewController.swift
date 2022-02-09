//
//  SignupViewController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 26.01.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import ReCaptcha
import SwiftyJSON
import Alamofire
import FBSDKLoginKit
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
        recaptcha?.configureWebView { [weak self] webview in
            webview.frame = self?.view.bounds ?? CGRect.zero
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        controllerOutput?.onDidDisappear()
    }
    
    func validate(completion: @escaping(Result<Bool,Error>)->()) {
        recaptcha?.validate(on: view) { [weak self] (result: ReCaptchaResult) in
            switch result {
            case .token:
                completion(.success(true))
            case .error(let error):
                completion(.failure(error.localizedDescription))
            }
        }
    }

    // MARK: - Properties
    var controllerOutput: SignupControllerOutput?
    var controllerInput: SignupControllerInput?
    let recaptcha = try? ReCaptcha()
//    private var reCAPTCHAViewModel: ReCAPTCHAViewModel?
}

// MARK: - View Input
extension SignupViewController: SignupViewInput {
    func onSignupSuccess() {
        print("onSignupSuccess")
    }
    
    func onCaptchaValidation(completion: @escaping(Result<Bool,Error>)->()) {
        validate{ completion($0) }
    }
    
    func onSignup(username: String, email: String, password: String, completion: @escaping (Result<Bool, Error>) -> ()) {
        recaptcha?.stop()
        API.shared.signup(email: email, password: password, username: username) { completion($0) }
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
    
//    func onFacebookTap(fbCompletion: @escaping(Result<Bool,Error>)->()) {
//        if AccessToken.current == nil || AccessToken.current!.expirationDate < Date() {
//            FBWorker.performLogin(viewController: self) { success in
//                if success {
//                    guard let token = AccessToken.current?.tokenString else { fatalError() }
//                    API.shared.loginViaProvider(provider: .Facebook, token: token) { result in
//                        switch result {
//                        case .success:
//                            NotificationCenter.default.post(name: Notifications.OAuth.TokenReceived, object: nil)
//                        case .failure(let error):
//                            
//                            NotificationCenter.default.post(name: Notifications.OAuth.TokenError, object: nil)
//                        }
//                    }
//                } else {
//                    fatalError("Facebook login ERROR")
//                }
//            }
//        }
//    }
    
    func onProviderAuth(provider: AuthProvider) async throws {
        func providerLogout() {
            switch provider {
            case .VK:
                VKWorker.logout()
            case .Facebook:
                FBWorker.logout()
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
                vkDelegateReference = VKDelegate()
                guard let providerToken = try await VKWorker.authorizeAsync().get() else { throw "VK token not available" }
                return providerToken
            case .Facebook:
                guard let providerToken = try await FBWorker.authorizeAsync(viewController: self).tokenString as? String else { throw "Facebook token not available" }
                return providerToken
            default:
#if DEBUG
                fatalError("Not implemented")
#endif
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
                            providerImage = try await API.shared.downloadImageAsync(from: url)
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
                case .Facebook:
                    guard let id = json["id"].string,
                          let email = json["email"].string,
                          let firstName = json["first_name"].string,
                          let lastName = json["last_name"].string else {
                              throw "VK json serialization failure"
                          }
                    if let pictureURL = json["picture"]["data"]["url"].string, let url = URL(string: pictureURL) {
                        do {
                            providerImage = try await API.shared.downloadImageAsync(from: url)
                            return FBWorker.prepareDjangoData(id: id,
                                                              firstName: firstName,
                                                              lastName: lastName,
                                                              email: email,
                                                              image: providerImage)
                        } catch {
                            return FBWorker.prepareDjangoData(id: id,
                                                              firstName: firstName,
                                                              lastName: lastName,
                                                              email: email)
                        }
                    } else {
                        return FBWorker.prepareDjangoData(id: id,
                                                          firstName: firstName,
                                                          lastName: lastName,
                                                          email: email)
                    }
                default:
                    throw "Not implemented"
                }
            }
            
            do {
                switch provider {
                case .VK:
                    let json = try await VKWorker.accountInfoAsync()
                    return try await prepareData(json: json)
                case .Facebook:
                    let json = try await FBWorker.accountInfoAsync()
                    return try await prepareData(json: json)
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
            await MainActor.run {
                controllerOutput?.onProviderControllerDisappear(provider: provider)
            }
            ///2. Login into our API
            try await API.shared.loginViaProviderAsync(provider: provider, token: providerToken)
        
            ///3. Get profile from API
            let userData = await API.shared.getUserDataOrNilAsync()
            do {
                ///4. If Profile was edited by user - no need to get data from provider
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .formatted(.dateTimeFormatter)
                Userprofiles.shared.current = try decoder.decode(Userprofile.self, from: userData!)
            } catch {
                ///5. Profile wasn't edited - we need to update it with provider data
                do {
                    let json = try JSON(data: userData!, options: .mutableContainers)
                    guard let id = json["id"].int else { throw "User ID not found" }
                    UserDefaults.Profile.id = id
                    ///5.1. Get user's profile from provider
                    let providerData = try await getProviderData()
                    ///5.2. Feed data to our API
                    let data = try await API.shared.updateUserprofileAsync(data: providerData) { progress in
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
    }
    
//    ///Performs vk.com login<Success,Error>
//    func onVKTap(completion: @escaping(Result<Bool,Error>)->()) {
//
//        ///Store downloaded user image
//        var image: UIImage?
//
//        ///Store downloaded image on success
//        func storeImage() {
//
//        }
//
//        ///Request necessary VK data for userprofile
//        func getProviderData(getProviderDataCompletion: @escaping(Result<Alamofire.Parameters,Error>)->()) {
//            VKWorker.accountInfo { [weak self] result in
//                guard `self` == self else { return }
//                switch result {
//                case .success(let json):
//                    guard let id = json[1]["user_id"].string,
//                          let email = json[1]["email"].string,
//                          let firstName = json[0]["first_name"].string,
//                          let lastName = json[0]["last_name"].string,
//                          let gender = json[0]["sex"].int,
//                          let domain = json[0]["domain"].string else {
//                              completion(.failure("VK response failed"))
//                              return
//                          }
//                    var parameters: Alamofire.Parameters! {
//                        didSet {
//                            getProviderDataCompletion(.success(parameters))
//                        }
//                    }
//                    let birthDate = json[0]["bdate"].string
//                    if let pictureURL = json[0]["photo_400_orig"].string, let url = URL(string: pictureURL) {
//                        API.shared.downloadImage(url: url) { _ in} completion: { [weak self] result in
//                            guard `self` == self else { return }
//                            switch result {
//                            case .success(let image):
//                                parameters = VKWorker.prepareDjangoData(id: id,
//                                                                        firstName: firstName,
//                                                                        lastName: lastName,
//                                                                        email: email,
//                                                                        gender: gender,
//                                                                        domain: domain,
//                                                                        birthDate: birthDate,
//                                                                        image: image)
//                            case .failure(let error):
//    #if DEBUG
//                                print(error.localizedDescription)
//    #endif
//                                parameters = VKWorker.prepareDjangoData(id: id,
//                                                                        firstName: firstName,
//                                                                        lastName: lastName,
//                                                                        email: email,
//                                                                        gender: gender,
//                                                                        domain: domain,
//                                                                        birthDate: birthDate)
//                            }
//                        }
//                    } else {
//                        parameters = VKWorker.prepareDjangoData(id: id,
//                                                                firstName: firstName,
//                                                                lastName: lastName,
//                                                                email: email,
//                                                                gender: gender,
//                                                                domain: domain,
//                                                                birthDate: birthDate)
//                    }
//                case .failure(let error):
//    #if DEBUG
//                    print(error.localizedDescription)
//    #endif
//                    getProviderDataCompletion(.failure(error))
//                }
//            }
//        }
//
//        ///Log in into API
//        func login(accessToken: String, loginCompletion: @escaping(Result<Bool,Error>)->()) {
//            API.shared.loginViaProvider(provider: .VK, token: accessToken) { result in
//                switch result {
//                case .success:
//                    loginCompletion(.success(true))
//                case .failure(let error):
//#if DEBUG
//                    print(error.localizedDescription)
//#endif
//                    completion(.failure(error))
//                }
//            }
//        }
//
//        func completeOnError(error: Error) {
//            VKWorker.logout()
//            completion(.failure(error))
//        }
//
//        ///1. Request grant access
//        VKWorker.authorize { [weak self] vkLoginResult in
//            guard let self = self else { return }
//            switch vkLoginResult {
//            case .success(let token):
//                guard let accessToken = token.get() else { completeOnError(error: "VK token error"); return }
//
//                ///2. Login into our API
//                login(accessToken: accessToken) { [weak self] apiLoginResult in
//                    guard `self` == self else { return }
//                    switch apiLoginResult {
//                    case .success:
//
//                        ///3. Check if profile was edited manually
//                        API.shared.getProfileNeedsUpdate { [weak self] needsUpdateResult in
//                            guard `self` == self else { return }
//                            switch needsUpdateResult {
//                            case .success(let needsUpdate):
//                                if needsUpdate {
//
//                                    ///3a. Request provider profile data
//                                    getProviderData { [weak self] providerResult in
//                                        guard `self` == self else { return }
//                                        switch providerResult {
//                                        case.success(let data):
//
//                                            ///4a. Feed data to our API
//                                            API.shared.updateUserprofile(data: data, uploadProgress: { _ in }) { [weak self] uploadResult in
//                                                guard `self` == self else { return }
//                                                switch uploadResult {
//                                                case .success(let json):
//
//                                                    ///5a. Import user data and image on device
//                                                    AppData.shared.importUserData(json, nil)
//                                                case .failure(let error):
//                                                    completeOnError(error: error); return}
//                                            }
//                                        case .failure(let error):
//                                            completeOnError(error: error); return }
//                                    }
//                                } else {
//                                    ///3b. Request API profile data
//                                    API.shared.getUserData { [weak self] getProfileResult in
//                                        guard `self` == self else { return }
//                                        switch getProfileResult {
//                                        case .success(let json):
//
//                                            ///4b. Import user data and image on device
//                                            AppData.shared.importUserData(json, nil)
//                                        case .failure(let error):
//                                            completeOnError(error: error); return }
//                                    }
//                                }
//                                case .failure(let error): completeOnError(error: error); return}
//                        }
//                    case .failure(let error):
//                        completeOnError(error: error); return}
//                }
//            case .failure(let error):
//                completeOnError(error: error); return }
//        }
//    }
//
//    func onLoginTap() {
//        print("onLoginTap")
//    }
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
