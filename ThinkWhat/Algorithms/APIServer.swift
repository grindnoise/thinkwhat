//
//  APIServer.swift
//  Burb
//
//  Created by Pavel Bukharov on 26.04.2018.
//  Copyright © 2018 Pavel Bukharov. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
//import MapKit

protocol APIServerProtocol {

    func logIn(username: String, password: String, completion: @escaping (TokenState) -> ())
    func logInViaSocialMedia(authToken: String, socialMedia: AuthVariant, completion: @escaping (TokenState) -> ())
    func logOut(completion: @escaping (TokenState) -> ())
    func getFacebookID(completion: @escaping (String) -> ())
    func updateUserProfile(json: JSON, completion: @escaping(Bool) -> ())
//    func requestUserData(socialNetwork: AuthVariant, completion: @escaping (JSON) -> ())
//    func downloadImage(url: URL, percentageClosure: @escaping (CGFloat) -> (), completion: @escaping (UIImage) -> ())
//    func pullUserData(_ userID: String, completion: @escaping (JSON) -> ())
//    func makeOrder(_ order: Order, completion: @escaping (JSON) -> ())
//    func requestSMSValidationCode(phoneNumber: String, completion: @escaping (JSON?) -> ())
//    func userExists(phoneNumber: String, completion: @escaping (JSON?) -> ())
//    func uploadUserImage(image: UIImage, completion: @escaping (JSON?) -> ())
//    func recoverPassword(_ password: String, completion: @escaping (JSON?) -> ())
}

class APIServer: APIServerProtocol {
    
    private var isProxyEnabled: Bool? {
        didSet {
            if isProxyEnabled != nil && isProxyEnabled != oldValue {
                if isProxyEnabled == true {
                    self.setupProxyConfiguration()
                } else {
                    requestManager = Alamofire.SessionManager.default
                }
            }
        }
    }
    private var requestManager = Alamofire.SessionManager.default
    
    init() {
        
        self.checkForReachability {
            completed in
            self.isProxyEnabled = completed
        }
        
    }
    
    private func checkForReachability(completion: @escaping (Bool) -> ()) {
        
        isProxyEnabled = nil
        let url = URL(string: SERVER_URLS.BASE_URL)!.appendingPathComponent(SERVER_URLS.TOKEN_URL)
        
        Alamofire.SessionManager.default.request(url, method: .get, parameters: [:], encoding: URLEncoding(), headers: nil).responseJSON(completionHandler: {
            response in
            var retVal = false
            if response.response != nil {
                retVal = false
            } else {
                retVal = true
            }
            completion(retVal)
        })
        
    }
    
    private func setupProxyConfiguration() {
        
        var proxyDictionary = [AnyHashable: Any]()
        proxyDictionary[kCFNetworkProxiesHTTPProxy as String] = "45.112.126.238"
        proxyDictionary[kCFNetworkProxiesHTTPPort as String] = 3128
        proxyDictionary[kCFNetworkProxiesHTTPEnable as String] = 1
        proxyDictionary[kCFStreamPropertyHTTPSProxyHost as String] = "45.112.126.238"
        proxyDictionary[kCFStreamPropertyHTTPSProxyPort as String] = 3128
        let proxyConfig = Alamofire.SessionManager.default.session.configuration
        proxyConfig.connectionProxyDictionary = proxyDictionary
        requestManager = Alamofire.SessionManager(configuration: proxyConfig)
    }

    func downloadImage(url: URL, percentageClosure: @escaping (CGFloat) -> (), completion: @escaping (UIImage) -> ()) {
        
        checkForReachability {
            completed in
            self.isProxyEnabled = completed
            performRequest()
        }
        
        //checkTokenExpiryDate
        func performRequest() {
            requestManager.request(url).downloadProgress(closure: {
                progress in
                let prog = CGFloat(progress.fractionCompleted)
                percentageClosure(prog)
            }).response(completionHandler: {
                response in
                if let data = response.data {
                    if let image = UIImage(data: data) {
                        completion(image)
                    }
                } else {
                    completion(UIImage())
                }
            })
        }
    }

