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
  class func search(userprofile: Userprofile, string: String) async {
    guard let url = URL(string: "http://api.geonames.org/searchJSON?name_startsWith=\(string)&cities=cities1000&featureClass=P&maxRows=10&lang=\(L10n.shared.language)&username=grindnoise".encodedURL)
    else {
      userprofile.cityFetchPublisher.send(completion: .failure(APIError.invalidURL))
      return
    }
    
    do {
      let data = try await requestAsync(url: url, httpMethod: .get)
      let json = try JSON(data: data, options: .mutableContainers)
      
      let jsonData = try json["geonames"].rawData()
      
      let decoder = JSONDecoder.withDateTimeDecodingStrategyFormatters()
      let decoded = try decoder.decode([GeonamesObject].self, from: jsonData)
      let fetchResult = decoded.reduce(into: [City]()) {
        cities, geonameObject in cities.append(City.initFromGeonamesObject(geonameObject))//(GeonamesObjects.shared.all.filter({ $0 == city }).first ?? city)
      }
      userprofile.cityFetchPublisher.send(fetchResult)
    } catch {
      userprofile.cityFetchPublisher.send(completion: .failure(APIError.badData))
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

class GeonamesObjects {
  static let shared = GeonamesObjects()
  private init() {}
  var all: [GeonamesObject] = []
  
  public func eraseData() {
    all.removeAll()
  }
}

class GeonamesObject: Decodable {
  private enum CodingKeys: String, CodingKey {
    case id, name, countryName, geonames, geonameId, localized, countryCode,
//         geoname_ID  = "geoname_id",
         regionID   = "adminCode1",
         countryID  = "countryId",
         regionName  = "adminName1"
  }
  var id: Int?
  var name: String
  var localized: String?
  var geonameID: Int
  var countryID: String
  var regionID: String?
  var countryCode: String
  var countryName: String
  var regionName: String
  
  required init(from decoder: Decoder) throws {
    do {
      let container   = try decoder.container(keyedBy: CodingKeys.self)
      id              = try container.decodeIfPresent(Int.self, forKey: .id)
      name            = try container.decode(String.self, forKey: .name)
      geonameID       = try container.decode(Int.self, forKey: .geonameId)
      localized       = try container.decodeIfPresent(String.self, forKey: .localized)
      countryID       = try container.decode(String.self, forKey: .countryID)
      regionID        = try container.decodeIfPresent(String.self, forKey: .regionID)
      countryName     = try container.decode(String.self, forKey: .countryName)
      countryCode     = try container.decode(String.self, forKey: .countryCode)
      regionName      = try container.decode(String.self, forKey: .regionName)
      if GeonamesObjects.shared.all.filter({ $0.hashValue == hashValue }).isEmpty {
        GeonamesObjects.shared.all.append(self)
      }
    } catch {
#if DEBUG
      error.printLocalized(class: type(of: self), functionName: #function)
#endif
      throw error
    }
  }
}

extension GeonamesObject: Hashable {
  static func == (lhs: GeonamesObject, rhs: GeonamesObject) -> Bool {
    return lhs.hashValue == rhs.hashValue
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(geonameID)
    hasher.combine(name)
  }
}
