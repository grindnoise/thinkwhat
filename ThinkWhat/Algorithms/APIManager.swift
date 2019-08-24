//
//  APIManager.swift
//  Burb
//
//  Created by Pavel Bukharov on 26.04.2018.
//  Copyright © 2018 Pavel Bukharov. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

protocol APIManagerProtocol {

    func login(_ auth: AuthVariant, username: String?, password: String?, token: String?, completion: @escaping (TokenState) -> ())
    func logout(completion: @escaping (TokenState) -> ())
    func getUserData(completion: @escaping(JSON?, Error?)->())
    func getProfileNeedsUpdate(completion: @escaping (Bool) -> ())
    func updateUserProfile(data: [String: Any], completion: @escaping(JSON?, Error?) -> ())
    func checkUsernameEmailAvailability(email: String, username: String, completion: @escaping(Bool?, Error?)->())
    func getEmailConfirmationCode(email: String, username: String, completion: @escaping(JSON?, Error?)->())
    func getEmailVerified(completion: @escaping(Bool?, Error?)->())
//    func requestUserData(socialNetwork: AuthVariant, completion: @escaping (JSON) -> ())
//    func downloadImage(url: URL, percentageClosure: @escaping (CGFloat) -> (), completion: @escaping (UIImage) -> ())
//    func pullUserData(_ userID: String, completion: @escaping (JSON) -> ())
//    func makeOrder(_ order: Order, completion: @escaping (JSON) -> ())
//    func requestSMSValidationCode(phoneNumber: String, completion: @escaping (JSON?) -> ())
//    func userExists(phoneNumber: String, completion: @escaping (JSON?) -> ())
//    func uploadUserImage(image: UIImage, completion: @escaping (JSON?) -> ())
//    func recoverPassword(_ password: String, completion: @escaping (JSON?) -> ())
}

protocol UserDataPreparatory: class {
    static func prepareUserData(_ data: [String: Any]) -> [String: Any]
}

class APIManager: APIManagerProtocol {
    private var isProxyEnabled: Bool? {
        didSet {
            if isProxyEnabled != nil && isProxyEnabled != oldValue {
                if isProxyEnabled == true {
                    self.sessionManager = proxySessionManager
                } else {
                    self.sessionManager = defaultSessionManager
                }
            }
        }
    }
    private var defaultSessionManager: Alamofire.SessionManager {
        let config = Alamofire.SessionManager.default.session.configuration
//        config.timeoutIntervalForRequest = 10
        return Alamofire.SessionManager(configuration: config)
    }
    private var proxySessionManager: Alamofire.SessionManager {
        var proxyDictionary = [AnyHashable: Any]()
        proxyDictionary[kCFNetworkProxiesHTTPProxy as String] = "68.183.56.239"
        proxyDictionary[kCFNetworkProxiesHTTPPort as String] = 8080
        proxyDictionary[kCFNetworkProxiesHTTPEnable as String] = 1
        proxyDictionary[kCFStreamPropertyHTTPSProxyHost as String] = "68.183.56.239"
        proxyDictionary[kCFStreamPropertyHTTPSProxyPort as String] = 8080
        let proxyConfig = Alamofire.SessionManager.default.session.configuration
        proxyConfig.connectionProxyDictionary = proxyDictionary
        proxyConfig.timeoutIntervalForRequest = 10
        return Alamofire.SessionManager(configuration: proxyConfig)
    }
    private var sessionManager: Alamofire.SessionManager!
    
    init() {
        sessionManager = defaultSessionManager
    }
    
    private func checkForReachability(completion: @escaping(ApiReachabilityState) -> ()) {
        let url = URL(string: SERVER_URLS.BASE)!.appendingPathComponent(SERVER_URLS.TOKEN)
        Alamofire.SessionManager.default.request(url, method: .get, parameters: [:], encoding: URLEncoding(), headers: nil).responseJSON(completionHandler: {
            response in
            var reachable = ApiReachabilityState.None
            if response.response != nil {
                reachable = .Reachable
            }
            apiReachability = reachable
            completion(reachable)
        })
    }
    
