//
//  ServerAPI.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 23.12.2021.
//  Copyright © 2021 Pavel Bukharov. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import simd
import CoreAudio

class API {
    static let shared = API()
    public let profiles = Profiles()
    public let surveys = Polls()
    private init() {
        profiles.parent = self
        surveys.parent = self
//        self.sessionManager.session.configuration.timeoutIntervalForRequest = 10
    }
    
    public var sessionManager: Session = {
        let configuration = URLSessionConfiguration.af.default
        configuration.timeoutIntervalForRequest = 21
        configuration.waitsForConnectivity = true
//        configuration.requestCachePolicy = .returnCacheDataElseLoad
        
        let responseCacher = ResponseCacher(behavior: .modify { _, response in
            let userInfo = ["date": Date()]
            return CachedURLResponse(
                response: response.response,
                data: response.data,
                userInfo: userInfo,
                storagePolicy: .allowed)
        })
        
        let interceptor = APIRequestInterceptor()
        
        return Session(configuration: configuration, interceptor: interceptor, eventMonitors: [NetworkLogger()])
//        return Session(configuration: configuration, interceptor: interceptor, cachedResponseHandler: responseCacher, eventMonitors: [NetworkLogger()])
    }()
    
//    public func setWaitsForConnectivity() {
//        let configuration = URLSessionConfiguration.af.default
//        configuration.timeoutIntervalForRequest = 21
//        configuration.waitsForConnectivity = true
//
////        let responseCacher = ResponseCacher(behavior: .modify { _, response in
////            let userInfo = ["date": Date()]
////            return CachedURLResponse(
////                response: response.response,
////                data: response.data,
////                userInfo: userInfo,
////                storagePolicy: .allowed)
////        })
//
//        let interceptor = APIRequestInterceptor()
//
//        sessionManager = Session(configuration: configuration, interceptor: interceptor, eventMonitors: [NetworkLogger()])
//    }
    
    class func prepareUserData(firstName: String?, lastName: String?, email: String?, gender: Gender?, birthDate: String?, city: City?, image: UIImage?, vkID: String?, vkURL: String?, facebookID: String?, facebookURL: String?) -> [String: Any] {
        
        var parameters = [String: Any]()
        if !firstName.isNil {
            parameters["owner.\(DjangoVariables.User.firstName)"] = firstName!
        }
        if !lastName.isNil {
            parameters["owner.\(DjangoVariables.User.lastName)"] = lastName!
        }
        if !email.isNil {
            parameters["owner.\(DjangoVariables.User.email)"] = email!
        }
        if !gender.isNil {
            parameters[DjangoVariables.UserProfile.gender] = gender!.rawValue
        }
        if !birthDate.isNil {
            parameters[DjangoVariables.UserProfile.birthDate] = birthDate!
        }
        if !vkID.isNil {
            parameters[DjangoVariables.UserProfile.vkID] = vkID!
        }
        if !vkURL.isNil {
            parameters[DjangoVariables.UserProfile.vkURL] = vkURL!
        }
        if !facebookID.isNil {
            parameters[DjangoVariables.UserProfile.facebookID] = facebookID!
        }
        if !facebookURL.isNil {
            parameters[DjangoVariables.UserProfile.facebookURL] = facebookURL!
        }
        if !image.isNil {
            parameters[DjangoVariables.UserProfile.image] = image!
        }
//        if !city.isNil {
//            parameters[DjangoVariables.UserProfile.city] = city!.id
////            parameters["\(DjangoVariables.UserProfile.city)"] = city!.id
//        }
        return parameters
    }

    
    private func headers() -> HTTPHeaders {
        let headers: HTTPHeaders = [
            "Authorization": "Bearer " + (KeychainService.loadAccessToken()! as String) as String,
            "Content-Type": "application/json"
        ]
        return headers
    }
    
    struct CustomGetEncoding: ParameterEncoding {
        func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
            var request = try URLEncoding().encode(urlRequest, with: parameters)
            request.url = URL(string: request.url!.absoluteString.replacingOccurrences(of: "%5B%5D=", with: "="))
            return request
        }
    }
    struct CustomPostEncoding: ParameterEncoding {
        func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
            var request = try URLEncoding().encode(urlRequest, with: parameters)
            let httpBody = NSString(data: request.httpBody!, encoding: String.Encoding.utf8.rawValue)!
            request.httpBody = httpBody.replacingOccurrences(of: "%5B%5D=", with: "=").data(using: .utf8)
            return request
        }
    }
    
    public enum SurveyType: String {
        case Top,New,All,Own,Favorite, Hot, HotExcept, User, UserFavorite
        
        func getURL() -> URL {
            let url = URL(string: API_URLS.BASE)!//.appendingPathComponent(SERVER_URLS.GET_CONFIRMATION_CODE)
            switch self {
            case .Top:
                return url.appendingPathComponent(API_URLS.SURVEYS_TOP)
            case .New:
                return url.appendingPathComponent(API_URLS.SURVEYS_NEW)
            case .All:
                return url.appendingPathComponent(API_URLS.SURVEYS_ALL)
            case .Own:
                return url.appendingPathComponent(API_URLS.SURVEYS_OWN)
            case .Favorite:
                return url.appendingPathComponent(API_URLS.SURVEYS_FAVORITE)
            case .Hot:
                return url.appendingPathComponent(API_URLS.SURVEYS_HOT)
                //            case .HotExcept:
                //                return url.appendingPathComponent(SERVER_URLS.SURVEYS_HOT_EXCEPT)
            case .User:
                return url.appendingPathComponent(API_URLS.SURVEYS_BY_OWNER)
            case .UserFavorite:
                return url.appendingPathComponent(API_URLS.SURVEYS_FAVORITE_LIST_BY_OWNER)
            default:
                return url.appendingPathComponent(API_URLS.SURVEYS_ALL)
            }
        }
    }
    private var isProxyEnabled: Bool? {
        didSet {
            if isProxyEnabled != nil && isProxyEnabled != oldValue {
                if isProxyEnabled == true {
                    var proxyDictionary = [AnyHashable: Any]()
                    proxyDictionary[kCFNetworkProxiesHTTPProxy as String] = "68.183.56.239"
                    proxyDictionary[kCFNetworkProxiesHTTPPort as String] = 8080
                    proxyDictionary[kCFNetworkProxiesHTTPEnable as String] = 1
                    proxyDictionary[kCFStreamPropertyHTTPSProxyHost as String] = "68.183.56.239"
                    proxyDictionary[kCFStreamPropertyHTTPSProxyPort as String] = 8080
                    self.sessionManager.sessionConfiguration.timeoutIntervalForRequest = 15
                    self.sessionManager.sessionConfiguration.connectionProxyDictionary = proxyDictionary
                } else {
                    self.sessionManager.sessionConfiguration.timeoutIntervalForRequest = 10
                }
            }
        }
    }
    
    private func checkForReachability(completion: @escaping(ApiReachabilityState) -> ()) {
        let url = URL(string: API_URLS.BASE)!.appendingPathComponent(API_URLS.CURRENT_TIME)
        self.sessionManager.request(url, method: .get, parameters: [:], encoding: URLEncoding(), headers: nil).response { response in
            var state = ApiReachabilityState.None
            switch response.result {
            case .success:
                state = ApiReachabilityState.Reachable
            case .failure(let error):
                print(error.localizedDescription)
            }
            apiReachability = state
            completion(state)
        }
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
            case .customValidationFailed(let description):
                errorDescription += ("Validation error: \(description.localizedDescription)")
            }
        case .responseSerializationFailed(let reason):
            errorDescription = ("Response serialization failed: \(error.localizedDescription)")
            errorDescription += ("Failure Reason: \(reason)")
            
            switch reason {
            case .customSerializationFailed(let error):
                errorDescription += ("A custom response serializer failed due to error: \(error)")
            case .decodingFailed(let error):
                errorDescription += ("A DataDecoder failed to decode the response due to: \(error)")
            case .inputDataNilOrZeroLength:
                errorDescription += ("The server response contained no data or the data was zero length")
            case .inputFileNil:
                errorDescription += ("The file containing the server response did not exist")
            case .inputFileReadFailed(let url):
                errorDescription += ("The file containing the server response could not be read from the associated URL: \(url)")
            case .invalidEmptyResponse(let type):
                errorDescription += ("Generic serialization failed for an empty response that wasn’t type Empty but instead the associated type: \(type)")
            case .jsonSerializationFailed(let error):
                errorDescription += ("JSON serialization failed with an underlying system error: \(error)")
            case .stringSerializationFailed(let encoding):
                errorDescription += ("String serialization failed using the provided String.Encoding: \(encoding)")
            }
        default:
            errorDescription += "Error: \(error.localizedDescription)"
        }
        return NSError(domain:"", code:523, userInfo:[ NSLocalizedDescriptionKey: errorDescription]) as Error
    }
    
//    private func parseDjangoError(_ json: JSON) -> TokenState {
//        var _tokenState = TokenState.Unassigned
//        for attr in json {
//            if attr.0 == "error_description" {
//                //                if let errorDesc = attr.1.stringValue.lowercased() as? String {
//                let errorDesc = attr.1.stringValue.lowercased()
//                if errorDesc.contains(DjangoError.InvalidGrant.rawValue) {
//                    _tokenState = .WrongCredentials
//                } else if errorDesc.contains(DjangoError.AccessDenied.rawValue) {
//                    _tokenState = .AccessDenied
//                } else if errorDesc.contains(DjangoError.Authentication.ConnectionFailed.rawValue) {
//                    _tokenState = .ConnectionError
//                } else {
//                    print(attr.1.stringValue)
//                    fatalError("func parseDjangoError failed to downcast attr.1.string")
//                }
//                //                }
//            }
//        }
//        return _tokenState
//    }
    
