//
//  GeoNames.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 21.02.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import L10n_swift

class GeoNamesWorker {
    class func searchByName(startsWith name: String) async throws -> Data {
        guard let url = URL(string: "http://api.geonames.org/searchJSON?name_startsWith=\(name)&cities=cities1000&featureClass=P&maxRows=10&lang=\(L10n.shared.language)&username=grindnoise".encodedURL) else { throw APIError.invalidURL }
        do {
            return try await requestAsync(url:
 url, httpMethod: .get)
        } catch let error {
            throw error
        }
    }
    
    class func getByGeonameId(_ id: Int) async throws -> Data {
        guard let url = URL(string: "http://api.geonames.org/getJSON?formatted=true&geonameId=\(id)&username=grindnoise".encodedURL) else { throw APIError.invalidURL }
        do {
            return try await requestAsync(url: url, httpMethod: .get)
        } catch let error {
            throw error
        }
    }
    
    class func requestAsync(url: URL, httpMethod: HTTPMethod,  parameters: Parameters? = nil, encoding: ParameterEncoding = JSONEncoding.default, headers: HTTPHeaders? = nil) async throws -> Data {
        try await withUnsafeThrowingContinuation { continuation in
            AF.request(url, method: httpMethod, parameters: parameters, encoding: encoding, headers: headers).responseData { response in
                switch response.result {
                case .success(let data):
                    guard let statusCode = response.response?.statusCode else { continuation.resume(throwing: APIError.httpStatusCodeMissing); return }
                    do {
                        let json = try JSON(data: data, options: .mutableContainers)
#if DEBUG
                        print(json)
#endif
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
            }
        }
    }
}