    private func parseAFError(_ error: AFError) -> Error {
        var errorDescription = ""
        switch error {
        case .invalidURL(let url):
            errorDescription = ("Invalid URL: \(url) - \(error.localizedDescription)")
        case .parameterEncodingFailed(let reason):
            errorDescription = ("Parameter encoding failed: \(error.localizedDescription)")
            errorDescription += ("Failure Reason: \(reason)")
        case .multipartEncodingFailed(let reason):
            errorDescription = ("Multipart encoding failed: \(error.localizedDescription)")
            errorDescription += ("Failure Reason: \(reason)")
        case .responseValidationFailed(let reason):
            errorDescription = ("Response validation failed: \(error.localizedDescription)")
            errorDescription += ("Failure Reason: \(reason)")
            
            switch reason {
            case .dataFileNil, .dataFileReadFailed:
                errorDescription += ("Downloaded file could not be read")
            case .missingContentType(let acceptableContentTypes):
                errorDescription += ("Content Type Missing: \(acceptableContentTypes)")
            case .unacceptableContentType(let acceptableContentTypes, let responseContentType):
                errorDescription += ("Response content type: \(responseContentType) was unacceptable: \(acceptableContentTypes)")
            case .unacceptableStatusCode(let code):
                errorDescription += ("Response status code was unacceptable: \(code)")
            }
        case .responseSerializationFailed(let reason):
            errorDescription = ("Response serialization failed: \(error.localizedDescription)")
            errorDescription += ("Failure Reason: \(reason)")
        }
        return NSError(domain:"", code:523, userInfo:[ NSLocalizedDescriptionKey: errorDescription]) as Error
    }
    
    private func parseDjangoError(_ json: JSON) -> TokenState {
        var _tokenState = TokenState.Unassigned
        for attr in json {
            if attr.0 ==  "error" {
                switch attr.1.stringValue {
                case DjangoError.InvalidGrant.rawValue:
                    _tokenState = .WrongCredentials
                default:
                    _tokenState = .Unassigned
                }
            }
        }
        return _tokenState
    }
    
    private func parseDebugDescription(_ debugDescription: String) -> TokenState {
        if debugDescription.contains("NSURLErrorDomain Code=-1004") {
            return TokenState.ConnectionError
        }
        return TokenState.Error
    }
    
//    private func setupProxyConfiguration() {
//
//        var proxyDictionary = [AnyHashable: Any]()
//        proxyDictionary[kCFNetworkProxiesHTTPProxy as String] = "45.112.126.238"
//        proxyDictionary[kCFNetworkProxiesHTTPPort as String] = 3128
//        proxyDictionary[kCFNetworkProxiesHTTPEnable as String] = 1
//        proxyDictionary[kCFStreamPropertyHTTPSProxyHost as String] = "45.112.126.238"
//        proxyDictionary[kCFStreamPropertyHTTPSProxyPort as String] = 3128
//        let proxyConfig = Alamofire.SessionManager.default.session.configuration
//        proxyConfig.connectionProxyDictionary = proxyDictionary
//        proxyConfig.timeoutIntervalForRequest = 10
//        sessionManager = Alamofire.SessionManager(configuration: proxyConfig)
//    }
    func getEmailConfirmationCode(email: String, username: String, completion: @escaping(JSON?, Error?)->()) {
        var returnValue: JSON?
        var error: Error?
        
        checkForReachability {
            reachable in
            if reachable == .Reachable {
                performRequest()
            } else {
                error = NSError(domain:"", code:523, userInfo:[ NSLocalizedDescriptionKey: "Server is unreachable"]) as Error
                completion(returnValue, error)
            }
        }
        
        func performRequest() {
            let url = URL(string: SERVER_URLS.BASE)!.appendingPathComponent(SERVER_URLS.GET_CONFIRMATION_CODE)
            
            let parameters = ["email": email,
                              "username": username]
            
            sessionManager.request(url, method: .get, parameters: parameters, headers: nil).responseJSON() {
                response in
                if response.result.isFailure {
                    print(response.result.debugDescription)
                }
                if let _error = response.result.error as? AFError {
                    error = NSError(domain:"", code:404, userInfo:[ NSLocalizedDescriptionKey: self.parseAFError(_error)]) as Error
                } else {
                    if let statusCode  = response.response?.statusCode{
                        if 200...299 ~= statusCode {
                            do {
                                returnValue = try JSON(data: response.data!)
                            } catch let _error {
                                error = _error
                            }
                        } else if 400...499 ~= statusCode {
                            do {
                                let json = try JSON(data: response.data!)
                                error = NSError(domain:"", code:404, userInfo:[ NSLocalizedDescriptionKey: json.rawString()!]) as Error
                            } catch  let _error{
                                error = _error
                            }
                        }
                    }
                }
                completion(returnValue, error)
            }
        }
    }
    
