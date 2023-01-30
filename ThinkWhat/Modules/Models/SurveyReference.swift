//
//  SurveyRef.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 28.10.2021.
//  Copyright © 2021 Pavel Bukharov. All rights reserved.
//

import Foundation
import SwiftyJSON
import Combine

class SurveyReference: Decodable {// NSObject,
  
  //    static let null: SurveyReference = SurveyReference(id: 0)
  
  private enum CodingKeys: String, CodingKey {
    case id, type, title, category, likes, views, progress, rating, description, share_link, active,
         startDate = "start_date",
         isComplete = "is_complete",
         isOwn = "is_own",
         isFavorite = "is_favorite",
         owner = "userprofile",
         votesLimit = "vote_capacity",
         votesTotal = "votes_total",
         commentsTotal = "comments_total",
         isHot = "is_hot",
         isAnonymous = "is_anonymous",
         isBanned = "is_banned",
         media = "media_preview"
  }
  
  //    //NS
  //    override var hash: Int {
  //        var hasher = Hasher()
  //        hasher.combine(title)
  //        hasher.combine(id)
  //        hasher.combine(topic)
  //        return hasher.finalize()
  //    }
  
  var id: Int
  var title: String
  //    @objc dynamic var title: String
  //    public let titleKeyPath = \SurveyReference.title
  var startDate: Date
  var isActive:               Bool {
    didSet {
      guard isActive != oldValue else { return }
      
      survey?.isActive = isActive
      isActivePublisher.send(isActive)
    }
  }
  var topic: Topic
  var truncatedDescription: String
  //    var completionPercentage: Int
  var rating: Double {
    didSet {
      guard oldValue != rating else { return }
      
      ratingPublisher.send(rating)
      //            ratingPublisher.send(completion: .finished)
      
      NotificationCenter.default.post(name: Notifications.Surveys.Rating, object: self)
      survey?.rating = rating
    }
  }
  var likes: Int {
    didSet {
      guard oldValue != likes else { return }
      
      likesPublisher.send(likes)
      //            likesPublisher.send(completion: .finished)
      
      NotificationCenter.default.post(name: Notifications.Surveys.Likes, object: self)
      survey?.likes = likes
    }
  }
  var views: Int {
    didSet {
      guard oldValue != views else { return }
      
      viewsPublisher.send(views)
      //            viewsPublisher.send(completion: .finished)
      
      NotificationCenter.default.post(name: Notifications.Surveys.Views, object: self)
      survey?.views = views
    }
  }
  var type: Survey.SurveyType
  var isComplete: Bool {
    didSet {
      guard oldValue != isComplete else { return }
      
      survey?.isComplete = isComplete
      isCompletePublisher.send(isComplete)
      //            isCompletePublisher.send(completion: .finished)
      NotificationCenter.default.post(name: Notifications.Surveys.Completed, object: self)
    }
  }
  var isOwn: Bool
  var isAnonymous: Bool
  var isHot: Bool {
    didSet {
      guard oldValue != isHot else { return }
      
      isHotPublisher.send(isHot)
      //            isHotPublisher.send(completion: .finished)
      NotificationCenter.default.post(name: Notifications.Surveys.SwitchHot, object: self)
    }
  }
  var isFavorite: Bool {
    didSet {
      guard oldValue != isFavorite else { return }
      
      isFavoritePublisher.send(isFavorite)
      //            isFavoritePublisher.send(completion: .finished)
      NotificationCenter.default.post(name: Notifications.Surveys.SwitchFavorite, object: self)
      
      guard let userprofile = Userprofiles.shared.current else { return }
      
      if isFavorite {
        NotificationCenter.default.post(name: Notifications.Surveys.FavoriteAppend, object: self)
        userprofile.favoritesTotal += 1
      } else {
        NotificationCenter.default.post(name: Notifications.Surveys.FavoriteRemove, object: self)
        userprofile.favoritesTotal -= 1
      }
      
      survey?.isFavorite = isFavorite
    }
  }
  var isBanned: Bool {
    didSet {
      guard oldValue != isBanned else { return }
      
      survey?.isBanned = isBanned
      isBannedPublisher.send(isBanned)
      //            isBannedPublisher.send(completion: .finished)
      
      NotificationCenter.default.post(name: Notifications.Surveys.Ban, object: self)
    }
  }
  var isClaimed: Bool = false {
    didSet {
      guard isClaimed, isClaimed != oldValue else { return }
      
      isClaimedPublisher.send(isClaimed)
      //            isClaimedPublisher.send(completion: .finished)
      
      NotificationCenter.default.post(name: Notifications.Surveys.Claim, object: self)
      survey?.isClaimed = isClaimed
    }
  }
  var owner: Userprofile
  var votesTotal: Int {
    didSet {
      guard oldValue != votesTotal else { return }
      
      survey?.votesTotal = votesTotal
      votesPublisher.send(votesTotal)
    }
  }
  var commentsTotal: Int {
    didSet {
      guard oldValue != commentsTotal else { return }
      
      commentsTotalPublisher.send(commentsTotal)
      NotificationCenter.default.post(name: Notifications.Surveys.CommentsTotal, object: self)
      survey?.commentsTotal = commentsTotal
    }
  }
  var votesLimit: Int
  var survey: Survey? {
    return Surveys.shared.all.filter{ $0.reference == self }.first
  }
  var progress: Int {
    didSet {
      guard oldValue != progress else { return }
      NotificationCenter.default.post(name: Notifications.Surveys.Progress, object: self)
      survey?.progress = progress
    }
  }
  var media: Mediafile? {
    didSet {
      guard let media = media,
            let survey = survey
      else { return }
      
      if survey.media.isEmpty {
        survey.media.append(media)
      } else if let firstMedia = survey.media.first, firstMedia.image.isNil {
        //Set image to prevent download
        firstMedia.image = media.image
      }
    }
  }
  var shareHash:              String = ""
  var shareEncryptedString:   String = ""
  //Publishers
  var surveyPublisher         = PassthroughSubject<Survey, Never>()
  var ratingPublisher         = PassthroughSubject<Double, Never>()
  var isActivePublisher       = PassthroughSubject<Bool, Never>()
  var isFavoritePublisher     = PassthroughSubject<Bool, Never>()
  var isCompletePublisher     = PassthroughSubject<Bool, Never>()
  var isClaimedPublisher      = PassthroughSubject<Bool, Never>()
  var isBannedPublisher       = PassthroughSubject<Bool, Never>()
  var isHotPublisher          = PassthroughSubject<Bool, Never>()
  var viewsPublisher          = PassthroughSubject<Int, Never>()
  var likesPublisher          = PassthroughSubject<Int, Never>()
  var votesPublisher          = PassthroughSubject<Int, Never>()
  var commentsTotalPublisher  = PassthroughSubject<Int, Never>()
  
  
  
