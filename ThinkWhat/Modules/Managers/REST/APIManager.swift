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
import UIKit

class API {
  static let shared   = API()
  public let auth     = Auth()
  public let system   = System()
  public let profiles = Profiles()
  public let surveys  = Polls()
  
  private init() {
    profiles.parent = self
    surveys.parent = self
    system.parent = self
    auth.parent = self
    //        self.sessionManager.session.configuration.timeoutIntervalForRequest = 10
  }
  
  public var sessionManager: Session = {
    let configuration = URLSessionConfiguration.af.default
    configuration.timeoutIntervalForRequest = 20
    //        configuration.waitsForConnectivity = true
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
    
    return Session(configuration: configuration, interceptor: interceptor, eventMonitors: [])//[NetworkLogger()])
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
  
  class func prepareUserData(firstName: String? = nil,
                             lastName: String? = nil,
                             email: String? = nil,
                             description: String? = nil,
                             gender: Gender? = nil,
                             birthDate: String? = nil,
                             city: City? = nil,
                             image: UIImage? = nil,
                             vkID: String? = nil,
                             vkURL: String? = nil,
                             facebookID: String? = nil,
                             facebookURL: String? = nil,
                             tiktokURL: String? = nil,
                             instagramURL: String? = nil,
                             locale: String? = nil) -> [String: Any] {
    
    var parameters: Parameters = ["is_edited": true]
    if !firstName.isNil || !lastName.isNil || !email.isNil {
      var dict: [String: Any] = [:]
      if let firstName = firstName, !firstName.isEmpty {
        dict[DjangoVariables.User.firstName] = firstName
      }
      if let lastName = lastName, !lastName.isEmpty {
        dict[DjangoVariables.User.lastName] = lastName
      }
      if let email = email, !email.isEmpty {
        dict[DjangoVariables.User.email] = email
      }
      parameters["owner"] = dict
      //            parameters["owner.\(DjangoVariables.User.firstName)"] = firstName!
      //        }
      //        if !lastName.isNil {
      //            parameters["owner.\(DjangoVariables.User.lastName)"] = lastName!
      //        }
      //        if !email.isNil {
      //            parameters["owner.\(DjangoVariables.User.email)"] = email!
    }
    
    if !description.isNil {
      parameters[DjangoVariables.UserProfile.description] = description!
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
    if !instagramURL.isNil {
      parameters[DjangoVariables.UserProfile.instagramURL] = instagramURL!
    }
    if !tiktokURL.isNil {
      parameters[DjangoVariables.UserProfile.tiktokURL] = tiktokURL!
    }
    if !image.isNil {
      parameters[DjangoVariables.UserProfile.image] = image!
    }
    if !locale.isNil {
      parameters[DjangoVariables.UserProfile.locale] = locale!
    }
    //        if !city.isNil {
    //            parameters[DjangoVariables.UserProfile.city] = city!.id
    ////            parameters["\(DjangoVariables.UserProfile.city)"] = city!.id
    //        }
    return parameters
  }
  
  
  private func headers() -> HTTPHeaders? {
    guard let accessToken = KeychainService.loadAccessToken() else { return nil }
    
    let headers: HTTPHeaders = [
      "Authorization": "Bearer " + (accessToken as String) as String,
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
    case Top,New,All,Own,Favorite, Hot, HotExcept, User, Topic
    
    func getURL() -> URL? {
      switch self {
      case .Top:
        return API_URLS.Surveys.top
      case .New:
        return API_URLS.Surveys.new
      case .All:
        return API_URLS.Surveys.all
      case .Own:
        return API_URLS.Surveys.own
      case .Favorite:
        return API_URLS.Surveys.favorite
      case .Hot:
        return API_URLS.Surveys.hot
      case .User:
        return API_URLS.Surveys.byUserprofile
      case .Topic:
        return API_URLS.Surveys.byTopic
      default:
        return nil
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
  
  
//  func getUserData(completion: @escaping(Result<JSON, Error>)->()) {
//    request(url: URL(string: API_URLS.BASE)!.appendingPathComponent(API_URLS.CURRENT_USER), httpMethod: .get, parameters: nil, encoding: URLEncoding.default) { completion($0) }
//  }
//
//  func getUserDataAsync() async throws -> Data {
//    guard let url = URL(string: API_URLS.BASE)?.appendingPathComponent(API_URLS.CURRENT_USER) else { throw APIError.invalidURL }
//    do {
//      return try await requestAsync(url: url, httpMethod: .get, parameters: nil, encoding: URLEncoding.default, headers: headers())
//    } catch {
//      throw error
//    }
//  }
  
//  func getProfileNeedsUpdate(completion: @escaping(Result<Bool, Error>)->()) {
//    request(url: URL(string: API_URLS.BASE)!.appendingPathComponent(API_URLS.PROFILE_NEEDS_UPDATE), httpMethod: .get) { result in
//      switch result {
//      case .success(let json):
//        guard let id = json["userprofile_id"].int, let needsUpdate = json["needs_update"].bool else { completion(.failure("User id is not found in response")); return }
//        UserDefaults.Profile.id = id
//        completion(.success(needsUpdate))
//      case .failure(let error):
//        completion(.failure(error))
//      }
//    }
//  }
  
//  func getEmailVerification(completion: @escaping (Result<Bool, Error>) -> ()) {
//    request(url: URL(string: API_URLS.BASE)!.appendingPathComponent(API_URLS.GET_EMAIL_VERIFIED), httpMethod: .get) { result in
//      switch result {
//      case .success(let json):
//        completion(.success(json[DjangoVariables.UserProfile.isEmailVerified].boolValue))
//      case .failure(let error):
//        completion(.failure(error))
//      }
//    }
//  }
  
  func initialLoad(completion: @escaping(Result<JSON,Error>)->()) {
    guard let url = URL(string: API_URLS.BASE)?.appendingPathComponent(API_URLS.APP_LAUNCH) else { completion(.failure(APIError.invalidURL)); return }
    self.request(url: url, httpMethod: .get, parameters: nil, encoding: URLEncoding.default) { result in
      completion(result)
    }
  }
  
  public func postVote(answer: Answer, completion: @escaping(Result<JSON, Error>)->()) {
    guard let url = URL(string: API_URLS.BASE)?.appendingPathComponent(API_URLS.SURVEYS) else { completion(.failure(APIError.invalidURL)); return }
    var parameters: [String: Any] = ["survey": answer.survey!.id, "answer": answer.id]
    if Surveys.shared.hot.count <= MIN_STACK_SIZE {
      let stackList = Surveys.shared.hot.map { $0.id }
      let rejectedList = Surveys.shared.all
        .filter { $0.isRejected}
        .map { $0.id }
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
  
  public func getUserStats(user: Userprofile, completion: @escaping(Result<JSON, Error>)->()) {
    guard let url = URL(string: API_URLS.BASE)?.appendingPathComponent(API_URLS.USER_PROFILE_STATS) else { completion(.failure(APIError.invalidURL)); return }
    let parameters = ["userprofile_id": user.id]
    request(url: url, httpMethod: .get, parameters: parameters, encoding: URLEncoding.default) { completion($0) }
  }
  
  //    public func subsribeToUser(subscribe: Bool, user: Userprofile, completion: @escaping(Result<JSON, Error>)->()) {
  //        guard let url = API_URLS.Profiles.subscribe else { completion(.failure(APIError.invalidURL)); return }
  //        let parameters: Parameters = ["userprofile_id": user.id]
  //        request(url: url, httpMethod: .get, parameters: parameters, encoding: URLEncoding.default) { completion($0) }
  //    }
  
  final class Auth {
    weak var parent: API! = nil
    var headers: HTTPHeaders? {
      return parent.headers()
    }
    
    ///**Async**
    ///Email auhorization. Stores access token if finished successful
    public func loginAsync(username: String,
                           password: String) async throws  {
      guard let url = API_URLS.Auth.token else { fatalError(APIError.invalidURL.localizedDescription) }
      
      let parameters = [
        "client_id": API_URLS.CLIENT_ID,
        "client_secret": API_URLS.CLIENT_SECRET,
        "grant_type": "password", "username": "\(username)",
        "password": "\(password)"
      ]

      do {
        let data = try await parent.requestAsync(url: url,
                                                 httpMethod: .post,
                                                 parameters: parameters,
                                                 encoding: URLEncoding(),
                                                 accessControl: false)
        let json = try JSON(data: data, options: .mutableContainers)
        let _ = saveTokenInKeychain(json: json)
      } catch let error {
        throw error
      }
    }
    
    public func loginViaProviderAsync(provider: AuthProvider,
                                      token: String) async throws  {
      
      var url: URL!
      if provider == .Apple {
        guard let _url = API_URLS.Auth.appleSignIn else { throw APIError.invalidURL }
        
        url = _url
      } else {
        guard let _url = API_URLS.Auth.convertToken else { throw APIError.invalidURL }
        
        url = _url
      }
      let parameters = ["client_id": API_URLS.CLIENT_ID, "client_secret": API_URLS.CLIENT_SECRET, "grant_type": "convert_token", "backend": "\(provider.rawValue.lowercased())", "token": "\(token)"]
      print(parameters)
      do {
        let data = try await parent.requestAsync(url: url,
                                                 httpMethod: .post,
                                                 parameters: parameters,
                                                 encoding: URLEncoding(),
                                                 accessControl: false)
        let json = try JSON(data: data, options: .mutableContainers)
        let _ = saveTokenInKeychain(json: json)
      } catch let error {
        throw error
      }
    }
    
    public func signupAsync(email: String,
                            password: String,
                            username: String) async throws {
      guard let url = API_URLS.Auth.signUp else { throw APIError.invalidURL.localizedDescription }
      
      let parameters = ["client_id": API_URLS.CLIENT_ID,
                        "grant_type": "password",
                        "email": "\(email)",
                        "password": "\(password)",
                        "username": "\(username)"]
      
      do {
        try await parent.requestAsync(url: url, httpMethod: .post, parameters: parameters, encoding: URLEncoding(), accessControl: false)
      } catch {
        throw error
      }
    }
    
    
    /// Sends email verification code
    /// - Parameter newEmail: force send to address, otherwise sends to current model email
    /// - Returns: dictionary with code
    public func sendEmailVerificationCode(newEmail: String = "") async throws -> Parameters {
      guard let url = API_URLS.Auth.getCodeViaMail else { fatalError(APIError.invalidURL.localizedDescription) }
      
      var parameters: Parameters?
      if !newEmail.isEmpty, newEmail.isValidEmail {
        parameters = ["email": newEmail]
      }
      
      let data = try await parent.requestAsync(url: url,
                                           httpMethod: .get,
                                           parameters: parameters,
                                           encoding: URLEncoding.default,
                                           headers: parent.headers(),
                                           accessControl: false)
      guard let dict = JSON(data).dictionaryObject else { throw AppError.server }
      
      return dict
      
//      self.request(url: URL(string: API_URLS.BASE)!.appendingPathComponent(API_URLS.GET_CONFIRMATION_CODE), httpMethod: .get, parameters: nil, encoding: URLEncoding.default) { completion($0) }
    }
    
    public func checkEmailAvailibilty(_ email: String) async throws -> Bool {
      guard let url = API_URLS.Auth.emailExists else { fatalError(APIError.invalidURL.localizedDescription) }
      
      let data = try await parent.requestAsync(url: url,
                                           httpMethod: .get,
                                           parameters: ["email": email],
                                           encoding: URLEncoding.default,
                                           accessControl: false)
      
      do {
        let json = try JSON(data: data, options: .mutableContainers)
        return json["exists"].boolValue
      } catch {
        throw AppError.server
      }
    }
    
    public func checkUsernameAvailibilty(_ username: String) async throws -> Bool {
      guard let url = API_URLS.Auth.usernameExists else { fatalError(APIError.invalidURL.localizedDescription) }
      
      let data =  try await parent.requestAsync(url: url,
                                                httpMethod: .get,
                                                parameters: ["username": username],
                                                encoding: URLEncoding.default,
                                                accessControl: false)
      
      do {
        let json = try JSON(data: data, options: .mutableContainers)
        return json["exists"].boolValue
      } catch {
        throw AppError.server
      }
    }
    
    
    ///**Callbacks**
    public func loginViaMail(username: String, password: String, completion: @escaping (Result<Bool, Error>) -> ()) {
      guard let url = API_URLS.Auth.token else { return completion(.failure(APIError.invalidURL)) }

      let parameters = ["client_id": API_URLS.CLIENT_ID,
                        "client_secret": API_URLS.CLIENT_SECRET,
                        "grant_type": "password",
                        "username": "\(username)",
                        "password": "\(password)"]
      self.parent.sessionManager.request(url,
                                         method: .post,
                                         parameters: parameters,
                                         encoding: URLEncoding.default,
                                         headers: nil).response { response in
        switch response.result {
        case .success(let value):
          guard let statusCode = response.response?.statusCode else { completion(.failure(APIError.httpStatusCodeMissing)); return }
          guard let data = value else { completion(.failure(APIError.badData)); return }
          do {
            //TODO: Определиться с инициализацией JSON
            let json = try JSON(data: data, options: .mutableContainers)
            guard 200...299 ~= statusCode else {
              completion(.failure(APIError.backend(code: statusCode, value: json.rawString())))
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
    
    public func getTokenByPassword(username: String, password: String, completion: @escaping (Result<Bool, Error>) -> ()) {
      guard let url = API_URLS.Auth.getTokenByPassword else { return completion(.failure(APIError.invalidURL)) }

      let parameters = ["username": "\(username)",
                        "password": "\(password)"]
      self.parent.sessionManager.request(url,
                                         method: .post,
                                         parameters: parameters,
                                         encoding: URLEncoding.default,
                                         headers: nil).response { response in
        switch response.result {
        case .success(let value):
          guard let statusCode = response.response?.statusCode else { completion(.failure(APIError.httpStatusCodeMissing)); return }
          guard let data = value else { completion(.failure(APIError.badData)); return }
          do {
            //TODO: Определиться с инициализацией JSON
            let json = try JSON(data: data, options: .mutableContainers)
            guard 200...299 ~= statusCode else {
              completion(.failure(APIError.backend(code: statusCode, value: json.rawString())))
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
    
    public func logout(completion: @escaping (Result<Bool, Error>) -> ()) {
      guard let url = URL(string: API_URLS.BASE)?.appendingPathComponent(API_URLS.TOKEN_REVOKE) else { completion(.failure(APIError.invalidURL)); return }
      guard let token = KeychainService.loadAccessToken() as String?, !token.isEmpty else {
        UserDefaults.clear()
        Surveys.shared.eraseData()
        Userprofiles.shared.eraseData()
        SurveyReferences.shared.eraseData()
//        FBWorker.logout()
        VKWorker.logout()
        completion(.success(true))
        return
      }
      let parameters = ["client_id": API_URLS.CLIENT_ID, "client_secret": API_URLS.CLIENT_SECRET, "token": token]
      
      self.parent.sessionManager.request(url, method: .post,
                                         parameters: parameters,
                                         encoding: URLEncoding.default).response { response in
        switch response.result {
        case .success(_):
          guard let statusCode = response.response?.statusCode else { completion(.failure(APIError.httpStatusCodeMissing)); return }
          UserDefaults.clear()
          Surveys.shared.eraseData()
          Userprofiles.shared.eraseData()
          SurveyReferences.shared.eraseData()
//          FBWorker.logout()
          VKWorker.logout()
          completion(.success(true))
          //                if 200...299 ~= statusCode {
          //                    completion(saveTokenInKeychain(json: json))
          //                } else if 400...499 ~= statusCode {
          //                    guard let description = json.rawString() else { completion(.failure(APIError.unexpected(code: statusCode)))}
          //                    completion(.failure(APIError.serverResponse(description: description)))
          //                }
        case let .failure(error):
          completion(.failure(self.parent.parseAFError(error)))
        }
      }
    }
    
    ///**OAuth**
    ///Social media auhorization. Store access token if finished successful
    public func loginViaProvider(provider: AuthProvider, token: String, completion: @escaping (Result<Bool, Error>) -> ()) {
      guard let url = API_URLS.Auth.convertToken else { completion(.failure(APIError.invalidURL)); return }
      
      let parameters = ["client_id": API_URLS.CLIENT_ID,
                        "client_secret": API_URLS.CLIENT_SECRET,
                        "grant_type": "convert_token",
                        "backend": "\(provider.rawValue.lowercased())",
                        "token": "\(token)"]
      self.parent.sessionManager.request(url,
                                         method: .post,
                                         parameters: parameters,
                                         encoding: URLEncoding(),
                                         headers: nil).response { response in
        switch response.result {
        case .success(let value):
          guard let statusCode = response.response?.statusCode else { completion(.failure(APIError.httpStatusCodeMissing)); return }
          guard let data = value else { completion(.failure(APIError.badData)); return }
          do {
            //TODO: Определиться с инициализацией JSON
            let json = try JSON(data: data, options: .mutableContainers)
            guard 200...299 ~= statusCode else { completion(.failure(APIError.backend(code: statusCode, value: json.rawString()))); return }
            completion(saveTokenInKeychain(json: json))
          } catch let error {
            completion(.failure(error))
          }
        case let .failure(error):
          completion(.failure(error))
        }
      }
    }
    
    public func signUp(email: String,
                       password: String,
                       username: String,
                       completion: @escaping (Result<Bool,Error>) -> ()) {
      guard let url = API_URLS.Auth.signUp else { fatalError(APIError.invalidURL.localizedDescription) }
      
      let parameters = ["client_id": API_URLS.CLIENT_ID,
                        "grant_type": "password",
                        "email": "\(email)",
                        "password": "\(password)",
                        "username": "\(username)"]
      self.parent.sessionManager.request(url,
                                         method: .post,
                                         parameters: parameters,
                                         encoding: URLEncoding.default).response { response in
        switch response.result {
        case .success(let value):
          guard let statusCode = response.response?.statusCode else { completion(.failure(APIError.httpStatusCodeMissing)); return }
          guard let data = value else { completion(.failure(APIError.badData)); return }
          do {
            //TODO: Определиться с инициализацией JSON
            let json = try JSON(data: data, options: .mutableContainers)
            guard 200...299 ~= statusCode else { completion(.failure(APIError.backend(code: statusCode, value: json.rawString()))); return }
//            self.loginViaMail(username: username, password: password) { completion($0) }
          }  catch let error {
            completion(.failure(error))
          }
        case let .failure(error):
          completion(.failure(error))
        }
      }
    }
  }
  
  final class System {
    weak var parent: API! = nil
    var headers: HTTPHeaders? {
      return parent.headers()
    }
    
    public func appLaunch() async throws -> JSON {
      guard let url = URL(string: API_URLS.BASE)?.appendingPathComponent(API_URLS.APP_LAUNCH) else {
        throw APIError.notFound
      }
      do {
        let data = try await parent.requestAsync(url: url,
                                                 httpMethod: .get,
                                                 parameters: [:],
                                                 encoding: URLEncoding.default,
                                                 headers: parent.headers())
        do {
          let json = try JSON(data: data,
                              options: .mutableContainers)
          return json
        } catch {
          throw error
        }
      } catch let error {
        throw error
      }
    }
    
    public func getCountryByIP() {
      guard let url = URL(string: API_URLS.Geocoding.countryByIP) else { return }
      
      parent.request(url: url, httpMethod: .get,
                     parameters: nil,
                     encoding: URLEncoding.default,
                     useHeaders: false,
                     accessControl: false) { result in
        switch result {
        case .success(let json):
          guard let code = json["countryCode"].string else { return }
          
//          UserDefaults.App.countryByIP = code
          AppData.shared.countryByIP = code
        case .failure(let error):
#if DEBUG
          print(error)
#endif
        }
      }
    }
    
    public func updateAppSettings(_ parameters: Parameters) async throws {
      guard let url = API_URLS.Profiles.updateAppSettings else { throw APIError.invalidURL }
      
      do {
        try await parent.requestAsync(url: url, httpMethod: .post, parameters: parameters, encoding: JSONEncoding.default, headers: parent.headers())
      } catch let error {
#if DEBUG
        print(error)
#endif
        throw error
      }
    }
    
    ///Return city `id`
    @discardableResult
    public func saveCity(_ parameters: Parameters) async throws -> City {
      guard let url = URL(string: API_URLS.BASE)?.appendingPathComponent(API_URLS.CREATE_CITY) else {
        throw APIError.notFound
      }
      do {
        let data = try await parent.requestAsync(url: url,
                                                 httpMethod: .post,
                                                 parameters: parameters,
                                                 encoding: JSONEncoding.default,
                                                 headers: parent.headers())
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategyFormatters = [ DateFormatter.ddMMyyyy,
                                                   DateFormatter.dateTimeFormatter,
                                                   DateFormatter.dateFormatter ]
        return try decoder.decode(City.self, from: data)
      } catch let error {
        throw error
      }
    }
    
    public func downloadImage(url: URL, downloadProgress: @escaping (Double) -> (), completion: @escaping(Result<UIImage, Error>)->()) {
      parent.accessControl { [unowned self] result in
        
        switch result {
        case .success:
          self.parent.sessionManager.download(url)
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
      parent.accessControl { [unowned self] result in
        
        switch result {
        case .success:
          self.parent.sessionManager.download(url)
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
        parent.sessionManager.download(url).responseData { response in
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
    
    public func sendPasswordResetLink(_ email: String) async throws {
      do {
        guard let url = URL(string: API_URLS.BASE)?.appendingPathComponent(API_URLS.RESET_PASSWORD) else {
          throw APIError.notFound
        }
        let parameters: Parameters = ["email": email]
        let data = try await parent.requestAsync(url: url,
                                                 httpMethod: .post,
                                                 parameters: parameters,
                                                 encoding: URLEncoding.default,
                                                 headers: nil,
                                                 accessControl: false)
        guard try JSON(data: data, options: .mutableContainers)["status"] == "OK" else { throw APIError.badData }
      } catch {
#if DEBUG
        error.printLocalized(class: type(of: self), functionName: #function)
#endif
        throw error
      }
    }
    
    /// Deletes push notification token from database
    /// - Parameter token: `PushNotificationToken` to be removed
    public func unregisterDevice(token: PushNotificationToken) async {
      guard let url = API_URLS.Profiles.unregisterDevice,
            let headers = headers
      else { return }
      
      let parameters: Parameters = [
        "device_type": "apns",
        "device_token": token.token,
      ]
      
      do {
        try await parent.requestAsync(url: url,
                                      httpMethod: .post,
                                      parameters: parameters,
                                      encoding: JSONEncoding.default,
                                      headers: headers)
        
      } catch let error {
#if DEBUG
        error.printLocalized(class: type(of: self), functionName: #function)
#endif
      }
    }
    
    /// Appends push notification token to database
    /// - Parameter token: `PushNotificationToken` to be removed
    public func registerDevice(token: PushNotificationToken) async {
      guard let url = API_URLS.Profiles.registerDevice,
            let headers = headers
      else { return }
      
      let parameters: Parameters = [
        "device_type": "apns",
        "device_token": token.token,
      ]
      
      do {
        try await parent.requestAsync(url: url,
                                      httpMethod: .post,
                                      parameters: parameters,
                                      encoding: JSONEncoding.default,
                                      headers: headers)
        
      } catch let error {
#if DEBUG
        error.printLocalized(class: type(of: self), functionName: #function)
#endif
      }
    }
  }
  
  final class Profiles {
    weak var parent: API! = nil
    var headers: HTTPHeaders? {
      return parent.headers()
    }
    
    func current() async throws -> Data {
      guard let url = API_URLS.Auth.current else { fatalError(APIError.invalidURL.localizedDescription) }
      
      do {
        return try await parent.requestAsync(url: url,
                                             httpMethod: .get,
                                             parameters: nil,
                                             encoding: URLEncoding.default,
                                             headers: parent.headers())
      } catch {
        throw error
      }
    }
    
    public func updateUserprofileAsync(data: [String: Any],
                                       uploadProgress: @escaping(Double) -> ()) async throws -> Data {
      guard let userprofile = Userprofiles.shared.current,
            let base = API_URLS.Profiles.base,
            let headers = headers
      else { throw APIError.invalidURL }
      
      let url = base.appendingPathComponent("\(userprofile.id)/")
      
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
        
        guard imageData != nil,
              fileFormat != .Unknown
        else {
          throw APIError.badData
        }
        
        multipartFormData.append(imageData, withName: "image", fileName: "\(String(describing: userprofile.id)).\(fileFormat)", mimeType: "jpg/png")
        for (key, value) in dict {
          if value is String || value is Int {
            multipartFormData.append("\(value)".data(using: .utf8)!, withName: key)
          }
        }
        do {
          return try await parent.uploadMultipartFormDataAsync(url: url, method: .patch, multipartDataForm: multipartFormData, headers: headers, uploadProgress:  { uploadProgress($0) })
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
    
    public func getSubscriptions(for userprofile: Userprofile) async throws {
      guard let url = API_URLS.Profiles.subscribedFor else { throw APIError.invalidURL }
      
      //Exclude
      let parameters: Parameters = [
        "exclude_ids": Array(userprofile.subscriptions.intersection(Userprofiles.shared.all.map { $0.id })),
        "userprofile_id": userprofile.id
      ]
      
      do {
        let data = try await parent.requestAsync(url: url,
                                                 httpMethod: .post,
                                                 parameters: parameters,
                                                 encoding: JSONEncoding.default,
                                                 headers: parent.headers())
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategyFormatters = [ DateFormatter.ddMMyyyy,
                                                   DateFormatter.dateTimeFormatter,
                                                   DateFormatter.dateFormatter ]
        
        Userprofiles.shared.append(try decoder.decode([Userprofile].self, from: data))
      } catch let error {
#if DEBUG
        print(error)
#endif
        throw error
      }
    }
    
    public func getSubscribers(for userprofile: Userprofile) async throws {
      guard let url = API_URLS.Profiles.subscribers else { throw APIError.invalidURL }
      
      //Exclude
      let parameters: Parameters = [
        "exclude_ids": Array(userprofile.subscribers.intersection(Userprofiles.shared.all.map { $0.id })),
        "userprofile_id": userprofile.id
      ]
      
      do {
        let data = try await parent.requestAsync(url: url,
                                                 httpMethod: .post,
                                                 parameters: parameters,
                                                 encoding: JSONEncoding.default,
                                                 headers: parent.headers())
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategyFormatters = [
          DateFormatter.ddMMyyyy,
          DateFormatter.dateTimeFormatter,
          DateFormatter.dateFormatter
        ]
        
        Userprofiles.shared.append(try decoder.decode([Userprofile].self, from: data))
      } catch let error {
#if DEBUG
        print(error)
#endif
        throw error
      }
    }
    
    
    public func subscribe(at userprofiles: [Userprofile]) async throws {
      guard let url = API_URLS.Profiles.subscribe else { throw APIError.invalidURL }
      
      let parameters: Parameters = ["ids": userprofiles.map{$0.id}]
      
      do {
        let _ = try await parent.requestAsync(url: url,
                                              httpMethod: .post,
                                              parameters: parameters,
                                              encoding: JSONEncoding.default,
                                              headers: parent.headers())
          userprofiles.forEach { $0.subscribedAt = true }
        if let current = Userprofiles.shared.current {
          current.subscriptionsTotal += userprofiles.count
        }
      } catch let error {
//        NotificationCenter.default.post(name: Notifications.Userprofiles.SubscriptionOperationFailure, object: userprofiles.first)
        if let userprofile = userprofiles.first {
          Userprofiles.shared.subscriptionFailure.send(userprofile)
        }
#if DEBUG
        error.printLocalized(class: type(of: self), functionName: #function)
#endif
        throw error
      }
    }
    
//    public func removeSubscribers(_ userprofiles: [Userprofile]) async throws {
//      guard let url = API_URLS.Profiles.removeSubscribers else { throw APIError.invalidURL }
//
//      let parameters: Parameters = ["ids": userprofiles.map{$0.id}]
//
//      do {
//        let _ = try await parent.requestAsync(url: url,
//                                              httpMethod: .post,
//                                              parameters: parameters,
//                                              encoding: JSONEncoding.default,
//                                              headers: parent.headers())
//          userprofiles.forEach { $0.subscribedAt = false }
//      } catch let error {
//#if DEBUG
//        error.printLocalized(class: type(of: self), functionName: #function)
//#endif
//        throw error
//      }
//    }
    
    public func unsubscribe(from userprofiles: [Userprofile]) async throws {
      guard let url = API_URLS.Profiles.unsubscribe else { throw APIError.invalidURL }
      
      let parameters: Parameters = ["ids": userprofiles.map{$0.id}]
      
      do {
        let _ = try await parent.requestAsync(url: url,
                                              httpMethod: .post,
                                              parameters: parameters,
                                              encoding: JSONEncoding.default,
                                              headers: parent.headers())
        userprofiles.forEach {
          $0.subscribedAt = false
          Userprofiles.shared.unsubscribedPublisher.send($0)
        }
        
        if let current = Userprofiles.shared.current {
          current.subscriptionsTotal -= userprofiles.count
        }
      } catch let error {
//        NotificationCenter.default.post(name: Notifications.Userprofiles.SubscriptionOperationFailure, object: userprofiles.first)
        if let userprofile = userprofiles.first {
          Userprofiles.shared.subscriptionFailure.send(userprofile)
        }
#if DEBUG
        error.printLocalized(class: type(of: self), functionName: #function)
#endif
        throw error
      }
    }
    
    public func updateCurrentUserStatistics() async throws {
      guard let url = API_URLS.Profiles.updateCurrentStats else { throw APIError.invalidURL }
      
      do {
        let data = try await parent.requestAsync(url: url,
                                                 httpMethod: .get,
                                                 parameters: nil,
                                                 encoding: URLEncoding.default,
                                                 headers: parent.headers())
        
        let json = try JSON(data: data, options: .mutableContainers)
        
        try Userprofiles.updateUserData(json)
      } catch {
#if DEBUG
        error.printLocalized(class: type(of: self), functionName: #function)
#endif
      }
    }
    
    public func feedback(description: String) async throws {
      guard let url = API_URLS.Profiles.feedback else { throw APIError.invalidURL }
      
      let parameters: Parameters = ["description": description]
      
      do {
        try await parent.requestAsync(url: url, httpMethod: .post, parameters: parameters, encoding: JSONEncoding.default, headers: parent.headers())
        NotificationCenter.default.post(name: Notifications.System.FeedbackSent, object: nil)
      } catch let error {
        NotificationCenter.default.post(name: Notifications.System.FeedbackFailure, object: nil)
#if DEBUG
        error.printLocalized(class: type(of: self), functionName: #function)
#endif
        throw error
      }
    }
    
    public func switchNotifications(userprofile: Userprofile, notify: Bool) async throws {
      guard let url = API_URLS.Profiles.switchNotifications else { throw APIError.invalidURL }
      
      do {
        try await parent.requestAsync(url: url,
                                      httpMethod: .post,
                                      parameters: [
                                        "userprofile_id": userprofile.id,
                                        "notify": notify
                                      ],
                                      encoding: JSONEncoding.default,
                                      headers: parent.headers())
        userprofile.notifyOnPublication = notify
      } catch {
#if DEBUG
        error.printLocalized(class: type(of: self), functionName: #function)
#endif
//        NotificationCenter.default.post(name: Notifications.Userprofiles.NotifyOnPublicationsFailure, object: userprofile)
        throw error
      }
    }
    
    public func compatibility(with userprofile: Userprofile) async throws {
      guard let url = API_URLS.Profiles.compatibility else { throw APIError.invalidURL }
      
      do {
        let data = try await parent.requestAsync(url: url,
                                                 httpMethod: .get,
                                                 parameters: ["id": userprofile.id],
                                                 encoding: URLEncoding.default,
                                                 headers: parent.headers())
        let json = try JSON(data: data, options: .mutableContainers)
        
        userprofile.compatibility = UserCompatibility(json)
        
//        userprofile.compatibility = compatibility
//        userprofile.compatibilityPublisher.send(compatibility)
      } catch {
        userprofile.compatibilityPublisher.send(completion: .failure(error))
      }
    }
    
    public func deleteAccount() async throws {
      guard let url = API_URLS.Profiles.deleteAccount else { throw APIError.invalidURL }
      
      do {
        try await parent.requestAsync(url: url,
                                      httpMethod: .post,
                                      parameters: nil,
                                      encoding: URLEncoding.default,
                                      headers: parent.headers())
      } catch {
#if DEBUG
        error.printLocalized(class: type(of: self), functionName: #function)
#endif
      }
    }
  }
  
  final class Polls {
    weak var parent: API! = nil
    var headers: HTTPHeaders? {
      return parent.headers()
    }
    
    //Get fullbody surveys
    func getSurveys(type: SurveyType, parameters: Parameters? = nil) async throws -> Data {
      guard let url = type.getURL(),
            let headers = headers
      else { throw APIError.invalidURL }
      
      return try await parent.requestAsync(url: url, httpMethod: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
    }
    
    //Get fullbody by reference ID
    @discardableResult
    func getSurvey(byReference surveyReference: SurveyReference,
                   incrementCounter: Bool = false) async throws -> Survey {
      guard let url = API_URLS.Surveys.surveyById,
            !headers.isNil
      else { throw APIError.invalidURL }
      
      var parameters: Parameters = ["survey_id": surveyReference.id]
      if incrementCounter {
        parameters["add_view_count"] = true
      }
      
      do {
        let data = try await parent.requestAsync(url: url,
                                                 httpMethod: .post,
                                                 parameters: parameters,
                                                 encoding: JSONEncoding.default,
                                                 headers: parent.headers())
        
        let json = try JSON(data: data, options: .mutableContainers)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategyFormatters = [ DateFormatter.ddMMyyyy,
                                                   DateFormatter.dateTimeFormatter,
                                                   DateFormatter.dateFormatter ]
        Surveys.shared.append([try decoder.decode(Survey.self, from: json.rawData())])
        
        let instance = Surveys.shared[surveyReference.id]
        instance!.isVisited = true
        
        return instance!
      } catch let error {
        throw error
      }
    }
    
    @discardableResult
    /// Loads `Survey` by string id
    /// - Parameter referenceId: survey id
    /// - Returns: `Survey`
    func getSurvey(byReferenceId referenceId: String) async throws -> Survey {
      guard let url = API_URLS.Surveys.surveyById,
            !headers.isNil
      else { throw APIError.invalidURL }
      
      var parameters: Parameters = [
        "survey_id": referenceId,
        "add_view_count": true
      ]
      
      do {
        let data = try await parent.requestAsync(url: url,
                                                 httpMethod: .post,
                                                 parameters: parameters,
                                                 encoding: JSONEncoding.default,
                                                 headers: parent.headers())
        
        let json = try JSON(data: data, options: .mutableContainers)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategyFormatters = [ DateFormatter.ddMMyyyy,
                                                   DateFormatter.dateTimeFormatter,
                                                   DateFormatter.dateFormatter ]
        let instance = try decoder.decode(Survey.self, from: json.rawData())
        instance.isVisited = true
        Surveys.shared.append([instance])
        SurveyReferences.shared.append([instance.reference])
        
        return instance
      } catch let error {
        throw error
      }
    }
    
    public func reject(survey: Survey,
                       requestHotExcept: [Survey] = []) async throws {
      
      guard let url = API_URLS.Surveys.reject,
            !headers.isNil
      else { throw APIError.invalidURL }
      
      var parameters: Parameters = ["survey_id": survey.id]
      
      if !requestHotExcept.isEmpty {
        parameters["exclude_ids"] = requestHotExcept.map { $0.id }
      }
      
      do {
        ///JSON with hot surveys returned
        let data = try await parent.requestAsync(url: url,
                                                 httpMethod: .post,
                                                 parameters: parameters,
                                                 encoding: JSONEncoding.default,
                                                 headers: headers,
                                                 accessControl: true)
        survey.isRejected = true
        
        guard !requestHotExcept.isEmpty else { return }
        
        let json = try JSON(data: data, options: .mutableContainers)
        try Surveys.shared.load(json)
      } catch let error {
#if DEBUG
        error.printLocalized(class: type(of: self), functionName: #function)
#endif
        throw error
      }
    }
    
    public func claim(surveyReference: SurveyReference,
                      reason: Claim,
                      requestHotExcept: [Survey] = []) async throws  {
      guard let url = API_URLS.Surveys.claim,
            !headers.isNil
      else { throw APIError.invalidURL }
      
      var parameters: Parameters = ["survey_id": surveyReference.id,
                                    "claim_id": reason.id]
      
      if !requestHotExcept.isEmpty {
        parameters["excluded_hot_list"] = requestHotExcept.map { $0.id }
      }
      
      do {
        let data = try await parent.requestAsync(url: url, httpMethod: .post,
                                              parameters: parameters,
                                              encoding: JSONEncoding.default,
                                              headers: parent.headers())
        surveyReference.isClaimed = true
        
        guard !requestHotExcept.isEmpty else { return }
        
        let json = try JSON(data: data, options: .mutableContainers)
        try Surveys.shared.load(json)
      } catch let error {
        surveyReference.isClaimedPublisher.send(completion: .failure(error))
        
        throw error
      }
    }
    
    public func incrementViewCounter(surveyReference: SurveyReference) async throws {
      guard let url = API_URLS.Surveys.incrementViews,
            !headers.isNil
      else { throw APIError.invalidURL }
      
      let data = try await parent.requestAsync(url: url, httpMethod: .post, parameters: ["survey_id": surveyReference.id], encoding: JSONEncoding.default, headers: parent.headers())
      let json = try JSON(data: data, options: .mutableContainers)
      if let value = json["views"].int {
        surveyReference.survey?.views = value
        surveyReference.isVisited = true
      } else if let error = json["error"].string {
        throw error
      } else {
        throw "Unknown error"
      }
    }
    
    public func surveyReferences(category: Survey.SurveyCategory,
                                 ids: [Int]? = nil,
                                 period: Period? = nil,
                                 topic: Topic? = nil,
                                 userprofile: Userprofile? = nil,
                                 compatibility: TopicCompatibility? = nil,
                                 fetchResult: [SurveyReference] = []) async throws {
      guard let url = category.url,
            let headers = headers
      else { throw APIError.invalidURL }
      
      var parameters: Parameters!
      if category == .Topic, !topic.isNil {
        parameters = ["exclude_ids": SurveyReferences.shared.all.filter({ $0.topic == topic }).map { $0.id }]
        parameters["category_id"] = topic?.id
      } else if category == .ByOwner, let userprofile = userprofile {
        parameters = ["exclude_ids": SurveyReferences.shared.all.filter({ $0.owner == userprofile }).map { $0.id }]
        parameters["userprofile_id"] = userprofile.id
      } else if category == .Compatibility, let compatibility = compatibility {
        var list = [Int]()
        if let ids = ids, !ids.isEmpty {
          list = ids
        } else {
          let fullSet = Set(compatibility.surveys)
          let existingSet = Set(Set(category.dataItems(compatibility: compatibility).map { $0.id }))
          list = Array(fullSet.symmetricDifference(existingSet))
        }
        guard !list.isEmpty else { return }
            
#if DEBUG
        print("APIManager.Polls.surveyReferences() by compatibility", list)
#endif
        parameters = ["ids": list]
      } else if category == .Search {
        parameters = ["exclude_ids": fetchResult.map { $0.id }]
      } else {
        parameters = ["exclude_ids": category.dataItems().map { $0.id }]
      }
      
      if let period = period, period != .AllTime, let dateFrom = period.date() {
        parameters["date_from"] = dateFrom.toDateString()
      }
      
      do {
        let data = try await parent.requestAsync(url: url,
                                                 httpMethod: .post,
                                                 parameters: parameters,
                                                 encoding: JSONEncoding.default,
                                                 headers: headers)
        try await MainActor.run {
          try Surveys.shared.load(try JSON(data: data, options: .mutableContainers))
        }
      } catch let error {
#if DEBUG
        error.printLocalized(class: type(of: self), functionName: #function)
#endif
        throw error
      }
    }
    /**
     Returns a new constraint designated by `multiplier`. Original constraint is deactivated
     - parameter instances: surveys to update.
     - parameter duration: time interval to animate.
     */
    public func updateSurveyStats(_ instances: [SurveyReference]) async throws {
      guard let url = API_URLS.Surveys.updateStats,
            let headers = headers
      else { throw APIError.invalidURL }
      
      let parameters: Parameters = ["ids": instances.compactMap { $0.id }]
      
      do {
        let data = try await parent.requestAsync(url: url,
                                                 httpMethod: .post,
                                                 parameters: parameters,
                                                 encoding: JSONEncoding.default,
                                                 headers: headers)
        let json = try JSON(data: data,
                            options: .mutableContainers)
        
        await MainActor.run {
          Surveys.shared.updateStats(json)
        }
      } catch let error {
        throw error
      }
    }
    
    /**
     Request update topics stats. `Topic.active` & `Topic.total`
     */
    public func updateTopicsStats() async throws {
      guard let url = API_URLS.Topics.updateStats,
            let headers = headers
      else { throw APIError.invalidURL }
      
      do {
        let data = try await parent.requestAsync(url: url,
                                                 httpMethod: .get,
                                                 parameters: nil,
                                                 encoding: URLEncoding.default,
                                                 headers: headers)
        let json = try JSON(data: data, options: .mutableContainers)
        Topics.shared.updateStats(json)
      } catch let error {
        throw error
      }
    }
    
    //Requests stats updates for survey
    public func updateResultStats(_ instance: Survey) async throws {
      guard let url = API_URLS.Surveys.updateResults,
            let headers = headers
      else { throw APIError.invalidURL }
      
      let parameters: Parameters = [
        "id": instance.id,
        "excluded_root_comment_ids": Comments.shared.all.filter({ $0.survey == instance && $0.isParentNode }).map { $0.id }
      ]

      do {
        let data = try await parent.requestAsync(url: url, httpMethod: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
        let json = try JSON(data: data, options: .mutableContainers)
        await MainActor.run {
          Surveys.shared.updateResultsStats(json)
        }
      } catch let error {
        throw error
      }
    }
    
    //Requests stats updates for comments
    public func updateCommentsStats(_ comments: [Comment]) async throws {
      guard let url = API_URLS.Surveys.updateCommentsStats,
            let headers = headers
      else { throw APIError.invalidURL }
      
      let parameters: Parameters = ["ids": comments.map { $0.id } ]

      do {
        let data = try await parent.requestAsync(url: url,
                                                 httpMethod: .post,
                                                 parameters: parameters,
                                                 encoding: JSONEncoding.default,
                                                 headers: headers)
        
        Comments.shared.updateStats(try JSON(data: data, options: .mutableContainers))
      } catch let error {
        throw error
      }
    }
    
    
    func markFavorite(mark: Bool, surveyReference: SurveyReference) async {
      guard let url = mark ? API_URLS.Surveys.addFavorite : API_URLS.Surveys.removeFavorite,
            let headers = headers
      else {
        NotificationCenter.default.post(name: Notifications.Surveys.FavoriteRequestFailure,
                                        object: surveyReference)
        return
      }
      
      do {
        try await parent.requestAsync(url: url,
                                      httpMethod: .post,
                                      parameters: ["survey_id": surveyReference.id],
                                      encoding: JSONEncoding.default,
                                      headers: headers)
        surveyReference.isFavorite = mark
      } catch {
        NotificationCenter.default.post(name: Notifications.Surveys.FavoriteRequestFailure,
                                        object: surveyReference)
      }
    }
    
//    func search(substring: String, excludedIds: [Int]) async throws -> [SurveyReference] {
//      guard let url = API_URLS.Surveys.searchBySubstring,
//            let headers = headers
//      else { throw APIError.invalidURL }
//
//      var parameters: Parameters = ["substring": substring]
//      if !excludedIds.isEmpty { parameters["exclude_ids"] = excludedIds }
//      do {
//        let data = try await parent.requestAsync(url: url, httpMethod: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
//        let decoder = JSONDecoder()
//        decoder.dateDecodingStrategyFormatters = [ DateFormatter.ddMMyyyy,
//                                                   DateFormatter.dateTimeFormatter,
//                                                   DateFormatter.dateFormatter ]
//
//        let instances = try decoder.decode([SurveyReference].self, from: data)
//        guard !instances.isEmpty else {
//          return []
//        }
//        return {
//          var array: [SurveyReference] = []
//          instances.forEach { instance in array.append(SurveyReferences.shared.all.filter({ $0 == instance }).first ?? instance) }
//          return array
//        }()
//      } catch let error {
//#if DEBUG
//        print(error)
//#endif
//        throw error
//      }
//    }
    
    func search(substring: String,
                localized: Bool = false,
                excludedIds: [Int] = [],
                ownersIds: [Int] = [],
                topicsIds: [Int] = []) async throws -> [SurveyReference] {
      guard let url = API_URLS.Surveys.search,
            let headers = headers
      else { throw APIError.invalidURL }
      
      let parameters: Parameters = [
        "localized": localized,
        "substring": substring,
        "owner_ids": ownersIds,
        "category_ids": topicsIds,
        "exclude_ids": excludedIds,
      ]
    
#if DEBUG
      print(parameters)
#endif

      do {
        let data = try await parent.requestAsync(url: url, httpMethod: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
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
          instances.forEach { instance in array.append(SurveyReferences.shared.all.filter({ $0 == instance }).first ?? instance) }
          return array
        }()
      } catch let error {
#if DEBUG
        print(error)
#endif
        throw error
      }
    }
    
    public func postComment(_ body: String, survey: SurveyReference, replyTo: Comment? = nil, username: String? = nil) async throws -> Comment {
      guard let url = API_URLS.Surveys.postComment,
            let headers = headers
      else { throw APIError.invalidURL }
      
      var parameters: Parameters = ["survey": survey.id, "body": body,]
      
      if let replyId = replyTo?.id {
        parameters["reply_to"] = replyId
      }
      
      if let username = username {
        parameters["anon"] = username
      }
      
      do {
        let data = try await parent.requestAsync(url: url, httpMethod: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategyFormatters = [ DateFormatter.ddMMyyyy,
                                                   DateFormatter.dateTimeFormatter,
                                                   DateFormatter.dateFormatter ]
        
        let instance = try decoder.decode(Comment.self, from: data)
        survey.commentsTotal += 1
        
        NotificationCenter.default.post(name: Notifications.Comments.Post, object: nil)
        survey.survey?.commentPostedPublisher.send(instance)
        
        //Root comment children count increase notification
        if let replyTo = replyTo {
          //Find root node
          let rootNode: Comment? = replyTo.isParentNode ? replyTo : replyTo.parent
          
          if let rootNode = rootNode {
            rootNode.replies += 1
          }
        }
        
        return instance
      } catch let error {
        throw error
      }
    }
    
    public func claimComment(comment: Comment, reason: Claim) async throws {
      guard let url = API_URLS.Surveys.claimComment,
            let headers = headers
      else { throw APIError.invalidURL }
      
      let parameters: Parameters = ["comment_id": comment.id, "claim_id": reason.id]
      
      do {
        let data = try await parent.requestAsync(url: url, httpMethod: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
        
        let json = try JSON(data: data, options: .mutableContainers)
        
        guard let status = json["status"].string,
              status == "ok"
        else { throw APIError.badData }
        
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
      guard let url = API_URLS.Surveys.deleteComment,
            let headers = headers
      else { throw APIError.invalidURL }
      
      let parameters: Parameters = ["comment_id": comment.id]
      
      do {
        let data = try await parent.requestAsync(url: url, httpMethod: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
        
        guard let json = try JSON(data: data, options: .mutableContainers) as? JSON,
              let status = json["status"].string,
              status == "ok"
        else { return }
        
        await MainActor.run {
          Comments.shared.all.remove(object: comment)
          //                    NotificationCenter.default.post(name: Notifications.Comments.Delete, object: comment)
          comment.isDeleted = true
          
          if let survey = comment.survey { survey.commentsTotal -= 1 }
        }
        
      } catch let error {
#if DEBUG
        error.printLocalized(class: type(of: self), functionName: #function)
#endif
        throw error
      }
    }
    
    
    public func requestRootComments(survey: SurveyReference, excludedComments: [Comment] = []) async throws {
      guard let url = API_URLS.Surveys.getRootComments,
            let headers = headers
      else { throw APIError.invalidURL }
      
      var parameters: Parameters = ["survey": survey.id]
      
      if !excludedComments.isEmpty {
        parameters["ids"] = excludedComments.map { $0.id }
      }
      
      do {
        let data = try await parent.requestAsync(url: url, httpMethod: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
        
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
      guard let url = API_URLS.Surveys.getChildComments,
            let headers = headers
      else { throw APIError.invalidURL }
      
      var parameters: Parameters = ["root_id": rootComment.id]
      
      if !excludedComments.isEmpty {
        parameters["ids"] = excludedComments.map { $0.id }
      }
      
      do {
        let data = try await parent.requestAsync(url: url, httpMethod: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
        
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
    
    @discardableResult
    public func getVoters(for answer: Answer) async throws -> [Userprofile] {
      guard let url = API_URLS.Surveys.voters,
            let headers = headers
      else { throw APIError.invalidURL }
      
      let parameters: Parameters = ["survey_id": answer.surveyID, "answer_id": answer.id, "exclude_ids": answer.voters.map({ return $0.id })]
#if DEBUG
      print(parameters)
#endif
      do {
        let data = try await parent.requestAsync(url: url, httpMethod: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategyFormatters = [
          DateFormatter.ddMMyyyy,
          DateFormatter.dateTimeFormatter,
          DateFormatter.dateFormatter
        ]
        var container: [Userprofile] = []
        let instances = try decoder.decode([Userprofile].self, from: data)
        instances.forEach { instance in
          if let existing = Userprofiles.shared.all.filter({ $0 == instance }).first {
            container.append(existing)
          } else {
            container.append(instance)
          }
        }
        
        return container.uniqued()
      } catch let error {
        throw error
      }
    }
    
    public func getSurveyState(_ instance: SurveyReference) async throws {
      guard let url = API_URLS.Surveys.getSurveyState,
            let headers = headers
      else { throw APIError.invalidURL }
        
      let parameters: Parameters = ["id": instance.id]
      
      do {
        let data = try await parent.requestAsync(url: url, httpMethod: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
        
        let json = try JSON(data: data, options:  .mutableContainers)
        
        guard let isActive = json["active"].bool,
              let isBanned = json["is_banned"].bool
        else { return }
        
        instance.isActive = isActive
        instance.isBanned = isBanned
      } catch let error {
        throw error
      }
    }
//    @discardableResult
//    public func getVoters(for answer: Answer, exclude: [Userprofile]) async throws -> Data {
//      guard let url = API_URLS.Surveys.voters,
//            let headers = headers
//      else { throw APIError.invalidURL }
//
//      let parameters: Parameters = ["survey_id": answer.surveyID, "answer_id": answer.id, "exclude_ids": answer.voters.map({ return $0.id })]
//
//      do {
//        return try await parent.requestAsync(url: url, httpMethod: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
//      } catch let error {
//        throw error
//      }
//    }
    public func vote(answer: Answer) async throws -> JSON {
      guard let url = API_URLS.Surveys.vote,
            let headers = headers,
            let id = answer.survey?.id
      else { throw APIError.invalidURL }
      
      var parameters: [String: Any] = ["survey": id, "answer": answer.id]
  #if DEBUG
      print(parameters)
  #endif
      if Surveys.shared.hot.count <= MIN_STACK_SIZE {
        let stackList = Surveys.shared.hot.map { $0.id }
        let rejectedList = Surveys.shared.all
          .filter { $0.isRejected}
          .map { $0.id }
        let completedList = [answer.id]
        let list = Array(Set(stackList + rejectedList + completedList))
        if !list.isEmpty {
          parameters["ids"] = list
        }
      }
      
      do {
        let data = try await parent.requestAsync(url: url,
                                                 httpMethod: .post,
                                                 parameters: parameters,
                                                 encoding: JSONEncoding.default,
                                                 headers: headers)
        let json = try JSON(data: data, options: .mutableContainers)
        answer.survey?.isComplete = true
//        await MainActor.run {
//          Surveys.shared.completed.append(answer.survey!)
//        }
        //            answer.survey?.reference.isComplete = true
        return json
      } catch let error {
        throw error
      }
    }
    
    func post(_ parameters: Parameters) async throws {
      guard let url = API_URLS.Surveys.root,
            let headers = headers
      else { throw APIError.invalidURL }
      
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
          multipartFormData.append("\(true)".data(using: .utf8)!, withName: "active")
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
          
          let data = try await parent.uploadMultipartFormDataAsync(url: url, method: .post, multipartDataForm: multipartFormData, headers: headers, uploadProgress: {_ in})
          let json = try JSON(data: data, options: .mutableContainers)
          let decoder = JSONDecoder()
          decoder.dateDecodingStrategyFormatters = [ DateFormatter.ddMMyyyy,
                                                     DateFormatter.dateTimeFormatter,
                                                     DateFormatter.dateFormatter ]
          
          do {
            try await MainActor.run {
              let instance = try decoder.decode(Survey.self, from: json["survey"].rawData())
              Surveys.shared.append([instance])
              
              if let userprofile = Userprofiles.shared.current {
                userprofile.publicationsTotal += 1
              }
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
              Surveys.shared.append([try decoder.decode(Survey.self, from: json["survey"].rawData())])
              
              guard let currentUser = Userprofiles.shared.current,
                    let balance = json["balance"].int
              else { return }
              
              currentUser.balance = balance
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
  
  public func getUserTopPublications(user: Userprofile, completion: @escaping(Result<JSON,Error>)->()) {
    guard let url = URL(string: API_URLS.BASE)?.appendingPathComponent(API_URLS.USER_PROFILE_TOP_PUBS) else { completion(.failure(APIError.invalidURL)); return }
    let parameters: Parameters = ["userprofile_id": user.id]
    request(url: URL(string: API_URLS.BASE)!.appendingPathComponent(API_URLS.USER_PROFILE_TOP_PUBS), httpMethod: .get, parameters: parameters, encoding: URLEncoding.default) { completion($0) }
  }
  
  func cancelAllRequests() {
    self.sessionManager.session.getAllTasks { (tasks) in
      tasks.forEach { $0.cancel() }
    }
            self.sessionManager.session.getTasksWithCompletionHandler {
                (sessionDataTask, uploadData, downloadData) in
                sessionDataTask.forEach { $0.cancel() }
                uploadData.forEach { $0.cancel() }
                downloadData.forEach { $0.cancel() }
            }
  }
}

private extension API {
  func uploadMultipartFormDataAsync(url: URL, method: HTTPMethod, multipartDataForm: MultipartFormData, headers: HTTPHeaders, uploadProgress: @escaping (Double) -> ()?) async throws -> Data {
    try await withUnsafeThrowingContinuation { (continuation: UnsafeContinuation<Data, Error>) in
      self.sessionManager.upload(multipartFormData: multipartDataForm, to: url, method: method, headers: headers)
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
                continuation.resume(throwing: APIError.backend(code: statusCode, value: json.rawString()))
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
  
  ///Check token expiration time, refresh if needed
  func accessControl(completion: @escaping (Result<Bool, Error>) -> ()) {
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
  
  func accessControlAsync() async throws {
    func refreshAccessTokenAsync() async throws {
      guard let refreshToken = (KeychainService.loadRefreshToken() as String?) else {
        throw "Error occured while retrieving refresh token from KeychainService"
      }
      //            print(refreshToken)
      let parameters = [
        "client_id": API_URLS.CLIENT_ID,
        "client_secret": API_URLS.CLIENT_SECRET,
        "grant_type": "refresh_token",
        "refresh_token": "\(refreshToken)"
      ]
      guard let url = API_URLS.Auth.token else {
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
    
    guard let nsstring = KeychainService.loadTokenExpireDateTime(),
          let expiryDate = (nsstring as String).dateTime else {
      throw "Can't retrieve token expiration date from KeychainService"
    }
    guard Date() >= expiryDate else { return }
    do {
      try await refreshAccessTokenAsync()
    } catch {
      throw error
    }
  }
  
  func refreshAccessToken(completion: @escaping (Result<Bool, Error>) -> ()) {
    guard let refreshToken = (KeychainService.loadRefreshToken() as String?) else {
      completion(.failure("Error occured while retrieving refresh token from KeychainService"))
      return
    }
    let parameters = ["client_id": API_URLS.CLIENT_ID, "client_secret": API_URLS.CLIENT_SECRET, "grant_type": "refresh_token", "refresh_token": "\(refreshToken)"]
    guard let url = API_URLS.Auth.token else {
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
          guard 200...299 ~= statusCode else { completion(.failure(APIError.backend(code: statusCode, value: json.rawString()))); return }
          completion(saveTokenInKeychain(json: json))
        } catch let _error {
          completion(.failure(_error))
        }
      case let .failure(_error):
        completion(.failure(_error))
      }
    }
  }
  
  @discardableResult
  func requestAsync(url: URL,
                    httpMethod: HTTPMethod,
                    parameters: Parameters? = nil,
                    encoding: ParameterEncoding = JSONEncoding.default,
                    headers: HTTPHeaders? = nil,
                    accessControl: Bool = true) async throws -> Data {
    
    func request() async throws -> Data {
      try await withUnsafeThrowingContinuation { (continuation: UnsafeContinuation<Data,Error>) in
        self.sessionManager.request(url,
                                    method: httpMethod,
                                    parameters: parameters,
                                    encoding: encoding,
                                    headers: headers).responseData { response in
          switch response.result {
          case .success(let data):
            guard let statusCode = response.response?.statusCode else { continuation.resume(throwing: APIError.httpStatusCodeMissing); return }
            do {
              let json = try JSON(data: data, options: .mutableContainers)
              guard 200...299 ~= statusCode else {
//                var value: Any = ""
//                if let string = json.string {
//                  value = string
//                } else if let dict = json.dictionary {
//                  value = dict
//                } else if let rawString =  json.rawString() {
//                  value = rawString.replacingOccurrences(of: "\n", with: "")
//                } else {
//                  value = "backend_error".localized
//                }
                continuation.resume(throwing: APIError.backend(code: statusCode, value: json))
                
                return
              }
              
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
  
  func request(url: URL, httpMethod: HTTPMethod,  parameters: Parameters? = nil, encoding: ParameterEncoding = JSONEncoding.default, useHeaders: Bool = true, accessControl useAccessControl: Bool = true, completion: @escaping(Result<JSON, Error>)->()) {
    if useAccessControl {
      accessControl { result in
        switch result {
        case .success:
          self.sessionManager.request(url, method: httpMethod, parameters: parameters, encoding: encoding, headers: useHeaders ? self.headers() : nil).response { response in
            switch response.result {
            case .success(let value):
              guard let statusCode = response.response?.statusCode else { completion(.failure(APIError.httpStatusCodeMissing)); return }
              guard let data = value else { completion(.failure(APIError.badData)); return }
              guard 200...299 ~= statusCode else { completion(.failure(APIError.backend(code: statusCode, value: String(decoding: data, as: UTF8.self)))); return }
              do {
                //TODO: Определиться с инициализацией JSON
                let json = try JSON(data: data, options: .mutableContainers)
                guard 200...299 ~= statusCode else { completion(.failure(APIError.backend(code: statusCode, value: json.rawString()))); return }
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
    } else {
      self.sessionManager.request(url, method: httpMethod, parameters: parameters, encoding: encoding, headers: useHeaders ? self.headers() : nil).response { response in
        switch response.result {
        case .success(let value):
          guard let statusCode = response.response?.statusCode else { completion(.failure(APIError.httpStatusCodeMissing)); return }
          guard let data = value else { completion(.failure(APIError.badData)); return }
          guard 200...299 ~= statusCode else { completion(.failure(APIError.backend(code: statusCode, value: String(decoding: data, as: UTF8.self)))); return }
          do {
            //TODO: Определиться с инициализацией JSON
            let json = try JSON(data: data, options: .mutableContainers)
            guard 200...299 ~= statusCode else { completion(.failure(APIError.backend(code: statusCode, value: json.rawString()))); return }
            completion(.success(json))
          } catch let error {
            completion(.failure(error))
          }
        case .failure(let error):
          completion(.failure(self.parseAFError(error)))
        }
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
}