    func getUserData(completion: @escaping(JSON?, Error?)->()) {
        var json: JSON?
        var error: Error?
        
        checkForReachability {
            reachable in
            if reachable == .Reachable {
                performRequest()
            } else {
                error = NSError(domain:"", code:523, userInfo:[ NSLocalizedDescriptionKey: "Server is unreachable"]) as Error
                completion(json, error)
            }
        }
        
        func performRequest() {
            let url = URL(string: SERVER_URLS.BASE)!.appendingPathComponent(SERVER_URLS.CURRENT_USER)
            
            let headers: HTTPHeaders = [
                "Authorization": "Bearer " + (KeychainService.loadAccessToken()! as String) as String,
                "Content-Type": "application/json"
            ]
            
            sessionManager.request(url, method: .get, parameters: nil, headers: headers).responseJSON() {
                response in
                if response.result.isFailure {
                    print(response.result.debugDescription)
                }
                if let _error = response.result.error as? AFError {
                    error = NSError(domain:"", code:404, userInfo:[ NSLocalizedDescriptionKey: self.parseAFError(_error)]) as Error
                } else {
                    if let statusCode  = response.response?.statusCode{
                        if 200...299 ~= statusCode {
                            do {
                                json = try JSON(data: response.data!)
                            } catch let _error {
                                error = _error
                            }
                        } else if 400...499 ~= statusCode {
                            do {
                                let json = try JSON(data: response.data!)
                                error = NSError(domain:"", code:404, userInfo:[ NSLocalizedDescriptionKey: json.rawString()!]) as Error
                            } catch  let _error{
                                error = _error
                            }
                        }
                    }
                }
                completion(json, error)
            }
        }
    }
    
    func login(_ auth: AuthVariant, username: String?, password: String?, token: String?, completion: @escaping (TokenState) -> ()) {
        var _tokenState             = TokenState.Error
        var parameters: Parameters  = [:]
        var url: URL!
        
        checkForReachability {
            reachable in
            if reachable == .Reachable {
                switch auth {
                case .Username:
                    if let _username = username, let _password = password {
                        usernameLogin(username: _username, password: _password)
                    } else {
                        completion(_tokenState)
                    }
                default:
                    if let _token = token {
                        socialMediaLogin(token: _token)
                    } else {
                        completion(_tokenState)
                    }
                }
            } else {
                completion(.ConnectionError)
            }
        }
        
        func usernameLogin(username: String, password: String) {
            parameters = ["client_id": SERVER_URLS.CLIENT_ID, "client_secret": SERVER_URLS.CLIENT_SECRET, "grant_type": "password", "username": "\(username)", "password": "\(password)"]
            url = URL(string: SERVER_URLS.BASE)!.appendingPathComponent(SERVER_URLS.TOKEN)
            sessionManager.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON() {
                response in
                if response.result.isFailure {
                    _tokenState = self.parseDebugDescription(response.result.debugDescription)
                }
                if let error = response.result.error as? AFError {
                    self.parseAFError(error)
                } else {
                    if let statusCode  = response.response?.statusCode {
                        if 200...299 ~= statusCode {
                            do {
                                let json = try JSON(data: response.data!)
                                print(json)
                                saveTokenInKeychain(json: json, tokenState: &_tokenState)
                                _tokenState = .Received
//                                DispatchQueue.main.async {
//                                    self.getUserData()
//                                }
                            } catch {
                                print(error.localizedDescription)
                            }
                        } else if 400...499 ~= statusCode {
                            do {
                                let json = try JSON(data: response.data!)
                                _tokenState = self.parseDjangoError(json)
                            } catch {
                                print(error.localizedDescription)
                            }
                        }
                    }
                }
                completion(_tokenState)
            }
        }
        
        func socialMediaLogin(token: String) {
            parameters = ["client_id": SERVER_URLS.CLIENT_ID, "client_secret": SERVER_URLS.CLIENT_SECRET, "grant_type": "convert_token", "backend": "\(auth.rawValue.lowercased())", "token": "\(token)"]
            print(parameters)
            url = URL(string: SERVER_URLS.BASE)!.appendingPathComponent(SERVER_URLS.TOKEN_CONVERT)
            sessionManager.request(url, method: .post, parameters: parameters, encoding: URLEncoding(), headers: nil).responseJSON() {
                response in
                if response.result.isFailure {
                    _tokenState = self.parseDebugDescription(response.result.debugDescription)
                }
                if let error = response.result.error as? AFError {
                    self.parseAFError(error)
                } else {
                    if let statusCode  = response.response?.statusCode{
                        if 200...299 ~= statusCode {
                            if let json = try? JSON(data: response.data!) {
                                saveTokenInKeychain(json: json, tokenState: &_tokenState)
                                _tokenState = .Received
                            }
//                            DispatchQueue.main.async {
//                                self.getUserData()
//                            }
                        } else if 400...499 ~= statusCode {
                            do {
                                let json = try JSON(data: response.data!)
                                _tokenState = self.parseDjangoError(json)
                            } catch {
                                print(error.localizedDescription)
                            }
                        }
                    }
                }
                completion(_tokenState)
            }
        }
    }
    
