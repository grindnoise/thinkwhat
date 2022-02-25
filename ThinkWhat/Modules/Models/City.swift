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
    
    public func eraseData() {
        all.removeAll()
    }
}

class City: Decodable {
    private enum CodingKeys: String, CodingKey {
        case id, name, countryName, geonames, geonameId,
             geoname_ID  = "geoname_id",
             regionID   = "region_id",
             countryID  = "country_id",
             regionName  = "adminName1"
    }
    var id: Int?
    var name: String
    var geonameID: Int
    var countryID: Int?
    var regionID: Int?
    var countryName: String
    var regionName: String
    
    required init(from decoder: Decoder) throws {
        do {
            let container   = try decoder.container(keyedBy: CodingKeys.self)
            id              = try container.decodeIfPresent(Int.self, forKey: .id)
            name            = try container.decode(String.self, forKey: .name)
            if let geonameId = try container.decodeIfPresent(Int.self, forKey: .geonameId) {
                geonameID = geonameId
            } else if let _geoname_ID = try container.decodeIfPresent(Int.self, forKey: .geoname_ID) {
                geonameID = _geoname_ID
            } else {
                throw "geonameID not found"
            }
            countryID       = try container.decodeIfPresent(Int.self, forKey: .countryID)
            regionID        = try container.decodeIfPresent(Int.self, forKey: .regionID)
            countryName     = try container.decode(String.self, forKey: .countryName)
            regionName      = try container.decode(String.self, forKey: .regionName)
            if Cities.shared.all.filter({ $0.hashValue == hashValue }).isEmpty {
                Cities.shared.all.append(self)
            }
        } catch {
            print(error)
            throw error
        }
    }
}

extension City: Hashable {
    static func == (lhs: City, rhs: City) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(geonameID)
        hasher.combine(name)
    }
}