  // MARK: - Initialization
  required init(from decoder: Decoder) throws {
    do {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      guard let topicId = try container.decode(Int.self, forKey: .category) as? Int,
            let _topic = Topics.shared.all.filter({ $0.id == topicId }).first else {
        throw "Topic not found"
      }
      guard let _type = Survey.SurveyType(rawValue: try container.decode(String.self, forKey: .type)) else {
        throw "Type not defined"
      }
      isAnonymous             = try container.decode(Bool.self, forKey: .isAnonymous)
      isActive             = try container.decode(Bool.self, forKey: .active)
      owner                   = Userprofile.anonymous
      let _owner              = try container.decodeIfPresent(Userprofile.self, forKey: .owner)
      if !_owner.isNil {
        owner = Userprofiles.shared.all.filter({ $0.id == _owner!.id }).first ?? _owner!
      }
      id      = try container.decode(Int.self, forKey: .id)
      title   = try container.decode(String.self, forKey: .title)
      truncatedDescription = try container.decode(String.self, forKey: .description)
      topic   = _topic
      type    = _type
      //            let _owner  = try container.decode(Userprofile.self, forKey: .owner)
      //            owner       = Userprofiles.shared.all.filter({ $0.id == _owner.id }).first ?? _owner
      likes       = try container.decode(Int.self, forKey: .likes)
      views       = try container.decode(Int.self, forKey: .views)
      votesLimit  = try container.decode(Int.self, forKey: .votesLimit)
      votesTotal  = try container.decode(Int.self, forKey: .votesTotal)
      commentsTotal = try container.decode(Int.self, forKey: .commentsTotal)
      startDate   = try container.decode(Date.self, forKey: .startDate)
      isComplete  = try container.decode(Bool.self, forKey: .isComplete)
      isOwn       = try container.decode(Bool.self, forKey: .isOwn)
      isFavorite  = try container.decode(Bool.self, forKey: .isFavorite)
      isHot       = try container.decode(Bool.self, forKey: .isHot)
      isBanned       = try container.decode(Bool.self, forKey: .isBanned)
      progress    = try container.decode(Int.self, forKey: .progress)
      let shareData           = try container.decode([String].self, forKey: .share_link)
      shareHash               = shareData.first ?? ""
      shareEncryptedString    = shareData.last ?? ""
      
      if let _media       = try container.decodeIfPresent([Mediafile].self, forKey: .media)?.first {
        media = _media
      }
      rating      = Double(try container.decode(String.self, forKey: .rating)) ?? 0
      //Check for existing instance by hashValue
      if SurveyReferences.shared.all.filter({ $0 == self }).isEmpty {
        SurveyReferences.shared.all.append(self)
      }
      //NS
      //            super.init()
      //            if SurveyReferences.shared.all.filter({ $0.isEqual(self) }).isEmpty {
      //                SurveyReferences.shared.all.append(self)
      //            }
    } catch {
#if DEBUG
      print(error.localizedDescription)
      fatalError()
#else
      throw error
#endif
    }
  }
  
