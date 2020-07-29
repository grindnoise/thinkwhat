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
    
    func cancelAllRequests()
    func login(_ auth: AuthVariant, username: String?, password: String?, token: String?, completion: @escaping (TokenState) -> ())
    func logout(completion: @escaping (TokenState) -> ())
    func getUserData(completion: @escaping(JSON?, Error?)->())
    func profileNeedsUpdate(completion: @escaping (Bool? , Error?) -> ())//If Profile was manualy edited -> true
    func updateUserProfile(data: [String: Any], completion: @escaping(JSON?, Error?) -> ())
    func isUsernameEmailAvailable(email: String, username: String, completion: @escaping(Bool?, Error?)->())
    func getEmailConfirmationCode(completion: @escaping(JSON?, Error?)->())
    func getEmailVerified(completion: @escaping(Bool?, Error?)->())
    func signUp(email: String, password: String, username: String, completion: @escaping (Error?) -> ())
    func initialLoad(completion: @escaping(JSON?, Error?)->())
    func loadSurveyCategories(completion: @escaping(JSON?, Error?)->())
    func loadSurveys(type: APIManager.SurveyType, completion: @escaping(JSON?, Error?)->())
    func loadSurvey(survey: ShortSurvey, completion: @escaping(JSON?, Error?)->())
    func loadTotalSurveysCount(completion: @escaping(JSON?, Error?)->())
    func loadSurveysByCategory(categoryID: Int, completion: @escaping(JSON?, Error?)->())
    func markFavorite(mark: Bool, survey: ShortSurvey, completion: @escaping(JSON?, Error?)->())
    func postSurvey(survey: FullSurvey, completion: @escaping(JSON?, Error?)->())
    func rejectSurvey(survey: FullSurvey, completion: @escaping(JSON?, Error?)->())
    func postResult(result: [String: Int], completion: @escaping(JSON?, Error?)->())
    func postClaim(surveyID: Int, claimID: Int, completion: @escaping(JSON?, Error?)->())
    
    //    func requestUserData(socialNetwork: AuthVariant, completion: @escaping (JSON) -> ())
    func downloadImage(url: String, percentageClosure: @escaping (CGFloat) -> (), completion: @escaping (UIImage?, Error?) -> ())
    func downloadImage(url: String, completion: @escaping (UIImage?, Error?) -> ())
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
    
    public enum SurveyType: String {
        case Top,New,All,Own,Favorite, Hot, HotExcept
        
        func getURL() -> URL {
            let url = URL(string: SERVER_URLS.BASE)!//.appendingPathComponent(SERVER_URLS.GET_CONFIRMATION_CODE)
            switch self {
            case .Top:
                return url.appendingPathComponent(SERVER_URLS.SURVEYS_TOP)
            case .New:
                return url.appendingPathComponent(SERVER_URLS.SURVEYS_NEW)
            case .All:
                return url.appendingPathComponent(SERVER_URLS.SURVEYS_ALL)
            case .Own:
                return url.appendingPathComponent(SERVER_URLS.SURVEYS_OWN)
            case .Favorite:
                return url.appendingPathComponent(SERVER_URLS.SURVEYS_FAVORITE)
            case .Hot:
                return url.appendingPathComponent(SERVER_URLS.SURVEYS_HOT)
            case .HotExcept:
                return url.appendingPathComponent(SERVER_URLS.SURVEYS_HOT_EXCEPT)
            }
        }
    }
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
        let configuration = Alamofire.SessionManager.default.session.configuration
        configuration.timeoutIntervalForRequest = 10
