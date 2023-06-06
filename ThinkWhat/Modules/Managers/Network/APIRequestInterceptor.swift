//
//  RequestInterceptor.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 16.08.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import Alamofire
import Foundation

class APIRequestInterceptor: RequestInterceptor {
    //1
    let retryLimit = 3
    let retryDelay: TimeInterval = 5
    //2
    func adapt(
        _ urlRequest: URLRequest,
        for session: Session,
        completion: @escaping (Result<URLRequest, Error>) -> Void
    ) {
        print("")
        var urlRequest = urlRequest
//        if let token = TokenManager.shared.fetchAccessToken() {
//            urlRequest.setValue("token \(token)", forHTTPHeaderField: "Authorization")
//        }
        completion(.success(urlRequest))
    }
    //3
    func retry(
        _ request: Request,
        for session: Session,
        dueTo error: Error,
        completion: @escaping (RetryResult) -> Void
    ) {
        let response = request.task?.response as? HTTPURLResponse
        //Retry for 5xx status codes
        if
//            let statusCode = response?.statusCode,
//            (500...599).contains(statusCode),
            request.retryCount < retryLimit {
            completion(.retryWithDelay(retryDelay))
        } else {
            return completion(.doNotRetry)
        }
    }
}

class APIRequestRetrier: RequestRetrier {
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        print("retry")
    }
}
