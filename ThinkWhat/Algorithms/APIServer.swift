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
    func getFacebookID(completion: @escaping (String) -> ())
    func updateUserProfile(data: [String: Any], completion: @escaping(Bool) -> ())
//    func requestUserData(socialNetwork: AuthVariant, completion: @escaping (JSON) -> ())
//    func downloadImage(url: URL, percentageClosure: @escaping (CGFloat) -> (), completion: @escaping (UIImage) -> ())
//    func pullUserData(_ userID: String, completion: @escaping (JSON) -> ())
//    func makeOrder(_ order: Order, completion: @escaping (JSON) -> ())
//    func requestSMSValidationCode(phoneNumber: String, completion: @escaping (JSON?) -> ())
//    func userExists(phoneNumber: String, completion: @escaping (JSON?) -> ())
//    func uploadUserImage(image: UIImage, completion: @escaping (JSON?) -> ())
//    func recoverPassword(_ password: String, completion: @escaping (JSON?) -> ())
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
    
//    private func checkForReachability(completion: @escaping (Bool) -> ()) {
//        isProxyEnabled = nil
//        let url = URL(string: SERVER_URLS.BASE_URL)!.appendingPathComponent(SERVER_URLS.TOKEN_URL)
//        Alamofire.SessionManager.default.request(url, method: .get, parameters: [:], encoding: URLEncoding(), headers: nil).responseJSON(completionHandler: {
//            response in
//            var retVal = false
//            if response.response != nil {
//                retVal = false
//            } else {
//                retVal = true
//            }
//            completion(retVal)
//        })
//
//    }
    private func checkForReachability(completion: @escaping(ApiReachabilityState) -> ()) {
        let url = URL(string: SERVER_URLS.BASE_URL)!.appendingPathComponent(SERVER_URLS.TOKEN_URL)
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
    
    private func parseError(_ error: AFError) {
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

    private func getUserData() {
//        checkForReachability {
//            completed in
//            self.isProxyEnabled = completed
//            performRequest()
//        }
        checkForReachability {
            state in
            if state == .Reachable {
                performRequest()
            }
        }
        
        func performRequest() {
            let url = URL(string: SERVER_URLS.BASE_URL)!.appendingPathComponent(SERVER_URLS.CURRENT_USER_URL)
            
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
                    self.parseError(error)
                } else {
                    if let statusCode  = response.response?.statusCode{
                        if 200...299 ~= statusCode {
                            do {
                                let json = try JSON(data: response.data!)
                                AppData.shared.importUserData(json)
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
                }
            }
        }
    }
//
//    func downloadImage(url: URL, percentageClosure: @escaping (CGFloat) -> (), completion: @escaping (UIImage) -> ()) {
//
//        checkForReachability {
//            completed in
//            self.isProxyEnabled = completed
//            performRequest()
//        }
//
//        //checkTokenExpiryDate
//        func performRequest() {
//            sessionManager.request(url).downloadProgress(closure: {
//                progress in
//                let prog = CGFloat(progress.fractionCompleted)
//                percentageClosure(prog)
//            }).response(completionHandler: {
//                response in
//                if let data = response.data {
//                    if let image = UIImage(data: data) {
//                        completion(image)
//                    }
//                } else {
//                    completion(UIImage())
//                }
//            })
//        }
//    }

    func login(_ auth: AuthVariant, username: String?, password: String?, token: String?, completion: @escaping (TokenState) -> ()) {
        var _tokenState             = TokenState.Error
        var parameters: Parameters  = [:]
        var url: URL!
        
        checkForReachability {
            reachable in
            if reachable == .Reachable {
                switch auth {
                case .Mail:
                    if let _username = username, let _password = password {
                        mailLogin(username: _username, password: _password)
                    } else {
                        completion(_tokenState)
                    }
                default:
                    if let _token = token {
                        mediaLogin(token: _token)
                    } else {
                        completion(_tokenState)
                    }
                }
            } else {
                completion(.ConnectionError)
            }
        }
        
        func mailLogin(username: String, password: String) {
            parameters = ["client_id": SERVER_URLS.CLIENT_ID, "client_secret": SERVER_URLS.CLIENT_SECRET, "grant_type": "password", "username": "\(username)", "password": "\(password)"]
            url = URL(string: SERVER_URLS.TOKEN_URL)!
            sessionManager.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON() {
                response in
                if response.result.isFailure {
                    _tokenState = self.parseDebugDescription(response.result.debugDescription)
                }
                if let error = response.result.error as? AFError {
                    self.parseError(error)
                } else {
                    if let statusCode  = response.response?.statusCode {
                        if 200...299 ~= statusCode {
                            do {
                                let json = try JSON(data: response.data!)
                                saveTokenInKeychain(json: json, tokenState: &_tokenState)
                                _tokenState = .Received
                                DispatchQueue.main.async {
                                    self.getUserData()
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
                }
                completion(_tokenState)
            }
        }
        
        func mediaLogin(token: String) {
            parameters = ["client_id": SERVER_URLS.CLIENT_ID, "client_secret": SERVER_URLS.CLIENT_SECRET, "grant_type": "convert_token", "backend": "\(auth.rawValue.lowercased())", "token": "\(token)"]
            print(parameters)
            url = URL(string: SERVER_URLS.BASE_URL)!.appendingPathComponent(SERVER_URLS.TOKEN_CONVERT_URL)
            sessionManager.request(url, method: .post, parameters: parameters, encoding: URLEncoding(), headers: nil).responseJSON() {
                response in
                if response.result.isFailure {
                    _tokenState = self.parseDebugDescription(response.result.debugDescription)
                }
                if let error = response.result.error as? AFError {
                    self.parseError(error)
                } else {
                    if let statusCode  = response.response?.statusCode{
                        if 200...299 ~= statusCode {
                            if let json = try? JSON(data: response.data!) {
                                saveTokenInKeychain(json: json, tokenState: &_tokenState)
                                _tokenState = .Received
                            }
                            DispatchQueue.main.async {
                                self.getUserData()
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
            let url = URL(string: SERVER_URLS.BASE_URL)!.appendingPathComponent(SERVER_URLS.TOKEN_REVOKE_URL)
            sessionManager.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON() {
                response in
                if response.result.isFailure {
                    fatalError(response.result.debugDescription)
                }
                if let error = response.result.error as? AFError {
                    self.parseError(error)
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
    
    func signUp(email: String, password: String, username: String, completion: @escaping (Bool) -> ()) {
        
        checkForReachability {
            reachable in
            if reachable == .Reachable {
                performRequest()
            } else {
                completion(false)
            }
        }
        
        func performRequest() {
            let parameters = ["client_id": SERVER_URLS.CLIENT_ID, "grant_type": "password", "email": "\(email)", "password": "\(password)", "username": "\(username)"]
            let url = URL(string: SERVER_URLS.SIGNUP_URL)!
            sessionManager.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON() {
                response in
                var success = false
                if response.result.isFailure {
                    fatalError(response.result.debugDescription)
                }
                if let error = response.result.error as? AFError {
                    self.parseError(error)
                } else {
                    let statusCode  = response.response?.statusCode
                    if 200...299 ~= statusCode! {
                        success = true
//                        if login {
//                            self.login(.Mail, username: username, password: password, token: nil, completion: { (state) in
//                                tokenState = state
//                            })
//                        }
                    } else if 400...499 ~= statusCode! {
                        do {
                            let json = try JSON(data: response.data!)
                            print(json)
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                }
                completion(success)
            }
        }
    }
    
    func getFacebookID(completion: @escaping (String) -> ()) {
        checkForReachability {
            completed in
//            self.isProxyEnabled = completed
            performRequest()
        }
        
        func performRequest() {
            let parameters = ["category": "1"]
            let url = URL(string: SERVER_URLS.BASE_URL)!.appendingPathComponent(SERVER_URLS.GET_FACEBOOK_ID_URL)
            
            let headers: HTTPHeaders = [
                "Authorization": "Bearer " + (KeychainService.loadAccessToken()! as String) as String,
                "Content-Type": "application/json"
            ]

            sessionManager.request(url, method: .get, parameters: parameters, headers: headers).responseJSON() {
                response in
                if response.result.isFailure {
                    print(response.result.debugDescription)
                }
                if let error = response.result.error as? AFError {
                    self.parseError(error)
                } else {
                    var id = ""
                    if let statusCode  = response.response?.statusCode{
                        if 200...299 ~= statusCode {
                            do {
                                let json = try JSON(data: response.data!)
                                for attr in json {
                                    if attr.0 ==  "facebook_ID" {
                                        id = attr.1.stringValue
                                        print("\(attr.0): \(attr.1.stringValue)")
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
                    completion(id)
                }
            }
        }
    }
    
    func updateUserProfile(data: [String: Any], completion: @escaping(Bool) -> ()) {
        checkForReachability {
            reachable in
            if reachable == .Reachable {
                performRequest()
            } else {
                completion(false)
            }
        }
        
        func performRequest() {
            print(data)
            let parameters = data
            let url = URL(string: SERVER_URLS.BASE_URL)!.appendingPathComponent(SERVER_URLS.GET_FACEBOOK_ID_URL)
            
            let headers: HTTPHeaders = [
                "Authorization": "Bearer " + (KeychainService.loadAccessToken()! as String) as String,
                "Content-Type": "application/json"
            ]
            
            sessionManager.request(url, method: .get, parameters: parameters, headers: headers).responseJSON() {
                response in
                if response.result.isFailure {
                    print(response.result.debugDescription)
                }
                if let error = response.result.error as? AFError {
                    self.parseError(error)
                } else {
                    var id = ""
                    if let statusCode  = response.response?.statusCode{
                        if 200...299 ~= statusCode {
                            do {
                                let json = try JSON(data: response.data!)
                                for attr in json {
                                    if attr.0 ==  "facebook_ID" {
                                        id = attr.1.stringValue
                                        print("\(attr.0): \(attr.1.stringValue)")
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
//                    completion(id)
                }
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
            let url = URL(string: SERVER_URLS.TOKEN_URL)!
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
    
    func requestUserData(socialNetwork: AuthVariant, completion: @escaping (JSON) -> ()) {
        
        
        //checkTokenExpiryDate()
        let url = URL(string: "https://api.instagram.com/v1/users/self/")!
        sessionManager.request(url, method: .get, parameters: [:], encoding: URLEncoding.default, headers: nil).responseJSON(completionHandler: {
            response in
            
            if let error = response.result.error as? AFError {
                
                var statusCode = response.response?.statusCode
                statusCode = error._code // statusCode private
                
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
                        statusCode = code
                        
                    }
                    print(statusCode as Any)
                    
                case .responseSerializationFailed(let reason):
                    print("Response serialization failed: \(error.localizedDescription)")
                    print("Failure Reason: \(reason)")
                }
            } else {
                if let json = try? JSON(data: response.data!) {
                    completion(json["results"])
                }
            }
        })
    }
    
//    func makeOrder(_ order: Order, completion: @escaping (JSON) -> ()) {
//
//        //MARK: - TODO: need to set orderID from JSON response
//        //order.setOrderID(<#T##id: String##String#>)
//
//    }
//
//    func pullUserData(_ userID: String = "", completion: @escaping (JSON) -> ()) {
//
//        checkForReachability {
//
//            completed in
//            self.isProxyEnabled = completed
//            performRequest()
//
//        }
//
//        func performRequest() {
//
//            checkTokenExpiryDate()
//            assert(KeychainService.loadAccessToken() != nil, "Failed to load access_token")
//            let parameters = ["access_token": (KeychainService.loadAccessToken()! as String)]//: SERVER_URLS.CLIENT_ID, "client_secret": SERVER_URLS.CLIENT_SECRET, "grant_type": "password", "username": "\(username)", "password": "\(password)"]
//            let url = URL(string: userID.isEmpty ? SERVER_URLS.CURRENT_USER_URL : SERVER_URLS.USER_URL + userID)!
//
//            sessionManager.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON(completionHandler: {
//                response in
//                if let error = response.result.error as? AFError {
//
//                    switch error {
//                    case .invalidURL(let url):
//                        print("Invalid URL: \(url) - \(error.localizedDescription)")
//                    case .parameterEncodingFailed(let reason):
//                        print("Parameter encoding failed: \(error.localizedDescription)")
//                        print("Failure Reason: \(reason)")
//                    case .multipartEncodingFailed(let reason):
//                        print("Multipart encoding failed: \(error.localizedDescription)")
//                        print("Failure Reason: \(reason)")
//                    case .responseValidationFailed(let reason):
//                        print("Response validation failed: \(error.localizedDescription)")
//                        print("Failure Reason: \(reason)")
//
//                        switch reason {
//                        case .dataFileNil, .dataFileReadFailed:
//                            print("Downloaded file could not be read")
//                        case .missingContentType(let acceptableContentTypes):
//                            print("Content Type Missing: \(acceptableContentTypes)")
//                        case .unacceptableContentType(let acceptableContentTypes, let responseContentType):
//                            print("Response content type: \(responseContentType) was unacceptable: \(acceptableContentTypes)")
//                        case .unacceptableStatusCode(let code):
//                            print("Response status code was unacceptable: \(code)")
//                        }
//                    case .responseSerializationFailed(let reason):
//                        print("Response serialization failed: \(error.localizedDescription)")
//                        print("Failure Reason: \(reason)")
//                    }
//                } else {
//                    let statusCode  = response.response?.statusCode
//                    if 200...299 ~= statusCode! {
//                        if let json = try? JSON(data: response.data!) {
//                            for attr in json {
//                                print("\(attr.0): \(attr.1.stringValue)")
//                            }
//                            completion(json)
//                        }
//                    } else if 400...499 ~= statusCode! {
//                        if let json = try? JSON(data: response.data!) {
//                            for attr in json {
//                                print("\(attr.0): \(attr.1.stringValue)")
//                            }
//                            completion(json)
//                        }
//                    }
//                }
//            })
//        }
//    }
//
//    func requestSMSValidationCode(phoneNumber: String, completion: @escaping (JSON?) -> ()) {
//        checkForReachability {
//            completed in
//            self.isProxyEnabled = completed
//            performRequest()
//        }
//
//        func performRequest() {
//            let parameters = ["phone_number": phoneNumber]
//            print(parameters)
//            let url = URL(string: SERVER_URLS.TOKEN_URL)!//TODO Change to SMSValidationURL
//            sessionManager.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON(completionHandler: {
//                response in
//                if let error = response.result.error as? AFError {
//                    tokenState = .Error
//                    switch error {
//                    case .invalidURL(let url):
//                        print("Invalid URL: \(url) - \(error.localizedDescription)")
//                    case .parameterEncodingFailed(let reason):
//                        print("Parameter encoding failed: \(error.localizedDescription)")
//                        print("Failure Reason: \(reason)")
//                    case .multipartEncodingFailed(let reason):
//                        print("Multipart encoding failed: \(error.localizedDescription)")
//                        print("Failure Reason: \(reason)")
//                    case .responseValidationFailed(let reason):
//                        print("Response validation failed: \(error.localizedDescription)")
//                        print("Failure Reason: \(reason)")
//
//                        switch reason {
//                        case .dataFileNil, .dataFileReadFailed:
//                            print("Downloaded file could not be read")
//                        case .missingContentType(let acceptableContentTypes):
//                            print("Content Type Missing: \(acceptableContentTypes)")
//                        case .unacceptableContentType(let acceptableContentTypes, let responseContentType):
//                            print("Response content type: \(responseContentType) was unacceptable: \(acceptableContentTypes)")
//                        case .unacceptableStatusCode(let code):
//                            print("Response status code was unacceptable: \(code)")
//                        }
//                    case .responseSerializationFailed(let reason):
//                        print("Response serialization failed: \(error.localizedDescription)")
//                        print("Failure Reason: \(reason)")
//                    }
//                } else {
//                    let statusCode  = response.response?.statusCode
//                    var json: JSON?
//                    if 200...299 ~= statusCode! {
//                        if let receivedJSON = try? JSON(data: response.data!) {
//                            for attr in receivedJSON {
//                                print("\(attr.0): \(attr.1.stringValue)")
//                            }
//                            json = receivedJSON
//                        }
//                    } else if 400...499 ~= statusCode! {
//                        if let json = try? JSON(data: response.data!) {
//                            for attr in json {
//                                print("\(attr.0): \(attr.1.stringValue)")
//                            }
//                        }
//                    }
//                    completion(json)
//                }
//            })
//        }
//    }
//
//    func userExists(phoneNumber: String, completion: @escaping (JSON?) -> ()) {
//        checkForReachability {
//            completed in
//            self.isProxyEnabled = completed
//            performRequest()
//        }
//
//        func performRequest() {
//
//        }
//    }
//
//    func uploadUserImage(image: UIImage, completion: @escaping (JSON?) -> ()) {
//        checkForReachability {
//            completed in
//            self.isProxyEnabled = completed
//            performRequest()
//        }
//
//        func performRequest() {
//
//        }
//    }
//
//    func recoverPassword(_ password: String, completion: @escaping (JSON?) -> ()) {
//        checkForReachability {
//            completed in
//            self.isProxyEnabled = completed
//            performRequest()
//        }
//
//        func performRequest() {
//
//        }
//    }
//
}

