//
//  City.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 22.02.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import Foundation

class Cities {
  static let shared = Cities()
  private init() {}
  var all: [City] = []
  
  public func eraseData() { all.removeAll() }
  
  subscript(id: Int) -> City? {
    return all.filter({ $0.geonameId == id }).first
  }
}

class City: Decodable {
  class func initFromGeonamesObject(_ object: GeonamesObject) -> City {
    guard let existing = Cities.shared.all.filter({ $0.geonameId == object.geonameID }).first else {
      return City(object)
    }
    
//    existing.geonamesObject = object
    return existing
  }
  
  private enum CodingKeys: String, CodingKey {
    case id, name, countryName = "country_name", geonames, regionName = "region_name", localizedName = "localized_name", geonameId = "geoname_id", countryCode = "country_code"
  }
  //    var id: Int?
  var name: String
  var localizedName: String
  var geonameId: Int
  //    var countryID: Int?
  //    var regionID: Int?
  var countryName: String
  var countryCode: String
  var regionName: String
//  var geonamesObject: GeonamesObject?
  
  required init(from decoder: Decoder) throws {
    do {
      let container   = try decoder.container(keyedBy: CodingKeys.self)
      name            = try container.decode(String.self, forKey: .name)
      geonameId       = try container.decode(Int.self, forKey: .geonameId)
      localizedName   = try container.decode(String.self, forKey: .localizedName)
      countryName     = try container.decode(String.self, forKey: .countryName)
      countryCode     = try container.decode(String.self, forKey: .countryCode)
      regionName      = try container.decode(String.self, forKey: .regionName)
      if Cities.shared.all.filter({ $0.hashValue == hashValue }).isEmpty {
        Cities.shared.all.append(self)
      }
    } catch {
//#if DEBUG
//      error.printLocalized(class: type(of: self), functionName: #function)
//#endif
      throw error
    }
  }
  
  
  init(_ geonamesObject: GeonamesObject)  {
    name            = geonamesObject.name
    geonameId       = geonamesObject.geonameID
    localizedName   = geonamesObject.name
    countryName     = geonamesObject.countryName
    countryCode     = geonamesObject.countryCode
    regionName      = geonamesObject.regionName
//    self.geonamesObject  = geonamesObject
    if Cities.shared.all.filter({ $0.hashValue == hashValue }).isEmpty {
      Cities.shared.all.append(self)
    }
  }
}

extension City: Hashable {
  static func == (lhs: City, rhs: City) -> Bool {
    return lhs.hashValue == rhs.hashValue
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(geonameId)
    hasher.combine(name)
  }
}
