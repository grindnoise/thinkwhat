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

enum APIError: Error {
    case httpStatusCodeMissing
    case apiUnreachable
    case invalidPassword
    case notFound
    case invalidURL
    case badImage
    case badData
    case unexpected(code: Int)
    case backend(code: Int, description: String?)
}

extension APIError {
    var isFatal: Bool {
        if case APIError.unexpected = self { return true }
        else { return false }
    }
}

extension APIError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .httpStatusCodeMissing:
            return NSLocalizedString(
                "HTTP status code is missing.",
                comment: "Server Response Error"
            )
        case .apiUnreachable:
            return NSLocalizedString(
                "Server is not reachable.",
                comment: "API is Unreachable"
            )
        case .invalidPassword:
            return NSLocalizedString(
                "The provided password is not valid.",
                comment: "Invalid Password"
            )
        case .notFound:
            return NSLocalizedString(
                "The specified item could not be found.",
                comment: "Resource Not Found"
            )
        case .unexpected(let code):
            return NSLocalizedString(
                "Error code \(code)",
                comment: "Unexpected Error"
            )
        case .invalidURL:
            return NSLocalizedString(
                "Error occured while requesting URL",
                comment: "Invalid URL"
            )
        case .badImage:
            return NSLocalizedString(
                "Can't compose image from data",
                comment: "Image error"
            )
        case .badData:
            return NSLocalizedString(
                "Can't resolve data",
                comment: "Data error"
            )
        case let .backend(code, description):
            return NSLocalizedString(
                "Code \(code): \(String(describing: description))",
                comment: "Server error"
            )
        }
    }
}