  init(id: Int) {
    self.id                      = id
    self.title                   = ""
    self.topic                   = Topics.shared.all.first!
    self.startDate               = Date()
    self.likes                   = 0
    self.views                   = 0
    self.type                    = .Poll
    self.isActive                = true
    self.isOwn                   = true
    self.isHot                   = true
    self.isComplete              = true
    self.isFavorite              = true
    self.isBanned = false
    self.votesTotal              = 0
    self.commentsTotal           = 0
    self.votesLimit              = 0
    self.owner                   = Userprofile.anonymous
    self.isAnonymous             = true
    self.truncatedDescription    = ""
    self.progress                = 0
    self.rating                  = 0
  }
  
  init(id: Int,
       title: String,
       description: String,
       startDate: Date,
       topic: Topic,
       type: Survey.SurveyType,
       likes: Int = 0,
       views: Int = 0,
       isOwn: Bool,
       isBanned: Bool,
       isActive: Bool,
       isComplete: Bool,
       isFavorite: Bool,
       isHot: Bool,
       survey: Survey,
       owner: Userprofile,
       votesTotal: Int = 0,
       votesLimit: Int = 0,
       isAnonymous: Bool,
       progress: Int = 0,
       rating: Double = 0,
       commentsTotal: Int = 0) {
    
    self.id                      = id
    self.title                   = title
    self.topic                   = topic
    self.startDate               = startDate
    self.likes                   = likes
    self.views                   = views
    self.type                    = type
    self.isOwn                   = isOwn
    self.isHot                   = isHot
    self.isComplete              = isComplete
    self.isFavorite              = isFavorite
    self.votesTotal              = votesTotal
    self.commentsTotal           = commentsTotal
    self.votesLimit              = votesLimit
    //        survey                  = _survey
    self.owner                   = owner
    self.isAnonymous             = isAnonymous
    self.truncatedDescription    = description
    self.progress                = progress
    self.rating                  = rating
    self.isActive                = isActive
    self.isBanned = isBanned
    
    //Swift
    if SurveyReferences.shared.all.filter({ $0 == self }).isEmpty {
      SurveyReferences.shared.all.append(self)
    }
    //        //NSObject
    //        super.init()
    //        if SurveyReferences.shared.all.filter({ $0.isEqual(self) }).isEmpty {
    //            SurveyReferences.shared.all.append(self)
    //        }
  }
  
  
  //MARK: - Public methods
  public func isValid(byBeriod period: Period) -> Bool {
    guard let dateBound = period.date() else { return false }
    
    return startDate >= dateBound
  }
}
extension SurveyReference: Hashable {
  static func == (lhs: SurveyReference, rhs: SurveyReference) -> Bool {
    return lhs.hashValue == rhs.hashValue
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(title)
    hasher.combine(id)
    hasher.combine(topic)
  }
}


class SurveyReferences {
  static let shared = SurveyReferences()
  private init() {}
  var all: [SurveyReference] = [] {
    didSet {
      //Remove
      if oldValue.count > all.count {
        let oldSet = Set(oldValue)
        let newSet = Set(all)
        
        let difference = oldSet.symmetricDifference(newSet)
        difference.forEach {
          NotificationCenter.default.post(name: Notifications.Surveys.RemoveReference, object: $0)
        }
      } else {
        //Append
        let oldSet = Set(oldValue)
        let newSet = Set(all)
        
        let difference = newSet.symmetricDifference(oldSet)
        difference.forEach { item in
          guard !oldValue.filter({ $0 == item }).isEmpty, let index = all.lastIndex(of: item) else {
            //Notify
            NotificationCenter.default.post(name: Notifications.Surveys.AppendReference, object: item)
            return
          }
          //Duplicate removal
          all.remove(at: index)
          SurveyReferences.shared.instancesPublisher.send([])
//          NotificationCenter.default.post(name: Notifications.Surveys.EmptyReceived, object: nil)
        }
      }
      
      ////            Check for duplicates
      //            guard let lastInstance = all.last else { return }
      //            if !oldValue.filter({ $0 == lastInstance }).isEmpty {
      //                all.remove(object: lastInstance)
      //            }
      //            NotificationCenter.default.post(name: Notifications.Surveys.Append, object: instance)
      ////            guard oldValue.count != all.count else { return }
      //            Notification.send(names: [Notifications.Surveys.UpdateAll])
    }
  }
  //Publishers
  public let instancesPublisher = PassthroughSubject<[SurveyReference], Never>()
  
  public func eraseData() {
    all.removeAll()
  }
}


//class Identity: NSObject {
//
//    let name: String
//    let email: String
//
//    init(name: String, email: String) {
//        self.name = name
//        self.email = email
//    }
//
//    override var hash: Int {
//        var hasher = Hasher()
//        hasher.combine(name)
//        hasher.combine(email)
//        return hasher.finalize()
//    }
//
//    override func isEqual(_ object: Any?) -> Bool {
//        guard let other = object as? Identity else {
//            return false
//        }
//        return name == other.name && email == other.email
//    }
//}
