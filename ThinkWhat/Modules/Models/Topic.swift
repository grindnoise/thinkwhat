//
//  SurveyCategory.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 17.08.2020.
//  Copyright © 2020 Pavel Bukharov. All rights reserved.
//

import Foundation
import SwiftyJSON
import Combine
import UIKit

class Topics {
  static let shared = Topics()
  private init() {}
  var all: [Topic] = []
  var active: Int {
    Topics.shared.all.filter({ !$0.isParentNode}).reduce(into: 0) { $0 += $1.activeCount }//{ $0 += $1.activeAndFavorite }
    //        return all.filter({ $0.isParentNode }).reduce(into: 0) { $0 += $1.active }
  }
  
  func load(_ data: Data) {
    let decoder = JSONDecoder()
    do {
      _ = try decoder.decode([Topic].self, from: data)
    } catch {
      fatalError("Topic init() threw error: \(error)")
    }
  }
  
  func updateStats(_ json: JSON) {
    //      for i in json {
    //        let instance: SurveyReference? = SurveyReferences.shared.all.filter({ $0.id == Int(i.0) }).first ?? Surveys.shared.all.filter({ $0.reference.id == Int(i.0)}).first?.reference
    //        guard let instance = instance,
    //              let progress = i.1["progress"].int,
    //              let comments = i.1["comments"].int,
    //              let rating = i.1["rating"].double,
    //              let active = i.1["active"].bool,
    //              let isBanned = i.1["is_banned"].bool,
    //              let views = i.1["views"].int else { return }
    //        instance.progress = progress
    //        instance.rating = rating
    //        instance.commentsTotal = comments
    //        instance.views = views
    //        instance.isActive = active
    //        instance.isBanned = isBanned
    //      }
    for i in json {
      guard let id = Int(i.0),
            let category = self[id],
            let total = i.1["total"].int,
            let active = i.1["active"].int
      else { return }
      category.totalCount = total
      category.activeCount = active
    }
  }
  
  subscript (ID: Int) -> Topic? {
    if let i = all.first(where: {$0.id == ID}) {
      return i
    } else {
      return nil
    }
  }
  
  subscript (title: String) -> Topic? {
    if let i = all.first(where: {$0.title == title}) {
      return i
    } else {
      return nil
    }
  }
}

class Topic: Decodable {
  private enum CodingKeys: String, CodingKey {
    case id, title, description, parent, children
    case createdAt          = "created_at"
    case ageRestriction     = "age_restriction"
    case tagColor           = "tag_color"
    case total              = "total_count"
    case active             = "active_count"
    case favorite           = "favorite_count"
    case activeAndFavorite  = "active_favorite_count"
    case viewsTotal         = "views_total"
    case hotTotal           = "hot_total"
    case imageId            = "image_id"
    case isOther            = "is_other"
    case watching           = "watching"
  }
  
  let id: Int
  let imageId: Int
  let title: String
  let description: String
  var parent: Topic? {
    return Topics.shared.all.filter({ $0.children.contains(self) }).first
  }
  var children: [Topic] = []
  var ageRestriction: Int
  var tagColor: UIColor
  var totalCount: Int = 0 {
    didSet {
      guard oldValue != totalCount else { return }
      
      totalCountPublisher.send(totalCount)
      parent?.totalCount += oldValue - totalCount
    }
  }
  var activeCount: Int = 0 {
    didSet {
//      guard oldValue != activeCount else { return }
      
      activeCountPublisher.send(activeCount)
      parent?.updateActiveCount()
    }
  }
  var favorite: Int = 0
  //    var activeAndFavorite: Int = 0
  var viewsTotal: Int = 0
  var hotTotal: Int = 0
  //    var visibleCount: Int {
  //        if isParentNode {
  //            return children.reduce(into: 0) { $0 += $1.activeAndFavorite }
  //        }
  //        return activeAndFavorite
  //    }
  var isParentNode: Bool {
    return !children.isEmpty
  }
  var isOther: Bool
  var watching: Bool {
    didSet {
      watchingPublisher.send(watching)
      
      guard watching else { return }
      
      Notifications.UIEvents.topicSubscriptionPublisher.send(self)
    }
  }
  var iconCategory: Icon.Category { Icon.Category(rawValue: imageId) ?? .Null }
  //Publishers
  public let totalCountPublisher = PassthroughSubject<Int, Never>()
  public let activeCountPublisher = PassthroughSubject<Int, Never>()
//  public let subscribePublisher = PassthroughSubject<Bool, Never>() // When user (un)subscribes
  public let watchingPublisher = PassthroughSubject<Bool, Error>()
  
  required init(from decoder: Decoder) throws {
    do {
      let container   = try decoder.container(keyedBy: CodingKeys.self)
      id              = try container.decode(Int.self, forKey: .id)
      imageId         = try container.decode(Int.self, forKey: .imageId)
      title           = try container.decode(String.self, forKey: .title)
      description     = try container.decode(String.self, forKey: .description)
      tagColor        = try container.decode(String.self, forKey: .tagColor).hexColor ?? Colors.main
      ageRestriction  = (try? container.decode(Int.self, forKey: .ageRestriction)) ?? 0
      children        = (try? container.decode([Topic].self, forKey: .children)) ?? []
      totalCount      = try container.decode(Int.self, forKey: .total)
      activeCount     = try container.decode(Int.self, forKey: .active)
      favorite        = try container.decode(Int.self, forKey: .favorite)
      viewsTotal      = try container.decodeIfPresent(Int.self, forKey: .viewsTotal) ?? 0
      hotTotal        = try container.decode(Int.self, forKey: .hotTotal)
      isOther         = try container.decode(Bool.self, forKey: .isOther)
      watching        = try container.decode(Bool.self, forKey: .watching)
      if Topics.shared.all.filter({ $0.hashValue == hashValue }).isEmpty {
        Topics.shared.all.append(self)
      }
    } catch {
      throw error
    }
  }
  
  // MARK: - Public methods
  public func updateActiveCount() {
    activeCount = Topics.shared.all
      .filter { $0.parent == self }
      .reduce(into: 0) { $0 += $1.activeCount }
  }
}

extension Topic: Hashable {
  func hash(into hasher: inout Hasher) {
    hasher.combine(title)
    hasher.combine(id)
    hasher.combine(description)
  }
  static func == (lhs: Topic, rhs: Topic) -> Bool {
    return lhs.hashValue == rhs.hashValue
  }
}
