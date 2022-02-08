////
////  APIManager.swift
////  Burb
////
////  Created by Pavel Bukharov on 26.04.2018.
////  Copyright © 2018 Pavel Bukharov. All rights reserved.
////
//
//import Foundation
//import Alamofire
//import SwiftyJSON
//
//protocol APIManagerProtocol {
//
//
//    func cancelAllRequests()
//    func login(_ auth: AuthVariant, username: String?, password: String?, token: String?, completion: @escaping (TokenState) -> ())
//    func logout(completion: @escaping (TokenState) -> ())
//    func getUserData(completion: @escaping(JSON?, Error?)->())
//    func profileNeedsUpdate(completion: @escaping (Bool? , Error?) -> ())//If Profile was manualy edited -> true
//    func updateUserProfile(data: [String: Any], completion: @escaping(JSON?, Error?) -> ())
//    func isUsernameEmailAvailable(email: String, username: String, completion: @escaping(Bool?, Error?)->())
//    func getEmailConfirmationCode(completion: @escaping(JSON?, Error?)->())
//    func getEmailVerified(completion: @escaping(Bool?, Error?)->())
//    func signUp(email: String, password: String, username: String, completion: @escaping (Error?) -> ())
//    func initialLoad(completion: @escaping(JSON?, Error?)->())
//    func loadSurveyCategories(completion: @escaping(JSON?, Error?)->())
//    func loadSurveys(type: APIManager.SurveyType, completion: @escaping(JSON?, Error?)->())
//    func loadSurvey(survey: SurveyRef, addViewCount: Bool, completion: @escaping(JSON?, Error?)->())
//    func loadTotalSurveysCount(completion: @escaping(JSON?, Error?)->())
//    func loadSurveysByCategory(categoryID: Int, completion: @escaping(JSON?, Error?)->())
//    func loadSurveysByOwner(userProfile: UserProfile, type: APIManager.SurveyType, completion: @escaping(JSON?, Error?)->())
//    func addFavorite(mark: Bool, survey: SurveyRef, completion: @escaping(JSON?, Error?)->())
//    func addViewCount(survey: SurveyRef, completion: @escaping(JSON?, Error?)->())
//    func updateSurveyStats(survey: SurveyRef, completion: @escaping(JSON?, Error?)->())
//    func postSurvey(survey: Survey, completion: @escaping(JSON?, Error?)->())
//    func rejectSurvey(survey: Survey, completion: @escaping(JSON?, Error?)->())
//    func postVote(result: [String: Int], completion: @escaping(JSON?, Error?)->())
//    func postClaim(survey: Survey, claimCategory: ClaimCategory, completion: @escaping(JSON?, Error?)->())
//    func getUserStats(userProfile: UserProfile, completion: @escaping(JSON?, Error?)->())
//    func subsribeToUserProfile(subscribe: Bool, userprofile: UserProfile, completion: @escaping(JSON?, Error?)->())
//    func getBalanceAndPrice()
//    //    func requestUserData(socialNetwork: AuthVariant, completion: @escaping (JSON) -> ())
//    func downloadImage(url: String, progressClosure: @escaping (CGFloat) -> (), completion: @escaping (UIImage?, Error?) -> ())
//    func downloadImage(url: String, completion: @escaping (UIImage?, Error?) -> ())
//    func getVoters(surveyID: Int, answerID: Int, userprofiles: [Int], completion: @escaping(JSON?, Error?)->())
//
//    func getTikTokEmbedHTML(url: URL, completion: @escaping(JSON?, Error?)->())
//    //    func pullUserData(_ userID: String, completion: @escaping (JSON) -> ())
//    //    func makeOrder(_ order: Order, completion: @escaping (JSON) -> ())
//    //    func requestSMSValidationCode(phoneNumber: String, completion: @escaping (JSON?) -> ())
//    //    func userExists(phoneNumber: String, completion: @escaping (JSON?) -> ())
//    //    func uploadUserImage(image: UIImage, completion: @escaping (JSON?) -> ())
//    //    func recoverPassword(_ password: String, completion: @escaping (JSON?) -> ())
//}
//
//protocol UserDataPreparatory: class {
//    static func prepareUserData(_ data: [String: Any]) -> [String: Any]
//}
//
//class APIManager: APIManagerProtocol {
//    struct CustomGetEncoding: ParameterEncoding {
//        func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
//            var request = try URLEncoding().encode(urlRequest, with: parameters)
//            request.url = URL(string: request.url!.absoluteString.replacingOccurrences(of: "%5B%5D=", with: "="))
//            return request
//        }
//    }
//    struct CustomPostEncoding: ParameterEncoding {
//        func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
//            var request = try URLEncoding().encode(urlRequest, with: parameters)
//            let httpBody = NSString(data: request.httpBody!, encoding: String.Encoding.utf8.rawValue)!
//            request.httpBody = httpBody.replacingOccurrences(of: "%5B%5D=", with: "=").data(using: .utf8)
//            return request
//        }
//    }
//
//    public enum SurveyType: String {
//        case Top,New,All,Own,Favorite, Hot, HotExcept, User, UserFavorite
//
//        func getURL() -> URL {
//            let url = URL(string: SERVER_URLS.BASE)!//.appendingPathComponent(SERVER_URLS.GET_CONFIRMATION_CODE)
//            switch self {
//            case .Top:
//                return url.appendingPathComponent(SERVER_URLS.SURVEYS_TOP)
//            case .New:
//                return url.appendingPathComponent(SERVER_URLS.SURVEYS_NEW)
//            case .All:
//                return url.appendingPathComponent(SERVER_URLS.SURVEYS_ALL)
//            case .Own:
//                return url.appendingPathComponent(SERVER_URLS.SURVEYS_OWN)
//            case .Favorite:
//                return url.appendingPathComponent(SERVER_URLS.SURVEYS_FAVORITE)
//            case .Hot:
//                return url.appendingPathComponent(SERVER_URLS.SURVEYS_HOT)
//                //            case .HotExcept:
//                //                return url.appendingPathComponent(SERVER_URLS.SURVEYS_HOT_EXCEPT)
//            case .User:
//                return url.appendingPathComponent(SERVER_URLS.SURVEYS_BY_OWNER)
//            case .UserFavorite:
//                return url.appendingPathComponent(SERVER_URLS.SURVEYS_FAVORITE_LIST_BY_OWNER)
//            default:
//                return url.appendingPathComponent(SERVER_URLS.SURVEYS_ALL)
//            }
//        }
//    }
//    private var isProxyEnabled: Bool? {
//        didSet {
//            if isProxyEnabled != nil && isProxyEnabled != oldValue {
//                if isProxyEnabled == true {
//                    var proxyDictionary = [AnyHashable: Any]()
//                    proxyDictionary[kCFNetworkProxiesHTTPProxy as String] = "68.183.56.239"
//                    proxyDictionary[kCFNetworkProxiesHTTPPort as String] = 8080
//                    proxyDictionary[kCFNetworkProxiesHTTPEnable as String] = 1
//                    proxyDictionary[kCFStreamPropertyHTTPSProxyHost as String] = "68.183.56.239"
//                    proxyDictionary[kCFStreamPropertyHTTPSProxyPort as String] = 8080
//                    AF.sessionConfiguration.timeoutIntervalForRequest = 15
//                    AF.sessionConfiguration.connectionProxyDictionary = proxyDictionary
//                } else {
//                    AF.sessionConfiguration.timeoutIntervalForRequest = 10
//                }
//            }
//        }
//    }
//
//    init() {
//        //TODO: - Read from UserDefaults
//        isProxyEnabled = false
//    }
//
//    private func checkForReachability(completion: @escaping(ApiReachabilityState) -> ()) {
//        let url = URL(string: SERVER_URLS.BASE)!.appendingPathComponent(SERVER_URLS.CURRENT_TIME)
//        AF.request(url, method: .get, parameters: [:], encoding: URLEncoding(), headers: nil).response { response in
//            var state = ApiReachabilityState.None
//            switch response.result {
//            case .success:
//                state = ApiReachabilityState.Reachable
//            case .failure(let error):
//                print(error.localizedDescription)
//            }
//            apiReachability = state
//            completion(state)
//        }
//    }
//
//    private func parseAFError(_ error: AFError) -> Error {
//        var errorDescription = ""
//        switch error {
//        case .invalidURL(let url):
//            errorDescription = ("Invalid URL: \(url) - \(error.localizedDescription)")
//        case .parameterEncodingFailed(let reason):
//            errorDescription = ("Parameter encoding failed: \(error.localizedDescription)")
//            errorDescription += ("Failure Reason: \(reason)")
//        case .multipartEncodingFailed(let reason):
//            errorDescription = ("Multipart encoding failed: \(error.localizedDescription)")
//            errorDescription += ("Failure Reason: \(reason)")
//        case .responseValidationFailed(let reason):
//            errorDescription = ("Response validation failed: \(error.localizedDescription)")
//            errorDescription += ("Failure Reason: \(reason)")
//
//            switch reason {
//            case .dataFileNil, .dataFileReadFailed:
//                errorDescription += ("Downloaded file could not be read")
//            case .missingContentType(let acceptableContentTypes):
//                errorDescription += ("Content Type Missing: \(acceptableContentTypes)")
//            case .unacceptableContentType(let acceptableContentTypes, let responseContentType):
//                errorDescription += ("Response content type: \(responseContentType) was unacceptable: \(acceptableContentTypes)")
//            case .unacceptableStatusCode(let code):
//                errorDescription += ("Response status code was unacceptable: \(code)")
//            case .customValidationFailed(let description):
//                errorDescription += ("Validation error: \(description.localizedDescription)")
//            }
//        case .responseSerializationFailed(let reason):
//            errorDescription = ("Response serialization failed: \(error.localizedDescription)")
//            errorDescription += ("Failure Reason: \(reason)")
//
//            switch reason {
//            case .customSerializationFailed(let error):
//                errorDescription += ("A custom response serializer failed due to error: \(error)")
//            case .decodingFailed(let error):
//                errorDescription += ("A DataDecoder failed to decode the response due to: \(error)")
//            case .inputDataNilOrZeroLength:
//                errorDescription += ("The server response contained no data or the data was zero length")
//            case .inputFileNil:
//                errorDescription += ("The file containing the server response did not exist")
//            case .inputFileReadFailed(let url):
//                errorDescription += ("The file containing the server response could not be read from the associated URL: \(url)")
//            case .invalidEmptyResponse(let type):
//                errorDescription += ("Generic serialization failed for an empty response that wasn’t type Empty but instead the associated type: \(type)")
//            case .jsonSerializationFailed(let error):
//                errorDescription += ("JSON serialization failed with an underlying system error: \(error)")
//            case .stringSerializationFailed(let encoding):
//                errorDescription += ("String serialization failed using the provided String.Encoding: \(encoding)")
//            }
//        default:
//            errorDescription += "Error: \(error.localizedDescription)"
//        }
//        return NSError(domain:"", code:523, userInfo:[ NSLocalizedDescriptionKey: errorDescription]) as Error
//    }
//
//    private func parseDjangoError(_ json: JSON) -> TokenState {
//        var _tokenState = TokenState.Unassigned
//        for attr in json {
//            if attr.0 == "error_description" {
////                if let errorDesc = attr.1.stringValue.lowercased() as? String {
//                let errorDesc = attr.1.stringValue.lowercased()
//                    if errorDesc.contains(DjangoError.InvalidGrant.rawValue) {
//                        _tokenState = .WrongCredentials
//                    } else if errorDesc.contains(DjangoError.AccessDenied.rawValue) {
//                        _tokenState = .AccessDenied
//                    } else if errorDesc.contains(DjangoError.Authentication.ConnectionFailed.rawValue) {
//                        _tokenState = .ConnectionError
//                    } else {
//                        print(attr.1.stringValue)
//                        fatalError("func parseDjangoError failed to downcast attr.1.string")
//                    }
////                }
//            }
//        }
//        return _tokenState
//    }
//
//    private func parseDebugDescription(_ debugDescription: String) -> TokenState {
//        if debugDescription.contains("NSURLErrorDomain Code=-1004") {
//            return TokenState.ConnectionError
//        }
//        return TokenState.Error
//    }
//
//    func getEmailConfirmationCode(completion: @escaping(JSON?, Error?)->()) {
//        var error: Error?
//
//        checkForReachability {
//            reachable in
//            if reachable == .Reachable {
//                self.checkTokenExpired() {
//                    success, error in
//                    if error != nil {
//                        completion(nil, error)
//                    } else if success {
//                        self._performRequest(url: URL(string: SERVER_URLS.BASE)!.appendingPathComponent(SERVER_URLS.GET_CONFIRMATION_CODE), httpMethod: .get, parameters: nil, encoding: URLEncoding.default, completion: completion)
//                    }
//                }
//            } else {
//                error = NSError(domain:"", code:523, userInfo:[ NSLocalizedDescriptionKey: "Server is unreachable"]) as Error
//                completion(nil, error)
//            }
//        }
//    }
//
//    func getUserData(completion: @escaping(JSON?, Error?)->()) {
//        var error: Error?
//
//        checkForReachability {
//            reachable in
//            if reachable == .Reachable {
//                self.checkTokenExpired() {
//                    success, error in
//                    if error != nil {
//                        completion(nil, error)
//                    } else if success {
//                        self._performRequest(url: URL(string: SERVER_URLS.BASE)!.appendingPathComponent(SERVER_URLS.CURRENT_USER), httpMethod: .get, parameters: nil, encoding: URLEncoding.default, completion: completion)
//                    }
//                }
//            } else {
//                error = NSError(domain:"", code:523, userInfo:[ NSLocalizedDescriptionKey: "Server is unreachable"]) as Error
//                completion(nil, error)
//            }
//        }
//    }
//
//    func login(_ auth: AuthVariant, username: String?, password: String?, token: String?, completion: @escaping (TokenState) -> ()) {
//        var _tokenState             = TokenState.Error
//        var parameters: Parameters  = [:]
//        var url: URL!
//
//        checkForReachability {
//            reachable in
//            if reachable == .Reachable {
//                switch auth {
//                case .Username:
//                    if let _username = username, let _password = password {
//                        usernameLogin(username: _username, password: _password)
//                    } else {
//                        completion(_tokenState)
//                    }
//                default:
//                    if let _token = token {
//                        socialMediaLogin(token: _token)
//                    } else {
//                        completion(_tokenState)
//                    }
//                }
//            } else {
//                completion(.ConnectionError)
//            }
//        }
//
//        func usernameLogin(username: String, password: String) {
//            parameters = ["client_id": SERVER_URLS.CLIENT_ID, "client_secret": SERVER_URLS.CLIENT_SECRET, "grant_type": "password", "username": "\(username)", "password": "\(password)"]
//            url = URL(string: SERVER_URLS.BASE)!.appendingPathComponent(SERVER_URLS.TOKEN)
//            AF.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil).response { response in
//                switch response.result {
//                case .success(let value):
//                    do {
//                        //TODO: Определиться с инициализацией JSON
//                        let json = try JSON(data: value!, options: .mutableContainers)
//                        if let statusCode = response.response?.statusCode {
//                            if 200...299 ~= statusCode {
//                                saveTokenInKeychain(json: json, tokenState: &_tokenState)
//                                _tokenState = .Received
//                            } else if 400...499 ~= statusCode {
//                                _tokenState = self.parseDjangoError(json)
//                            }
//                        }
//                    }  catch let error {
//                        print("Error: \(error.localizedDescription)")
//                    }
//                case let .failure(error):
//                    print(error)
//                }
//                completion(_tokenState)
//            }
////            AF.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil).response { response in
////                switch response.result {
////                case .success:
////                    if let statusCode = response.response?.statusCode {
////                        if 200...299 ~= statusCode {
////                            do {
////                                let json = try JSON(data: response.data!)
////                                saveTokenInKeychain(json: json, tokenState: &_tokenState)
////                                _tokenState = .Received
////                            }
////                        } else if 400...499 ~= statusCode {
////                            do {
////                                let json = try JSON(data: response.data!)
////                                _tokenState = self.parseDjangoError(json)
////                            } catch {
////                                print(error.localizedDescription)
////                            }
////                        }
////                    }
////                case .failure(let error):
////                    _tokenState = self.parseDebugDescription(error.localizedDescription)
////                }
////                completion(_tokenState)
////            }
//        }
//
//        func socialMediaLogin(token: String) {
//            parameters = ["client_id": SERVER_URLS.CLIENT_ID, "client_secret": SERVER_URLS.CLIENT_SECRET, "grant_type": "convert_token", "backend": "\(auth.rawValue.lowercased())", "token": "\(token)"]
//            print(parameters)
//            url = URL(string: SERVER_URLS.BASE)!.appendingPathComponent(SERVER_URLS.TOKEN_CONVERT)
//            AF.request(url, method: .post, parameters: parameters, encoding: URLEncoding(), headers: nil).response { response in
//                switch response.result {
//                case .success(let value):
//                    do {
//                        //TODO: Определиться с инициализацией JSON
//                        let json = try JSON(data: value!, options: .mutableContainers)
//                        if let statusCode = response.response?.statusCode {
//                            if 200...299 ~= statusCode {
//                                saveTokenInKeychain(json: json, tokenState: &_tokenState)
//                                _tokenState = .Received
//                            } else if 400...499 ~= statusCode {
//                                _tokenState = self.parseDjangoError(json)
//                            }
//                        }
//                    }  catch let error {
//                        print("Error: \(error.localizedDescription)")
//                    }
////                    if let statusCode = response.response?.statusCode, let json = JSON(value!) as? JSON {
////                        if 200...299 ~= statusCode {
////                            saveTokenInKeychain(json: json, tokenState: &_tokenState)
////                            _tokenState = .Received
////                        } else if 400...499 ~= statusCode {
////                            _tokenState = self.parseDjangoError(json)
////                        }
////                    }
//                case let .failure(error):
//                    print(error)
//                }
//                completion(_tokenState)
//
////                if response.result.isFailure {
////                    _tokenState = self.parseDebugDescription(response.result.debugDescription)
////                }
////                if let error = response.result.error as? AFError {
////                    self.parseAFError(error)
////                } else {
////                    if let statusCode  = response.response?.statusCode{
////                        if 200...299 ~= statusCode {
////                            if let json = try? JSON(data: response.data!) {
////                                saveTokenInKeychain(json: json, tokenState: &_tokenState)
////                                _tokenState = .Received
////                            }
////                            //                            DispatchQueue.main.async {
////                            //                                self.getUserData()
////                            //                            }
////                        } else if 400...499 ~= statusCode {
////                            do {
////                                let json = try JSON(data: response.data!)
////                                print(json.stringValue)
////                                _tokenState = self.parseDjangoError(json)
////                            } catch {
////                                print(error.localizedDescription)
////                            }
////                        }
////                    }
////                }
////                completion(_tokenState)
//            }
//        }
//    }
//
//    func logout(completion: @escaping (TokenState) -> ()) {
//
//        var _tokenState             = TokenState.Error
//        temporaryTokenToRevoke = KeychainService.loadAccessToken()! as String
//        AppData.shared.eraseData()
//        Surveys.shared.eraseData()
//        FBManager.performLogout()
//        VKManager.performLogout()
//
//        checkForReachability {
//            reachable in
//            if reachable == .Reachable {
//                performRequest()
//            } else {
//                completion(.ConnectionError)
//            }
//        }
//
//        func performRequest() {
//            if !temporaryTokenToRevoke.isEmpty {
//                let parameters = ["client_id": SERVER_URLS.CLIENT_ID, "client_secret": SERVER_URLS.CLIENT_SECRET, "token": temporaryTokenToRevoke]
//                let url = URL(string: SERVER_URLS.BASE)!.appendingPathComponent(SERVER_URLS.TOKEN_REVOKE)
//                //                AppData.shared.eraseData()
//                //                Surveys.shared.eraseData()
//                //                FBManager.performLogout()
//                //                VKManager.performLogout()
//                AF.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil).response { response in
//                    switch response.result {
//                    case .success(let value):
//                        if let statusCode = response.response?.statusCode {
////                            if 200...299 ~= statusCode {
////                                print("LOGGED OUT")
//                                temporaryTokenToRevoke = ""
//                                _tokenState = .Revoked
////                            } else if 400...499 ~= statusCode {
////                                _tokenState = self.parseDjangoError(json)
////                            }
//                        }
//                    case let .failure(error):
//                        print(self.parseAFError(error))
//                        _tokenState = .Revoked
//                        temporaryTokenToRevoke = ""
//                    }
//                    completion(_tokenState)
//
//
////                    if response.result.isFailure {
////                        print(response.result.description)
////                        //                        delay(seconds: 5) { performRequest() }
////                        temporaryTokenToRevoke = ""
////                    }
////                    if let error = response.result.error as? AFError {
////                        self.parseAFError(error)
////                    } else {
////                        if let statusCode  = response.response?.statusCode {
////                            if 200...299 ~= statusCode {
////                                print("LOGGED OUT")
////                                temporaryTokenToRevoke = ""
////                                _tokenState = .Revoked
////                            } else if 400...499 ~= statusCode {
////                                do {
////                                    let json = try JSON(data: response.data!)
////                                    print(json)
////                                } catch {
////                                    print(error.localizedDescription)
////                                }
////                            }
////                        }
////                    }
////                    completion(_tokenState)
//                }
//            }
//        }
//    }
//
//    func signUp(email: String, password: String, username: String, completion: @escaping (Error?) -> ()) {
//        var error: Error?
//
//        checkForReachability {
//            reachable in
//            if reachable == .Reachable {
//                performRequest()
//            } else {
//                error = NSError(domain:"", code:523, userInfo:[ NSLocalizedDescriptionKey: "Server is unreachable"]) as Error
//                completion(error!)
//            }
//        }
//
//        func performRequest() {
//            let parameters = ["client_id": SERVER_URLS.CLIENT_ID, "grant_type": "password", "email": "\(email)", "password": "\(password)", "username": "\(username)"]
//            let url =  URL(string: SERVER_URLS.BASE)!.appendingPathComponent(SERVER_URLS.SIGNUP)
//            AF.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil).response { response in
//                switch response.result {
//                case .success(let value):
//                    do {
//                        //TODO: Определиться с инициализацией JSON
//                        let json = try JSON(data: value!, options: .mutableContainers)
//                        if let statusCode = response.response?.statusCode {
//                            if 200...299 ~= statusCode {
//                                self.login(.Username, username: username, password: password, token: nil, completion: { (state) in
//                                    tokenState = state
//                                })
//                            } else if 400...499 ~= statusCode, let errorDescription = json.rawString() {
//                                error = NSError(domain:"", code:404, userInfo:[ NSLocalizedDescriptionKey: errorDescription]) as Error
//                            }
//                        }
//                    }  catch let _error {
//                        error = _error
//                        print(_error.localizedDescription)
//                    }
//                case let .failure(_error):
//                    error = _error
//                }
//                completion(error)
//
//
//
////                if response.result.isFailure {
////                    error = NSError(domain:"", code:404, userInfo:[ NSLocalizedDescriptionKey: response.result.debugDescription]) as Error
////                }
////                if let _error = response.result.error as? AFError {
////                    error = NSError(domain:"", code:404, userInfo:[ NSLocalizedDescriptionKey: self.parseAFError(_error)]) as Error
////                } else {
////                    let statusCode  = response.response?.statusCode
////                    if 200...299 ~= statusCode! {
////                        do {
////                            let json = try JSON(data: response.data!)
////                            //                            TemporaryUserCredentials.shared.importJson(json)
////                            self.login(.Username, username: username, password: password, token: nil, completion: { (state) in
////                                tokenState = state
////                            })
////                        } catch {
////                            print(error.localizedDescription)
////                        }
////                        //                        success = true
////                        //                        if login {
////                        //                            self.login(.Mail, username: username, password: password, token: nil, completion: { (state) in
////                        //                                tokenState = state
////                        //                            })
////                        //                        }
////                    } else if 400...499 ~= statusCode! {
////                        do {
////                            let json = try JSON(data: response.data!)
////                            error = NSError(domain:"", code:404, userInfo:[ NSLocalizedDescriptionKey: json.rawString()]) as Error
////                        } catch let _error {
////                            error = _error
////                        }
////                    }
////                }
////                completion(error)
//            }
//        }
//    }
//
//    func profileNeedsUpdate(completion: @escaping(Bool?, Error?)->()) {
//        var error: Error?
//
//        checkForReachability {
//            reachable in
//            if reachable == .Reachable {
//                self.checkTokenExpired() {
//                    success, error in
//                    if error != nil {
//                        completion(nil, error)
//                    } else if success {
//                        self._performRequest(url: URL(string: SERVER_URLS.BASE)!.appendingPathComponent(SERVER_URLS.PROFILE_NEEDS_UPDATE), searchString: "needs_update", httpMethod: .get, completion: completion)
//                    }
//                }
//            } else {
//                error = NSError(domain:"", code:523 , userInfo:[ NSLocalizedDescriptionKey: "Server is unreachable"]) as Error
//                completion(nil, error)
//            }
//        }
//    }
//
//    func isUsernameEmailAvailable(email: String, username: String, completion: @escaping(Bool?, Error?)->()) {
//        var error: Error?
//
//        checkForReachability {
//            reachable in
//            if reachable == .Reachable {
//                self.checkTokenExpired() {
//                    success, error in
//                    if error != nil {
//                        completion(nil, error)
//                    } else if success {
//                        self._performRequest(url: URL(string: SERVER_URLS.BASE)!.appendingPathComponent(email.isEmpty ? SERVER_URLS.USERNAME_EXISTS : SERVER_URLS.EMAIL_EXISTS), searchString: "exists", httpMethod: .get, completion: completion)
//                    }
//                }
//            } else {
//                error = NSError(domain:"", code:523 , userInfo:[ NSLocalizedDescriptionKey: "Server is unreachable"]) as Error
//                completion(nil, error)
//            }
//        }
//    }
//
//
//    func updateUserProfile(data: [String: Any], completion: @escaping(JSON?, Error?) -> ()) {
//        var dict = data
//        var json: JSON?
//        var error: Error?
//
//        checkForReachability {
//            reachable in
//            if reachable == .Reachable {
//                self.checkTokenExpired() {
//                    success, error in
//                    if error != nil {
//                        completion(nil, error)
//                    } else if success {
//                        performRequest()
//                    }
//                }
//            } else {
//                error = NSError(domain:"", code:523, userInfo:[ NSLocalizedDescriptionKey: "Server is unreachable"]) as Error
//                completion(nil, error!)
//            }
//        }
//
//        func performRequest() {
//            let url = URL(string: SERVER_URLS.BASE)!.appendingPathComponent(SERVER_URLS.PROFILES + AppData.shared.userProfile.ID! + "/")
//            let headers: HTTPHeaders = [
//                "Authorization": "Bearer " + (KeychainService.loadAccessToken()! as String) as String,
//                "Content-Type": "application/json"
//            ]
//            if let image = data["image"] as? UIImage {
//                dict.removeValue(forKey: "image")
//                AF.upload(multipartFormData: { multipartFormData in
//                    var imgExt: FileFormat = .Unknown
//                    var imageData: Data?
//                    if let data = image.jpegData(compressionQuality: 1) {
//                        imageData = data
//                        imgExt = .JPEG
//                    } else if let data = image.pngData() {
//                        imageData = data
//                        imgExt = .PNG
//                    }
//                    multipartFormData.append(imageData!, withName: "image", fileName: "\(AppData.shared.userProfile.ID!).\(imgExt.rawValue)", mimeType: "jpg/png")
//                    for (key, value) in dict {
//                        if value is String || value is Int {
//                            multipartFormData.append("\(value)".data(using: .utf8)!, withName: key)
//                        }
//                    }
//                }, to: url, method: HTTPMethod.patch, headers: headers).uploadProgress(queue: .main, closure: { progress in
//                    print("Upload Progress: \(progress.fractionCompleted)")
//                }).response { response in
//                    switch response.result {
//                    case .success(let value):
//                        do {
//                            //TODO: Определиться с инициализацией JSON
//                            json = try JSON(data: value!, options: .mutableContainers)
//                            if let statusCode = response.response?.statusCode {
//                                if 200...299 ~= statusCode {
//                                    print("Upload complete: \(json)")
//                                } else if 400...499 ~= statusCode, let errorDescription = json?.rawString() {
//                                    error = NSError(domain:"", code:404, userInfo:[ NSLocalizedDescriptionKey: errorDescription]) as Error
//                                }
//                            }
//                            completion(json, error)
//                        }  catch let _error {
//                            error = _error
//                            print(_error.localizedDescription)
//                        }
//                    case let .failure(_error):
//                        error = _error
//                        completion(nil, error)
//                    }
//                }
//            } else {
//                _performRequest(url: url, httpMethod: .patch, parameters: data, encoding: JSONEncoding.default, completion: completion)
//            }
//
//
//
//
//
////                AF.upload(multipartFormData: { multipartFormData in
////                    var imgExt: FileFormat = .Unknown
////                    var imageData: Data?
////                    if let data = image.jpegData(compressionQuality: 1) {
////                        imageData = data
////                        imgExt = .JPEG
////                    } else if let data = image.pngData() {
////                        imageData = data
////                        imgExt = .PNG
////                    }
////                    multipartFormData.append(imageData!, withName: "image", fileName: "\(AppData.shared.userProfile.ID!).\(imgExt.rawValue)", mimeType: "jpg/png")
////                    for (key, value) in dict {
////                        if value is String || value is Int {
////                            multipartFormData.append("\(value)".data(using: .utf8)!, withName: key)
////                        }
////                    }
////                }, usingThreshold: SessionManager.multipartFormDataEncodingMemoryThreshold, to: url, method: .patch, headers: headers) {
////                    result in
////                    switch result {
////                    case .failure(let _error):
////                        error = _error
////                        completion(json, error)
////                    case .success(request: let upload, streamingFromDisk: _, streamFileURL: _):
////                        upload.uploadProgress(closure: { (progress) in
////                            print("Upload Progress: \(progress.fractionCompleted)")
////                        })
////                        upload.responseJSON(completionHandler: { (response) in
////                            if response.result.isFailure {
////                                error = NSError(domain:"", code:404, userInfo:[ NSLocalizedDescriptionKey: response.result.debugDescription]) as Error
////                            }
////                            if let _error = response.result.error as? AFError {
////                                error = self.parseAFError(_error)
////                            } else {
////                                if let statusCode  = response.response?.statusCode{
////                                    if 200...299 ~= statusCode {
////                                        do {
////                                            json = try JSON(data: response.data!)
////                                        } catch let _error {
////                                            error = _error
////                                        }
////                                    } else if 400...499 ~= statusCode {
////                                        do {
////                                            let errorJSON = try JSON(data: response.data!)
////                                            error = NSError(domain:"", code:404, userInfo:[ NSLocalizedDescriptionKey: errorJSON.rawString()]) as Error
////                                        } catch let _error {
////                                            error = _error
////                                        }
////                                    }
////                                }
////                                completion(json, error)
////                            }
////                        })
////                    }
////                }
////            } else {
////                _performRequest(url: url, httpMethod: .patch, parameters: data, encoding: JSONEncoding.default, completion: completion)
////            }
//        }
//    }
//
//    func getEmailVerified(completion: @escaping (Bool?, Error?) -> ()) {
//        var error:              Error?
//        var isEmailVerified:    Bool?
//
//        checkForReachability {
//            reachable in
//            if reachable == .Reachable {
//                self.checkTokenExpired() {
//                    success, error in
//                    if error != nil {
//                        completion(nil, error)
//                    } else if success {
//                        self._performRequest(url: URL(string: SERVER_URLS.BASE)!.appendingPathComponent(SERVER_URLS.GET_EMAIL_VERIFIED), searchString: DjangoVariables.UserProfile.isEmailVerified, httpMethod: .get, completion: completion)
//                    }
//                }
//            } else {
//                error = NSError(domain:"", code:523 , userInfo:[ NSLocalizedDescriptionKey: "Server is unreachable"]) as Error
//                completion(isEmailVerified, error)
//            }
//        }
//    }
//
//    private func checkTokenExpired(completion: @escaping (Bool, Error?) -> ()) {
//        var success = true
//        var error: Error?
//        if let expString = KeychainService.loadTokenExpireDateTime() as String? {
//            let expiryDate = expString.toDateTime()
//            if Date() >= expiryDate {
//                tokenState = .Expired
//                refreshAccessToken(completion: {
//                    _tokenState in
//                    tokenState = _tokenState
//                    if _tokenState != TokenState.Received {
//                        success = false
//                        error = NSError(domain:"", code:404, userInfo:[ NSLocalizedDescriptionKey: "Error refreshing access token"]) as Error
//                    }
//                    completion(success, error)
//                })
//            } else {
//                completion(success, error)
//            }
//        }
//    }
//
//    func refreshAccessToken(completion: @escaping (TokenState) -> ()) {
//        checkForReachability {
//            reachable in
//            if reachable == .Reachable {
//                performRequest()
//            } else {
//                completion(.ConnectionError)
//            }
//        }
//
//        func performRequest() {
//            let refresh_token = KeychainService.loadRefreshToken()! as String
//            let parameters = ["client_id": SERVER_URLS.CLIENT_ID, "client_secret": SERVER_URLS.CLIENT_SECRET, "grant_type": "refresh_token", "refresh_token": "\(refresh_token)"]
//            let url = URL(string: SERVER_URLS.BASE)!.appendingPathComponent(SERVER_URLS.TOKEN)
//
//            AF.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil).response { response in
//                var _tokenState = TokenState.Error
//                switch response.result {
//                case .success(let value):
//                    do {
//                        //TODO: Определиться с инициализацией JSON
//                        let json = try JSON(data: value!, options: .mutableContainers)
//                        if let statusCode = response.response?.statusCode {
//                            if 200...299 ~= statusCode {
//                                saveTokenInKeychain(json: json, tokenState: &tokenState)
//                                _tokenState = TokenState.Received
//                            } else if 400...499 ~= statusCode, let errorDescription = json.rawString() {
//                                print(NSError(domain:"", code:404, userInfo:[ NSLocalizedDescriptionKey: errorDescription]) as Error)
//                            }
//                        }
//                    }  catch let _error {
//                        print(_error.localizedDescription)
//                    }
//                case let .failure(_error):
//                    print(_error.localizedDescription)
//                }
//                completion(_tokenState)
//            }
//
//
//
////            session.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON(completionHandler: {
////                response in
////                var _tokenState = TokenState.Error
////                if let _error = response.result.error as? AFError {
////                    let error = NSError(domain:"", code:404, userInfo:[ NSLocalizedDescriptionKey: self.parseAFError(_error)]) as Error
////                    print(error.localizedDescription)
////                } else {
////                    let statusCode  = response.response?.statusCode
////                    if 200...299 ~= statusCode! {
////                        if let json = try? JSON(data: response.data!) {
////                            for attr in json {
////                                print("\(attr.0): \(attr.1.stringValue)")
////                            }
////                            saveTokenInKeychain(json: json, tokenState: &tokenState)
////                            _tokenState = TokenState.Received
////                        } else {
////                            _tokenState = .Error
////                        }
////                    } else if 400...499 ~= statusCode! {
////                        _tokenState = .Error
////                    }
////                    completion(_tokenState)
////                }
////            })
//        }
//    }
//
//    func initialLoad(completion: @escaping(JSON?, Error?)->()) {
//        var error: Error?
//
//        checkForReachability {
//            reachable in
//            if reachable == .Reachable {
//                self.checkTokenExpired() {
//                    success, error in
//                    if error != nil {
//                        completion(nil, error)
//                    } else if success {
//                        self._performRequest(url: URL(string: SERVER_URLS.BASE)!.appendingPathComponent(SERVER_URLS.APP_LAUNCH), httpMethod: .get, parameters: nil, encoding: URLEncoding.default, completion: completion)
//                    }
//                }
//            } else {
//                error = NSError(domain:"", code:523, userInfo:[ NSLocalizedDescriptionKey: "Server is unreachable"]) as Error
//                completion(nil, error!)
//            }
//        }
//    }
//
//    func loadSurveys(type: APIManager.SurveyType, completion: @escaping(JSON?, Error?)->()) {
//        var error: Error?
//        var httpMethod: HTTPMethod = .get
//        var url: URL = type.getURL()
//        //        var encoding
//
//        checkForReachability {
//            reachable in
//            if reachable == .Reachable {
//                self.checkTokenExpired() {
//                    success, error in
//                    if error != nil {
//                        completion(nil, error)
//                    } else if success {
//                        var parameters: [String: [Any]]?
//                        if type == .Hot {
//                            //                            var list: [Int] = []
//                            //                            if !Surveys.shared.stackObjects.isEmpty {
//                            //                                list = Surveys.shared.stackObjects.filter({ $0.ID != nil }).map(){ $0.ID!}
//                            //                            }
//                            //                            if let _id = Surveys.shared.currentHotSurvey?.ID {
//                            //                                list.append(_id)
//                            //                            }
//                            //                            if !list.isEmpty {
//                            //                                parameters = list.asParameters(arrayParametersKey: "ids") as! [String : [Any]]//["ids": ["df", "sdf"]]
//                            //                                httpMethod = .post
//                            //                                url = APIManager.SurveyType.HotExcept.getURL()
//                            //                            }
//                        }
//                        //                        parameters = nil
//                        self._performRequest(url: url, httpMethod: httpMethod, parameters: parameters, encoding: JSONEncoding.default, completion: completion)
//                    }
//                }
//            } else {
//                error = NSError(domain:"", code:523, userInfo:[ NSLocalizedDescriptionKey: "Server is unreachable"]) as Error
//                completion(nil, error!)
//            }
//        }
//    }
//
//
//    func loadSurveyCategories(completion: @escaping(JSON?, Error?)->()) {
//        //        var json: JSON?
//        var error: Error?
//
//        checkForReachability {
//            reachable in
//            if reachable == .Reachable {
//                self.checkTokenExpired() {
//                    success, error in
//                    if error != nil {
//                        completion(nil, error)
//                    } else if success {
//                        self._performRequest(url: URL(string: SERVER_URLS.BASE)!.appendingPathComponent(SERVER_URLS.CATEGORIES), httpMethod: .get, parameters: nil, encoding: JSONEncoding.default, completion: completion)
//                    }
//                }
//            } else {
//                error = NSError(domain:"", code:523, userInfo:[ NSLocalizedDescriptionKey: "Server is unreachable"]) as Error
//                completion(nil, error!)
//            }
//        }
//    }
//
//    func loadTotalSurveysCount(completion: @escaping(JSON?, Error?)->()) {
//        var error: Error?
//
//        checkForReachability {
//            reachable in
//            if reachable == .Reachable {
//                self.checkTokenExpired() {
//                    success, error in
//                    if error != nil {
//                        completion(nil, error)
//                    } else if success {
//                        self._performRequest(url: URL(string: SERVER_URLS.BASE)!.appendingPathComponent(SERVER_URLS.SURVEYS_TOTAL_COUNT), httpMethod: .get, completion: completion)
//                    }
//                }
//            } else {
//                error = NSError(domain:"", code:523, userInfo:[ NSLocalizedDescriptionKey: "Server is unreachable"]) as Error
//                completion(nil, error!)
//            }
//        }
//    }
//
//    func loadSurveysByCategory(categoryID: Int, completion: @escaping(JSON?, Error?)->()) {
//        var error: Error?
//
//        checkForReachability {
//            reachable in
//            if reachable == .Reachable {
//                self.checkTokenExpired() {
//                    success, error in
//                    if error != nil {
//                        completion(nil, error)
//                    } else if success {
//                        self._performRequest(url: URL(string: SERVER_URLS.BASE)!.appendingPathComponent(SERVER_URLS.SURVEYS_BY_CATEGORY), httpMethod: .get, parameters: ["category_id": categoryID], encoding: URLEncoding.default, completion: completion)
//                    }
//                }
//            } else {
//                error = NSError(domain:"", code:523, userInfo:[ NSLocalizedDescriptionKey: "Server is unreachable"]) as Error
//                completion(nil, error!)
//            }
//        }
//    }
//
//    func loadSurvey(survey: SurveyRef, addViewCount: Bool = false, completion: @escaping(JSON?, Error?)->()) {
//        var error: Error?
//
//        checkForReachability {
//            reachable in
//            if reachable == .Reachable {
//                self.checkTokenExpired() {
//                    success, error in
//                    if error != nil {
//                        completion(nil, error)
//                    } else if success {
//                        self._performRequest(url: URL(string: SERVER_URLS.BASE)!.appendingPathComponent(SERVER_URLS.SURVEYS + "\(survey.ID)/"), httpMethod: .get, parameters: addViewCount ? ["add_view_count": true] : nil, encoding: URLEncoding.default, completion: completion)
//                    }
//                }
//            } else {
//                error = NSError(domain:"", code:523, userInfo:[ NSLocalizedDescriptionKey: "Server is unreachable"]) as Error
//                completion(nil, error!)
//            }
//        }
//    }
//
//    func addFavorite(mark: Bool, survey: SurveyRef, completion: @escaping(JSON?, Error?)->()) {
//        var error: Error?
//        checkForReachability {
//            reachable in
//            if reachable == .Reachable {
//                self.checkTokenExpired() {
//                    success, error in
//                    if error != nil {
//                        completion(nil, error!)
//                    } else if success {
//                        self._performRequest(url: URL(string: SERVER_URLS.BASE)!.appendingPathComponent(mark ? SERVER_URLS.SURVEYS_ADD_FAVORITE : SERVER_URLS.SURVEYS_REMOVE_FAVORITE), httpMethod: .get, parameters: ["survey_id": survey.ID], encoding: URLEncoding.default, completion: completion)
//                    }
//                }
//            } else {
//                error = NSError(domain:"", code:523, userInfo:[ NSLocalizedDescriptionKey: "Server is unreachable"]) as Error
//                completion(nil, error!)
//            }
//        }
//    }
//
//    func addViewCount(survey: SurveyRef, completion: @escaping(JSON?, Error?)->()) {
//        var error: Error?
//        checkForReachability {
//            reachable in
//            if reachable == .Reachable {
//                self.checkTokenExpired() {
//                    success, error in
//                    if error != nil {
//                        completion(nil, error!)
//                    } else if success {
//                        self._performRequest(url: URL(string: SERVER_URLS.BASE)!.appendingPathComponent(SERVER_URLS.SURVEYS_ADD_VIEW_COUNT), httpMethod: .get, parameters: ["survey_id": survey.ID], encoding: URLEncoding.default, completion: completion)
//                    }
//                }
//            } else {
//                error = NSError(domain:"", code:523, userInfo:[ NSLocalizedDescriptionKey: "Server is unreachable"]) as Error
//                completion(nil, error!)
//            }
//        }
//    }
//
//    func updateSurveyStats(survey: SurveyRef, completion: @escaping(JSON?, Error?)->()) {
//        var error: Error?
//        checkForReachability {
//            reachable in
//            if reachable == .Reachable {
//                self.checkTokenExpired() {
//                    success, error in
//                    if error != nil {
//                        completion(nil, error!)
//                    } else if success {
//                        self._performRequest(url: URL(string: SERVER_URLS.BASE)!.appendingPathComponent(SERVER_URLS.SURVEYS_UPDATE_STATS), httpMethod: .get, parameters: ["survey_id": survey.ID], encoding: URLEncoding.default, completion: completion)
//                    }
//                }
//            } else {
//                error = NSError(domain:"", code:523, userInfo:[ NSLocalizedDescriptionKey: "Server is unreachable"]) as Error
//                completion(nil, error!)
//            }
//        }
//    }
//
//    func postSurvey(survey: Survey, completion: @escaping(JSON?, Error?)->()) {
//        var dict = survey.dict
//        print(dict)
//        var json: JSON?
//        var error: Error?
//
//        checkForReachability {
//            reachable in
//            if reachable == .Reachable {
//                self.checkTokenExpired() {
//                    success, error in
//                    if error != nil {
//                        completion(nil, error!)
//                    } else if success {
//                        performRequest()
//                    }
//                }
//            } else {
//                error = NSError(domain:"", code:523, userInfo:[ NSLocalizedDescriptionKey: "Server is unreachable"]) as Error
//                completion(nil, error!)
//            }
//        }
//
//        func performRequest() {
//            var url = URL(string: SERVER_URLS.BASE)!.appendingPathComponent(SERVER_URLS.SURVEYS)
//            let images = dict.removeValue(forKey: DjangoVariables.Survey.images) as? [[UIImage: String]]
//
//            _performRequest(url: url, httpMethod: .post, parameters: dict, encoding: JSONEncoding.default) {
//                _json, _error in
//                if _error != nil {
//                    error = _error
//                    completion(json, error)
//                } else if _json != nil {
//                    json = _json
//
//                    if images != nil, images?.count != 0 {
//                        //Upload images
//                        let surveyID = json!["id"].intValue
//                        let headers: HTTPHeaders = [
//                            "Authorization": "Bearer " + (KeychainService.loadAccessToken()! as String) as String,
//                            "Content-Type": "application/json"
//                        ]
//                        url = URL(string: SERVER_URLS.BASE)!.appendingPathComponent(SERVER_URLS.SURVEYS_MEDIA)
//                        var uploadError: Error?
//                        for (index, image) in images!.enumerated() {
//                            AF.upload(multipartFormData: { multipartFormData in
//                                var imgExt: FileFormat = .Unknown
//                                var imageData: Data?
//                                if let data = image.keys.first!.jpegData(compressionQuality: 1) {
//                                    imageData = data
//                                    imgExt = .JPEG
//                                } else if let data = image.keys.first!.pngData() {
//                                    imageData = data
//                                    imgExt = .PNG
//                                }
//                                multipartFormData.append(imageData!, withName: "image", fileName: "\(AppData.shared.userProfile.ID!).\(imgExt.rawValue)", mimeType: "jpg/png")
//                                multipartFormData.append("\(surveyID)".data(using: .utf8)!, withName: "survey")
//                                multipartFormData.append("\(index)".data(using: .utf8)!, withName: "order")
//                                if !(image.values.first?.isEmpty)! {
//                                    multipartFormData.append(image.values.first!.data(using: .utf8)!, withName: "title")
//                                }
//                            }, to: url, method: HTTPMethod.patch, headers: headers).uploadProgress(queue: .main, closure: { progress in
//                                print("Upload Progress: \(progress.fractionCompleted)")
//                            }).response { response in
//                                switch response.result {
//                                case .success(let value):
//                                    do {
//                                        //TODO: Определиться с инициализацией JSON
//                                        json = try JSON(data: value!, options: .mutableContainers)
//                                        if let statusCode = response.response?.statusCode {
//                                            if 200...299 ~= statusCode {
//                                                print("Upload complete: \(String(describing: json))")
//                                            } else if 400...499 ~= statusCode, let errorDescription = json?.rawString() {
//                                                uploadError = NSError(domain:"", code:404, userInfo:[ NSLocalizedDescriptionKey: errorDescription]) as Error
//                                                print(uploadError!)
//                                            }
//                                        }
//                                        completion(json, error)
//                                    }  catch let _error {
//                                        uploadError = _error
//                                        print(_error.localizedDescription)
//                                    }
//                                case let .failure(_error):
//                                    uploadError = _error
//                                    completion(nil, error)
//                                }
//                            }
//                        }
//                        completion(json, uploadError)
//                    } else {
//                        completion(json, error)
//                    }
////
////
////
////
////                            Alamofire.upload(multipartFormData: { multipartFormData in
////                                //                            for image in images! {
////                                var imgExt: FileFormat = .Unknown
////                                var imageData: Data?
////                                if let data = image.keys.first!.jpegData(compressionQuality: 1) {
////                                    imageData = data
////                                    imgExt = .JPEG
////                                } else if let data = image.keys.first!.pngData() {
////                                    imageData = data
////                                    imgExt = .PNG
////                                }
////                                multipartFormData.append(imageData!, withName: "image", fileName: "\(AppData.shared.userProfile.ID!).\(imgExt.rawValue)", mimeType: "jpg/png")
////                                multipartFormData.append("\(surveyID)".data(using: .utf8)!, withName: "survey")
////                                if !(image.values.first?.isEmpty)! {
////                                    multipartFormData.append(image.values.first!.data(using: .utf8)!, withName: "title")
////                                }
////                            }, usingThreshold: SessionManager.multipartFormDataEncodingMemoryThreshold, to: url, method: .post, headers: headers) {
////                                result in
////                                switch result {
////                                case .failure(let _error):
////                                    uploadError = _error
////                                    //                                completion(json, error)
////                                case .success(request: let upload, streamingFromDisk: _, streamFileURL: _):
////                                    upload.uploadProgress(closure: { (progress) in
////                                        print("Upload Progress: \(progress.fractionCompleted)")
////                                    })
////                                    upload.responseJSON(completionHandler: { (response) in
////                                        if response.result.isFailure {
////                                            uploadError = NSError(domain:"", code:404, userInfo:[ NSLocalizedDescriptionKey: response.result.debugDescription]) as Error
////                                        }
////                                        if let _error = response.result.error as? AFError {
////                                            uploadError = self.parseAFError(_error)
////                                        } else {
////                                            if let statusCode  = response.response?.statusCode{
////                                                if 200...299 ~= statusCode {
////                                                    do {
////                                                        json = try JSON(data: response.data!)
////                                                    } catch let _error {
////                                                        uploadError = _error
////                                                    }
////
////                                                    //TODO save local
////                                                } else if 400...499 ~= statusCode {
////                                                    do {
////                                                        let errorJSON = try JSON(data: response.data!)
////                                                        uploadError = NSError(domain:"", code:404, userInfo:[ NSLocalizedDescriptionKey: errorJSON.rawString()!]) as Error
////                                                        print(uploadError!)
////                                                    } catch let _error {
////                                                        uploadError = _error
////                                                    }
////                                                }
////                                            }
////                                        }
////                                    })
////                                }
////                            }
////                        }
////                        error = uploadError
////                        completion(json, error)
////                    } else {
////                        completion(json, error)
////                    }
//                }
//            }
//
//
//
//            //
//            //
//            //            if let images = dict["media"] as? [[UIImage: String]], images.count != 0 {
//            //                dict.removeValue(forKey: "images")
//            //                Alamofire.upload(multipartFormData: { multipartFormData in
//            //                    for image in images {
//            //                        var imgExt: FileFormat = .Unknown
//            //                        var imageData: Data?
//            //                        if let data = image.keys.first!.jpegData(compressionQuality: 1) {
//            //                            imageData = data
//            //                            imgExt = .JPEG
//            //                        } else if let data = image.keys.first!.pngData() {
//            //                            imageData = data
//            //                            imgExt = .PNG
//            //                        }
//            //                        multipartFormData.append(imageData!, withName: "media.image", fileName: "\(AppData.shared.userProfile.ID!).\(imgExt.rawValue)", mimeType: "jpg/png")
//            //                        multipartFormData.append("\(image.values.first!)".data(using: .utf8)!, withName: "media.title")
//            //                    }
//            //
//            //                    for (key, value) in dict {
//            //                        if value is String || value is Int {
//            //                            multipartFormData.append("\(value)".data(using: .utf8)!, withName: key)
//            //                        }
//            //                    }
//            //                }, usingThreshold: SessionManager.multipartFormDataEncodingMemoryThreshold, to: url, method: .patch, headers: headers) {
//            //                    result in
//            //                    switch result {
//            //                    case .failure(let _error):
//            //                        error = _error
//            //                        completion(json, error)
//            //                    case .success(request: let upload, streamingFromDisk: _, streamFileURL: _):
//            //                        upload.uploadProgress(closure: { (progress) in
//            //                            print("Upload Progress: \(progress.fractionCompleted)")
//            //                        })
//            //                        upload.responseJSON(completionHandler: { (response) in
//            //                            if response.result.isFailure {
//            //                                error = NSError(domain:"", code:404, userInfo:[ NSLocalizedDescriptionKey: response.result.debugDescription]) as Error
//            //                            }
//            //                            if let _error = response.result.error as? AFError {
//            //                                error = self.parseAFError(_error)
//            //                            } else {
//            //                                if let statusCode  = response.response?.statusCode{
//            //                                    if 200...299 ~= statusCode {
//            //                                        do {
//            //                                            json = try JSON(data: response.data!)
//            //                                        } catch let _error {
//            //                                            error = _error
//            //                                        }
//            //                                    } else if 400...499 ~= statusCode {
//            //                                        do {
//            //                                            let errorJSON = try JSON(data: response.data!)
//            //                                            error = NSError(domain:"", code:404, userInfo:[ NSLocalizedDescriptionKey: errorJSON.rawString()]) as Error
//            //                                        } catch let _error {
//            //                                            error = _error
//            //                                        }
//            //                                    }
//            //                                }
//            //                                completion(json, error)
//            //                            }
//            //                        })
//            //                    }
//            //                }
//            //            } else {
//            //                _performRequest(url: url, httpMethod: .post, parameters: dict, encoding: JSONEncoding.default, completion: completion)
//            //            }
//        }
//    }
//
//    func postVote(result: [String: Int], completion: @escaping(JSON?, Error?)->()) {
//        var parameters: [String: Any] = result
//        var error: Error?
//        var dict: Parameters = [:]
//        if Surveys.shared.stackObjects.count <= MIN_STACK_SIZE {
//            let stackList = Surveys.shared.stackObjects.filter({ $0.ID != nil }).map(){ $0.ID!}
//            let rejectedList = Surveys.shared.rejectedSurveys.filter({ $0.ID != nil }).map(){ $0.ID!}
//            let completedList = [result.values.first!]
//            let list = Array(Set(stackList + rejectedList + completedList))//Surveys.shared.stackObjects.filter({ $0.ID != nil }).map(){ $0.ID!}
//            if !list.isEmpty {
//                parameters["ids"] = list
//            }
//        }
//        checkForReachability {
//            reachable in
//            if reachable == .Reachable {
//                self.checkTokenExpired() {
//                    success, error in
//                    if error != nil {
//                        completion(nil, error!)
//                    } else if success {
//                        self._performRequest(url: URL(string: SERVER_URLS.BASE)!.appendingPathComponent(SERVER_URLS.VOTE), httpMethod: .post, parameters: parameters, encoding: JSONEncoding.default, completion: completion)
//                    }
//                }
//            } else {
//                error = NSError(domain:"", code:523, userInfo:[ NSLocalizedDescriptionKey: "Server is unreachable"]) as Error
//                completion(nil, error!)
//            }
//        }
//    }
//
//    func rejectSurvey(survey: Survey, completion: @escaping(JSON?, Error?)->()) {
//        var parameters: [String: Any] = ["survey": survey.ID! as Any]
//        if Surveys.shared.stackObjects.count <= MIN_STACK_SIZE {
//            let stackList = Surveys.shared.stackObjects.filter({ $0.ID != nil }).map(){ $0.ID!}
//            let rejectedList = Surveys.shared.rejectedSurveys.filter({ $0.ID != nil }).map(){ $0.ID!}
//            let list = Array(Set(stackList + rejectedList))//Surveys.shared.stackObjects.filter({ $0.ID != nil }).map(){ $0.ID!}
//            if !list.isEmpty {
//                let dict = list.asParameters(arrayParametersKey: "ids")
//                parameters.merge(dict) {(current, _) in current}
//            }
//        }
//        checkForReachability {
//            reachable in
//            if reachable == .Reachable {
//                self.checkTokenExpired() {
//                    success, error in
//                    if error != nil {
//                        print(error!)
//                    } else if success {
//                        //                        var parameters: [String: Any] = ["survey": survey.ID! as Any]
//                        ////                        print("Surveys.shared.stackObjects.count \(Surveys.shared.stackObjects.count)")
//                        //                        if Surveys.shared.stackObjects.count <= MIN_STACK_SIZE {
//                        //                            var list = Surveys.shared.stackObjects.filter({ $0.ID != nil }).map(){ $0.ID!}
//                        //                            if !list.isEmpty {
//                        //                                let dict = list.asParameters(arrayParametersKey: "ids") as! [String : Any]
//                        //                                parameters.merge(dict) {(current, _) in current}
//                        //                            }
//                        //                        }
//                        self._performRequest(url: URL(string: SERVER_URLS.BASE)!.appendingPathComponent(SERVER_URLS.SURVEYS_REJECT), httpMethod: .post, parameters: parameters, encoding: JSONEncoding.default, completion: completion)
//                    }
//                }
//            } else {
//                print(NSError(domain:"", code:523, userInfo:[ NSLocalizedDescriptionKey: "Server is unreachable"]) as Error)
//            }
//        }
//    }
//
//    func postClaim(survey: Survey, claimCategory: ClaimCategory, completion: @escaping(JSON?, Error?)->()) {
//        //Local delete
//        //        delay(seconds: 1) {
//        Surveys.shared.banSurvey(object: survey)
//        //        }
//        var error: Error?
//        checkForReachability {
//            reachable in
//            if reachable == .Reachable {
//                self.checkTokenExpired() {
//                    success, error in
//                    if error != nil {
//                        completion(nil, error!)
//                    } else if success {
//                        self._performRequest(url: URL(string: SERVER_URLS.BASE)!.appendingPathComponent(SERVER_URLS.SURVEYS_CLAIM), httpMethod: .post, parameters: ["survey": survey.ID, "claim": claimCategory.ID], encoding: JSONEncoding.default, completion: completion)
//                    }
//                }
//            } else {
//                error = NSError(domain:"", code:523, userInfo:[ NSLocalizedDescriptionKey: "Server is unreachable"]) as Error
//                completion(nil, error!)
//            }
//        }
//    }
//
//    func getUserStats(userProfile: UserProfile, completion: @escaping(JSON?, Error?)->()) {
//        var error: Error?
//
//        checkForReachability {
//            reachable in
//            if reachable == .Reachable {
//                self.checkTokenExpired() {
//                    success, error in
//                    if error != nil {
//                        completion(nil, error)
//                    } else if success {
//                        self._performRequest(url: URL(string: SERVER_URLS.BASE)!.appendingPathComponent(SERVER_URLS.USER_PROFILE_STATS), httpMethod: .get, parameters: ["userprofile_id": userProfile.ID], encoding: URLEncoding.default, completion: completion)
//                    }
//                }
//            } else {
//                error = NSError(domain:"", code:523, userInfo:[ NSLocalizedDescriptionKey: "Server is unreachable"]) as Error
//                completion(nil, error!)
//            }
//        }
//    }
//
//    func loadSurveysByOwner(userProfile: UserProfile, type: SurveyType, completion: @escaping(JSON?, Error?)->()) {
//        var error: Error?
//
//        checkForReachability {
//            reachable in
//            if reachable == .Reachable {
//                self.checkTokenExpired() {
//                    success, error in
//                    if error != nil {
//                        completion(nil, error)
//                    } else if success {
//                        self._performRequest(url: type.getURL(), httpMethod: .get, parameters: ["userprofile_id": userProfile.ID], encoding: URLEncoding.default, completion: completion)
//                    }
//                }
//            } else {
//                error = NSError(domain:"", code:523, userInfo:[ NSLocalizedDescriptionKey: "Server is unreachable"]) as Error
//                completion(nil, error!)
//            }
//        }
//    }
//
//    func subsribeToUserProfile(subscribe: Bool, userprofile: UserProfile, completion: @escaping(JSON?, Error?)->()) {
//        var error: Error?
//        checkForReachability {
//            reachable in
//            if reachable == .Reachable {
//                self.checkTokenExpired() {
//                    success, error in
//                    if error != nil {
//                        completion(nil, error!)
//                    } else if success {
//                        self._performRequest(url: URL(string: SERVER_URLS.BASE)!.appendingPathComponent(subscribe ? SERVER_URLS.USERPOFILE_SUBSCRIBE : SERVER_URLS.USERPOFILE_UNSUBSCRIBE), httpMethod: .get, parameters: ["userprofile_id": userprofile.ID], encoding: URLEncoding.default, completion: completion)
//                    }
//                }
//            } else {
//                error = NSError(domain:"", code:523, userInfo:[ NSLocalizedDescriptionKey: "Server is unreachable"]) as Error
//                completion(nil, error!)
//            }
//        }
//    }
//
//    func getBalanceAndPrice() {
//        checkForReachability {
//            reachable in
//            if reachable == .Reachable {
//                self.checkTokenExpired() {
//                    success, _ in
//                    if success {
//                        self._performRequest(url: URL(string: SERVER_URLS.BASE)!.appendingPathComponent(SERVER_URLS.BALANCE), httpMethod: .get, parameters: [:], encoding: URLEncoding.default) {
//                            json, error in
//                            if error != nil {
//                                print(error!.localizedDescription)
//                            } else if let strongJSON = json {
//                                PriceList.shared.importJson(strongJSON["pricelist"])
//                                if let balance = strongJSON[DjangoVariables.UserProfile.balance].intValue as? Int {
//                                    AppData.shared.userProfile.balance = balance
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//        }
//    }
//
//    func getTikTokEmbedHTML(url: URL, completion: @escaping(JSON?, Error?)->()) {
//        _performRequest(url: url, httpMethod: .get) {
//            json, error in
//            completion(json, error)
//        }
//    }
//
//    func getVoters(surveyID: Int, answerID: Int, userprofiles: [Int], completion: @escaping(JSON?, Error?)->()) {
//        var error: Error?
//
//        checkForReachability {
//            reachable in
//            if reachable == .Reachable {
//                self.checkTokenExpired() {
//                    success, error in
//                    if error != nil {
//                        completion(nil, error)
//                    } else if success {
//                        self._performRequest(url: URL(string: SERVER_URLS.BASE)!.appendingPathComponent(SERVER_URLS.VOTERS), httpMethod: .get, parameters: ["survey": surveyID, "answer": answerID, "userprofiles": userprofiles], encoding: CustomGetEncoding(), completion: completion)
//                    }
//                }
//            } else {
//                error = NSError(domain:"", code:523, userInfo:[ NSLocalizedDescriptionKey: "Server is unreachable"]) as Error
//                completion(nil, error!)
//            }
//        }
//
//    }
//
//    private func _performRequest(url: URL, httpMethod: HTTPMethod,  parameters: Parameters? = nil, encoding: ParameterEncoding = JSONEncoding.default, completion: @escaping(JSON?, Error?)->()) {
//        var json: JSON?
//        var error: Error?
//        let headers: HTTPHeaders = [
//            "Authorization": "Bearer " + (KeychainService.loadAccessToken()! as String) as String,
//            "Content-Type": "application/json"
//        ]
//
//        AF.request(url, method: httpMethod, parameters: parameters, encoding: encoding, headers: headers).response { response in
//            switch response.result {
//            case .success(let value):
//                do {
//                    //TODO: Определиться с инициализацией JSON
//                    json = try JSON(data: value!, options: .mutableContainers)
//                    if let statusCode = response.response?.statusCode {
//                        if 200...299 ~= statusCode {
//
//                        } else if 400...499 ~= statusCode, let errorDescription = json?.rawString() {
//                            error = NSError(domain:"", code:404, userInfo:[ NSLocalizedDescriptionKey: errorDescription]) as Error
//                        }
//                    }
//                }  catch let _error {
//                    error = _error
//                }
//            case let .failure(_error):
//                error = self.parseAFError(_error)
//                debugPrint(error!)
//            }
//            completion(json, error)
//        }
//
////        session.request(url, method: httpMethod, parameters: parameters, encoding: encoding, headers: headers).responseJSON() {
////            response in
////            if response.result.isFailure {
////                print(response.result.debugDescription)
////                error = NSError(domain:"", code:404, userInfo:[ NSLocalizedDescriptionKey: response.result.debugDescription]) as Error
////            } else {
////                if let _error = response.result.error as? AFError {
////                    error = self.parseAFError(_error)
////                } else {
////                    if let statusCode  = response.response?.statusCode{
////                        if 200...299 ~= statusCode {
////                            do {
////                                json = try JSON(data: response.data!)
////                            } catch let _error {
////                                error = NSError(domain:"", code:404, userInfo:[ NSLocalizedDescriptionKey: _error.localizedDescription]) as Error
////                            }
////                        } else if 400...499 ~= statusCode {
////                            do {
////                                let errorJSON = try JSON(data: response.data!)
////                                error = NSError(domain:"", code:404, userInfo:[ NSLocalizedDescriptionKey: errorJSON.rawString()!]) as Error
////                                print(error!.localizedDescription)
////                            } catch let _error {
////                                error = NSError(domain:"", code:404, userInfo:[ NSLocalizedDescriptionKey: _error.localizedDescription]) as Error
////                            }
////                        }
////                    }
////                }
////            }
////            completion(json, error)
////        }
//    }
//
//    private func _performRequest(url: URL, searchString: String, httpMethod: HTTPMethod,  parameters: Parameters? = nil, encoding: ParameterEncoding = JSONEncoding.default, completion: @escaping(Bool?, Error?)->()) {
//        var flag: Bool?
//        var error: Error?
//        let headers: HTTPHeaders = [
//            "Authorization": "Bearer " + (KeychainService.loadAccessToken()! as String) as String,
//            "Content-Type": "application/json"
//        ]
//
//        AF.request(url, method: httpMethod, parameters: parameters, encoding: encoding, headers: headers).response { response in
//            switch response.result {
//            case .success(let value):
//                do {
//                    //TODO: Определиться с инициализацией JSON
//                    let json = try JSON(data: value!, options: .mutableContainers)
//                    if let statusCode = response.response?.statusCode {
//                        if 200...299 ~= statusCode {
//                            for attr in json {
//                                if attr.0 ==  searchString {
//                                    flag = attr.1.boolValue
//                                }
//                                if attr.0 ==  "error" {
//                                    error = NSError(domain:"", code:404 , userInfo:[ NSLocalizedDescriptionKey: attr.1.stringValue]) as Error
//                                }
//                            }
//                        } else if 400...499 ~= statusCode, let errorDescription = json.rawString() {
//                            error = NSError(domain:"", code:404, userInfo:[ NSLocalizedDescriptionKey: errorDescription]) as Error
//                        }
//                    }
//                }  catch let _error {
//                    error = _error
//                }
//            case let .failure(_error):
//                error = self.parseAFError(_error)
//                debugPrint(error!)
//            }
//            completion(flag, error)
//        }
//
//
//
////        session.request(url, method: httpMethod, parameters: parameters, encoding: encoding, headers: headers).responseJSON() {
////            response in
////            if response.result.isFailure {
////                error = NSError(domain:"", code:404, userInfo:[ NSLocalizedDescriptionKey: response.result.description]) as Error
////            } else {
////                if let _error = response.result.error as? AFError {
////                    error = self.parseAFError(_error)
////                } else {
////                    if let statusCode  = response.response?.statusCode{
////                        if 200...299 ~= statusCode {
////                            do {
////                                let json = try JSON(data: response.data!)
////                                for attr in json {
////                                    if attr.0 ==  searchString {
////                                        flag = attr.1.boolValue
////                                    }
////                                    if attr.0 ==  "error" {
////                                        error = NSError(domain:"", code:404 , userInfo:[ NSLocalizedDescriptionKey: attr.1.stringValue]) as Error
////                                    }
////                                }
////                            } catch let _error {
////                                error = _error
////                            }
////                        } else if 400...499 ~= statusCode {
////                            do {
////                                let json = try JSON(data: response.data!)
////                                error = NSError(domain:"", code:404 , userInfo:[ NSLocalizedDescriptionKey: json.rawString()!]) as Error
////                            } catch let _error {
////                                error = _error
////                            }
////                        }
////                    }
////                }
////            }
////            completion(flag, error)
//    }
//
//    func downloadImage(url urlString: String, progressClosure: @escaping (CGFloat) -> (), completion: @escaping (UIImage?, Error?) -> ()) {
//
//        var error: Error?
//        var url: URL!
//        if let _url = URL(string: urlString) {
//            url = _url
//        } else {
//            error = NSError(domain:"", code:523, userInfo:[ NSLocalizedDescriptionKey: "Incorrect URL provided"]) as Error
//            completion(nil, error!)
//        }
//
//        checkForReachability {
//            reachable in
//            if reachable == .Reachable {
//                self.checkTokenExpired() {
//                    success, error in
//                    if error != nil {
//                        completion(nil, error)
//                    } else if success {
//                        performRequest()
//                    }
//                }
//            } else {
//                error = NSError(domain:"", code:523, userInfo:[ NSLocalizedDescriptionKey: "Server is unreachable"]) as Error
//                completion(nil, error!)
//            }
//        }
//
//        func performRequest() {
//            AF.download(url)
//                .downloadProgress { progress in
//                    print("Download Progress: \(progress.fractionCompleted)")
//                    progressClosure(CGFloat(progress.fractionCompleted))
//                }
//                .responseData { response in
//                    if let data = response.value {
//                        let image = UIImage(data: data)
//                        completion(image, nil)
//                    } else {
//                        error = NSError(domain:"", code:523, userInfo:[ NSLocalizedDescriptionKey: "Image initialization failure"]) as Error
//                        completion(nil, error)
//                    }
//                }
//
//
////            session.request(url).downloadProgress(closure: {
////                progress in
////                let prog = CGFloat(progress.fractionCompleted)
////                percentageClosure(prog)
////            }).response(completionHandler: {
////                response in
////                if let data = response.data { response.request?.url
////                    if let image = UIImage(data: data) {
////                        completion(image, nil)
////                    } else {
////                        //Image init failure
////                        error = NSError(domain:"", code:523, userInfo:[ NSLocalizedDescriptionKey: "Image initialization failure"]) as Error
////                        completion(nil, error)
////                    }
////                } else {
////                    error = NSError(domain:"", code:523, userInfo:[ NSLocalizedDescriptionKey: "Image data error during download"]) as Error
////                    completion(nil, error)
////                }
////            })
//        }
//    }
//
//    func downloadImage(url urlString: String, completion: @escaping (UIImage?, Error?) -> ()) {
//        var error: Error?
//        var url: URL!
//        if let _url = URL(string: urlString) {
//            url = _url
//        } else {
//            error = NSError(domain:"", code:523, userInfo:[ NSLocalizedDescriptionKey: "Incorrect URL provided"]) as Error
//            completion(nil, error!)
//        }
//
//        checkForReachability {
//            reachable in
//            if reachable == .Reachable {
//                self.checkTokenExpired() {
//                    success, error in
//                    if error != nil {
//                        completion(nil, error)
//                    } else if success {
//                        performRequest()
//                    }
//                }
//            } else {
//                error = NSError(domain:"", code:523, userInfo:[ NSLocalizedDescriptionKey: "Server is unreachable"]) as Error
//                completion(nil, error!)
//            }
//        }
//
//        func performRequest() {
//            AF.download(url).responseData { response in
//                    if let data = response.value {
//                        let image = UIImage(data: data)
//                        completion(image, nil)
//                    } else {
//                        error = NSError(domain:"", code:523, userInfo:[ NSLocalizedDescriptionKey: "Image initialization failure"]) as Error
//                        completion(nil, error)
//                    }
//                }
//
////            session.request(url).response(completionHandler: {
////                response in
////                if let data = response.data { response.request?.url
////                    if let image = UIImage(data: data) {
////                        completion(image, nil)
////                    } else {
////                        //Image init failure
////                        error = NSError(domain:"", code:523, userInfo:[ NSLocalizedDescriptionKey: "Image initialization failure"]) as Error
////                        completion(nil, error)
////                    }
////                } else {
////                    error = NSError(domain:"", code:523, userInfo:[ NSLocalizedDescriptionKey: "Image data error during download"]) as Error
////                    completion(nil, error)
////                }
////            })
//        }
//    }
//
//    //    private func _performRequest(url: URL, httpMethod: HTTPMethod,  parameters: Parameters? = nil, encoding: ParameterEncoding = JSONEncoding.default, completion: @escaping(Error?)->()) {
//    //        var error: Error?
//    //        let headers: HTTPHeaders = [
//    //            "Authorization": "Bearer " + (KeychainService.loadAccessToken()! as String) as String,
//    //            "Content-Type": "application/json"
//    //        ]
//    //
//    //        session.request(url, method: httpMethod, parameters: parameters, encoding: encoding, headers: headers).response() {
//    //            response in
//    //            if response.result.isFailure {
//    //                print(response.result.debugDescription)
//    //            }
//    //            if let _error = response.result.error as? AFError {
//    //                error = self.parseAFError(_error)
//    //            } else {
//    //                if let statusCode  = response.response?.statusCode{
//    //                    if 400...499 ~= statusCode {
//    //                        do {
//    //                            let errorJSON = try JSON(data: response.data!)
//    //                            error = NSError(domain:"", code:404, userInfo:[ NSLocalizedDescriptionKey: errorJSON.rawString()!]) as Error
//    //                        } catch let _error {
//    //                            error = NSError(domain:"", code:404, userInfo:[ NSLocalizedDescriptionKey: _error.localizedDescription]) as Error
//    //                        }
//    //                    }
//    //                }
//    //            }
//    //            completion(error)
//    //        }
//    //    }
//
//    func cancelAllRequests() {
//        AF.session.getAllTasks { (tasks) in
//                    tasks.forEach {$0.cancel() }
//                }
////        self.session.session.getTasksWithCompletionHandler {
////            (sessionDataTask, uploadData, downloadData) in
////            sessionDataTask.forEach { $0.cancel() }
////            uploadData.forEach { $0.cancel() }
////            downloadData.forEach { $0.cancel() }
////        }
//    }
//}
//
