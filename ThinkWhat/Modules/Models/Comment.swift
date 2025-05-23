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
  
  public let instancesPublisher = PassthroughSubject<Comment, Never>()
  
  static let shared = Comments()
  private init() {}
  var all: [Comment] = [] {
    didSet {
      guard !oldValue.isEmpty else {
        all.forEach { instancesPublisher.send($0) }
        return
      }
      
      let existingSet = Set(oldValue)
      let appendingSet = Set(all)
      
      ///Difference
      appendingSet.subtracting(existingSet).forEach { instancesPublisher.send($0) }
      
//      //Append
//      if oldValue.count < all.count {
//        //            Check for duplicates
        guard let lastInstance = all.last,
              let survey = lastInstance.survey
        else { return }
//
//        guard oldValue.filter({ $0 == lastInstance }).isEmpty else {
//          all.remove(object: lastInstance)
//
//          return
//        }
//
      survey.commentAppendPublisher.send(lastInstance)
//
//        guard lastInstance.isParentNode else {
//          NotificationCenter.default.post(name: Notifications.Comments.ChildAppend, object: lastInstance)
////          survey.commentChildAppendPublisher.send(lastInstance)
//          return
//        }
//        //            if lastInstance.isBanned
//        guard !lastInstance.isDeleted else { return }
//
////        survey.commentRootAppendPublisher.send(lastInstance)
//        NotificationCenter.default.post(name: Notifications.Comments.Append, object: lastInstance)
//        //            if let survey = lastInstance.survey {
//        //                survey.reference.commentsTotal += 1
//        //            }
//      }
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
  
  func update(_ json: JSON) {
    guard let array = json.array else { return }
    
    array.forEach {
      guard let id = $0["id"].int,
            let comment = all.filter({ $0.id == id }).first,
            let replies = $0["replies"].int,
            let isDeleted = $0["is_deleted"].bool,
            let isBanned = $0["is_banned"].bool
      else { return }
      
      comment.replies = replies
      comment.isDeleted = isDeleted
      comment.isBanned = isBanned
    }
  }
  
  func commentsCount(for survey: Survey) -> Int {
    return all.filter({ $0.surveyId == survey.id && !$0.isDeleted && !$0.isBanned && !$0.isClaimed }).count
  }
  
  func append(_ instances: [Comment]) {
    guard !instances.isEmpty else {
//      instancesPublisher.send([]);
      return
    }
    
    guard !all.isEmpty else { all.append(contentsOf: instances); return }
    
    let existingSet = Set(all)
    let appendingSet = Set(replaceWithExisting(all, instances))
    let difference = Array(appendingSet.subtracting(existingSet))
    
    guard !difference.isEmpty else { return }
    
    all.append(contentsOf: difference)
  }
  
  subscript(id: Int) -> Comment? { Comments.shared.all.filter({ $0.id == id }).first }
}

class Comment: Decodable, Complaintable {
  private enum CodingKeys: String, CodingKey {
    case id, survey, parent, children, body, replies, choice
    case userprofile        = "user"
    case anonUsername       = "name"
    case createdAt          = "created_on"
    case childrenCount      = "children_count"
    case replyTo            = "reply_to"
    case isBanned           = "is_banned"
    case isDeleted          = "is_deleted"
    case isClaimed          = "is_claimed"
  }
  
  let id: Int
  let body: String
  let surveyId: Int
  let parentId: Int?
  var replies: Int {
    didSet {
      guard oldValue != replies else { return }
      
      repliesPublisher.send(replies)
    }
  }
  var survey: Survey? { Surveys.shared.all.filter { $0.id == surveyId }.first }
  var userprofile: Userprofile?
  let anonUsername: String
  let createdAt: Date
  let replyToId: Int?
  let answerId: Int?
  var replyTo: Comment? { Comments.shared.all.filter { $0.id == replyToId }.first }
  var isAnonymous: Bool { userprofile.isNil && !anonUsername.isEmpty }
  var parent: Comment? { Comments.shared.all.filter({ $0.id == parentId }).first }
  var isParentNode: Bool { parentId.isNil }
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
      survey?.commentBannedPublisher.send(self)
    }
  }
  var isDeleted: Bool = false {
    didSet {
      guard isDeleted else { return }
      
      isDeletedPublisher.send(true)
      isDeletedPublisher.send(completion: .finished)
      survey?.commentRemovePublisher.send(self)
    }
  }
  var isClaimed: Bool = false {
    didSet {
      guard isClaimed else { return }
      
      isClaimedPublisher.send(true)
      isClaimedPublisher.send(completion: .finished)
      survey?.commentClaimedPublisher.send(self)
    }
  }
  var choice: Answer? {
    didSet {
      guard let choice = choice else { return }
      
      choicePublisher.send(choice)
    }
  }
  //Publishers
  var isDeletedPublisher      = PassthroughSubject<Bool, Never>()
  var isClaimedPublisher      = PassthroughSubject<Bool, Error>()
  var isBannedPublisher       = PassthroughSubject<Bool, Never>()
  var repliesPublisher        = PassthroughSubject<Int, Never>()
  var choicePublisher         = PassthroughSubject<Answer, Never>()
  
  required init(from decoder: Decoder) throws {
    do {
      let container   = try decoder.container(keyedBy: CodingKeys.self)
      id              = try container.decode(Int.self, forKey: .id)
      body            = try container.decode(String.self, forKey: .body)
      anonUsername    = try container.decode(String.self, forKey: .anonUsername)
      let _userprofile = try? container.decodeIfPresent(Userprofile.self, forKey: .userprofile)
      if !_userprofile.isNil {
        userprofile = Userprofiles.shared.all.filter({ $0.id == _userprofile!.id }).first ?? _userprofile
      }
      surveyId        = try container.decode(Int.self, forKey: .survey)
      createdAt       = try container.decode(Date.self, forKey: .createdAt)
      replies         = try container.decode(Int.self, forKey: .replies)
      replyToId       = try container.decodeIfPresent(Int.self, forKey: .replyTo)
      parentId        = try container.decodeIfPresent(Int.self, forKey: .parent)
      isBanned        = try container.decode(Bool.self, forKey: .isBanned)
      isClaimed       = try container.decode(Bool.self, forKey: .isClaimed)
      isDeleted       = try container.decode(Bool.self, forKey: .isDeleted)
      answerId        = try container.decodeIfPresent(Int.self, forKey: .choice)
      
      if let userprofile = userprofile,
         !answerId.isNil {
        (userprofile.isCurrent ? Userprofiles.shared.current! : userprofile).answers[surveyId] = answerId!
      }
//      if let choice = try container.decodeIfPresent(Int.self, forKey: .choice),
//         let survey = self.survey,
//         let answer = survey.answers.filter({ $0.id == choice }).first,
//         let userprofile = self.userprofile {
//        userprofile.choices[survey] = answer
//        self.answer = answer
//      }
      
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