//    private func parseDebugDescription(_ debugDescription: String) -> TokenState {
//        if debugDescription.contains("NSURLErrorDomain Code=-1004") {
//            return TokenState.ConnectionError
//        }
//        return TokenState.Error
//    }
    
    public func getEmailConfirmationCode(completion: @escaping(Result<JSON, Error>)->()) {
        self.request(url: URL(string: API_URLS.BASE)!.appendingPathComponent(API_URLS.GET_CONFIRMATION_CODE), httpMethod: .get, parameters: nil, encoding: URLEncoding.default) { completion($0) }
    }
    
    func getUserData(completion: @escaping(Result<JSON, Error>)->()) {
        request(url: URL(string: API_URLS.BASE)!.appendingPathComponent(API_URLS.CURRENT_USER), httpMethod: .get, parameters: nil, encoding: URLEncoding.default) { completion($0) }
    }
    
    func getUserDataAsync() async throws -> Data {
        guard let url = URL(string: API_URLS.BASE)?.appendingPathComponent(API_URLS.CURRENT_USER) else { throw APIError.invalidURL }
        do {
            return try await requestAsync(url: url, httpMethod: .get, parameters: nil, encoding: URLEncoding.default, headers: headers())
        } catch {
            throw error
        }
    }
    
    func getUserDataOrNilAsync() async -> Data? {
        guard let url = URL(string: API_URLS.BASE)?.appendingPathComponent(API_URLS.CURRENT_USER_OR_NULL) else { fatalError(APIError.invalidURL.localizedDescription) }
        do {
            return try await requestAsync(url: url, httpMethod: .get, parameters: nil, encoding: URLEncoding.default, headers: headers())
        } catch {
            return nil
        }
    }
    
    func loginViaMail(username: String, password: String, completion: @escaping (Result<Bool, Error>) -> ()) {
        guard let url = URL(string: API_URLS.BASE)?.appendingPathComponent(API_URLS.TOKEN) else { completion(.failure(APIError.invalidURL)); return }
        let parameters = ["client_id": API_URLS.CLIENT_ID, "client_secret": API_URLS.CLIENT_SECRET, "grant_type": "password", "username": "\(username)", "password": "\(password)"]
        self.sessionManager.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil).response { response in
            switch response.result {
            case .success(let value):
                    guard let statusCode = response.response?.statusCode else { completion(.failure(APIError.httpStatusCodeMissing)); return }
                    guard let data = value else { completion(.failure(APIError.badData)); return }
                do {
                    //TODO: Определиться с инициализацией JSON
                    let json = try JSON(data: data, options: .mutableContainers)
                    guard 200...299 ~= statusCode else {
                        completion(.failure(APIError.backend(code: statusCode, description: json.rawString())))
                        return
                    }
                    completion(saveTokenInKeychain(json: json))
                } catch let error {
                    completion(.failure(error))
                }
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    ///Email/username auhorization. Store access token if finished successful
    func loginAsync(username: String, password: String) async throws  {
        guard let url = URL(string: API_URLS.BASE)?.appendingPathComponent(API_URLS.TOKEN) else { throw APIError.invalidURL }
        let parameters = ["client_id": API_URLS.CLIENT_ID, "client_secret": API_URLS.CLIENT_SECRET, "grant_type": "password", "username": "\(username)", "password": "\(password)"]
        do {
            let data = try await requestAsync(url: url, httpMethod: .post, parameters: parameters, encoding: URLEncoding())
            let json = try JSON(data: data, options: .mutableContainers)
            saveTokenInKeychain(json: json)
        } catch let error {
            throw error
        }
    }
    
    ///Third-party auhorization. Store access token if finished successful
    func loginViaProvider(provider: AuthProvider, token: String, completion: @escaping (Result<Bool, Error>) -> ()) {
        guard let url = URL(string: API_URLS.BASE)?.appendingPathComponent(API_URLS.TOKEN_CONVERT) else { completion(.failure(APIError.invalidURL)); return }
        let parameters = ["client_id": API_URLS.CLIENT_ID, "client_secret": API_URLS.CLIENT_SECRET, "grant_type": "convert_token", "backend": "\(provider.rawValue.lowercased())", "token": "\(token)"]
        self.sessionManager.request(url, method: .post, parameters: parameters, encoding: URLEncoding(), headers: nil).response { response in
            switch response.result {
            case .success(let value):
                guard let statusCode = response.response?.statusCode else { completion(.failure(APIError.httpStatusCodeMissing)); return }
                guard let data = value else { completion(.failure(APIError.badData)); return }
                do {
                    //TODO: Определиться с инициализацией JSON
                    let json = try JSON(data: data, options: .mutableContainers)
                guard 200...299 ~= statusCode else { completion(.failure(APIError.backend(code: statusCode, description: json.rawString()))); return }
                    completion(saveTokenInKeychain(json: json))
                } catch let error {
                    completion(.failure(error))
                }
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    func loginViaProviderAsync(provider: AuthProvider, token: String) async throws  {
        guard let url = URL(string: API_URLS.BASE)?.appendingPathComponent(API_URLS.TOKEN_CONVERT) else { throw APIError.invalidURL }
        let parameters = ["client_id": API_URLS.CLIENT_ID, "client_secret": API_URLS.CLIENT_SECRET, "grant_type": "convert_token", "backend": "\(provider.rawValue.lowercased())", "token": "\(token)"]
        do {
            let data = try await requestAsync(url: url, httpMethod: .post, parameters: parameters, encoding: URLEncoding(), accessControl: false)
            let json = try JSON(data: data, options: .mutableContainers)
            saveTokenInKeychain(json: json)
        } catch let error {
            throw error
        }
    }
    
    func logout(completion: @escaping (Result<Bool, Error>) -> ()) {
        guard let url = URL(string: API_URLS.BASE)?.appendingPathComponent(API_URLS.TOKEN_REVOKE) else { completion(.failure(APIError.invalidURL)); return }
        guard let token = KeychainService.loadAccessToken() as String?, !token.isEmpty else {
            UserDefaults.clear()
            Surveys.shared.eraseData()
            Userprofiles.shared.eraseData()
            SurveyReferences.shared.eraseData()
            FBWorker.logout()
            VKWorker.logout()
            completion(.success(true))
            return
        }
        let parameters = ["client_id": API_URLS.CLIENT_ID, "client_secret": API_URLS.CLIENT_SECRET, "token": token]
        
        self.sessionManager.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default).response { response in
            switch response.result {
            case .success(let value):
                guard let statusCode = response.response?.statusCode else { completion(.failure(APIError.httpStatusCodeMissing)); return }
                UserDefaults.clear()
                Surveys.shared.eraseData()
                Userprofiles.shared.eraseData()
                SurveyReferences.shared.eraseData()
                FBWorker.logout()
                VKWorker.logout()
                completion(.success(true))
//                if 200...299 ~= statusCode {
//                    completion(saveTokenInKeychain(json: json))
//                } else if 400...499 ~= statusCode {
//                    guard let description = json.rawString() else { completion(.failure(APIError.unexpected(code: statusCode)))}
//                    completion(.failure(APIError.serverResponse(description: description)))
//                }
            case let .failure(error):
                completion(.failure(self.parseAFError(error)))
            }
        }
    }
    
    func signup(email: String, password: String, username: String, completion: @escaping (Result<Bool,Error>) -> ()) {
        guard let url = URL(string: API_URLS.BASE)?.appendingPathComponent(API_URLS.SIGNUP) else { completion(.failure(APIError.invalidURL)); return }
        let parameters = ["client_id": API_URLS.CLIENT_ID, "grant_type": "password", "email": "\(email)", "password": "\(password)", "username": "\(username)"]
        self.sessionManager.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default).response { response in
            switch response.result {
            case .success(let value):
                guard let statusCode = response.response?.statusCode else { completion(.failure(APIError.httpStatusCodeMissing)); return }
                guard let data = value else { completion(.failure(APIError.badData)); return }
                do {
                    //TODO: Определиться с инициализацией JSON
                    let json = try JSON(data: data, options: .mutableContainers)
                    guard 200...299 ~= statusCode else { completion(.failure(APIError.backend(code: statusCode, description: json.rawString()))); return }
                    self.loginViaMail(username: username, password: password) { completion($0) }
                }  catch let error {
                    completion(.failure(error))
                }
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    func getProfileNeedsUpdate(completion: @escaping(Result<Bool, Error>)->()) {
        request(url: URL(string: API_URLS.BASE)!.appendingPathComponent(API_URLS.PROFILE_NEEDS_UPDATE), httpMethod: .get) { result in
            switch result {
            case .success(let json):
                guard let id = json["userprofile_id"].int, let needsUpdate = json["needs_update"].bool else { completion(.failure("User id is not found in response")); return }
                UserDefaults.Profile.id = id
                completion(.success(needsUpdate))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getProfileNeedsUpdateAsync() async throws -> Bool {
        guard let url = URL(string: API_URLS.BASE)?.appendingPathComponent(API_URLS.PROFILE_NEEDS_UPDATE) else { throw APIError.invalidURL }
        do {
            let data = try await requestAsync(url: url, httpMethod: .get, headers: headers())
            let json = try JSON(data: data, options: .mutableContainers)
            guard let id = json["userprofile_id"].int, let needsUpdate = json["needs_update"].bool else { throw "Invalid JSON data" }
            UserDefaults.Profile.id = id
            return needsUpdate
        } catch let error {
            throw error
        }
    }
    
    func isUsernameEmailAvailable(email: String, username: String, completion: @escaping(Result<Bool, Error>)->()) {
        self.request(url: URL(string: API_URLS.BASE)!.appendingPathComponent(email.isEmpty ? API_URLS.USERNAME_EXISTS : API_URLS.EMAIL_EXISTS), httpMethod: .get, parameters: email.isEmpty ? ["username": username] : ["email": email], encoding: URLEncoding.default) { result in
            switch result {
            case .success(let json):
                print(json)
                completion(.success(json["exists"].boolValue))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    
    func updateUserprofile(user: Userprofile, uploadProgress: @escaping(Double) -> (), completion: @escaping(Result<JSON, Error>) -> ()) {
            guard let url = URL(string: API_URLS.BASE)?.appendingPathComponent(API_URLS.PROFILES + "\(UserDefaults.Profile.id!)" + "/") else {
                completion(.failure(APIError.invalidURL))
                return
            }
        //TODO: - encode Userprofile
        var dict: [String: Any] = [:]// = user.encoded

//            if let image = data["image"] as? UIImage {
//                dict.removeValue(forKey: "image")
            if let image = dict.removeValue(forKey: "image") as? UIImage {
                assert(dict["image"] == nil)
                let multipartFormData = MultipartFormData()
                var imgExt: FileFormat = .Unknown
                var imageData: Data?
                if let data = image.jpegData(compressionQuality: 1) {
                    imageData = data
                    imgExt = .JPEG
                } else if let data = image.pngData() {
                    imageData = data
                    imgExt = .PNG
                }
                guard imageData != nil else { completion(.failure(APIError.badData)); return }
                multipartFormData.append(imageData!, withName: "image", fileName: "\(String(describing: UserDefaults.Profile.id!)).\(imgExt.rawValue)", mimeType: "jpg/png")
                for (key, value) in dict {
                    if value is String || value is Int {
                        multipartFormData.append("\(value)".data(using: .utf8)!, withName: key)
                    }
                }
                uploadMultipartFormData(url: url, method: .patch, multipartDataForm: multipartFormData, uploadProgress:  { uploadProgress($0) }) { completion($0) }
            } else {
                request(url: url, httpMethod: .patch, parameters: dict, encoding: JSONEncoding.default) { completion($0) }
            }
            
            
            
            
            //                self.sessionManager.upload(multipartFormData: { multipartFormData in
            //
            //
            //                    var imgExt: FileFormat = .Unknown
            //                    var imageData: Data?
            //                    if let data = image.jpegData(compressionQuality: 1) {
            //                        imageData = data
            //                        imgExt = .JPEG
            //                    } else if let data = image.pngData() {
            //                        imageData = data
            //                        imgExt = .PNG
            //                    }
            //                    guard imageData != nil else { completion(.failure(APIError.badData)) }
            //                    multipartFormData.append(imageData!, withName: "image", fileName: "\(String(describing: AppData.shared.profile.id)).\(imgExt.rawValue)", mimeType: "jpg/png")
            //                    for (key, value) in dict {
            //                        if value is String || value is Int {
            //                            multipartFormData.append("\(value)".data(using: .utf8)!, withName: key)
            //                        }
            //                    }
            //                }, to: url, method: HTTPMethod.patch, headers: headers()).uploadProgress(queue: .main, closure: { progress in
            //                    //TODO: - Add completionPercentage closure
            //                    print("Upload Progress: \(progress.fractionCompleted)")
            //                }).response { response in
            //                    switch response.result {
            //                    case .success(let value):
            //                        guard let data = value else { completion(.failure(APIError.badData)) }
            //                        do {
            //                            //TODO: Определиться с инициализацией JSON
            //                            let json = try JSON(data: data, options: .mutableContainers)
            //                            if let statusCode = response.response?.statusCode {
            //                                if 200...299 ~= statusCode {
            //                                    print("Upload complete: \(json)")
            //                                } else if 400...499 ~= statusCode {
            //                                    guard let description = json.rawString() else { completion(.failure(APIError.unexpected(code: statusCode)))}
            //                                    completion(.failure(APIError.backend(description: description)))
            //                                } else {
            //                                    completion(.failure(APIError.unexpected(code: statusCode)))
            //                                }
            //                            }
            //                        }  catch let error {
            //                            completion(.failure(error))
            //                        }
            //                    case let .failure(error):
            //                        completion(.failure(error))
            //                    }
            //                }
            //                self.sessionManager.upload(multipartFormData: { multipartFormData in
            //                    var imgExt: FileFormat = .Unknown
            //                    var imageData: Data?
            //                    if let data = image.jpegData(compressionQuality: 1) {
            //                        imageData = data
            //                        imgExt = .JPEG
            //                    } else if let data = image.pngData() {
            //                        imageData = data
            //                        imgExt = .PNG
            //                    }
            //                    multipartFormData.append(imageData!, withName: "image", fileName: "\(AppData.shared.userprofile.ID!).\(imgExt.rawValue)", mimeType: "jpg/png")
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
            //                _performRequest(url: url, httpMethod: .patch, parameters: data, encoding: JSONEncoding.default, completion: completion)
            //            }
        
    }
    
    func updateUserprofile(data: [String: Any], uploadProgress: @escaping(Double) -> (), completion: @escaping(Result<JSON, Error>) -> ()) {
        guard let url = URL(string: API_URLS.BASE)?.appendingPathComponent(API_URLS.PROFILES + "\(UserDefaults.Profile.id!)" + "/") else {
            completion(.failure(APIError.invalidURL))
            return
        }
        var dict = data
        //            if let image = data["image"] as? UIImage {
        //                dict.removeValue(forKey: "image")
        if let image = dict.removeValue(forKey: "image") as? UIImage {
            assert(dict["image"] == nil)
            let multipartFormData = MultipartFormData()
            var fileFormat: FileFormat = .Unknown
            var imageData: Data!
            if let data = image.jpegData(compressionQuality: 1) {
                imageData = data
                fileFormat = .JPEG
            } else if let data = image.pngData() {
                imageData = data
                fileFormat = .PNG
            }
            guard imageData != nil, fileFormat != .Unknown else { completion(.failure(APIError.badData)); return }
//            guard imageData != nil else { completion(.failure(APIError.badData)); return }
            multipartFormData.append(imageData, withName: "image", fileName: "\(String(describing: UserDefaults.Profile.id!)).\(fileFormat)", mimeType: "jpg/png")
            for (key, value) in dict {
                if value is String || value is Int {
                    multipartFormData.append("\(value)".data(using: .utf8)!, withName: key)
                }
            }
            uploadMultipartFormData(url: url, method: .patch, multipartDataForm: multipartFormData, uploadProgress:  { uploadProgress($0) }) { completion($0) }
        } else {
            request(url: url, httpMethod: .patch, parameters: dict, encoding: JSONEncoding.default) { completion($0) }
        }
    }
    
    
    
    func getEmailVerification(completion: @escaping (Result<Bool, Error>) -> ()) {
        request(url: URL(string: API_URLS.BASE)!.appendingPathComponent(API_URLS.GET_EMAIL_VERIFIED), httpMethod: .get) { result in
                    switch result {
                    case .success(let json):
                        completion(.success(json[DjangoVariables.UserProfile.isEmailVerified].boolValue))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
    }
    
    
    
    ///Check token expiration time, refresh if needed
    private func accessControl(completion: @escaping (Result<Bool, Error>) -> ()) {
        guard let expiryDate = (KeychainService.loadTokenExpireDateTime() as String?)?.toDateTime() else {
            completion(.failure("Can't retrieve token expiration date from KeychainService"))
            return
        }
        if Date() >= expiryDate {
            refreshAccessToken { result in
                completion(result)
            }
        } else {
            completion (.success(true))
        }
    }
    
    private func accessControlAsync() async throws {
        func refreshAccessTokenAsync() async throws {
            guard let refreshToken = (KeychainService.loadRefreshToken() as String?) else {
                throw "Error occured while retrieving refresh token from KeychainService"
            }
            print(refreshToken)
            let parameters = ["client_id": API_URLS.CLIENT_ID, "client_secret": API_URLS.CLIENT_SECRET, "grant_type": "refresh_token", "refresh_token": "\(refreshToken)"]
            guard let url = URL(string: API_URLS.BASE)?.appendingPathComponent(API_URLS.TOKEN) else {
                throw APIError.invalidURL
            }
            
            do {
                let data = try await requestAsync(url: url, httpMethod: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil, accessControl: false)
                let json = try JSON(data: data, options: .mutableContainers)
                saveTokenInKeychain(json: json)
            } catch {
                throw error
            }
        }
        
        guard let string = KeychainService.loadTokenExpireDateTime() as String?,
              !string.isEmpty,
              let expiryDate = string.dateTime else {
            throw "Can't retrieve token expiration date from KeychainService"
        }
        guard Date() >= expiryDate else { return }
        do {
            try await refreshAccessTokenAsync()
        } catch {
            throw error
        }
    }

    
    private func refreshAccessToken(completion: @escaping (Result<Bool, Error>) -> ()) {
        guard let refreshToken = (KeychainService.loadRefreshToken() as String?) else {
            completion(.failure("Error occured while retrieving refresh token from KeychainService"))
            return
        }
        let parameters = ["client_id": API_URLS.CLIENT_ID, "client_secret": API_URLS.CLIENT_SECRET, "grant_type": "refresh_token", "refresh_token": "\(refreshToken)"]
        guard let url = URL(string: API_URLS.BASE)?.appendingPathComponent(API_URLS.TOKEN) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        self.sessionManager.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil).response { response in
            switch response.result {
            case .success(let value):
                guard let statusCode = response.response?.statusCode else { completion(.failure(APIError.httpStatusCodeMissing)); return }
                guard let data = value else { completion(.failure(APIError.badData)); return }
                do {
                    let json = try JSON(data: data, options: .mutableContainers)
                    guard 200...299 ~= statusCode else { completion(.failure(APIError.backend(code: statusCode, description: json.rawString()))); return }
                    completion(saveTokenInKeychain(json: json))
                } catch let _error {
                    completion(.failure(_error))
                }
            case let .failure(_error):
                completion(.failure(_error))
            }
        }
    }
    
    func initialLoad(completion: @escaping(Result<JSON,Error>)->()) {
        guard let url = URL(string: API_URLS.BASE)?.appendingPathComponent(API_URLS.APP_LAUNCH) else { completion(.failure(APIError.invalidURL)); return }
        self.request(url: url, httpMethod: .get, parameters: nil, encoding: URLEncoding.default) { result in
            completion(result)
        }
    }
    
    
    func downloadSurveys(type: SurveyType, completion: @escaping(Result<JSON, Error>)->()) {
        //TODO: - Add survey type
//        guard let url = URL(string: API_URLS.BASE)?.appendingPathComponent(API_URLS.APP_LAUNCH) else { completion(.failure(APIError.invalidURL)); return }
        self.request(url: type.getURL(), httpMethod: .get, parameters: nil, encoding: URLEncoding.default) { result in
            completion(result)
        }
    }
    
    func downloadSurveysAsync(type: SurveyType, parameters: Parameters? = nil) async throws -> Data{
        return try await requestAsync(url: type.getURL(), httpMethod: .get, parameters: parameters, encoding: CustomGetEncoding(), headers: headers())
    }
    
    func appLaunch() async throws -> JSON {
        guard let url = URL(string: API_URLS.BASE)?.appendingPathComponent(API_URLS.APP_LAUNCH) else {
            throw APIError.notFound
        }
        do {
            let data = try await requestAsync(url: url, httpMethod: .get, parameters: [:], encoding: URLEncoding.default, headers: headers())
            do {
                let json = try JSON(data: data, options: .mutableContainers)
                return json
            } catch {
                throw error
            }
        } catch let error {
            throw error
        }
    }
    
    func requestAsync(url: URL, httpMethod: HTTPMethod,  parameters: Parameters? = nil, encoding: ParameterEncoding = JSONEncoding.default, headers: HTTPHeaders? = nil, accessControl: Bool = true) async throws -> Data {
        
        func request() async throws -> Data {
            try await withUnsafeThrowingContinuation { (continuation: UnsafeContinuation<Data,Error>) in
                self.sessionManager.request(url, method: httpMethod, parameters: parameters, encoding: encoding, headers: headers).responseData { response in
                    switch response.result {
                    case .success(let data):
                        guard let statusCode = response.response?.statusCode else { continuation.resume(throwing: APIError.httpStatusCodeMissing); return }
                        do {
                            let json = try JSON(data: data, options: .mutableContainers)
                            guard 200...299 ~= statusCode else { continuation.resume(throwing: APIError.backend(code: statusCode, description: json.rawString())); return }
                            continuation.resume(returning: data)
                            return
                        } catch {
                            continuation.resume(throwing: error)
                            return
                        }
                    case let .failure(error):
#if DEBUG
                        print(error.localizedDescription)
#endif
                        continuation.resume(throwing: error)
                        return
                    }
                }
            }
        }
        
        do {
            if accessControl {
                try await accessControlAsync()
                return try await request()
            } else {
                return try await request()
            }
        } catch {
            throw error
        }
    }
    
    func downloadTopics(completion: @escaping(Result<JSON, Error>)->()) {
        guard let url = URL(string: API_URLS.BASE)?.appendingPathComponent(API_URLS.CATEGORIES) else { completion(.failure(APIError.invalidURL)); return }
        self.request(url: url, httpMethod: .get, parameters: nil, encoding: URLEncoding.default) { result in
            completion(result)
        }
    }


    func downloadTotalSurveysCount(completion: @escaping(Result<JSON, Error>)->()) {
                guard let url = URL(string: API_URLS.BASE)?.appendingPathComponent(API_URLS.SURVEYS_TOTAL_COUNT) else { completion(.failure(APIError.invalidURL)); return }
                self.request(url: url, httpMethod: .get, parameters: nil, encoding: URLEncoding.default) { result in
                    completion(result)
                }
    }
    
    func downloadSurveys(topic: Topic, completion: @escaping(Result<JSON, Error>)->()) {
        guard let url = URL(string: API_URLS.BASE)?.appendingPathComponent(API_URLS.SURVEYS_BY_CATEGORY) else { completion(.failure(APIError.invalidURL)); return }
        self.request(url: url, httpMethod: .get, parameters: ["category_id": topic.id], encoding: URLEncoding.default) { result in
            completion(result)
        }
    }
    
    func downloadSurvey(surveyReference: SurveyReference, incrementCounter: Bool = false, completion: @escaping(Result<JSON, Error>)->()) {
        guard let url = URL(string: API_URLS.BASE)?.appendingPathComponent(API_URLS.SURVEYS + "\(surveyReference.id)/") else { completion(.failure(APIError.invalidURL)); return }
        self.request(url: url, httpMethod: .get, parameters: incrementCounter ? ["add_view_count": true] : nil, encoding: URLEncoding.default) { result in
            completion(result)
        }
    }
    
    func downloadSurveyAsync(reference: SurveyReference, incrementCounter: Bool = false) async throws {
        guard let url = URL(string: API_URLS.BASE)?.appendingPathComponent(API_URLS.SURVEYS + "\(reference.id)/") else { throw APIError.invalidURL }
        
        do {
            let data = try await requestAsync(url: url, httpMethod: .get, parameters: incrementCounter ? ["add_view_count": true] : nil, encoding: URLEncoding.default, headers: headers())
            let json = try JSON(data: data, options: .mutableContainers)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategyFormatters = [ DateFormatter.ddMMyyyy,
                                                       DateFormatter.dateTimeFormatter,
                                                       DateFormatter.dateFormatter ]
            try decoder.decode(Survey.self, from: json.rawData())
        } catch let error {
            throw error
        }
    }
    
    func markFavorite(mark: Bool, surveyReference: SurveyReference, completion: @escaping(Result<JSON, Error>)->()) {
        guard let url = URL(string: API_URLS.BASE)?.appendingPathComponent(mark ? API_URLS.SURVEYS_ADD_FAVORITE : API_URLS.SURVEYS_REMOVE_FAVORITE) else { completion(.failure(APIError.invalidURL)); return }
        self.request(url: url, httpMethod: .get, parameters: ["survey_id": surveyReference.id], encoding: URLEncoding.default) { result in
            completion(result)
        }
    }
    
    
    
    func incrementViewCounter(surveyReference: SurveyReference, completion: @escaping(Result<JSON, Error>)->()) {
        guard let url = URL(string: API_URLS.BASE)?.appendingPathComponent(API_URLS.SURVEYS_ADD_VIEW_COUNT) else { completion(.failure(APIError.invalidURL)); return }
        self.request(url: url, httpMethod: .get, parameters: ["survey_id": surveyReference.id], encoding: URLEncoding.default) { result in
            completion(result)
        }
    }
    
    func incrementViewCounterAsync(surveyReference: SurveyReference) async throws {
        guard let url = URL(string: API_URLS.BASE)?.appendingPathComponent(API_URLS.SURVEYS_ADD_VIEW_COUNT) else { throw APIError.invalidURL }
        
        let data = try await requestAsync(url: url, httpMethod: .get, parameters: ["survey_id": surveyReference.id], encoding: URLEncoding.default, headers: headers())
        let json = try JSON(data: data, options: .mutableContainers)
        if let value = json["views"].int {
            await MainActor.run {
                surveyReference.survey?.views = value
            }
        } else if let error = json["views"].string {
            throw error
        } else {
            throw "Unknown error"
        }
    }
    
//    func getSurveyStats(surveyReference: SurveyReference, completion: @escaping(Result<JSON, Error>)->()) {
//        guard let url = URL(string: API_URLS.BASE)?.appendingPathComponent(API_URLS.SURVEYS_UPDATE_STATS) else { completion(.failure(APIError.invalidURL)); return }
//        self.request(url: url, httpMethod: .get, parameters: ["survey_id": surveyReference.id], encoding: URLEncoding.default) { completion($0) }
//    }
    
    func postPoll(survey: Survey, uploadProgress: @escaping(Double)->()?, completion: @escaping(Result<JSON, Error>)->()) {
        //TODO: - postSurvey replace dict()
        var dict: [String: AnyObject] = [:]//survey.dict
        guard let url = URL(string: API_URLS.BASE)?.appendingPathComponent(API_URLS.SURVEYS) else { completion(.failure(APIError.invalidURL)); return }
        request(url: url, httpMethod: .post, parameters: dict, encoding: JSONEncoding.default) { result in
            switch result {
            case .success(let json):
                completion(.success(json))
                if !survey.images.isEmpty {
                    for mediafile in survey.mediaWithImagesSortedByOrder {
                        let multipartFormData = MultipartFormData()
                        var imgExt: FileFormat = .Unknown
                        var imageData: Data?
                        if let data = mediafile.image!.jpegData(compressionQuality: 1) {
                            imageData = data
                            imgExt = .JPEG
                        } else if let data = mediafile.image!.pngData() {
                            imageData = data
                            imgExt = .PNG
                        }
                        multipartFormData.append(imageData!, withName: "image", fileName: "\(UserDefaults.Profile.id!).\(imgExt.rawValue)", mimeType: "jpg/png")
                        multipartFormData.append("\(survey.id)".data(using: .utf8)!, withName: "survey")
                        multipartFormData.append("\(mediafile.order)".data(using: .utf8)!, withName: "order")
                        multipartFormData.append("\(mediafile.title)".data(using: .utf8)!, withName: "title")
                        self.uploadMultipartFormData(url: url, method: .patch, multipartDataForm: multipartFormData, uploadProgress:  { uploadProgress($0) }) { completion($0) }
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    public func postVote(answer: Answer, completion: @escaping(Result<JSON, Error>)->()) {
        guard let url = URL(string: API_URLS.BASE)?.appendingPathComponent(API_URLS.SURVEYS) else { completion(.failure(APIError.invalidURL)); return }
        var parameters: [String: Any] = ["survey": answer.survey!.id, "answer": answer.id]
        if Surveys.shared.hot.count <= MIN_STACK_SIZE {
            let stackList = Surveys.shared.hot.map { $0.id }
            let rejectedList = Surveys.shared.rejected.map { $0.id }
            let completedList = [answer.id]
            let list = Array(Set(stackList + rejectedList + completedList))//Surveys.shared.stackObjects.filter({ $0.ID != nil }).map(){ $0.ID!}
            if !list.isEmpty {
                parameters["ids"] = list
            }
        }
        self.request(url: url, httpMethod: .post, parameters: parameters, encoding: JSONEncoding.default) { completion($0) }
    }
    
    public func vote(answer: Answer) async throws -> JSON {
        guard let url = URL(string: API_URLS.BASE)?.appendingPathComponent(API_URLS.VOTE) else { throw APIError.notFound }
        guard let surveyID = answer.survey?.id else { throw APIError.badData }
        var parameters: [String: Any] = ["survey": surveyID, "answer": answer.id]
        #if DEBUG
        print(parameters)
        #endif
        if Surveys.shared.hot.count <= MIN_STACK_SIZE {
            let stackList = Surveys.shared.hot.map { $0.id }
            let rejectedList = Surveys.shared.rejected.map { $0.id }
            let completedList = [answer.id]
            let list = Array(Set(stackList + rejectedList + completedList))
            if !list.isEmpty {
                parameters["ids"] = list
            }
        }
        
        do {
            let data = try await requestAsync(url: url, httpMethod: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers())
            let json = try JSON(data: data, options: .mutableContainers)
            await MainActor.run {
                Surveys.shared.completed.append(answer.survey!)
            }
//            answer.survey?.reference.isComplete = true
            return json
        } catch let error {
            throw error
        }
    }
    
//    @propertyWrapper
//    struct AccessControl {
//        var hasPermission: Result<Bool, Error>
//        var wrappedValue: Result<Bool, Error> {
//            get {
//                guard let expiryDate = (KeychainService.loadTokenExpireDateTime() as String?)?.toDateTime() else {
//                    return .failure("Can't retrieve token expiration date from KeychainService")
//                }
//                guard Date() >= expiryDate else { return .success(true) }
//                API.shared.refreshAccessToken { _ in return .success(true) }
//            }
//        }
//    }
//
//    @dynamicCallable
//    struct Route<S: Service, T: Encodable> {
//        private let route: (KeyValuePairs<String, Any>) -> T
//        let registerRoute: (S) -> Void
//
//        func dynamicallyCall(withKeywordArguments args: KeyValuePairs<String, Any>) -> T {
//            route(args)
//        }
//
//        init<A>(_ format: URLFormat<A>, handler: @escaping (A) -> T) {
//            self.route = { handler(packKeyValueParams($0)) }
//            self.registerRoute = { service in
//                service.routes {
//                    SwiftNIOMock.route(format) { (request, params, response, next) in
//                        let result = handler(params)
//                        try? response.sendJSON(.ok, value: result)
//                        next()
//                    }
//                }
//            }
//        }
//    }
//
    public func rejectSurvey(survey: Survey, completion: @escaping(Result<JSON, Error>)->()) {
        guard let url = URL(string: API_URLS.BASE)?.appendingPathComponent(API_URLS.SURVEYS_REJECT) else { completion(.failure(APIError.invalidURL)); return }
        var parameters: Parameters = ["survey": survey.id]
        if Surveys.shared.hot.count <= MIN_STACK_SIZE {
            let stackList = Surveys.shared.hot.map { $0.id }
            let rejectedList = Surveys.shared.rejected.map { $0.id }
            let list = Array(Set(stackList + rejectedList))//Surveys.shared.stackObjects.filter({ $0.ID != nil }).map(){ $0.ID!}
            if !list.isEmpty {
                let dict = list.asParameters(arrayParametersKey: "ids")
                parameters.merge(dict) {(current, _) in current}
            }
        }
        request(url: url, httpMethod: .post, parameters: parameters, encoding: JSONEncoding.default) { completion($0) }
    }
    
    public func postClaim(survey: Survey, reason: Claim, completion: @escaping(Result<JSON, Error>)->()) {
        guard let url = URL(string: API_URLS.BASE)?.appendingPathComponent(API_URLS.SURVEYS_CLAIM) else { completion(.failure(APIError.invalidURL)); return }
        let parameters: Parameters = ["survey": survey.id, "claim": reason.id]
        Surveys.shared.banSurvey(object: survey)
        request(url: url, httpMethod: .post, parameters: parameters, encoding: JSONEncoding.default) { completion($0) }
    }
    
    
    
    
    public func getUserStats(user: Userprofile, completion: @escaping(Result<JSON, Error>)->()) {
        guard let url = URL(string: API_URLS.BASE)?.appendingPathComponent(API_URLS.USER_PROFILE_STATS) else { completion(.failure(APIError.invalidURL)); return }
        let parameters = ["userprofile_id": user.id]
        request(url: url, httpMethod: .get, parameters: parameters, encoding: URLEncoding.default) { completion($0) }
    }
    
    public func loadSurveysByOwner(user: Userprofile, type: SurveyType, completion: @escaping(Result<JSON, Error>)->()) {
        let parameters = ["userprofile_id": user.id]
        request(url: type.getURL(), httpMethod: .get, parameters: parameters, encoding: URLEncoding.default) { completion($0) }
    }
    
    public func subsribeToUser(subscribe: Bool, user: Userprofile, completion: @escaping(Result<JSON, Error>)->()) {
        guard let url = API_URLS.Profiles.subscribe else { completion(.failure(APIError.invalidURL)); return }
        let parameters: Parameters = ["userprofile_id": user.id]
        request(url: url, httpMethod: .get, parameters: parameters, encoding: URLEncoding.default) { completion($0) }
    }
    
    class Profiles {
        weak var parent: API! = nil
        
        public func updateUserprofileAsync(data: [String: Any], uploadProgress: @escaping(Double) -> ()) async throws -> Data {
            guard let url = URL(string: API_URLS.BASE)?.appendingPathComponent(API_URLS.PROFILES + "\(UserDefaults.Profile.id!)" + "/") else { throw APIError.invalidURL
            }
            
            var dict = data
            if let image = dict.removeValue(forKey: "image") as? UIImage {
                assert(dict["image"] == nil)
                let multipartFormData = MultipartFormData()
                var fileFormat: FileFormat = .Unknown
                var imageData: Data!
                if let data = image.jpegData(compressionQuality: 1) {
                    imageData = data
                    fileFormat = .JPEG
                } else if let data = image.pngData() {
                    imageData = data
                    fileFormat = .PNG
                }
                guard imageData != nil, fileFormat != .Unknown else { throw APIError.badData }
                multipartFormData.append(imageData, withName: "image", fileName: "\(String(describing: UserDefaults.Profile.id!)).\(fileFormat)", mimeType: "jpg/png")
                for (key, value) in dict {
                    if value is String || value is Int {
                        multipartFormData.append("\(value)".data(using: .utf8)!, withName: key)
                    }
                }
                do {
                    return try await parent.uploadMultipartFormDataAsync(url: url, method: .patch, multipartDataForm: multipartFormData, uploadProgress:  { uploadProgress($0) })
                } catch {
                    throw error
                }
            } else {
                do {
                    return try await parent.requestAsync(url: url, httpMethod: .patch, parameters: dict, encoding: JSONEncoding.default, headers: parent.headers())//JSON(data: responseData, options: .mutableContainers)
                } catch {
                    throw error
                }
            }
        }
        
        public func subscribedFor() async throws {
            guard let url = API_URLS.Profiles.subscribedFor else { throw APIError.invalidURL }
            let parameters: Parameters = ["ids": Userprofiles.shared.subscribedFor.map{ return $0.id}]
            do {
                let data = try await parent.requestAsync(url: url, httpMethod: .get, parameters: parameters, encoding: CustomGetEncoding(), headers: parent.headers())
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategyFormatters = [ DateFormatter.ddMMyyyy,
                                                           DateFormatter.dateTimeFormatter,
                                                           DateFormatter.dateFormatter ]
                let instances = try decoder.decode([Userprofile].self, from: data)
                await MainActor.run {
                    instances.forEach { instance in
                        if Userprofiles.shared.subscribedFor.filter({ $0 == instance }).isEmpty {
                            if let existing = Userprofiles.shared.all.filter({ $0 == instance }).first {
                                Userprofiles.shared.subscribedFor.append(existing)
                            } else {
                                Userprofiles.shared.subscribedFor.append(instance)
                            }
                        }
                    }
                }
            } catch let error {
    #if DEBUG
                print(error)
    #endif
                throw error
            }
        }
        
        public func subscribers() async throws {
            guard let url = API_URLS.Profiles.subscribers else { throw APIError.invalidURL }
            let parameters: Parameters = ["ids": Userprofiles.shared.subscribers.map{ return $0.id}]
            do {
                let data = try await parent.requestAsync(url: url, httpMethod: .get, parameters: parameters, encoding: CustomGetEncoding(), headers: parent.headers())
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategyFormatters = [ DateFormatter.ddMMyyyy,
                                                           DateFormatter.dateTimeFormatter,
                                                           DateFormatter.dateFormatter ]
                let instances = try decoder.decode([Userprofile].self, from: data)
                await MainActor.run {
                    instances.forEach { instance in
                        if Userprofiles.shared.subscribers.filter({ $0 == instance }).isEmpty {
                            if let existing = Userprofiles.shared.all.filter({ $0 == instance }).first {
                                Userprofiles.shared.subscribers.append(existing)
                            } else {
                                Userprofiles.shared.subscribers.append(instance)
                            }
                        }
                    }
                }
            } catch let error {
    #if DEBUG
                print(error)
    #endif
                throw error
            }
        }
        
        public func subscribe(_ userprofile: Userprofile) async throws {
            guard let url = API_URLS.Profiles.subscribe else { throw APIError.invalidURL }
            let parameters: Parameters = ["userprofile_id": userprofile.id]
            do {
                let _ = try await parent.requestAsync(url: url, httpMethod: .get, parameters: parameters, encoding: URLEncoding.default, headers: parent.headers())
                await MainActor.run {
                    Userprofiles.shared.subscribedFor.append(userprofile)
                }
            } catch let error {
    #if DEBUG
                print(error)
    #endif
                throw error
            }
        }
        
        public func unsubscribe(_ userprofiles: [Userprofile]) async throws {
            guard let url = API_URLS.Profiles.unsubscribe else { throw APIError.invalidURL }
            let parameters: Parameters = ["ids": userprofiles.map{$0.id}]
            do {
                let _ = try await parent.requestAsync(url: url, httpMethod: .post, parameters: parameters, encoding: JSONEncoding.default, headers: parent.headers())
                await MainActor.run {
                    userprofiles.forEach {
                        Userprofiles.shared.subscribedFor.remove(object: $0)
                    }
                }
            } catch let error {
    #if DEBUG
                print(error)
    #endif
                throw error
            }
        }
    }
    
    class Polls {
        weak var parent: API! = nil
        var headers: HTTPHeaders {
            return parent.headers()
        }
        
        public func reject(survey: Survey) async throws {
            guard let url = API_URLS.Surveys.reject else { throw APIError.invalidURL }
            var parameters: Parameters = ["survey": survey.id]
            if Surveys.shared.hot.count <= MIN_STACK_SIZE {
                let stackList = Surveys.shared.hot.map { $0.id }
                let rejectedList = Surveys.shared.rejected.map { $0.id }
                let list = Array(Set(stackList + rejectedList))//Surveys.shared.stackObjects.filter({ $0.ID != nil }).map(){ $0.ID!}
                if !list.isEmpty {
                    let dict = list.asParameters(arrayParametersKey: "ids")
                    parameters.merge(dict) {(current, _) in current}
                }
            }
            do {
                ///JSON with hot surveys returned
                let data = try await parent.requestAsync(url: url,
                                                         httpMethod: .post,
                                                         parameters: parameters,
                                                         encoding: JSONEncoding.default,
                                                         headers: headers,
                                                         accessControl: true)
                do {
                    let json = try JSON(data: data, options: .mutableContainers)
                    await MainActor.run {
                        Surveys.shared.load(json)
                    }
                } catch {}
                
            } catch {
#if DEBUG
                print(error.localizedDescription)
#endif
                throw error
            }
        }
        
        public func claim(surveyReference: SurveyReference, reason: Claim) async throws  {
            guard let url = URL(string: API_URLS.BASE)?.appendingPathComponent(API_URLS.SURVEYS_CLAIM) else { throw APIError.notFound }
            let parameters: Parameters = ["survey": surveyReference.id, "claim": reason.id]
            
            do {
                let _ = try await parent.requestAsync(url: url, httpMethod: .post, parameters: parameters, encoding: JSONEncoding.default, headers: parent.headers())
                await MainActor.run {
                    surveyReference.isClaimed = true
                }
            } catch let error {
                await MainActor.run {
                    NotificationCenter.default.post(name: Notifications.Surveys.ClaimFailure, object: surveyReference)
                }
                throw error
            }
        }
        
//        public func updateStats() async throws -> Data {
//            guard let url = API_URLS.System.updateStats else { throw APIError.invalidURL }
//            
//            return try await parent.requestAsync(url: url, httpMethod: .get, parameters: nil, encoding: URLEncoding.default, headers: parent.headers())
//        }
        
        public func loadSurveys(type: SurveyType, parameters: Parameters? = nil) async throws -> Data{
            return try await parent.requestAsync(url: type.getURL(), httpMethod: .get, parameters: parameters, encoding: CustomGetEncoding(), headers: parent.headers())
        }
        
        public func loadSurveyReferences(_ category: Survey.SurveyCategory, _ topic: Topic? = nil) async throws {
            guard let url = category.url else { throw APIError.invalidURL }
            var parameters: Parameters!
            if category == .Topic, !topic.isNil {
                parameters = ["ids": SurveyReferences.shared.all.filter({ $0.topic == topic }).map { $0.id }]
                parameters["category_id"] = topic?.id
            } else {
                parameters  = ["ids": category.dataItems().map { $0.id }]
            }
            
            do {
                let data = try await parent.requestAsync(url: url, httpMethod: .get, parameters: parameters, encoding: CustomGetEncoding(), headers: parent.headers())
                try await MainActor.run {
                    Surveys.shared.load(try JSON(data: data, options: .mutableContainers))
                }
            } catch let error {
    #if DEBUG
                print(error)
    #endif
                throw error
            }
        }
        
        
        public func updateSurveyStats(_ instances: [SurveyReference]) async throws {
            guard let url = API_URLS.Surveys.updateStats else { throw APIError.invalidURL }
            
            let parameters: Parameters = ["ids": instances.compactMap { $0.id }]
            
            do {
                let data = try await parent.requestAsync(url: url, httpMethod: .post, parameters: parameters, encoding: JSONEncoding.default, headers: parent.headers())
                let json = try JSON(data: data, options: .mutableContainers)
                await MainActor.run {
                    Surveys.shared.updateSurveyStats(json)
                }
            } catch let error {
                throw error
            }
        }
        
        public func updateResultStats(_ instance: SurveyReference) async throws {
            guard let url = API_URLS.Surveys.updateResults else { throw APIError.invalidURL }
            
            let parameters: Parameters = ["id": instance.id]
            
            do {
                let data = try await parent.requestAsync(url: url, httpMethod: .post, parameters: parameters, encoding: JSONEncoding.default, headers: parent.headers())
                let json = try JSON(data: data, options: .mutableContainers)
                await MainActor.run {
                    Surveys.shared.updateResultsStats(json)
                }
            } catch let error {
                throw error
            }
        }
        
        func markFavoriteAsync(mark: Bool, surveyReference: SurveyReference) async throws -> Data {
            guard let url = mark ? API_URLS.Surveys.addFavorite : API_URLS.Surveys.removeFavorite else { throw APIError.invalidURL }
            
            let data = try await parent.requestAsync(url: url, httpMethod: .get, parameters: ["survey_id": surveyReference.id], encoding: URLEncoding.default, headers: parent.headers())
            await MainActor.run {
                surveyReference.isFavorite = mark
//                if let survey = surveyReference.survey {
//                    survey.isFavorite = mark
//                }
            }
            return data
        }
        
        func search(substring: String, excludedIds: [Int]) async throws -> [SurveyReference] {
            guard let url = API_URLS.Surveys.search else { throw APIError.invalidURL }
            var parameters: Parameters = ["substring": substring]
            if !excludedIds.isEmpty { parameters["ids"] = excludedIds }
            do {
                let data = try await parent.requestAsync(url: url, httpMethod: .get, parameters: parameters, encoding: CustomGetEncoding(), headers: parent.headers())
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategyFormatters = [ DateFormatter.ddMMyyyy,
                                                           DateFormatter.dateTimeFormatter,
                                                           DateFormatter.dateFormatter ]
                
                let instances = try decoder.decode([SurveyReference].self, from: data)
                guard !instances.isEmpty else {
                    return []
                }
                return {
                    var array: [SurveyReference] = []
                    instances.forEach { instance in array.append(SurveyReferences.shared.all.filter({ $0 == instance }).first ?? instance)
                    }
                    return array
                }()
            } catch let error {
#if DEBUG
                print(error)
#endif
                throw error
            }
        }
        
        public func postComment(_ body: String, survey: Survey, replyTo: Comment? = nil) async throws -> Comment {
            guard let url = API_URLS.Surveys.postComment else { throw APIError.invalidURL }
            
            var parameters: Parameters = ["survey": survey.id, "body": body,]
            
            if let replyId = replyTo?.id {
                parameters["reply_to"] = replyId
            }
            
            do {
                let data = try await parent.requestAsync(url: url, httpMethod: .post, parameters: parameters, encoding: JSONEncoding.default, headers: parent.headers())
                
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategyFormatters = [ DateFormatter.ddMMyyyy,
                                                           DateFormatter.dateTimeFormatter,
                                                           DateFormatter.dateFormatter ]
                
                let instance = try decoder.decode(Comment.self, from: data)
                
                NotificationCenter.default.post(name: Notifications.Comments.Post, object: nil)
                
                //Root comment children count increase notification
                if let replyTo = replyTo {
                    //Find root node
                    let rootNode: Comment? = replyTo.isParentNode ? replyTo : replyTo.parent
                    
                    if let rootNode = rootNode {
//                        await MainActor.run {
                            rootNode.replies += 1
                            survey.reference.commentsTotal += 1
                            NotificationCenter.default.post(name: Notifications.Comments.ChildrenCountChange, object: rootNode)
//                        }
                    }
                }
 
                return instance
            } catch let error {
                throw error
            }
        }
        
        public func claimComment(comment: Comment, reason: Claim) async throws {
            guard let url = API_URLS.Surveys.claimComment else { throw APIError.invalidURL }
            
            let parameters: Parameters = ["comment_id": comment.id, "claim_id": reason.id]
            
            do {
                let data = try await parent.requestAsync(url: url, httpMethod: .post, parameters: parameters, encoding: JSONEncoding.default, headers: parent.headers())
                
                guard let json = try JSON(data: data, options: .mutableContainers) as? JSON,
                      let status = json["status"].string,
                      status == "ok"
                else { return }
                
                comment.isClaimed = true
            } catch let error {
#if DEBUG
                error.printLocalized(class: type(of: self), functionName: #function)
#endif
                NotificationCenter.default.post(name: Notifications.Comments.ClaimFailure, object: comment)
                throw error
            }
        }
        
        public func deleteComment(comment: Comment) async throws {
            guard let url = API_URLS.Surveys.deleteComment else { throw APIError.invalidURL }
            
            let parameters: Parameters = ["comment_id": comment.id]
            
            do {
                let data = try await parent.requestAsync(url: url, httpMethod: .post, parameters: parameters, encoding: JSONEncoding.default, headers: parent.headers())
                
                guard let json = try JSON(data: data, options: .mutableContainers) as? JSON,
                      let status = json["status"].string,
                      status == "ok"
                else { return }
                
                await MainActor.run {
                    Comments.shared.all.remove(object: comment)
//                    NotificationCenter.default.post(name: Notifications.Comments.Delete, object: comment)
                    comment.isDeleted = true
                }
                
            } catch let error {
#if DEBUG
                error.printLocalized(class: type(of: self), functionName: #function)
#endif
                throw error
            }
        }

        
        public func requestRootComments(survey: Survey, excludedComments: [Comment] = []) async throws {
            guard let url = API_URLS.Surveys.getRootComments else { throw APIError.invalidURL }
            
            var parameters: Parameters = ["survey": survey.id]
            
            if !excludedComments.isEmpty {
                parameters["ids"] = excludedComments.map { $0.id }
            }
            
            do {
                let data = try await parent.requestAsync(url: url, httpMethod: .post, parameters: parameters, encoding: JSONEncoding.default, headers: parent.headers())
                
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategyFormatters = [ DateFormatter.ddMMyyyy,
                                                           DateFormatter.dateTimeFormatter,
                                                           DateFormatter.dateFormatter ]
                await MainActor.run {
                    let instances = try? decoder.decode([Comment].self, from: data)
                }
            } catch let error {
                throw error
            }
        }
        
        public func requestChildComments(rootComment: Comment, excludedComments: [Comment] = []) async throws {
            guard let url = API_URLS.Surveys.getChildComments else { throw APIError.invalidURL }
            
            var parameters: Parameters = ["root_id": rootComment.id]
            
            if !excludedComments.isEmpty {
                parameters["ids"] = excludedComments.map { $0.id }
            }
            
            do {
                let data = try await parent.requestAsync(url: url, httpMethod: .post, parameters: parameters, encoding: JSONEncoding.default, headers: parent.headers())
                
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategyFormatters = [ DateFormatter.ddMMyyyy,
                                                           DateFormatter.dateTimeFormatter,
                                                           DateFormatter.dateFormatter ]
                await MainActor.run {
                    let instances = try? decoder.decode([Comment].self, from: data)
                }
            } catch let error {
                throw error
            }
        }
        
        func post(_ parameters: Parameters) async throws {
            guard let url = API_URLS.Surveys.root else { throw APIError.invalidURL }
            
            do {
                if parameters.keys.contains("media") {
                    guard let url = API_URLS.Surveys.root else { throw APIError.invalidURL }
                    guard let category = parameters["category"] as? Int,
                          let type = parameters["type"] as? String,
                          let is_private = parameters["is_private"] as? Bool,
                          let is_anonymous = parameters["is_anonymous"] as? Bool,
                          let is_commenting_allowed = parameters["is_commenting_allowed"] as? Bool,
                          let post_hot = parameters["post_hot"] as? Bool,
                          let vote_capacity = parameters["vote_capacity"] as? Int,
                          let title = parameters["title"] as? String,
                          let question = parameters["question"] as? String,
                          let description = parameters["description"] as? String,
                          let answers = parameters["answers"] as? [[String: String]],
                          let media = parameters["media"] as? [Parameters] else {
                        throw APIError.badData
                    }
                    let multipartFormData = MultipartFormData()
                    multipartFormData.append("\(category)".data(using: .utf8)!, withName: "category")
                    multipartFormData.append("\(type)".data(using: .utf8)!, withName: "type")
                    multipartFormData.append("\(is_private)".data(using: .utf8)!, withName: "is_private")
                    multipartFormData.append("\(is_anonymous)".data(using: .utf8)!, withName: "is_anonymous")
                    multipartFormData.append("\(is_commenting_allowed)".data(using: .utf8)!, withName: "is_commenting_allowed")
                    multipartFormData.append("\(post_hot)".data(using: .utf8)!, withName: "post_hot")
                    multipartFormData.append("\(vote_capacity)".data(using: .utf8)!, withName: "vote_capacity")
                    multipartFormData.append("\(title)".data(using: .utf8)!, withName: "title")
                    multipartFormData.append("\(question)".data(using: .utf8)!, withName: "question")
                    multipartFormData.append("\(description)".data(using: .utf8)!, withName: "description")
                    
                    answers.enumerated().forEach { index, dict in
                        guard let description = dict["description"] else { return }
                        multipartFormData.append("\(index)".data(using: .utf8)!, withName: "answers[\(index)]order")
                        multipartFormData.append(description.data(using: .utf8)!, withName: "answers[\(index)]description")
                    }
                    
                    if let hlink = parameters["hlink"] as? [Parameters] {
                        multipartFormData.append("\(hlink)".data(using: .utf8)!, withName: "hlink")
                    }
                    
                    media.enumerated().forEach{ index, dict in
                        multipartFormData.append("\(index)".data(using: .utf8)!, withName: "media[\(index)]order")
                        if let title = dict["title"] as? String { multipartFormData.append(title.data(using: .utf8)!, withName: "media[\(index)]title") }
                        if let image = dict["image"] as? UIImage,
                           let jpegData = image.jpegData(compressionQuality: 1) {
                            multipartFormData.append(jpegData, withName: "media[\(index)]image", fileName: "\(UUID().uuidString).\(FileFormat.JPEG.rawValue)", mimeType: "jpg/png")
                        }
                    }
                    
                    let data = try await parent.uploadMultipartFormDataAsync(url: url, method: .post, multipartDataForm: multipartFormData, uploadProgress: {_ in})
                    let json = try JSON(data: data, options: .mutableContainers)
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategyFormatters = [ DateFormatter.ddMMyyyy,
                                                               DateFormatter.dateTimeFormatter,
                                                               DateFormatter.dateFormatter ]
                    
                    do {
                        try await MainActor.run {
                            let instance = try decoder.decode(Survey.self, from: json["survey"].rawData())
                            Surveys.shared.ownReferences.append(instance.reference)
                        }
                    } catch {
                        guard let errorText = json["error"].string else {
                            throw APIError.badData
                        }
#if DEBUG
                        print(errorText)
#endif
                        throw error
                    }
                } else {
                    let data = try await parent.requestAsync(url: url,
                                                             httpMethod: .post,
                                                             parameters: parameters,
                                                             encoding: JSONEncoding.default,
                                                             headers: headers,
                                                             accessControl: true)
                    let json = try JSON(data: data, options: .mutableContainers)
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategyFormatters = [ DateFormatter.ddMMyyyy,
                                                               DateFormatter.dateTimeFormatter,
                                                               DateFormatter.dateFormatter ]
                    
                    do {
                        try await MainActor.run {
                            let instance = try decoder.decode(Survey.self, from: json["survey"].rawData())
                            Surveys.shared.ownReferences.append(instance.reference)
                        }
                    } catch {
                        guard let errorText = json["error"].string else {
                            throw APIError.badData
                        }
#if DEBUG
                        print(errorText)
                        errorText.printLocalized(class: type(of: self), functionName: #function)
#endif
                        throw error
                    }
                }
            } catch {
#if DEBUG
                error.printLocalized(class: type(of: self), functionName: #function)
#endif
                throw error
            }
        }
    }
    
    public func getBalanceAndPrice() {
        guard let url = URL(string: API_URLS.BASE)?.appendingPathComponent(API_URLS.BALANCE) else { fatalError() }
        request(url: url, httpMethod: .get, encoding: URLEncoding.default) { result in
            switch result {
            case .success(let json):
                PriceList.shared.importJson(json["pricelist"])
                if let balance = json[DjangoVariables.UserProfile.balance].int {
                    Userprofiles.shared.current!.balance = balance
                }
            case .failure(let error):
                fatalError(error.localizedDescription)
            }
        }
    }
    
    public func getTikTokEmbedHTML(url: URL, completion: @escaping(Result<JSON, Error>)->()) {
        request(url: url, httpMethod: .get, encoding: URLEncoding.default) { completion($0) }
    }
    
    public func getVoters(answer: Answer, users: [Userprofile], completion: @escaping(Result<JSON, Error>)->()) {
        guard let url = URL(string: API_URLS.BASE)?.appendingPathComponent(API_URLS.VOTERS) else { completion(.failure(APIError.invalidURL)); return }
        guard let survey = answer.survey else { fatalError("answer.survey is nil") }
        let parameters: Parameters = ["survey": survey.id, "answer": answer.id, "voters": users.map { $0.id }]
        request(url: url, httpMethod: .get, parameters: parameters, encoding: CustomGetEncoding()) { completion($0) }
    }
    
    public func getVotersAsync(answer: Answer) async throws -> Data {
        guard let url = URL(string: API_URLS.BASE)?.appendingPathComponent(API_URLS.VOTERS) else {
            throw APIError.notFound
        }
        let parameters: Parameters = ["survey": answer.surveyID, "answer": answer.id, "voters": answer.voters.map({ return $0.id })]
        do {
            return try await requestAsync(url: url, httpMethod: .get, parameters: parameters, encoding: CustomGetEncoding(), headers: headers())
        } catch let error {
#if DEBUG
            print(error)
#endif
            throw error
        }
    }
    
    public func request(url: URL, httpMethod: HTTPMethod,  parameters: Parameters? = nil, encoding: ParameterEncoding = JSONEncoding.default, useHeaders: Bool = true, completion: @escaping(Result<JSON, Error>)->()) {
        accessControl { result in
            switch result {
            case .success:
                self.sessionManager.request(url, method: httpMethod, parameters: parameters, encoding: encoding, headers: useHeaders ? self.headers() : nil).response { response in
                    switch response.result {
                    case .success(let value):
                        guard let statusCode = response.response?.statusCode else { completion(.failure(APIError.httpStatusCodeMissing)); return }
                        guard let data = value else { completion(.failure(APIError.badData)); return }
                        guard 200...299 ~= statusCode else { completion(.failure(APIError.backend(code: statusCode, description: String(decoding: data, as: UTF8.self)))); return }
                        do {
                            //TODO: Определиться с инициализацией JSON
                            let json = try JSON(data: data, options: .mutableContainers)
                            guard 200...299 ~= statusCode else { completion(.failure(APIError.backend(code: statusCode, description: json.rawString()))); return }
                            completion(.success(json))
                        } catch let error {
                            completion(.failure(error))
                        }
                    case .failure(let error):
                        completion(.failure(self.parseAFError(error)))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
    
        //        session.request(url, method: httpMethod, parameters: parameters, encoding: encoding, headers: headers).responseJSON() {
        //            response in
        //            if response.result.isFailure {
        //                print(response.result.debugDescription)
        //                error = NSError(domain:"", code:404, userInfo:[ NSLocalizedDescriptionKey: response.result.debugDescription]) as Error
        //            } else {
        //                if let _error = response.result.error as? AFError {
        //                    error = self.parseAFError(_error)
        //                } else {
        //                    if let statusCode  = response.response?.statusCode{
        //                        if 200...299 ~= statusCode {
        //                            do {
        //                                json = try JSON(data: response.data!)
        //                            } catch let _error {
        //                                error = NSError(domain:"", code:404, userInfo:[ NSLocalizedDescriptionKey: _error.localizedDescription]) as Error
        //                            }
        //                        } else if 400...499 ~= statusCode {
        //                            do {
        //                                let errorJSON = try JSON(data: response.data!)
        //                                error = NSError(domain:"", code:404, userInfo:[ NSLocalizedDescriptionKey: errorJSON.rawString()!]) as Error
        //                                print(error!.localizedDescription)
        //                            } catch let _error {
        //                                error = NSError(domain:"", code:404, userInfo:[ NSLocalizedDescriptionKey: _error.localizedDescription]) as Error
        //                            }
        //                        }
        //                    }
        //                }
        //            }
        //            completion(json, error)
        //        }
    }
    
//    private func _performRequest(url: URL, searchString: String, httpMethod: HTTPMethod,  parameters: Parameters? = nil, encoding: ParameterEncoding = JSONEncoding.default, completion: @escaping(Bool?, Error?)->()) {
//        var flag: Bool?
//        var error: Error?
//        let headers: HTTPHeaders = [
//            "Authorization": "Bearer " + (KeychainService.loadAccessToken()! as String) as String,
//            "Content-Type": "application/json"
//        ]
//
//        self.sessionManager.request(url, method: httpMethod, parameters: parameters, encoding: encoding, headers: headers).response { response in
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
//    }
    
    //    @available(iOS 13.0.0, *)
    //    func downloadAsync(url: URL) async throws -> U {
    //        guard let url = URL(string: SERVER_URLS.BASE)?.appendingPathComponent(SERVER_URLS.APP_LAUNCH) else {
    //            throw APIError.notFound
    //        }
    //        do {
    //            let data = try await afRequest(url: url, httpMethod: .get, parameters: [:], encoding: URLEncoding.default, headers: headers())
    //            do {
    //                let json = try JSON(data: data, options: .mutableContainers)
    //                return json
    //            } catch {
    //                throw error
    //            }
    //        } catch let error {
    //            throw error
    //        }
    //    }
    
    public func downloadImage(url: URL, downloadProgress: @escaping (Double) -> (), completion: @escaping(Result<UIImage, Error>)->()) {
        accessControl { result in
            switch result {
            case .success:
                self.sessionManager.download(url)
                    .downloadProgress { progress in
                        downloadProgress(progress.fractionCompleted)
                    }
                    .responseData { response in
                        guard let data = response.value else { completion(.failure(APIError.badData)); return }
                        guard let image = UIImage(data: data) else { completion(.failure(APIError.badImage)); return }
                        completion(.success(image))
                    }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    public func downloadFile(url: URL, downloadProgress: @escaping (Double) -> (), completion: @escaping(Result<Data, Error>)->()) {
        accessControl { result in
            switch result {
            case .success:
                self.sessionManager.download(url)
                    .downloadProgress { progress in
                        downloadProgress(progress.fractionCompleted)
                    }
                    .responseData { response in
                        guard let data = response.value else { completion(.failure(APIError.badData)); return }
                        completion(.success(data))
                    }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
//    public func downloadImage(url _url: URL, completion: @escaping (UIImage?, Error?) -> ()) {
//        var error: Error?
//
//        checkForReachability {
//            reachable in
//            if reachable == .Reachable {
//                self.accessControl() {
//                    success, error in
//                    if error != nil {
//                        completion(nil, error)
//                    } else if success {
//                        performRequest()
//                    }
//                }
//            } else {
//                completion(nil, "Server is unreachable")
//            }
//        }
//
//        func performRequest() {
//            self.sessionManager.download(_url).responseData { response in
//                if let data = response.value {
//                    let image = UIImage(data: data)
//                    completion(image, nil)
//                } else {
//                    completion(nil, "Image initialization failure")
//                }
//            }
//        }
//    }
    
    //progressClosure: @escaping (CGFloat) -> ()
    public func uploadMultipartFormData(url: URL, method: HTTPMethod, multipartDataForm: MultipartFormData, uploadProgress: @escaping (Double) -> ()?, completion: @escaping(Result<JSON,Error>) -> ()) {
        self.sessionManager.upload(multipartFormData: multipartDataForm, to: url, method: method, headers: headers())
            .uploadProgress(closure: { prog in
                print("Upload Progress: \(prog.fractionCompleted)")
                uploadProgress(prog.fractionCompleted)
            })
            .response { response in
                switch response.result {
                case .success(let value):
                    guard let statusCode = response.response?.statusCode else { completion(.failure(APIError.httpStatusCodeMissing)); return }
                    guard let data = value else { completion(.failure(APIError.badData)); return }
                    do {
                        //TODO: Определиться с инициализацией JSON
                        let json = try JSON(data: data, options: .mutableContainers)
                        guard 200...299 ~= statusCode else { completion(.failure(APIError.backend(code: statusCode, description: json.rawString()))); return }
                        completion(.success(json))
                    } catch let error {
                        completion(.failure(error))
                    }
                case let .failure(error):
                    completion(.failure(error))
                }
            }
        
        
//        self.sessionManager.upload(multipartFormData: { multipartFormData in
//            var imgExt: FileFormat = .Unknown
//            var imageData: Data?
//            if let data = image.keys.first!.jpegData(compressionQuality: 1) {
//                imageData = data
//                imgExt = .JPEG
//            } else if let data = image.keys.first!.pngData() {
//                imageData = data
//                imgExt = .PNG
//            }
//            multipartFormData.append(imageData!, withName: "image", fileName: "\(AppData.shared.profile.id!).\(imgExt.rawValue)", mimeType: "jpg/png")
//            multipartFormData.append("\(surveyID)".data(using: .utf8)!, withName: "survey")
//            multipartFormData.append("\(index)".data(using: .utf8)!, withName: "order")
//            if !(image.values.first?.isEmpty)! {
//                multipartFormData.append(image.values.first!.data(using: .utf8)!, withName: "title")
//            }
//        }, to: url, method: HTTPMethod.patch, headers: headers).uploadProgress(queue: .main, closure: { progress in
//            print("Upload Progress: \(progress.fractionCompleted)")
//        }).response { response in
//            switch response.result {
//            case .success(let value):
//                do {
//                    //TODO: Определиться с инициализацией JSON
//                    json = try JSON(data: value!, options: .mutableContainers)
//                    if let statusCode = response.response?.statusCode {
//                        if 200...299 ~= statusCode {
//                            print("Upload complete: \(String(describing: json))")
//                        } else if 400...499 ~= statusCode, let errorDescription = json?.rawString() {
//                            uploadError = NSError(domain:"", code:404, userInfo:[ NSLocalizedDescriptionKey: errorDescription]) as Error
//                            print(uploadError!)
//                        }
//                    }
//                    completion(json, error)
//                }  catch let _error {
//                    uploadError = _error
//                    print(_error.localizedDescription)
//                }
//            case let .failure(_error):
//                uploadError = _error
//                completion(nil, error)
//            }
//        }
    }
    
    public func uploadMultipartFormDataAsync(url: URL, method: HTTPMethod, multipartDataForm: MultipartFormData, uploadProgress: @escaping (Double) -> ()?) async throws -> Data {
        try await withUnsafeThrowingContinuation { (continuation: UnsafeContinuation<Data, Error>) in
        self.sessionManager.upload(multipartFormData: multipartDataForm, to: url, method: method, headers: headers())
            .uploadProgress(closure: { prog in
                uploadProgress(prog.fractionCompleted)
            }).response { response in
                switch response.result {
                case .success(let value):
                    guard let statusCode = response.response?.statusCode else {
                        continuation.resume(throwing:APIError.httpStatusCodeMissing)
                        return
                    }
                    guard let data = value else {
                        continuation.resume(throwing: APIError.badData)
                        return
                    }
                    do {
                        //TODO: Определиться с инициализацией JSON
                        let json = try JSON(data: data, options: .mutableContainers)
                        guard 200...299 ~= statusCode else {
                            continuation.resume(throwing: APIError.backend(code: statusCode, description: json.rawString()))
                            return
                        }
                        continuation.resume(returning: data)
                        return
                    } catch let error {
                        continuation.resume(throwing: error)
                        return
                    }
                case let .failure(error):
                    continuation.resume(throwing: error)
                    return
                }
            }
        }
    }
    
    public func downloadImageAsync(from url: URL, timeoutInterval: TimeInterval = 30) async throws -> UIImage {
//        if #available(iOS 15.0, *) {
//            var request = URLRequest.init(url:url)
//            request.timeoutInterval = timeoutInterval
//            let (data, response) = try await URLSession.shared.data(for: request)
//            guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw APIError.invalidURL }
//            guard let image = UIImage(data: data) else {
//                throw APIError.badImage
//            }
//            return image
//            //            guard let thumbnail = await maybeImage?.thumbnail else { throw FetchError.badImage }
//            //            return  UImage(uiImage: thumbnail)
//        } else {
            try await withUnsafeThrowingContinuation { (continuation: UnsafeContinuation<UIImage, Error>) in
                self.sessionManager.download(url).responseData { response in
                    switch response.result {
                    case .success(let data):
                        guard let statusCode = response.response?.statusCode else {
                            continuation.resume(throwing: APIError.httpStatusCodeMissing)
                            return
                        }
                        guard 200...299 ~= statusCode else { continuation.resume(throwing:  APIError.unexpected(code: statusCode)); return }
                        guard let image = UIImage(data: data) else { continuation.resume(throwing: APIError.badImage); return }
                        continuation.resume(returning: image)
                        return
                    case .failure(let error):
                        continuation.resume(throwing: error)
                        return
                    }
                }
            }
//            fatalError("should not get here")
//        }
    }
    
    public func getUserTopPublications(user: Userprofile, completion: @escaping(Result<JSON,Error>)->()) {
        guard let url = URL(string: API_URLS.BASE)?.appendingPathComponent(API_URLS.USER_PROFILE_TOP_PUBS) else { completion(.failure(APIError.invalidURL)); return }
        let parameters: Parameters = ["userprofile_id": user.id]
        request(url: URL(string: API_URLS.BASE)!.appendingPathComponent(API_URLS.USER_PROFILE_TOP_PUBS), httpMethod: .get, parameters: parameters, encoding: URLEncoding.default) { completion($0) }
    }
    
    public func sendPasswordResetLink(_ email: String) async throws {
        do {
            guard let url = URL(string: API_URLS.BASE)?.appendingPathComponent(API_URLS.RESET_PASSWORD) else {
                throw APIError.notFound
            }
            let parameters: Parameters = ["email": email]
            let data = try await requestAsync(url: url, httpMethod: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
            guard try JSON(data: data, options: .mutableContainers)["status"] == "OK" else { throw "Email error" }
        } catch {
            throw error
        }
    }
    
    public func getCountryByIP()  {
        guard let url = URL(string: API_URLS.Geocoding.countryByIP) else {
            return
        }
        request(url: url, httpMethod: .get, parameters: nil, encoding: URLEncoding.default, useHeaders: false) { result in
            switch result {
            case .success(let json):
                guard let code = json["countryCode"].string else { return }
                UserDefaults.App.countryByIP = code
            case .failure(let error):
#if DEBUG
                print(error)
#endif
            }
        }
    }
//    public func getCountryByIP() async throws {
//        guard let url = URL(string: API_URLS.Geocoding.countryByIP) else {
//            throw APIError.notFound
//        }
//        do {
//            let data = try await requestAsync(url: url, httpMethod: .get, parameters: nil, encoding: URLEncoding.default, headers: nil, accessControl: false)
//            let json = try JSON(data: data, options: .mutableContainers)
//            print(json)
//        } catch let error {
//            throw error
//        }
//    }
    
    func cancelAllRequests() {
        self.sessionManager.session.getAllTasks { (tasks) in
            tasks.forEach { $0.cancel() }
        }
        //        self.session.session.getTasksWithCompletionHandler {
        //            (sessionDataTask, uploadData, downloadData) in
        //            sessionDataTask.forEach { $0.cancel() }
        //            uploadData.forEach { $0.cancel() }
        //            downloadData.forEach { $0.cancel() }
        //        }
    }
}

extension API {
    ///Return city `id`
    public func saveCity(_ parameters: Parameters) async throws -> Int {
        guard let url = URL(string: API_URLS.BASE)?.appendingPathComponent(API_URLS.CREATE_CITY) else {
            throw APIError.notFound
        }
        do {
            let data = try await requestAsync(url: url, httpMethod: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers())
            guard let id = try JSON(data: data, options: .mutableContainers)["id"].int else { throw "City id error" }
            return id
        } catch let error {
            throw error
        }
    }
}
