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
    var all: [Comment] = [] {
        didSet {
            //Append
            if oldValue.count < all.count {
                //            Check for duplicates
                guard let lastInstance = all.last else { return }
                guard oldValue.filter({ $0 == lastInstance }).isEmpty else {
                    all.remove(object: lastInstance)
                    return
                }
                guard lastInstance.isParentNode else {
                    NotificationCenter.default.post(name: Notifications.Comments.ChildAppend, object: lastInstance)
                    return
                }
                //            if lastInstance.isBanned
                guard !lastInstance.isDeleted else { return }
                NotificationCenter.default.post(name: Notifications.Comments.Append, object: lastInstance)
                //            if let survey = lastInstance.survey {
                //                survey.reference.commentsTotal += 1
                //            }
            }
        }
    }
    
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
    let parentId: Int?
    var replies: Int
    var survey: Survey? {
        return Surveys.shared.all.filter { $0.id == surveyId }.first
    }
    var userprofile: Userprofile?
    let anonUsername: String
    let createdAt: Date
    let replyToId: Int?
//    let parentId: Int?
    var replyTo: Comment? {
        return Comments.shared.all.filter { $0.id == replyToId }.first
    }
    var isAnonymous: Bool {
        return userprofile.isNil && !anonUsername.isEmpty
    }
    var parent: Comment? {
        return Comments.shared.all.filter({ $0.id == parentId }).first
//        return Comments.shared.all.filter({ $0.children.contains(self) }).first
    }
    var children: [Comment] = [] //{
//        didSet {
//            NotificationCenter.default.post(name: Notifications.Comments.ChildrenCountChange, object: self)
//        }
//    }
    var isParentNode: Bool {
        return parentId.isNil
//        return !children.isEmpty
    }
    var isOwn: Bool {
        guard let userprofile = userprofile,
              let currentUser = Userprofiles.shared.current else {
            return false
        }
        
        return userprofile.id == currentUser.id
    }
    var isBanned: Bool = false {
        didSet {
            guard isBanned else { return }
            NotificationCenter.default.post(name: Notifications.Comments.Ban, object: self)
        }
    }
    var isDeleted: Bool = false {
        didSet {
            guard isDeleted else { return }
            NotificationCenter.default.post(name: Notifications.Comments.Delete, object: self)
        }
    }
    var isClaimed: Bool = false {
        didSet {
            guard isClaimed else { return }
            NotificationCenter.default.post(name: Notifications.Comments.Claim, object: self)
        }
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
            replyToId       = try container.decodeIfPresent(Int.self, forKey: .replyTo)
            parentId        = try container.decodeIfPresent(Int.self, forKey: .parent)
            
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
        hasher.combine(surveyId)
        hasher.combine(id)
        hasher.combine(body)
    }
    static func == (lhs: Comment, rhs: Comment) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}