class API {
    static let shared = API()
    private init() {}
    
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
                    AF.sessionConfiguration.timeoutIntervalForRequest = 15
                    AF.sessionConfiguration.connectionProxyDictionary = proxyDictionary
                } else {
                    AF.sessionConfiguration.timeoutIntervalForRequest = 10
                }
            }
        }
    }
    
    private func checkForReachability(completion: @escaping(ApiReachabilityState) -> ()) {
        let url = URL(string: API_URLS.BASE)!.appendingPathComponent(API_URLS.CURRENT_TIME)
        AF.request(url, method: .get, parameters: [:], encoding: URLEncoding(), headers: nil).response { response in
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
        AF.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil).response { response in
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
        AF.request(url, method: .post, parameters: parameters, encoding: URLEncoding(), headers: nil).response { response in
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
            let data = try await requestAsync(url: url, httpMethod: .post, parameters: parameters, encoding: URLEncoding())
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
        
        AF.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default).response { response in
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
        AF.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default).response { response in
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
            
            
            
            
            //                AF.upload(multipartFormData: { multipartFormData in
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
    
    func updateUserprofileAsync(data: [String: Any], uploadProgress: @escaping(Double) -> ()) async throws -> Data {
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
                return try await uploadMultipartFormDataAsync(url: url, method: .patch, multipartDataForm: multipartFormData, uploadProgress:  { uploadProgress($0) })
            } catch {
                throw error
            }
        } else {
            do {
            return try await requestAsync(url: url, httpMethod: .patch, parameters: dict, encoding: JSONEncoding.default)//JSON(data: responseData, options: .mutableContainers)
            } catch {
                throw error
            }
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
        
        AF.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil).response { response in
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
    
    private func refreshAccessTokenAsync() async throws -> Bool {
        guard let refreshToken = (KeychainService.loadRefreshToken() as String?) else {
            throw "Error occured while retrieving refresh token from KeychainService"
        }
        let parameters = ["client_id": API_URLS.CLIENT_ID, "client_secret": API_URLS.CLIENT_SECRET, "grant_type": "refresh_token", "refresh_token": "\(refreshToken)"]
        guard let url = URL(string: API_URLS.BASE)?.appendingPathComponent(API_URLS.TOKEN) else {
            throw APIError.invalidURL
        }
        
        do {
            let data = try await requestAsync(url: url, httpMethod: .post, parameters: parameters, encoding: URLEncoding.default)
            let json = try JSON(data: data, options: .mutableContainers)
            saveTokenInKeychain(json: json)
            return true
        } catch {
            throw error
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
        guard let url = URL(string: API_URLS.BASE)?.appendingPathComponent(API_URLS.APP_LAUNCH) else { completion(.failure(APIError.invalidURL)); return }
        self.request(url: url, httpMethod: .get, parameters: nil, encoding: URLEncoding.default) { result in
            completion(result)
        }
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
    
    func requestAsync(url: URL, httpMethod: HTTPMethod,  parameters: Parameters? = nil, encoding: ParameterEncoding = JSONEncoding.default, headers: HTTPHeaders? = nil) async throws -> Data {
        try await withUnsafeThrowingContinuation { continuation in
            AF.request(url, method: httpMethod, parameters: parameters, encoding: encoding, headers: headers).responseData { response in
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
                    continuation.resume(throwing: error)
                    return
                }
                //                if let data = response.data {
                //                    continuation.resume(returning: data)
                //                    return
                //                }
                //                if let err = response.error {
                //                    continuation.resume(throwing: err)
                //                    return
                //                }
                fatalError("should not get here")
            }
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
    
    func getSurveyStats(surveyReference: SurveyReference, completion: @escaping(Result<JSON, Error>)->()) {
        guard let url = URL(string: API_URLS.BASE)?.appendingPathComponent(API_URLS.SURVEYS_UPDATE_STATS) else { completion(.failure(APIError.invalidURL)); return }
        self.request(url: url, httpMethod: .get, parameters: ["survey_id": surveyReference.id], encoding: URLEncoding.default) { completion($0) }
    }
    
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
            
//            uploadMultipartFormData(url: url, method: .patch, multipartDataForm: multipartFormData, uploadProgress:  { uploadProgress($0) }) { completion($0) }
//
//            for (index, image) in images!.enumerated() {
//                AF.upload(multipartFormData: { multipartFormData in
//                    var imgExt: FileFormat = .Unknown
//                    var imageData: Data?
//                    if let data = image.keys.first!.jpegData(compressionQuality: 1) {
//                        imageData = data
//                        imgExt = .JPEG
//                    } else if let data = image.keys.first!.pngData() {
//                        imageData = data
//                        imgExt = .PNG
//                    }
//                    multipartFormData.append(imageData!, withName: "image", fileName: "\(AppData.shared.profile.id!).\(imgExt.rawValue)", mimeType: "jpg/png")
//                    multipartFormData.append("\(surveyID)".data(using: .utf8)!, withName: "survey")
//                    multipartFormData.append("\(index)".data(using: .utf8)!, withName: "order")
//                    if !(image.values.first?.isEmpty)! {
//                        multipartFormData.append(image.values.first!.data(using: .utf8)!, withName: "title")
//                    }
//                }, to: url, method: HTTPMethod.patch, headers: headers).uploadProgress(queue: .main, closure: { progress in
//                    print("Upload Progress: \(progress.fractionCompleted)")
//                }).response { response in
//                    switch response.result {
//                    case .success(let value):
//
//                        do {
//                            //TODO: Определиться с инициализацией JSON
//                            json = try JSON(data: value!, options: .mutableContainers)
//                            if let statusCode = response.response?.statusCode {
//                                if 200...299 ~= statusCode {
//                                    print("Upload complete: \(String(describing: json))")
//                                } else if 400...499 ~= statusCode, let errorDescription = json?.rawString() {
//                                    uploadError = NSError(domain:"", code:404, userInfo:[ NSLocalizedDescriptionKey: errorDescription]) as Error
//                                    print(uploadError!)
//                                }
//                            }
//                            completion(json, error)
//                        }  catch let _error {
//                            uploadError = _error
//                            print(_error.localizedDescription)
//                        }
//                    case let .failure(_error):
//                        uploadError = _error
//                        completion(nil, error)
//                    }
//                }
//            }
//
//
//
//
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
//                                multipartFormData.append(imageData!, withName: "image", fileName: "\(AppData.shared.profile.id!).\(imgExt.rawValue)", mimeType: "jpg/png")
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
//
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
//                    //
//                    //
//                    //
//                    //
//                    //                            Alamofire.upload(multipartFormData: { multipartFormData in
//                    //                                //                            for image in images! {
//                    //                                var imgExt: FileFormat = .Unknown
//                    //                                var imageData: Data?
//                    //                                if let data = image.keys.first!.jpegData(compressionQuality: 1) {
//                    //                                    imageData = data
//                    //                                    imgExt = .JPEG
//                    //                                } else if let data = image.keys.first!.pngData() {
//                    //                                    imageData = data
//                    //                                    imgExt = .PNG
//                    //                                }
//                    //                                multipartFormData.append(imageData!, withName: "image", fileName: "\(AppData.shared.userprofile.ID!).\(imgExt.rawValue)", mimeType: "jpg/png")
//                    //                                multipartFormData.append("\(surveyID)".data(using: .utf8)!, withName: "survey")
//                    //                                if !(image.values.first?.isEmpty)! {
//                    //                                    multipartFormData.append(image.values.first!.data(using: .utf8)!, withName: "title")
//                    //                                }
//                    //                            }, usingThreshold: SessionManager.multipartFormDataEncodingMemoryThreshold, to: url, method: .post, headers: headers) {
//                    //                                result in
//                    //                                switch result {
//                    //                                case .failure(let _error):
//                    //                                    uploadError = _error
//                    //                                    //                                completion(json, error)
//                    //                                case .success(request: let upload, streamingFromDisk: _, streamFileURL: _):
//                    //                                    upload.uploadProgress(closure: { (progress) in
//                    //                                        print("Upload Progress: \(progress.fractionCompleted)")
//                    //                                    })
//                    //                                    upload.responseJSON(completionHandler: { (response) in
//                    //                                        if response.result.isFailure {
//                    //                                            uploadError = NSError(domain:"", code:404, userInfo:[ NSLocalizedDescriptionKey: response.result.debugDescription]) as Error
//                    //                                        }
//                    //                                        if let _error = response.result.error as? AFError {
//                    //                                            uploadError = self.parseAFError(_error)
//                    //                                        } else {
//                    //                                            if let statusCode  = response.response?.statusCode{
//                    //                                                if 200...299 ~= statusCode {
//                    //                                                    do {
//                    //                                                        json = try JSON(data: response.data!)
//                    //                                                    } catch let _error {
//                    //                                                        uploadError = _error
//                    //                                                    }
//                    //
//                    //                                                    //TODO save local
//                    //                                                } else if 400...499 ~= statusCode {
//                    //                                                    do {
//                    //                                                        let errorJSON = try JSON(data: response.data!)
//                    //                                                        uploadError = NSError(domain:"", code:404, userInfo:[ NSLocalizedDescriptionKey: errorJSON.rawString()!]) as Error
//                    //                                                        print(uploadError!)
//                    //                                                    } catch let _error {
//                    //                                                        uploadError = _error
//                    //                                                    }
//                    //                                                }
//                    //                                            }
//                    //                                        }
//                    //                                    })
//                    //                                }
//                    //                            }
//                    //                        }
//                    //                        error = uploadError
//                    //                        completion(json, error)
//                    //                    } else {
//                    //                        completion(json, error)
//                    //                    }
                
            
            
            
            
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
            //                        multipartFormData.append(imageData!, withName: "media.image", fileName: "\(AppData.shared.userprofile.ID!).\(imgExt.rawValue)", mimeType: "jpg/png")
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
        var parameters: [String: Any] = ["survey": survey.id as Any]
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
        guard let url = URL(string: API_URLS.BASE)?.appendingPathComponent(API_URLS.SURVEYS_REJECT) else { completion(.failure(APIError.invalidURL)); return }
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
        guard let url = URL(string: API_URLS.BASE)?.appendingPathComponent(subscribe ? API_URLS.USERPOFILE_SUBSCRIBE : API_URLS.USERPOFILE_UNSUBSCRIBE) else { completion(.failure(APIError.invalidURL)); return }
        let parameters: Parameters = ["userprofile_id": user.id]
        request(url: url, httpMethod: .get, parameters: parameters, encoding: URLEncoding.default) { completion($0) }
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
        let parameters: Parameters = ["survey": survey.id, "answer": answer.id, "userprofiles": users.map { $0.id }]
        request(url: url, httpMethod: .get, parameters: parameters, encoding: CustomGetEncoding()) { completion($0) }
    }
    
    public func getVotersAsync(answer: Answer) async throws -> Data {
        guard let url = URL(string: API_URLS.BASE)?.appendingPathComponent(API_URLS.VOTERS) else {
            throw APIError.notFound
        }
        let parameters: Parameters = ["survey": answer.surveyID, "answer": answer.id, "userprofiles": answer.voters.map({ return $0.id })]
        do {
            return try await requestAsync(url: url, httpMethod: .get, parameters: parameters, encoding: CustomGetEncoding(), headers: headers())
        } catch let error {
            throw error
        }
    }
    
    public func request(url: URL, httpMethod: HTTPMethod,  parameters: Parameters? = nil, encoding: ParameterEncoding = JSONEncoding.default, completion: @escaping(Result<JSON, Error>)->()) {
        accessControl { result in
            switch result {
            case .success:
                AF.request(url, method: httpMethod, parameters: parameters, encoding: encoding, headers: self.headers()).response { response in
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
                AF.download(url)
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
                AF.download(url)
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
//            AF.download(_url).responseData { response in
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
        AF.upload(multipartFormData: multipartDataForm, to: url, method: method, headers: headers())
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
        
        
//        AF.upload(multipartFormData: { multipartFormData in
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
        AF.upload(multipartFormData: multipartDataForm, to: url, method: method, headers: headers())
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
    
    public func downloadImageAsync(from url: URL) async throws -> UIImage {
        if #available(iOS 15.0, *) {
            let request = URLRequest.init(url:url)
            let (data, response) = try await URLSession.shared.data(for: request)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw APIError.invalidURL }
            guard let image = UIImage(data: data) else {
                throw APIError.badImage
            }
            return image
            //            guard let thumbnail = await maybeImage?.thumbnail else { throw FetchError.badImage }
            //            return  UImage(uiImage: thumbnail)
        } else {
            try await withUnsafeThrowingContinuation { (continuation: UnsafeContinuation<UIImage, Error>) in
                AF.download(url).responseData { response in
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
            fatalError("should not get here")
        }
    }
    
    public func getUserTopPublications(user: Userprofile, completion: @escaping(Result<JSON,Error>)->()) {
        guard let url = URL(string: API_URLS.BASE)?.appendingPathComponent(API_URLS.USER_PROFILE_TOP_PUBS) else { completion(.failure(APIError.invalidURL)); return }
        let parameters: Parameters = ["userprofile_id": user.id]
        request(url: URL(string: API_URLS.BASE)!.appendingPathComponent(API_URLS.USER_PROFILE_TOP_PUBS), httpMethod: .get, parameters: parameters, encoding: URLEncoding.default) { completion($0) }
    }
    
    func cancelAllRequests() {
        AF.session.getAllTasks { (tasks) in
            tasks.forEach {$0.cancel() }
        }
        //        self.session.session.getTasksWithCompletionHandler {
        //            (sessionDataTask, uploadData, downloadData) in
        //            sessionDataTask.forEach { $0.cancel() }
        //            uploadData.forEach { $0.cancel() }
        //            downloadData.forEach { $0.cancel() }
        //        }
    }
}


protocol UserDataPreparatory: class {
    static func prepareUserData(_ data: [String: Any]) -> [String: Any]
}
