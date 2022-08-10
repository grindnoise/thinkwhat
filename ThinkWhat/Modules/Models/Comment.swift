//
//  Comment.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 08.08.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import Foundation
import SwiftyJSON

class Comments {
    static let shared = Comments()
    private init() {}
    var all: [Comment] = []
    
    func load(_ data: Data) {
        let decoder = JSONDecoder()
        do {
            _ = try decoder.decode([Comment].self, from: data)
        } catch {
#if DEBUG
            error.printLocalized(class: type(of: self), functionName: #function)
            fatalError()
#endif
        }
    }
}

class Comment: Decodable {
    private enum CodingKeys: String, CodingKey {
        case id, survey, parent, children, body, replies
        case userprofile        = "user"
        case anonUsername       = "name"
        case createdAt          = "created_on"
        case childrenCount      = "children_count"
        case replyTo            = "reply_to"
    }
    
    let id: Int
    let body: String
    let surveyId: Int?
    let replies: Int
    var survey: Survey? {
        return Surveys.shared.all.filter { $0.id == surveyId }.first
    }
    var userprofile: Userprofile?
    let anonUsername: String
    let createdAt: Date
    var replyTo: Comment?
    var isAnonymous: Bool {
        return userprofile.isNil && !anonUsername.isEmpty
    }
    var parent: Comment? {
        return Comments.shared.all.filter({ $0.children.contains(self) }).first
    }
    var children: [Comment] = []
    var isParentNode: Bool {
        return !children.isEmpty
    }
    
    required init(from decoder: Decoder) throws {
        do {
            let container   = try decoder.container(keyedBy: CodingKeys.self)
            id              = try container.decode(Int.self, forKey: .id)
            body            = try container.decode(String.self, forKey: .body)
            anonUsername    = try container.decode(String.self, forKey: .anonUsername)
            let _userprofile = try container.decodeIfPresent(Userprofile.self, forKey: .userprofile)
            if !_userprofile.isNil {
                userprofile = Userprofiles.shared.all.filter({ $0.id == _userprofile!.id }).first ?? _userprofile
            }
            surveyId        = try container.decode(Int.self, forKey: .survey)
            createdAt       = try container.decode(Date.self, forKey: .createdAt)
            children        = (try? container.decode([Comment].self, forKey: .children)) ?? []
            replies         = try container.decode(Int.self, forKey: .replies)
            
            if Comments.shared.all.filter({ $0 == self }).isEmpty {
                Comments.shared.all.append(self)
            }
        } catch {
            throw error
        }
    }
}

extension Comment: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(body)
        hasher.combine(id)
    }
    static func == (lhs: Comment, rhs: Comment) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
}





