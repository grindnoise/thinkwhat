//
//  ClaimCategory.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 28.10.2021.
//  Copyright © 2021 Pavel Bukharov. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Claim: Decodable {
    private enum CodingKeys: String, CodingKey {
        case id, description
    }
    let id: Int
    let description: String
    
    init(from decoder: Decoder) throws {
        do {
            let container   = try decoder.container(keyedBy: CodingKeys.self)
            id              = try container.decode(Int.self, forKey: .id)
            description     = try container.decode(String.self, forKey: .description)
            if Claims.shared.all.filter({ $0.hashValue == hashValue }).isEmpty {
                Claims.shared.all.append(self)
            }
        } catch {
            throw error
        }
    }
}

extension Claim: Hashable {
    static func == (lhs: Claim, rhs: Claim) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(description)
        hasher.combine(id)
    }
}

class Claims {
    static let shared = Claims()
    var all: [Claim] = []
    private init() {}
    
    func load(_ data: Data) {
        let decoder = JSONDecoder()
        do {
            _ = try decoder.decode([Claim].self, from: data)
            print(all.count)
        } catch {
            fatalError("Claim init() threw error: \(error)")
        }
    }
    
    subscript (id: Int) -> Claim? {
        if let i = all.first(where: {$0.id == id}) {
            return i
        } else {
            return nil
        }
    }
}