    func logIn(username: String, password: String, completion: @escaping (TokenState) -> ()) {
        
        checkForReachability {
            
            completed in
            self.isProxyEnabled = completed
            performRequest()
            
        }
        
        func performRequest() {
            
            let parameters = ["client_id": SERVER_URLS.CLIENT_ID, "client_secret": SERVER_URLS.CLIENT_SECRET, "grant_type": "password", "username": "\(username)", "password": "\(password)"]
            let url = URL(string: SERVER_URLS.TOKEN_URL)!
            //        Alamofire.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON(completionHandler: {
            requestManager.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON(completionHandler: {
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
                    if let statusCode  = response.response?.statusCode {
                        
                        if 200...299 ~= statusCode {
                            if let json = try? JSON(data: response.data!) {
                                for attr in json {
                                    print("\(attr.0): \(attr.1.stringValue)")
                                }
                                saveTokenInKeychain(json: json, tokenState: &tokenState)
                                
//                                switch emailLoginType {
//                                case .Email:
//                                    appData.email = username
//                                case .Username:
                                    appData.username = username
//                                }
                            } else {
                                _tokenState = .Error
                            }
                        } else if 400...499 ~= statusCode {
                            if let json = try? JSON(data: response.data!) {
                                for attr in json {
                                    print("\(attr.0): \(attr.1.stringValue)")
                                }
                            }
                            _tokenState = .Error
                        }
                    }
                    completion(_tokenState)
                }
            })
        }
    }
    
    func logInViaSocialMedia(authToken: String, socialMedia: AuthVariant, completion: @escaping (TokenState) -> ()) {
        
        checkForReachability {
            completed in
            self.isProxyEnabled = completed
            performRequest()
        }
        
        func performRequest() {
            
            let parameters = ["client_id": SERVER_URLS.CLIENT_ID, "client_secret": SERVER_URLS.CLIENT_SECRET, "grant_type": "convert_token", "backend": "\(socialMedia.rawValue.lowercased())", "token": "\(authToken)"]
            print(parameters)
            let url = URL(string: SERVER_URLS.BASE_URL)!.appendingPathComponent(SERVER_URLS.TOKEN_CONVERT_URL)
            requestManager.request(url, method: .post, parameters: parameters, encoding: URLEncoding(), headers: nil).responseJSON() {
                response in
                if response.result.isFailure {
                    fatalError(response.result.debugDescription)
                }
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
                    if let statusCode  = response.response?.statusCode{
                        if 200...299 ~= statusCode {
                            if let json = try? JSON(data: response.data!) {
                                for attr in json {
                                    print("\(attr.0): \(attr.1.stringValue)")
                                }
                                saveTokenInKeychain(json: json, tokenState: &_tokenState)
                            } else {
                                _tokenState = .Error
                            }
                        } else if 400...499 ~= statusCode {
                            if let json = try? JSON(data: response.data!) {
                                for attr in json {
                                    print("\(attr.0): \(attr.1.stringValue)")
                                }
                            }
                            _tokenState = .Error
                        }
                        completion(_tokenState)
                    }
                }
            }
        }
    }
    
    func logOut(completion: @escaping (TokenState) -> ()) {
        
        checkForReachability {
            completed in
            self.isProxyEnabled = completed
            performRequest()
        }
        
        func performRequest() {
            let access_token = KeychainService.loadAccessToken()! as String
            let parameters = ["client_id": SERVER_URLS.CLIENT_ID, "client_secret": SERVER_URLS.CLIENT_SECRET, "token": "\(access_token)"]
            print(parameters)
            let url = URL(string: SERVER_URLS.BASE_URL)!.appendingPathComponent(SERVER_URLS.TOKEN_REVOKE_URL)
            requestManager.request(url, method: .post, parameters: parameters, encoding: URLEncoding(), headers: nil).responseJSON() {
                response in
                var _tokenState = TokenState.Error
                if response.result.isFailure {
                    fatalError(response.result.debugDescription)
                } else if let error = response.result.error as? AFError {
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
                    if let statusCode  = response.response?.statusCode{
                    if 200...299 ~= statusCode {
                        if let json = try? JSON(data: response.data!) {
                            for attr in json {
                                print("\(attr.0): \(attr.1.stringValue)")
                            }
                            KeychainService.saveAccessToken(token: "" as NSString)
                            KeychainService.saveRefreshToken(token: "" as NSString)
                        } else {
                            _tokenState = .Error
                        }
                    } else if 400...499 ~= statusCode {
                        if let json = try? JSON(data: response.data!) {
                            for attr in json {
                                print("\(attr.0): \(attr.1.stringValue)")
                            }
                        }
                        _tokenState = .Error
                    }
                    completion(_tokenState)
                }
            }
        }
    }
    }
    
    func getFacebookID(completion: @escaping (String?) -> ()) {
        
        checkForReachability {
            completed in
            self.isProxyEnabled = completed
            performRequest()
        }
        
        func performRequest() {
            let access_token = KeychainService.loadAccessToken()! as String
            let parameters = ["access_token": "\(access_token)"]
            print(parameters)
            let url = URL(string: SERVER_URLS.BASE_URL)!.appendingPathComponent(SERVER_URLS.GET_FACEBOOK_ID_URL)
            requestManager.request(url, method: .post, parameters: parameters, encoding: URLEncoding(), headers: nil).responseJSON() {
                response in
                if response.result.isFailure {
                    fatalError(response.result.debugDescription)
                }
                if let error = response.result.error as? AFError {
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
                    var id: String
                    if let statusCode  = response.response?.statusCode{
                        if 200...299 ~= statusCode {
                            if let json = try? JSON(data: response.data!) {
                                for attr in json {
                                    print("\(attr.0): \(attr.1.stringValue)")
                                }
                            }
                        } else if 400...499 ~= statusCode {
                            if let json = try? JSON(data: response.data!) {
                                for attr in json {
                                    print("\(attr.0): \(attr.1.stringValue)")
                                }
                            }
                        }
                        completion(id)
                    }
                }
            }
        }
    }
    
    func updateUserProfile(json: JSON, completion: @escaping(Bool) -> ()) {
    
        
    
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
            
            completed in
            self.isProxyEnabled = completed
            performRequest()
            
        }
        
        func performRequest() {
            
            let refresh_token = KeychainService.loadRefreshToken()! as String
            let parameters = ["client_id": SERVER_URLS.CLIENT_ID, "client_secret": SERVER_URLS.CLIENT_SECRET, "grant_type": "refresh_token", "refresh_token": "\(refresh_token)"]
            let url = URL(string: SERVER_URLS.TOKEN_URL)!
            requestManager.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON(completionHandler: {
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
        requestManager.request(url, method: .get, parameters: [:], encoding: URLEncoding.default, headers: nil).responseJSON(completionHandler: {
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
    func pullUserData(_ userID: String = "", completion: @escaping (JSON) -> ()) {
        
        checkForReachability {
            
            completed in
            self.isProxyEnabled = completed
            performRequest()
            
        }
        
        func performRequest() {
            
            checkTokenExpiryDate()
            assert(KeychainService.loadAccessToken() != nil, "Failed to load access_token")
            let parameters = ["access_token": (KeychainService.loadAccessToken()! as String)]//: SERVER_URLS.CLIENT_ID, "client_secret": SERVER_URLS.CLIENT_SECRET, "grant_type": "password", "username": "\(username)", "password": "\(password)"]
            let url = URL(string: userID.isEmpty ? SERVER_URLS.CURRENT_USER_URL : SERVER_URLS.USER_URL + userID)!
            
            requestManager.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON(completionHandler: {
                response in
                if let error = response.result.error as? AFError {
                    
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
                            completion(json)
                        }
                    } else if 400...499 ~= statusCode! {
                        if let json = try? JSON(data: response.data!) {
                            for attr in json {
                                print("\(attr.0): \(attr.1.stringValue)")
                            }
                            completion(json)
                        }
                    }
                }
            })
        }
    }
    
    func requestSMSValidationCode(phoneNumber: String, completion: @escaping (JSON?) -> ()) {
        checkForReachability {
            completed in
            self.isProxyEnabled = completed
            performRequest()
        }
        
        func performRequest() {
            let parameters = ["phone_number": phoneNumber]
            print(parameters)
            let url = URL(string: SERVER_URLS.TOKEN_URL)!//TODO Change to SMSValidationURL
            requestManager.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON(completionHandler: {
                response in
                if let error = response.result.error as? AFError {
                    tokenState = .Error
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
                    var json: JSON?
                    if 200...299 ~= statusCode! {
                        if let receivedJSON = try? JSON(data: response.data!) {
                            for attr in receivedJSON {
                                print("\(attr.0): \(attr.1.stringValue)")
                            }
                            json = receivedJSON
                        }
                    } else if 400...499 ~= statusCode! {
                        if let json = try? JSON(data: response.data!) {
                            for attr in json {
                                print("\(attr.0): \(attr.1.stringValue)")
                            }
                        }
                    }
                    completion(json)
                }
            })
        }
    }
    
    func userExists(phoneNumber: String, completion: @escaping (JSON?) -> ()) {
        checkForReachability {
            completed in
            self.isProxyEnabled = completed
            performRequest()
        }
        
        func performRequest() {
            
        }
    }
    
    func uploadUserImage(image: UIImage, completion: @escaping (JSON?) -> ()) {
        checkForReachability {
            completed in
            self.isProxyEnabled = completed
            performRequest()
        }
        
        func performRequest() {
            
        }
    }
    
    func recoverPassword(_ password: String, completion: @escaping (JSON?) -> ()) {
        checkForReachability {
            completed in
            self.isProxyEnabled = completed
            performRequest()
        }
        
        func performRequest() {
            
        }
    }
    
}
}