    func logout(completion: @escaping (TokenState) -> ()) {
        
        var _tokenState             = TokenState.Error
        
        checkForReachability {
            reachable in
            if reachable == .Reachable {
                performRequest()
            } else {
                completion(.ConnectionError)
            }
        }
        
        func performRequest() {
            let parameters = ["client_id": SERVER_URLS.CLIENT_ID, "client_secret": SERVER_URLS.CLIENT_SECRET, "token": "\(KeychainService.loadAccessToken()! as String)"]
            let url = URL(string: SERVER_URLS.BASE)!.appendingPathComponent(SERVER_URLS.TOKEN_REVOKE)
            sessionManager.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON() {
                response in
                if response.result.isFailure {
                    fatalError(response.result.debugDescription)
                }
                if let error = response.result.error as? AFError {
                    self.parseAFError(error)
                } else {
                    let statusCode  = response.response?.statusCode
                    if 200...299 ~= statusCode! {
                        _tokenState = .Revoked
                    } else if 400...499 ~= statusCode! {
                        do {
                            let json = try JSON(data: response.data!)
                            print(json)
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                }
            }
        }
        completion(_tokenState)
    }
    
    func signUp(email: String, password: String, username: String, completion: @escaping (Error?) -> ()) {
        var error: Error?
        
        checkForReachability {
            reachable in
            if reachable == .Reachable {
                performRequest()
            } else {
                error = NSError(domain:"", code:523, userInfo:[ NSLocalizedDescriptionKey: "Server is unreachable"]) as Error
                completion(error!)
            }
        }
        
        func performRequest() {
            let parameters = ["client_id": SERVER_URLS.CLIENT_ID, "grant_type": "password", "email": "\(email)", "password": "\(password)", "username": "\(username)"]
            let url =  URL(string: SERVER_URLS.BASE)!.appendingPathComponent(SERVER_URLS.SIGNUP)
            sessionManager.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON() {
                response in
//                var success = false
                if response.result.isFailure {
                    error = NSError(domain:"", code:404, userInfo:[ NSLocalizedDescriptionKey: response.result.debugDescription]) as Error
                }
                if let _error = response.result.error as? AFError {
                    error = NSError(domain:"", code:404, userInfo:[ NSLocalizedDescriptionKey: self.parseAFError(_error)]) as Error
                } else {
                    let statusCode  = response.response?.statusCode
                    if 200...299 ~= statusCode! {
                        do {
                            let json = try JSON(data: response.data!)
                            TemporaryUserCredentials.shared.importJson(json)
                        } catch {
                            print(error.localizedDescription)
                        }
//                        success = true
//                        if login {
//                            self.login(.Mail, username: username, password: password, token: nil, completion: { (state) in
//                                tokenState = state
//                            })
//                        }
                    } else if 400...499 ~= statusCode! {
                        do {
                            let json = try JSON(data: response.data!)
                            error = NSError(domain:"", code:404, userInfo:[ NSLocalizedDescriptionKey: json.rawString()]) as Error
                        } catch let _error {
                            error = _error
                        }
                    }
                }
                completion(error)
            }
        }
    }
    
    func getProfileNeedsUpdate(completion: @escaping (Bool) -> ()) {
        var needsUpdate = false
        checkForReachability {
            reachable in
            if reachable == .Reachable {
                performRequest()
            } else {
                completion(needsUpdate)
            }
        }
        
        func performRequest() {
            let url = URL(string: SERVER_URLS.BASE)!.appendingPathComponent(SERVER_URLS.PROFILE_NEEDS_UPDATE)
            
            let headers: HTTPHeaders = [
                "Authorization": "Bearer " + (KeychainService.loadAccessToken()! as String) as String,
                "Content-Type": "application/json"
            ]

            sessionManager.request(url, method: .get, parameters: nil, headers: headers).responseJSON() {
                response in
                if response.result.isFailure {
                    print(response.result.debugDescription)
                }
                if let error = response.result.error as? AFError {
                    self.parseAFError(error)
                } else {
                    
                    if let statusCode  = response.response?.statusCode{
                        if 200...299 ~= statusCode {
                            do {
                                let json = try JSON(data: response.data!)
                                for attr in json {
                                    if attr.0 ==  "needs_update" {
                                        needsUpdate = attr.1.boolValue
                                    }
                                }
                            } catch {
                                print(error.localizedDescription)
                            }
                        } else if 400...499 ~= statusCode {
                            do {
                                let json = try JSON(data: response.data!)
                                print(json)
                            } catch {
                                print(error.localizedDescription)
                            }
                        }
                    }
                    completion(needsUpdate)
                }
            }
        }
    }
    
    func checkUsernameEmailAvailability(email: String, username: String, completion: @escaping(Bool?, Error?)->()) {
        var error: Error?
        var exists: Bool?
        
        checkForReachability {
            reachable in
            if reachable == .Reachable {
                performRequest()
            } else {
                error = NSError(domain:"", code:523 , userInfo:[ NSLocalizedDescriptionKey: "Server is unreachable"]) as Error
                completion(exists, error)
            }
        }
        
        func performRequest() {
            let url = URL(string: SERVER_URLS.BASE)!.appendingPathComponent(email.isEmpty ? SERVER_URLS.USERNAME_EXISTS : SERVER_URLS.EMAIL_EXISTS)
            let parameters = ["email": email,
                              "username": username]
//            let headers: HTTPHeaders = [
//                "Authorization": "Bearer " + (KeychainService.loadAccessToken()! as String) as String,
//                "Content-Type": "application/json"
//            ]
            
            sessionManager.request(url, method: .get, parameters: parameters, headers: nil/*headers*/).responseJSON() {
                response in
                if response.result.isFailure {
                    error = NSError(domain:"", code:404, userInfo:[ NSLocalizedDescriptionKey: response.result.description]) as Error
                }
                if let _error = response.result.error as? AFError {
                    error = self.parseAFError(_error)
                } else {
                    if let statusCode  = response.response?.statusCode{
                        if 200...299 ~= statusCode {
                            do {
                                let json = try JSON(data: response.data!)
                                for attr in json {
                                    if attr.0 ==  "exists" {
                                        exists = attr.1.boolValue
                                    }
                                }
                            } catch let _error {
                                error = _error
                            }
                        } else if 400...499 ~= statusCode {
                            do {
                                let json = try JSON(data: response.data!)
                                error = NSError(domain:"", code:404 , userInfo:[ NSLocalizedDescriptionKey: json.rawString()!]) as Error
                            } catch let _error {
                                error = _error
                            }
                        }
                    }
                }
                completion(exists, error)
            }
        }
    }

    
    func updateUserProfile(data: [String: Any], completion: @escaping(JSON?, Error?) -> ()) {
        var dict = data
        var json: JSON?
        var error: Error?
        
        checkForReachability {
            reachable in
            if reachable == .Reachable {
                performRequest()
            } else {
                error = NSError(domain:"", code:523, userInfo:[ NSLocalizedDescriptionKey: "Server is unreachable"]) as Error
                completion(nil, error!)
            }
        }
        
        func performRequest() {
            
            let url = URL(string: SERVER_URLS.BASE)!.appendingPathComponent(SERVER_URLS.PROFILE + AppData.shared.userProfile.ID + "/")
            let headers: HTTPHeaders = [
                "Authorization": "Bearer " + (KeychainService.loadAccessToken()! as String) as String,
                "Content-Type": "application/json"
            ]
            if let image = data["image"] as? UIImage {
                dict.removeValue(forKey: "image")
                Alamofire.upload(multipartFormData: { multipartFormData in
                    var imgExt: FileFormat = .Unknown
                    var imageData: Data?
                    if let data = image.jpegData(compressionQuality: 1) {
                        imageData = data
                        imgExt = .JPEG
                    } else if let data = image.pngData() {
                        imageData = data
                        imgExt = .PNG
                    }
                    multipartFormData.append(imageData!, withName: "image", fileName: "\(AppData.shared.userProfile.ID!).\(imgExt.rawValue)", mimeType: "jpg/png")
                    for (key, value) in dict {
                        if value is String || value is Int {
                            multipartFormData.append("\(value)".data(using: .utf8)!, withName: key)
                        }
                    }
                }, usingThreshold: SessionManager.multipartFormDataEncodingMemoryThreshold, to: url, method: .patch, headers: headers) {
                    result in
                    switch result {
                    case .failure(let _error):
                        error = _error
                        completion(json, error)
                    case .success(request: let upload, streamingFromDisk: _, streamFileURL: _):
                        upload.uploadProgress(closure: { (progress) in
                            print("Upload Progress: \(progress.fractionCompleted)")
                        })
                        upload.responseJSON(completionHandler: { (response) in
                            if response.result.isFailure {
                                error = NSError(domain:"", code:404, userInfo:[ NSLocalizedDescriptionKey: response.result.debugDescription]) as Error
                            }
                            if let _error = response.result.error as? AFError {
                                error = self.parseAFError(_error)
                            } else {
                                if let statusCode  = response.response?.statusCode{
                                    if 200...299 ~= statusCode {
                                        do {
                                            json = try JSON(data: response.data!)
                                        } catch let _error {
                                            error = _error
                                        }
                                    } else if 400...499 ~= statusCode {
                                        do {
                                            let errorJSON = try JSON(data: response.data!)
                                            error = NSError(domain:"", code:404, userInfo:[ NSLocalizedDescriptionKey: errorJSON.rawString()]) as Error
                                        } catch let _error {
                                            error = _error
                                        }
                                    }
                                }
                                completion(json, error)
                            }
                        })
                    }
                }
            } else {
                sessionManager.request(url, method: .patch, parameters: data, encoding: JSONEncoding.default, headers: headers).responseJSON() {//.request(url, method: .patch, parameters: nil, headers: headers).responseJSON() {
                    response in
                    if response.result.isFailure {
                        print(response.result.debugDescription)
                    }
                    if let error = response.result.error as? AFError {
                        self.parseAFError(error)
                    } else {
                        if let statusCode  = response.response?.statusCode{
                            if 200...299 ~= statusCode {
                                do {
                                    json = try JSON(data: response.data!)
                                } catch {
                                    print(error.localizedDescription)
                                }
                            } else if 400...499 ~= statusCode {
                                do {
                                    let errorJSON = try JSON(data: response.data!)
                                    error = NSError(domain:"", code:404, userInfo:[ NSLocalizedDescriptionKey: errorJSON.rawString()!]) as Error
                                } catch {
                                    print(error.localizedDescription)
                                }
                            }
                        }
                        completion(json, error)
                    }
                }
            }
        }
    }
    
    func getEmailVerified(completion: @escaping (Bool?, Error?) -> ()) {
        var error:              Error?
        var isEmailVerified:    Bool?
        
        checkForReachability {
            reachable in
            if reachable == .Reachable {
                performRequest()
            } else {
                error = NSError(domain:"", code:523 , userInfo:[ NSLocalizedDescriptionKey: "Server is unreachable"]) as Error
                completion(isEmailVerified, error)
            }
        }
        
        func performRequest() {
            let url = URL(string: SERVER_URLS.BASE)!.appendingPathComponent(SERVER_URLS.GET_EMAIL_VERIFIED)
            
            let headers: HTTPHeaders = [
                "Authorization": "Bearer " + (KeychainService.loadAccessToken()! as String) as String,
                "Content-Type": "application/json"
            ]
            print(headers)
            print(url)
            sessionManager.request(url, method: .get, parameters: nil, headers: headers).responseJSON() {
                response in
                if response.result.isFailure {
                    error = NSError(domain:"", code:404, userInfo:[ NSLocalizedDescriptionKey: response.result.description]) as Error
                }
                if let _error = response.result.error as? AFError {
                    error = self.parseAFError(_error)
                } else {
                    if let statusCode  = response.response?.statusCode{
                        if 200...299 ~= statusCode {
                            do {
                                let json = try JSON(data: response.data!)
                                for attr in json {
                                    if attr.0 ==  "is_email_verified" {
                                        isEmailVerified = attr.1.boolValue
                                    }
                                    if attr.0 ==  "error" {
                                        error = NSError(domain:"", code:404 , userInfo:[ NSLocalizedDescriptionKey: attr.1.stringValue]) as Error
                                    }
                                }
                            } catch let _error {
                                error = _error
                            }
                        } else if 400...499 ~= statusCode {
                            do {
                                let json = try JSON(data: response.data!)
                                error = NSError(domain:"", code:404 , userInfo:[ NSLocalizedDescriptionKey: json.rawString()!]) as Error
                            } catch let _error {
                                error = _error
                            }
                        }
                    }
                }
                completion(isEmailVerified, error)
            }
        }
    }
    
    func checkTokenExpiryDate() {
        if let expString = KeychainService.loadTokenExpireDateTime() as String? {
            let expiryDate = expString.toDateTime()
            if Date() >= expiryDate {
                tokenState = .Expired
                refreshAccessToken(completion: {
                    _tokenState in
                    tokenState = _tokenState
                })
            }
        }
    }
    
    func refreshAccessToken(completion: @escaping (TokenState) -> ()) {
        checkForReachability {
            reachable in
            if reachable == .Reachable {
                performRequest()
            } else {
                completion(.ConnectionError)
            }
        }
        
        func performRequest() {
            
            let refresh_token = KeychainService.loadRefreshToken()! as String
            let parameters = ["client_id": SERVER_URLS.CLIENT_ID, "client_secret": SERVER_URLS.CLIENT_SECRET, "grant_type": "refresh_token", "refresh_token": "\(refresh_token)"]
            let url = URL(string: SERVER_URLS.TOKEN)!
            sessionManager.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON(completionHandler: {
                response in
                var _tokenState = TokenState.Error
                if let error = response.result.error as? AFError {
                    
                    _tokenState = .Error
                    
                    switch error {
                    case .invalidURL(let url):
                        print("Invalid URL: \(url) - \(error.localizedDescription)")
                    case .parameterEncodingFailed(let reason):
                        print("Parameter encoding failed: \(error.localizedDescription)")
                        print("Failure Reason: \(reason)")
                    case .multipartEncodingFailed(let reason):
                        print("Multipart encoding failed: \(error.localizedDescription)")
                        print("Failure Reason: \(reason)")
                    case .responseValidationFailed(let reason):
                        print("Response validation failed: \(error.localizedDescription)")
                        print("Failure Reason: \(reason)")
                        
                        switch reason {
                        case .dataFileNil, .dataFileReadFailed:
                            print("Downloaded file could not be read")
                        case .missingContentType(let acceptableContentTypes):
                            print("Content Type Missing: \(acceptableContentTypes)")
                        case .unacceptableContentType(let acceptableContentTypes, let responseContentType):
                            print("Response content type: \(responseContentType) was unacceptable: \(acceptableContentTypes)")
                        case .unacceptableStatusCode(let code):
                            print("Response status code was unacceptable: \(code)")
                        }
                        
                    case .responseSerializationFailed(let reason):
                        print("Response serialization failed: \(error.localizedDescription)")
                        print("Failure Reason: \(reason)")
                    }
                    
                } else {
                    let statusCode  = response.response?.statusCode
                    if 200...299 ~= statusCode! {
                        if let json = try? JSON(data: response.data!) {
                            for attr in json {
                                print("\(attr.0): \(attr.1.stringValue)")
                            }
                            saveTokenInKeychain(json: json, tokenState: &tokenState)
                            _tokenState = TokenState.Received
                        } else {
                            _tokenState = .Error
                        }
                    } else if 400...499 ~= statusCode! {
                        _tokenState = .Error
                    }
                    completion(_tokenState)
                }
            })
        }
    }
    
}
