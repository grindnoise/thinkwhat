//
//  UserCompatibility.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 30.01.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import Foundation
import SwiftyJSON

struct TopicCompatibility {
  var topic: Topic
  var surveys: [Int]
  var matches: [Int]
  var percent: Int
}

struct UserCompatibility {
  var userId: String
  var percent: Int
  var value: Double { Double(percent)/100 }
  var details: [TopicCompatibility]
  
  init?(_ json: JSON) {
    guard let compatibility = json["compatibility"].dictionary,
          let id = compatibility["id"]?.string,
          let total = compatibility["total"]?.int,
          let matches = compatibility["matches"]?.int,
          let topics = json["topics"].array
    else { return nil }
    
    details = []
    userId = id
    percent = 100 * matches / total
    topics.forEach { dict in
      guard let topicId = dict["topic"].int,
            let topic = Topics.shared.all.filter({ $0.id == topicId}).first,
            let surveys = dict["surveys"].array,
            let surveysIds = surveys.compactMap({ $0.int }) as? [Int],
            let matches = dict["matches"].array,
            let matchesIds = matches.compactMap({ $0.int }) as? [Int],
            let total = dict["total"].int
      else { return }
      
      let compatibility = TopicCompatibility(topic: topic,
                                             surveys: surveysIds,
                                             matches: matchesIds,
                                             percent: 100 * matchesIds.count / total)
      details.append(compatibility)
    }
  }
}

extension UserCompatibility: Hashable {
  static func == (lhs: UserCompatibility, rhs: UserCompatibility) -> Bool {
    return lhs.userId == rhs.userId
  }
}

extension TopicCompatibility: Hashable {
  static func == (lhs: TopicCompatibility, rhs: TopicCompatibility) -> Bool {
    return lhs.topic.hashValue == rhs.topic.hashValue
  }
}