//        configuration.timeoutIntervalForResource = 10
        return Alamofire.SessionManager(configuration: configuration)
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
        let url = URL(string: SERVER_URLS.BASE)!.appendingPathComponent(SERVER_URLS.CURRENT_TIME)
        Alamofire.SessionManager.default.request(url, method: .get, parameters: [:], encoding: URLEncoding(), headers: nil).responseJSON(completionHandler: {
            response in
            var state = ApiReachabilityState.None
            if let _error = response.result.error as? AFError {
                if _error.responseCode == NSURLErrorTimedOut {
                    print(_error.responseCode!)
                }
            } else if response.response != nil {
                state = .Reachable
            }
            apiReachability = state
            completion(state)
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
            if attr.0 == "error_description"{
                if let errorDesc = attr.1.stringValue.lowercased() as? String {
                    if errorDesc.contains(DjangoError.InvalidGrant.rawValue) {
                        _tokenState = .WrongCredentials
                    } else if errorDesc.contains(DjangoError.AccessDenied.rawValue) {
                        _tokenState = .AccessDenied
                    } else if errorDesc.contains(DjangoError.Authentication.ConnectionFailed.rawValue) {
                        _tokenState = .ConnectionError
                    } else {
                        fatalError("func parseDjangoError failed to downcast attr.1.string")
                    }
                    //            case "error_description":
                    //                print(attr.1.stringValue)
                    //                switch attr.1.stringValue {
                    //                case DjangoError.InvalidGrant.rawValue:
                    //                    _tokenState = .WrongCredentials
                    //                default:
                    //                    _tokenState = .Unassigned
                    //                }
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
    func getEmailConfirmationCode(completion: @escaping(JSON?, Error?)->()) {
        var error: Error?
        
        checkForReachability {
            reachable in
            if reachable == .Reachable {
                self.checkTokenExpired() {
                    success, error in
                    if error != nil {
                        completion(nil, error)
                    } else if success {
                        self._performRequest(url: URL(string: SERVER_URLS.BASE)!.appendingPathComponent(SERVER_URLS.GET_CONFIRMATION_CODE), httpMethod: .get, parameters: nil, encoding: URLEncoding.default, completion: completion)
                    }
                }
            } else {
                error = NSError(domain:"", code:523, userInfo:[ NSLocalizedDescriptionKey: "Server is unreachable"]) as Error
                completion(nil, error)
            }
        }
    }
    
    func getUserData(completion: @escaping(JSON?, Error?)->()) {
        var error: Error?
        
        checkForReachability {
            reachable in
            if reachable == .Reachable {
                self.checkTokenExpired() {
                    success, error in
                    if error != nil {
                        completion(nil, error)
                    } else if success {
                        self._performRequest(url: URL(string: SERVER_URLS.BASE)!.appendingPathComponent(SERVER_URLS.CURRENT_USER), httpMethod: .get, parameters: nil, encoding: URLEncoding.default, completion: completion)
                    }
                }
            } else {
                error = NSError(domain:"", code:523, userInfo:[ NSLocalizedDescriptionKey: "Server is unreachable"]) as Error
                completion(nil, error)
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
                                print(json.stringValue)
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
        temporaryTokenToRevoke = KeychainService.loadAccessToken()! as String
        AppData.shared.eraseData()
        Surveys.shared.eraseData()
        FBManager.performLogout()
        VKManager.performLogout()
        
        checkForReachability {
            reachable in
            if reachable == .Reachable {
                performRequest()
            } else {
                completion(.ConnectionError)
            }
        }
        
        func performRequest() {
            if !temporaryTokenToRevoke.isEmpty {
                let parameters = ["client_id": SERVER_URLS.CLIENT_ID, "client_secret": SERVER_URLS.CLIENT_SECRET, "token": temporaryTokenToRevoke]
                let url = URL(string: SERVER_URLS.BASE)!.appendingPathComponent(SERVER_URLS.TOKEN_REVOKE)
                //                AppData.shared.eraseData()
                //                Surveys.shared.eraseData()
                //                FBManager.performLogout()
                //                VKManager.performLogout()
                sessionManager.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON() {
                    response in
                    if response.result.isFailure {
                        print(response.result.description)
                        //                        delay(seconds: 5) { performRequest() }
                        temporaryTokenToRevoke = ""
                    }
                    if let error = response.result.error as? AFError {
                        self.parseAFError(error)
                    } else {
                        if let statusCode  = response.response?.statusCode {
                            if 200...299 ~= statusCode {
                                print("LOGGED OUT")
                                temporaryTokenToRevoke = ""
                                _tokenState = .Revoked
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
                            //                            TemporaryUserCredentials.shared.importJson(json)
                            self.login(.Username, username: username, password: password, token: nil, completion: { (state) in
                                tokenState = state
                            })
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
    
    func profileNeedsUpdate(completion: @escaping(Bool?, Error?)->()) {
        var error: Error?
        
        checkForReachability {
            reachable in
            if reachable == .Reachable {
                self.checkTokenExpired() {
                    success, error in
                    if error != nil {
                        completion(nil, error)
                    } else if success {
                        self._performRequest(url: URL(string: SERVER_URLS.BASE)!.appendingPathComponent(SERVER_URLS.PROFILE_NEEDS_UPDATE), searchString: "needs_update", httpMethod: .get, completion: completion)
                    }
                }
            } else {
                error = NSError(domain:"", code:523 , userInfo:[ NSLocalizedDescriptionKey: "Server is unreachable"]) as Error
                completion(nil, error)
            }
        }
    }
    
    func isUsernameEmailAvailable(email: String, username: String, completion: @escaping(Bool?, Error?)->()) {
        var error: Error?
        
        checkForReachability {
            reachable in
            if reachable == .Reachable {
                self.checkTokenExpired() {
                    success, error in
                    if error != nil {
                        completion(nil, error)
                    } else if success {
                        self._performRequest(url: URL(string: SERVER_URLS.BASE)!.appendingPathComponent(email.isEmpty ? SERVER_URLS.USERNAME_EXISTS : SERVER_URLS.EMAIL_EXISTS), searchString: "exists", httpMethod: .get, completion: completion)
                    }
                }
            } else {
                error = NSError(domain:"", code:523 , userInfo:[ NSLocalizedDescriptionKey: "Server is unreachable"]) as Error
                completion(nil, error)
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
                self.checkTokenExpired() {
                    success, error in
                    if error != nil {
                        completion(nil, error)
                    } else if success {
                        performRequest()
                    }
                }
            } else {
                error = NSError(domain:"", code:523, userInfo:[ NSLocalizedDescriptionKey: "Server is unreachable"]) as Error
                completion(nil, error!)
            }
        }
        
        func performRequest() {
            
            let url = URL(string: SERVER_URLS.BASE)!.appendingPathComponent(SERVER_URLS.PROFILES + AppData.shared.userProfile.ID! + "/")
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
                _performRequest(url: url, httpMethod: .patch, parameters: data, encoding: JSONEncoding.default, completion: completion)
            }
        }
    }
    
    func getEmailVerified(completion: @escaping (Bool?, Error?) -> ()) {
        var error:              Error?
        var isEmailVerified:    Bool?
        
        checkForReachability {
            reachable in
            if reachable == .Reachable {
                self.checkTokenExpired() {
                    success, error in
                    if error != nil {
                        completion(nil, error)
                    } else if success {
                        self._performRequest(url: URL(string: SERVER_URLS.BASE)!.appendingPathComponent(SERVER_URLS.GET_EMAIL_VERIFIED), searchString: DjangoVariables.UserProfile.isEmailVerified, httpMethod: .get, completion: completion)
                    }
                }
            } else {
                error = NSError(domain:"", code:523 , userInfo:[ NSLocalizedDescriptionKey: "Server is unreachable"]) as Error
                completion(isEmailVerified, error)
            }
        }
    }
    
    private func checkTokenExpired(completion: @escaping (Bool, Error?) -> ()) {
        var success = true
        var error: Error?
        if let expString = KeychainService.loadTokenExpireDateTime() as String? {
            let expiryDate = expString.toDateTime()
            if Date() >= expiryDate {
                tokenState = .Expired
                refreshAccessToken(completion: {
                    _tokenState in
                    tokenState = _tokenState
                    if _tokenState != TokenState.Received {
                        success = false
                        error = NSError(domain:"", code:404, userInfo:[ NSLocalizedDescriptionKey: "Error refreshing access token"]) as Error
                    }
                    completion(success, error)
                })
            } else {
                completion(success, error)
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
            let url = URL(string: SERVER_URLS.BASE)!.appendingPathComponent(SERVER_URLS.TOKEN)
            sessionManager.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON(completionHandler: {
                response in
                var _tokenState = TokenState.Error
                if let _error = response.result.error as? AFError {
                    let error = NSError(domain:"", code:404, userInfo:[ NSLocalizedDescriptionKey: self.parseAFError(_error)]) as Error
                    print(error.localizedDescription)
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
    
    func initialLoad(completion: @escaping(JSON?, Error?)->()) {
        var error: Error?
        
        checkForReachability {
            reachable in
            if reachable == .Reachable {
                self.checkTokenExpired() {
                    success, error in
                    if error != nil {
                        completion(nil, error)
                    } else if success {
                        self._performRequest(url: URL(string: SERVER_URLS.BASE)!.appendingPathComponent(SERVER_URLS.APP_LAUNCH), httpMethod: .get, parameters: nil, encoding: URLEncoding.default, completion: completion)
                    }
                }
            } else {
                error = NSError(domain:"", code:523, userInfo:[ NSLocalizedDescriptionKey: "Server is unreachable"]) as Error
                completion(nil, error!)
            }
        }
    }
    
    func loadSurveys(type: APIManager.SurveyType, completion: @escaping(JSON?, Error?)->()) {
        var error: Error?
        var httpMethod: HTTPMethod = .get
        var url: URL = type.getURL()
//        var encoding
        
        checkForReachability {
            reachable in
            if reachable == .Reachable {
                self.checkTokenExpired() {
                    success, error in
                    if error != nil {
                        completion(nil, error)
                    } else if success {
                        var parameters: [String: [Any]]?
                        if type == .Hot {
//                            var list: [Int] = []
//                            if !Surveys.shared.stackObjects.isEmpty {
//                                list = Surveys.shared.stackObjects.filter({ $0.ID != nil }).map(){ $0.ID!}
//                            }
//                            if let _id = Surveys.shared.currentHotSurvey?.ID {
//                                list.append(_id)
//                            }
//                            if !list.isEmpty {
//                                parameters = list.asParameters(arrayParametersKey: "ids") as! [String : [Any]]//["ids": ["df", "sdf"]]
//                                httpMethod = .post
//                                url = APIManager.SurveyType.HotExcept.getURL()
//                            }
                        }
//                        parameters = nil
                        self._performRequest(url: url, httpMethod: httpMethod, parameters: parameters, encoding: JSONEncoding.default, completion: completion)
                    }
                }
            } else {
                error = NSError(domain:"", code:523, userInfo:[ NSLocalizedDescriptionKey: "Server is unreachable"]) as Error
                completion(nil, error!)
            }
        }
    }
   
    
    func loadSurveyCategories(completion: @escaping(JSON?, Error?)->()) {
//        var json: JSON?
        var error: Error?
        
        checkForReachability {
            reachable in
            if reachable == .Reachable {
                self.checkTokenExpired() {
                    success, error in
                    if error != nil {
                        completion(nil, error)
                    } else if success {
                        self._performRequest(url: URL(string: SERVER_URLS.BASE)!.appendingPathComponent(SERVER_URLS.CATEGORIES), httpMethod: .get, parameters: nil, encoding: JSONEncoding.default, completion: completion)
                    }
                }
            } else {
                error = NSError(domain:"", code:523, userInfo:[ NSLocalizedDescriptionKey: "Server is unreachable"]) as Error
                completion(nil, error!)
            }
        }
    }
    
    func loadTotalSurveysCount(completion: @escaping(JSON?, Error?)->()) {
        var error: Error?
        
        checkForReachability {
            reachable in
            if reachable == .Reachable {
                self.checkTokenExpired() {
                    success, error in
                    if error != nil {
                        completion(nil, error)
                    } else if success {
                        self._performRequest(url: URL(string: SERVER_URLS.BASE)!.appendingPathComponent(SERVER_URLS.SURVEYS_TOTAL_COUNT), httpMethod: .get, completion: completion)
                    }
                }
            } else {
                error = NSError(domain:"", code:523, userInfo:[ NSLocalizedDescriptionKey: "Server is unreachable"]) as Error
                completion(nil, error!)
            }
        }
    }
    
    func loadSurveysByCategory(categoryID: Int, completion: @escaping(JSON?, Error?)->()) {
        var error: Error?
        
        checkForReachability {
            reachable in
            if reachable == .Reachable {
                self.checkTokenExpired() {
                    success, error in
                    if error != nil {
                        completion(nil, error)
                    } else if success {
                        self._performRequest(url: URL(string: SERVER_URLS.BASE)!.appendingPathComponent(SERVER_URLS.SURVEYS_BY_CATEGORY), httpMethod: .get, parameters: ["category_id": categoryID], encoding: URLEncoding.default, completion: completion)
                    }
                }
            } else {
                error = NSError(domain:"", code:523, userInfo:[ NSLocalizedDescriptionKey: "Server is unreachable"]) as Error
                completion(nil, error!)
            }
        }
    }
    
    func loadSurvey(survey: ShortSurvey, completion: @escaping(JSON?, Error?)->()) {
        var error: Error?
        
        checkForReachability {
            reachable in
            if reachable == .Reachable {
                self.checkTokenExpired() {
                    success, error in
                    if error != nil {
                        completion(nil, error)
                    } else if success {
                        self._performRequest(url: URL(string: SERVER_URLS.BASE)!.appendingPathComponent(SERVER_URLS.SURVEYS + "\(survey.ID)/"), httpMethod: .get, parameters: nil, encoding: URLEncoding.default, completion: completion)
                    }
                }
            } else {
                error = NSError(domain:"", code:523, userInfo:[ NSLocalizedDescriptionKey: "Server is unreachable"]) as Error
                completion(nil, error!)
            }
        }
    }
    
    func markFavorite(mark: Bool, survey: ShortSurvey, completion: @escaping(JSON?, Error?)->()) {
        var error: Error?
        checkForReachability {
            reachable in
            if reachable == .Reachable {
                self.checkTokenExpired() {
                    success, error in
                    if error != nil {
                        completion(nil, error!)
                    } else if success {
                        self._performRequest(url: URL(string: SERVER_URLS.BASE)!.appendingPathComponent(mark ? SERVER_URLS.SURVEYS_ADD_FAVORITE : SERVER_URLS.SURVEYS_REMOVE_FAVORITE), httpMethod: .get, parameters: ["survey_id": survey.ID], encoding: URLEncoding.default, completion: completion)
                    }
                }
            } else {
                error = NSError(domain:"", code:523, userInfo:[ NSLocalizedDescriptionKey: "Server is unreachable"]) as Error
                completion(nil, error!)
            }
        }
    }
    
    func postSurvey(survey: FullSurvey, completion: @escaping(JSON?, Error?)->()) {
        var dict = survey.dict
        var json: JSON?
        var error: Error?
        
        checkForReachability {
            reachable in
            if reachable == .Reachable {
                self.checkTokenExpired() {
                    success, error in
                    if error != nil {
                        completion(nil, error!)
                    } else if success {
                        performRequest()
                    }
                }
            } else {
                error = NSError(domain:"", code:523, userInfo:[ NSLocalizedDescriptionKey: "Server is unreachable"]) as Error
                completion(nil, error!)
            }
        }
        
        func performRequest() {
            var url = URL(string: SERVER_URLS.BASE)!.appendingPathComponent(SERVER_URLS.SURVEYS)
            let images = dict.removeValue(forKey: "media") as? [[UIImage: String]]
            
            _performRequest(url: url, httpMethod: .post, parameters: dict, encoding: JSONEncoding.default) {
                _json, _error in
                if _error != nil {
                    error = _error
                    completion(json, error)
                } else if _json != nil {
                    json = _json
                    
                    if images != nil, images?.count != 0 {
                        //Upload images
                        let surveyID = json!["id"].intValue
                        let headers: HTTPHeaders = [
                            "Authorization": "Bearer " + (KeychainService.loadAccessToken()! as String) as String,
                            "Content-Type": "application/json"
                        ]
                        url = URL(string: SERVER_URLS.BASE)!.appendingPathComponent(SERVER_URLS.SURVEYS_MEDIA)
                        var uploadError: Error?
                        for image in images! {
                            Alamofire.upload(multipartFormData: { multipartFormData in
                                //                            for image in images! {
                                var imgExt: FileFormat = .Unknown
                                var imageData: Data?
                                if let data = image.keys.first!.jpegData(compressionQuality: 1) {
                                    imageData = data
                                    imgExt = .JPEG
                                } else if let data = image.keys.first!.pngData() {
                                    imageData = data
                                    imgExt = .PNG
                                }
                                multipartFormData.append(imageData!, withName: "image", fileName: "\(AppData.shared.userProfile.ID!).\(imgExt.rawValue)", mimeType: "jpg/png")
                                multipartFormData.append("\(surveyID)".data(using: .utf8)!, withName: "survey")
                                if !(image.values.first?.isEmpty)! {
                                    multipartFormData.append(image.values.first!.data(using: .utf8)!, withName: "title")
                                }
                            }, usingThreshold: SessionManager.multipartFormDataEncodingMemoryThreshold, to: url, method: .post, headers: headers) {
                                result in
                                switch result {
                                case .failure(let _error):
                                    uploadError = _error
                                //                                completion(json, error)
                                case .success(request: let upload, streamingFromDisk: _, streamFileURL: _):
                                    upload.uploadProgress(closure: { (progress) in
                                        print("Upload Progress: \(progress.fractionCompleted)")
                                    })
                                    upload.responseJSON(completionHandler: { (response) in
                                        if response.result.isFailure {
                                            uploadError = NSError(domain:"", code:404, userInfo:[ NSLocalizedDescriptionKey: response.result.debugDescription]) as Error
                                        }
                                        if let _error = response.result.error as? AFError {
                                            uploadError = self.parseAFError(_error)
                                        } else {
                                            if let statusCode  = response.response?.statusCode{
                                                if 200...299 ~= statusCode {
                                                    do {
                                                        json = try JSON(data: response.data!)
                                                    } catch let _error {
                                                        uploadError = _error
                                                    }
                                                    
                                                    //TODO save local
                                                } else if 400...499 ~= statusCode {
                                                    do {
                                                        let errorJSON = try JSON(data: response.data!)
                                                        uploadError = NSError(domain:"", code:404, userInfo:[ NSLocalizedDescriptionKey: errorJSON.rawString()!]) as Error
                                                        print(uploadError!)
                                                    } catch let _error {
                                                        uploadError = _error
                                                    }
                                                }
                                            }
                                        }
                                    })
                                }
                            }
                        }
                        error = uploadError
                        completion(json, error)
                    } else {
                        completion(json, error)
                    }
                }
            }



//
//
//            if let images = dict["media"] as? [[UIImage: String]], images.count != 0 {
//                dict.removeValue(forKey: "images")
//                Alamofire.upload(multipartFormData: { multipartFormData in
//                    for image in images {
//                        var imgExt: FileFormat = .Unknown
//                        var imageData: Data?
//                        if let data = image.keys.first!.jpegData(compressionQuality: 1) {
//                            imageData = data
//                            imgExt = .JPEG
//                        } else if let data = image.keys.first!.pngData() {
//                            imageData = data
//                            imgExt = .PNG
//                        }
//                        multipartFormData.append(imageData!, withName: "media.image", fileName: "\(AppData.shared.userProfile.ID!).\(imgExt.rawValue)", mimeType: "jpg/png")
//                        multipartFormData.append("\(image.values.first!)".data(using: .utf8)!, withName: "media.title")
//                    }
//
//                    for (key, value) in dict {
//                        if value is String || value is Int {
//                            multipartFormData.append("\(value)".data(using: .utf8)!, withName: key)
//                        }
//                    }
//                }, usingThreshold: SessionManager.multipartFormDataEncodingMemoryThreshold, to: url, method: .patch, headers: headers) {
//                    result in
//                    switch result {
//                    case .failure(let _error):
//                        error = _error
//                        completion(json, error)
//                    case .success(request: let upload, streamingFromDisk: _, streamFileURL: _):
//                        upload.uploadProgress(closure: { (progress) in
//                            print("Upload Progress: \(progress.fractionCompleted)")
//                        })
//                        upload.responseJSON(completionHandler: { (response) in
//                            if response.result.isFailure {
//                                error = NSError(domain:"", code:404, userInfo:[ NSLocalizedDescriptionKey: response.result.debugDescription]) as Error
//                            }
//                            if let _error = response.result.error as? AFError {
//                                error = self.parseAFError(_error)
//                            } else {
//                                if let statusCode  = response.response?.statusCode{
//                                    if 200...299 ~= statusCode {
//                                        do {
//                                            json = try JSON(data: response.data!)
//                                        } catch let _error {
//                                            error = _error
//                                        }
//                                    } else if 400...499 ~= statusCode {
//                                        do {
//                                            let errorJSON = try JSON(data: response.data!)
//                                            error = NSError(domain:"", code:404, userInfo:[ NSLocalizedDescriptionKey: errorJSON.rawString()]) as Error
//                                        } catch let _error {
//                                            error = _error
//                                        }
//                                    }
//                                }
//                                completion(json, error)
//                            }
//                        })
//                    }
//                }
//            } else {
//                _performRequest(url: url, httpMethod: .post, parameters: dict, encoding: JSONEncoding.default, completion: completion)
//            }
        }
    }
    
    func postResult(result: [String: Int], completion: @escaping(JSON?, Error?)->()) {
        var error: Error?
        checkForReachability {
            reachable in
            if reachable == .Reachable {
                self.checkTokenExpired() {
                    success, error in
                    if error != nil {
                        completion(nil, error!)
                    } else if success {
                        self._performRequest(url: URL(string: SERVER_URLS.BASE)!.appendingPathComponent(SERVER_URLS.SURVEYS_RESULTS), httpMethod: .post, parameters: result, encoding: JSONEncoding.default, completion: completion)
                    }
                }
            } else {
                error = NSError(domain:"", code:523, userInfo:[ NSLocalizedDescriptionKey: "Server is unreachable"]) as Error
                completion(nil, error!)
            }
        }
    }
    
    func rejectSurvey(survey: FullSurvey, completion: @escaping(JSON?, Error?)->()) {
        checkForReachability {
            reachable in
            if reachable == .Reachable {
                self.checkTokenExpired() {
                    success, error in
                    if error != nil {
                        print(error!)
                    } else if success {
                        var parameters: [String: Any] = ["survey": survey.ID! as Any]
                        if Surveys.shared.stackObjects.count <= MIN_STACK_SIZE {
                            var list = Surveys.shared.stackObjects.filter({ $0.ID != nil }).map(){ $0.ID!}
                            if !list.isEmpty {
                                let dict = list.asParameters(arrayParametersKey: "ids") as! [String : Any]
                                parameters.merge(dict) {(current, _) in current}
                            }
                        }
                        self._performRequest(url: URL(string: SERVER_URLS.BASE)!.appendingPathComponent(SERVER_URLS.SURVEYS_REJECT), httpMethod: .post, parameters: parameters, encoding: JSONEncoding.default, completion: completion)
                    }
                }
            } else {
                print(NSError(domain:"", code:523, userInfo:[ NSLocalizedDescriptionKey: "Server is unreachable"]) as Error)
            }
        }
    }
    
    func postClaim(surveyID: Int, claimID: Int, completion: @escaping(JSON?, Error?)->()) {
        var error: Error?
        checkForReachability {
            reachable in
            if reachable == .Reachable {
                self.checkTokenExpired() {
                    success, error in
                    if error != nil {
                        completion(nil, error!)
                    } else if success {
                        self._performRequest(url: URL(string: SERVER_URLS.BASE)!.appendingPathComponent(SERVER_URLS.SURVEYS_CLAIM), httpMethod: .post, parameters: ["survey": surveyID, "claim": claimID], encoding: JSONEncoding.default, completion: completion)
                    }
                }
            } else {
                error = NSError(domain:"", code:523, userInfo:[ NSLocalizedDescriptionKey: "Server is unreachable"]) as Error
                completion(nil, error!)
            }
        }
    }
    
    private func _performRequest(url: URL, httpMethod: HTTPMethod,  parameters: Parameters? = nil, encoding: ParameterEncoding = JSONEncoding.default, completion: @escaping(JSON?, Error?)->()) {
        var json: JSON?
        var error: Error?
        let headers: HTTPHeaders = [
            "Authorization": "Bearer " + (KeychainService.loadAccessToken()! as String) as String,
            "Content-Type": "application/json"
        ]

        sessionManager.request(url, method: httpMethod, parameters: parameters, encoding: encoding, headers: headers).responseJSON() {
            response in
            if response.result.isFailure {
                print(response.result.debugDescription)
                error = NSError(domain:"", code:404, userInfo:[ NSLocalizedDescriptionKey: response.result.debugDescription]) as Error
            } else {
                if let _error = response.result.error as? AFError {
                    error = self.parseAFError(_error)
                } else {
                    if let statusCode  = response.response?.statusCode{
                        if 200...299 ~= statusCode {
                            do {
                                json = try JSON(data: response.data!)
                            } catch let _error {
                                error = NSError(domain:"", code:404, userInfo:[ NSLocalizedDescriptionKey: _error.localizedDescription]) as Error
                            }
                        } else if 400...499 ~= statusCode {
                            do {
                                let errorJSON = try JSON(data: response.data!)
                                error = NSError(domain:"", code:404, userInfo:[ NSLocalizedDescriptionKey: errorJSON.rawString()!]) as Error
                                print(error!.localizedDescription)
                            } catch let _error {
                                error = NSError(domain:"", code:404, userInfo:[ NSLocalizedDescriptionKey: _error.localizedDescription]) as Error
                            }
                        }
                    }
                }
            }
            completion(json, error)
        }
    }
    
    private func _performRequest(url: URL, searchString: String, httpMethod: HTTPMethod,  parameters: Parameters? = nil, encoding: ParameterEncoding = JSONEncoding.default, completion: @escaping(Bool?, Error?)->()) {
        var flag: Bool?
        var error: Error?
        let headers: HTTPHeaders = [
            "Authorization": "Bearer " + (KeychainService.loadAccessToken()! as String) as String,
            "Content-Type": "application/json"
        ]
    
        sessionManager.request(url, method: httpMethod, parameters: parameters, encoding: encoding, headers: headers).responseJSON() {
            response in
            if response.result.isFailure {
                error = NSError(domain:"", code:404, userInfo:[ NSLocalizedDescriptionKey: response.result.description]) as Error
            } else {
                if let _error = response.result.error as? AFError {
                    error = self.parseAFError(_error)
                } else {
                    if let statusCode  = response.response?.statusCode{
                        if 200...299 ~= statusCode {
                            do {
                                let json = try JSON(data: response.data!)
                                for attr in json {
                                    if attr.0 ==  searchString {
                                        flag = attr.1.boolValue
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
            }
            completion(flag, error)
        }
    }
    
    func downloadImage(url urlString: String, percentageClosure: @escaping (CGFloat) -> (), completion: @escaping (UIImage?, Error?) -> ()) {
        
        var error: Error?
        var url: URL!
        if let _url = URL(string: urlString) {
            url = _url
        } else {
            error = NSError(domain:"", code:523, userInfo:[ NSLocalizedDescriptionKey: "Incorrect URL provided"]) as Error
            completion(nil, error!)
        }
        
        checkForReachability {
            reachable in
            if reachable == .Reachable {
                self.checkTokenExpired() {
                    success, error in
                    if error != nil {
                        completion(nil, error)
                    } else if success {
                        performRequest()
                    }
                }
            } else {
                error = NSError(domain:"", code:523, userInfo:[ NSLocalizedDescriptionKey: "Server is unreachable"]) as Error
                completion(nil, error!)
            }
        }
        
        func performRequest() {
            sessionManager.request(url).downloadProgress(closure: {
                progress in
                let prog = CGFloat(progress.fractionCompleted)
                percentageClosure(prog)
            }).response(completionHandler: {
                response in
                if let data = response.data { response.request?.url
                    if let image = UIImage(data: data) {
                        completion(image, nil)
                    } else {
                        //Image init failure
                        error = NSError(domain:"", code:523, userInfo:[ NSLocalizedDescriptionKey: "Image initialization failure"]) as Error
                        completion(nil, error)
                    }
                } else {
                    error = NSError(domain:"", code:523, userInfo:[ NSLocalizedDescriptionKey: "Image data error during download"]) as Error
                    completion(nil, error)
                }
            })
        }
    }
    
    func downloadImage(url urlString: String, completion: @escaping (UIImage?, Error?) -> ()) {
        var error: Error?
        var url: URL!
        if let _url = URL(string: urlString) {
            url = _url
        } else {
            error = NSError(domain:"", code:523, userInfo:[ NSLocalizedDescriptionKey: "Incorrect URL provided"]) as Error
            completion(nil, error!)
        }
        
        checkForReachability {
            reachable in
            if reachable == .Reachable {
                self.checkTokenExpired() {
                    success, error in
                    if error != nil {
                        completion(nil, error)
                    } else if success {
                        performRequest()
                    }
                }
            } else {
                error = NSError(domain:"", code:523, userInfo:[ NSLocalizedDescriptionKey: "Server is unreachable"]) as Error
                completion(nil, error!)
            }
        }
        
        func performRequest() {
            sessionManager.request(url).response(completionHandler: {
                response in
                if let data = response.data { response.request?.url
                    if let image = UIImage(data: data) {
                        completion(image, nil)
                    } else {
                        //Image init failure
                        error = NSError(domain:"", code:523, userInfo:[ NSLocalizedDescriptionKey: "Image initialization failure"]) as Error
                        completion(nil, error)
                    }
                } else {
                    error = NSError(domain:"", code:523, userInfo:[ NSLocalizedDescriptionKey: "Image data error during download"]) as Error
                    completion(nil, error)
                }
            })
        }
    }
    
//    private func _performRequest(url: URL, httpMethod: HTTPMethod,  parameters: Parameters? = nil, encoding: ParameterEncoding = JSONEncoding.default, completion: @escaping(Error?)->()) {
//        var error: Error?
//        let headers: HTTPHeaders = [
//            "Authorization": "Bearer " + (KeychainService.loadAccessToken()! as String) as String,
//            "Content-Type": "application/json"
//        ]
//
//        sessionManager.request(url, method: httpMethod, parameters: parameters, encoding: encoding, headers: headers).response() {
//            response in
//            if response.result.isFailure {
//                print(response.result.debugDescription)
//            }
//            if let _error = response.result.error as? AFError {
//                error = self.parseAFError(_error)
//            } else {
//                if let statusCode  = response.response?.statusCode{
//                    if 400...499 ~= statusCode {
//                        do {
//                            let errorJSON = try JSON(data: response.data!)
//                            error = NSError(domain:"", code:404, userInfo:[ NSLocalizedDescriptionKey: errorJSON.rawString()!]) as Error
//                        } catch let _error {
//                            error = NSError(domain:"", code:404, userInfo:[ NSLocalizedDescriptionKey: _error.localizedDescription]) as Error
//                        }
//                    }
//                }
//            }
//            completion(error)
//        }
//    }
    
    func cancelAllRequests() {
        self.sessionManager.session.getTasksWithCompletionHandler {
            (sessionDataTask, uploadData, downloadData) in
            sessionDataTask.forEach { $0.cancel() }
            uploadData.forEach { $0.cancel() }
            downloadData.forEach { $0.cancel() }
        }
    }
}

