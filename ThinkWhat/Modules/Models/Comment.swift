//
//  Comment.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 08.08.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import Foundation
import SwiftyJSON
import Combine

class Comments {
  static let shared = Comments()
  private init() {}
  var all: [Comment] = [] {
    didSet {
      //Append
      if oldValue.count < all.count {
        //            Check for duplicates
        guard let lastInstance = all.last,
              let survey = lastInstance.survey
        else { return }
        
        guard oldValue.filter({ $0 == lastInstance }).isEmpty else {
          all.remove(object: lastInstance)
          
          return
        }
        
        survey.commentAppendPublisher.send(lastInstance)
        
        guard lastInstance.isParentNode else {
          NotificationCenter.default.post(name: Notifications.Comments.ChildAppend, object: lastInstance)
//          survey.commentChildAppendPublisher.send(lastInstance)
          return
        }
        //            if lastInstance.isBanned
        guard !lastInstance.isDeleted else { return }
        
//        survey.commentRootAppendPublisher.send(lastInstance)
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
  
  func updateStats(_ json: JSON) {
    guard let array = json.array else { return }
    
    array.forEach {
      guard let id = $0["id"].int,
            let comment = all.filter({ $0.id == id }).first,
            let replies = $0["replies"].int
      else { return }
      
      comment.replies = replies
    }
  }
  
  func commentsCount(for survey: Survey) -> Int {
    return all.filter({ $0.surveyId == survey.id && !$0.isDeleted && !$0.isBanned && !$0.isClaimed }).count
  }
}

class Comment: Decodable {
  private enum CodingKeys: String, CodingKey {
    case id, survey, parent, children, body, replies, choice
    case userprofile        = "user"
    case anonUsername       = "name"
    case createdAt          = "created_on"
    case childrenCount      = "children_count"
    case replyTo            = "reply_to"
    case isBanned           = "is_banned"
    case isDeleted          = "is_deleted"
  }
  
  let id: Int
  let body: String
  let surveyId: Int?
  let parentId: Int?
  var replies: Int {
    didSet {
      guard oldValue != replies else { return }
      
      repliesPublisher.send(replies)
    }
  }
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
      
      isBannedPublisher.send(true)
      isBannedPublisher.send(completion: .finished)
      
      NotificationCenter.default.post(name: Notifications.Comments.Ban, object: self)
      
      guard let survey = survey else { return }
      
      survey.commentBannedPublisher.send(self)
    }
  }
  var isDeleted: Bool = false {
    didSet {
      guard isDeleted else { return }
      
      isDeletedPublisher.send(true)
      isDeletedPublisher.send(completion: .finished)
      
      NotificationCenter.default.post(name: Notifications.Comments.Delete, object: self)
      
      guard let survey = survey else { return }
      
      survey.commentRemovePublisher.send(self)
    }
  }
  var isClaimed: Bool = false {
    didSet {
      guard isClaimed else { return }
      
      isClaimedPublisher.send(true)
      isClaimedPublisher.send(completion: .finished)
      
      NotificationCenter.default.post(name: Notifications.Comments.Claim, object: self)
      
      guard let survey = survey else { return }
      
      survey.commentClaimedPublisher.send(self)
    }
  }
  var answer: Answer? {
    didSet {
      guard let answer = answer else { return }
      
      choicePublisher.send(answer)
    }
  }
  //Publishers
  var isDeletedPublisher      = PassthroughSubject<Bool, Never>()
  var isClaimedPublisher      = PassthroughSubject<Bool, Never>()
  var isBannedPublisher       = PassthroughSubject<Bool, Never>()
  var repliesPublisher        = PassthroughSubject<Int, Never>()
  var choicePublisher         = PassthroughSubject<Answer, Never>()
  
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
      isBanned        = try container.decode(Bool.self, forKey: .isBanned)
      isDeleted       = try container.decode(Bool.self, forKey: .isDeleted)
      
      if let choice = try container.decodeIfPresent(Int.self, forKey: .choice),
         let survey = self.survey,
         let answer = survey.answers.filter({ $0.id == choice }).first,
         let userprofile = self.userprofile {
        userprofile.choices[survey] = answer
        self.answer = answer
      }
      
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





