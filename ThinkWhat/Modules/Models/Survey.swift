//
//  Survey.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 18.10.2019.
//  Copyright © 2019 Pavel Bukharov. All rights reserved.
//

import Foundation
import SwiftyJSON
import Combine

class Survey: Decodable {
  // MARK: - Enums
  enum SurveyCategory: String, CaseIterable {
    case Hot, New, Top, Own, Favorite, Subscriptions, All, Topic, Search, ByOwner, Compatibility
    
    func dataItems(topic: Topic? = nil,
                   userprofile: Userprofile? = nil,
                   compatibility: TopicCompatibility? = nil) -> [SurveyReference] {
      switch self {
      case .Hot:
        return Surveys.shared.hot.map { return $0.reference }.filter { !$0.isClaimed && !$0.isBanned }
      case .New:
        //                return Surveys.shared.newReferences
        return Surveys.shared.newReferences.filter { !$0.isClaimed && !$0.isBanned }//.filter({ $0.isFavorite })// || !$0.isComplete })
      case .Top:
        //                return Surveys.shared.topReferences
        return Surveys.shared.topReferences.filter { !$0.isClaimed && !$0.isBanned }//.filter({ $0.isFavorite })// || !$0.isComplete })
      case .Own:
        return Surveys.shared.ownReferences.filter { !$0.isClaimed && !$0.isBanned }
      case .Favorite:
        return SurveyReferences.shared.all.filter { $0.isFavorite && !$0.isClaimed && !$0.isBanned }
      case .Subscriptions:
        return SurveyReferences.shared.all.filter { $0.owner.subscribedAt && !$0.isClaimed && !$0.isBanned }
        //                return Surveys.shared.subscriptions.filter { !$0.isClaimed && !$0.isBanned }
      case .All:
        return SurveyReferences.shared.all.filter { !$0.isClaimed && !$0.isBanned }
      case .Topic:
        guard !topic.isNil else { return [] }
        //                var all = SurveyReferences.shared.all.filter({ $0.topic == topic! })
        //                var completed = all.filter({ $0.isComplete })
        //                let favorite = all.filter({ $0.isFavorite })
        //                favorite.forEach {
        //                    completed.remove(object: $0)
        //                }
        //                completed.forEach {
        //                    all.remove(object: $0)
        //                }
        //                return all
        return SurveyReferences.shared.all.filter({ $0.topic == topic! }).uniqued().filter { !$0.isClaimed && !$0.isBanned }
      case .ByOwner:
        guard let userprofile = userprofile else { return [] }
        
        return SurveyReferences.shared.all.filter { $0.owner == userprofile && !$0.isClaimed && !$0.isBanned }
      case .Search:
        fatalError()
      case .Compatibility:
        guard let compatibility = compatibility else { return [] }
        
        return SurveyReferences.shared[compatibility.surveys]
      }
    }
    
    
    var url: URL? {
      switch self {
      case .Hot:
        return API_URLS.Surveys.hot
      case .New:
        return API_URLS.Surveys.new
      case .Top:
        return API_URLS.Surveys.top
      case .Own:
        return API_URLS.Surveys.own
      case .Favorite:
        return API_URLS.Surveys.favorite
      case .Subscriptions:
        return API_URLS.Surveys.subscriptions
      case .All:
        return API_URLS.Surveys.all
      case .Topic:
        return API_URLS.Surveys.byTopic
      case .Search:
        return API_URLS.Surveys.search
      case .ByOwner:
        return API_URLS.Surveys.byUserprofile
      case .Compatibility:
        return API_URLS.Surveys.ids
      }
    }
  }
  
  enum SurveyType: String, CaseIterable {
    case Poll = "Poll"
    case Ranking = "Ranking"
  }
  
  private enum CodingKeys: String, CodingKey {
    case active,
         id,
         title,
         description,
         category,
         question,
         type,
         watchers,
         likes,
         views,
         media,
         answers,
         comments,
         result,
         rating,
         progress,
         startDate = "start_date",
         url = "hlink",
         voteCapacity = "vote_capacity",
         isPrivate = "is_private",
         isAnonymous = "is_anonymous",
         isFavorite = "is_favorite",
         isCommentingAllowed = "is_commenting_allowed",
         totalVotes = "votes_total",
         commentsTotal = "comments_total",
         owner = "userprofile",
         isHot = "is_hot",
         isOwn = "is_own",
         isComplete = "is_complete",
         isBanned = "is_banned",
         shareLink = "share_link"
  }
  
  // MARK: - Properties
  var isActive:               Bool {
    didSet {
      reference.isActive = isActive
    }
  }
  var id:                     Int
  var title:                  String
  var startDate:              Date
  var topic:                  Topic
  var description:            String
  var question:               String
  var rating:                 Double
  //Media
  var media:                  [Mediafile] = []
  var mediaSortedByOrder: [Mediafile] { media.sorted { $0.order < $1.order }}
  var mediaWithImagesSortedByOrder: [Mediafile] { media.filter { $0.image != nil } .sorted { $0.order < $1.order }}
  var mediaWithImageURLs: [Mediafile] { media.filter { $0.imageURL != nil }}
  //Images
  var images: [UIImage] {media.filter { $0.image != nil } .map { $0.image! }}
  var imagesCount: Int { max(media.filter({ $0.image != nil }).count, media.filter({ $0.imageURL != nil }).count)}
  //Answers
  var answers:                [Answer] = []
  var answersSortedByVotes:   [Answer] { answers.sorted { $0.totalVotes > $1.totalVotes }}
  var answersSortedByOrder:   [Answer] { answers.sorted { $0.order < $1.order }}
  //    var comments:               [Comment] = []
  var shareHash:              String = ""
  var shareEncryptedString:   String = ""
  var url:                    URL? = nil///hlink
  var votesLimit:             Int {
    didSet {
      reference.votesLimit = votesLimit
    }
  }
  var isPrivate:              Bool
  var isAnonymous:            Bool
  var isCommentingAllowed:    Bool
  var votesTotal:             Int = 0 {
    didSet {
      reference.votesTotal = votesTotal
    }
  }
  var commentsTotal:          Int {
    didSet {
      reference.commentsTotal = commentsTotal
    }
  }
  var commentsSortedByDate: [Comment] { Comments.shared.all.filter({ $0.survey == self && $0.isClaimed == false && $0.isBanned == false }).sorted { $0.createdAt > $1.createdAt }}
  var watchers:               Int = 0
  var result:                 [Int: Date]? {
    didSet {
      //            print("")
      //            if let _result = result, let _oldValue = oldValue, _oldValue.isEmpty, !_result.isEmpty, let surveyRef = SurveyReferences.shared.all.filter({ $0.hashValue == self.hashValue }).first {
      //                surveyRef.isComplete = true
      //            }
    }
  }
  var resultDetails:          SurveyResult?
  var owner:                  Userprofile
  var likes:                  Int = 0 {
    didSet {
      guard oldValue != likes else { return }
      
      reference.likes = likes
    }
  }
  var views:                  Int = 0 {
    didSet {
      guard oldValue != views else { return }
      
      reference.views = views
    }
  }
  var type: SurveyType
  var isHot: Bool {
    didSet {
      guard oldValue != isHot else { return }
      reference.isHot = isHot
    }
  }
  var isBanned: Bool {
    didSet {
      guard oldValue != isBanned else { return }
      
      reference.isBanned = isBanned
    }
  }
  var isClaimed: Bool = false {
    didSet {
      guard isClaimed else { return }
      reference.isClaimed = isClaimed
    }
  }
  var isComplete: Bool {
    didSet {
      guard isComplete else { return }
      
      reference.isComplete = isComplete
    }
    
    //        guard let result = result else {
    //            return false
    //        }
    //        reference.isComplete = !result.isEmpty
    //        return !result.isEmpty
  }
  var isOwn: Bool {
    didSet {
      //        assert(UserDefaults.Profile.id.isNil)
      //        return owner.id == UserDefaults.Profile.id
      guard isOwn else { return }
      reference.isOwn = isOwn
    }
  }
  var isFavorite: Bool {
    didSet {
      guard oldValue != isFavorite else { return }
      reference.isFavorite = isFavorite
    }
  }
  var reference: SurveyReference {
    return getReference()
    //        return SurveyReferences.shared.all.filter({ $0.hashValue == hashValue}).first ?? createReference()
  }
  var progress: Int {
    didSet {
      guard oldValue != progress else { return }
      reference.progress = progress
    }
  }
  
  //Publishers
  public let commentPostedPublisher = PassthroughSubject<Comment, Never>()
  public let commentAppendPublisher = PassthroughSubject<Comment, Never>()
  public let commentRemovePublisher = PassthroughSubject<Comment, Never>()
  public let commentBannedPublisher = PassthroughSubject<Comment, Never>()
  public let commentClaimedPublisher = PassthroughSubject<Comment, Never>()
  ///Convert to dict to create new survey
  //    var dict: [String: Any] {
  //        var _dict: [String: Any] = [:]
  //        ///Necessary data
  //        _dict[DjangoVariables.Survey.title] = title
  //        _dict[DjangoVariables.Survey.category] = topic.id
  //        _dict[DjangoVariables.Survey.description] = description
  //        _dict[DjangoVariables.Survey.voteCapacity] = votesLimit
  //        _dict[DjangoVariables.Survey.isPrivate] = isPrivate
  //        _dict[DjangoVariables.Survey.postHot] = isHot
  //        _dict[DjangoVariables.Survey.type] = type
  //
  //
  //        _dict[DjangoVariables.Survey.startDate] = startDate.toDateTimeString()
  //        var _answers: [[String: String]] = []
  //        for answer in answersWithoutID {
  //            _answers.append(["text" : answer])
  //        }
  //        _dict[DjangoVariables.Survey.answers] = _answers
  //
  //        ///Optional
  //        if images != nil {
  //            _dict[DjangoVariables.Survey.images] = images!
  //        }
  //        if !url.isNil { _dict[DjangoVariables.Survey.hlink] = url! }
  ////        if endDate != nil {
  ////            _dict[DjangoVariables.Survey.endDate] = endDate!.toDateTimeString()
  ////        }
  //        return _dict
  //    }
  
  required init(from decoder: Decoder) throws {
    do {
      let container   = try decoder.container(keyedBy: CodingKeys.self)
      guard let topicId = try container.decode(Int.self, forKey: .category) as? Int,
            let _topic = Topics.shared.all.filter({ $0.id == topicId }).first else {
        throw "Topic not found"
      }
      guard let _type = SurveyType(rawValue: try container.decode(String.self, forKey: .type)) else {
        throw "SurveyType not defined"
      }
      isAnonymous             = try container.decode(Bool.self, forKey: .isAnonymous)
      owner                   = Userprofile.anonymous
      let _owner              = try container.decodeIfPresent(Userprofile.self, forKey: .owner)
      if !_owner.isNil {
        owner = Userprofiles.shared.all.filter({ $0.id == _owner!.id }).first ?? _owner!
      }
      topic                   = _topic
      isActive                = try container.decode(Bool.self, forKey: .active)
      id                      = try container.decode(Int.self, forKey: .id)
      progress                = try container.decode(Int.self, forKey: .progress)
      title                   = try container.decode(String.self, forKey: .title)
      description             = try container.decode(String.self, forKey: .description)
      startDate               = try container.decode(Date.self, forKey: .startDate)
      url                     = URL(string: try container.decode(String.self, forKey: .url))
      question                = try container.decode(String.self, forKey: .question)
      type                    = _type
      answers                 = try container.decode([Answer].self, forKey: .answers)
      votesLimit              = try container.decode(Int.self, forKey: .voteCapacity)
      votesTotal              = try container.decode(Int.self, forKey: .totalVotes)
      commentsTotal           = try container.decode(Int.self, forKey: .commentsTotal)
      watchers                = try container.decode(Int.self, forKey: .watchers)
      likes                   = try container.decode(Int.self, forKey: .likes)
      views                   = try container.decode(Int.self, forKey: .views)
      rating                  = Double(try container.decode(String.self, forKey: .rating)) ?? 0
      isPrivate               = try container.decode(Bool.self, forKey: .isPrivate)
      isCommentingAllowed     = try container.decode(Bool.self, forKey: .isCommentingAllowed)
      isFavorite              = try container.decode(Bool.self, forKey: .isFavorite)
      isHot                   = try container.decode(Bool.self, forKey: .isHot)
      isOwn                   = try container.decode(Bool.self, forKey: .isOwn)
      isComplete              = try container.decode(Bool.self, forKey: .isComplete)
      isBanned                = try container.decode(Bool.self, forKey: .isBanned)
      let shareData           = try container.decode([String].self, forKey: .shareLink)
      shareHash               = shareData.first ?? ""
      shareEncryptedString    = shareData.last ?? ""
      
      
      
      
      //            comments = try container.decode([Comment].self, forKey: .comments)
      
      if let dict = try container.decodeIfPresent([String: Date].self, forKey: .result), !dict.isEmpty {
        result = [Int(dict.keys.first!)!: dict.values.first!]
      }
      ///Check for existing
      if Surveys.shared.all.filter({ $0 == self }).isEmpty {
        Surveys.shared.all.append(self)
      }
      //            getReference()
      
      //Import comments
      let _ = try container.decode([Comment].self, forKey: .comments)
      
      //Media
      if let first = reference.media {
        //Prevent duplicates
        var imported = try container.decode([Mediafile].self, forKey: .media)
        if let existing = imported.filter({ $0 == first }).first {
          imported.remove(object: existing)
        }
        media = [first] + imported
      } else {
        media                   = try container.decode([Mediafile].self, forKey: .media)
      }
      //            if SurveyReferences.shared.all.filter({$0 == self.reference}).isEmpty {
      //                SurveyReferences.shared.all.append(self.reference)
      //            }
    } catch {
#if DEBUG
      print(error.localizedDescription)
#endif
      throw error
    }
  }
  
  //    init(type: SurveyType,
  //         title: String,
  //         topic: Topic,
  //         description: String,
  //         question: String,
  //         answers: [String],
  //         media: [Int: [UIImage: String]],
  //         url: URL?,
  //         voteCapacity: Int,
  //         isPrivate: Bool,
  //         isAnonymous: Bool,
  //         isCommentingAllowed: Bool,
  //         isHot: Bool,
  //         isFavorite: Bool,
  //         isOwn: Bool) {
  //        self.rating              = 0
  //        self.owner               = Userprofiles.shared.current!
  //        self.topic               = topic
  //        self.active              = true
  //        self.id                  = tempId
  //        self.title               = title
  //        self.description         = description
  //        self.startDate           = Date()
  //        self.url                 = url
  //        self.question            = question
  //        self.type                = type
  //        self.votesLimit          = voteCapacity
  //        self.isPrivate           = isPrivate
  //        self.isAnonymous         = isAnonymous
  //        self.isCommentingAllowed = isCommentingAllowed
  //        self.isFavorite          = isFavorite
  //        self.isHot               = isHot
  //        self.isOwn               = isOwn
  //        self.progress            = 0
  //        self.media = media.map({ number, dict in
  //            return Mediafile(title: dict.first?.value ?? "", order: number, survey: self, image: dict.first?.key)
  //        })
  //        self.answers = answers.enumerated().map({ (index,title) in
  //            return Answer(description: "", title: title, survey: self, order: index)
  //        })
  //    }
  
  //Creates SurveyReference
  private func getReference() -> SurveyReference {
    //        guard let existing = SurveyReferences.shared.all.filter({ $0.id == self.id && $0.topic == $0.topic && $0.title == self.title }).first
    guard let existing = SurveyReferences.shared.all.filter({ $0.id == self.id }).first
    else {
      let instance = SurveyReference(id: id,
                                     title: title,
                                     description: description,
                                     startDate: startDate,
                                     topic: topic,
                                     type: type,
                                     likes: likes,
                                     views: views,
                                     isOwn: isOwn,
                                     isBanned: isBanned,
                                     isActive: isActive,
                                     isComplete: isComplete,
                                     isFavorite: isFavorite,
                                     isHot: isHot,
                                     survey: self,
                                     owner: owner,
                                     isAnonymous: isAnonymous,
                                     progress: progress,
                                     rating: rating)
      //            SurveyReferences.shared.all.append(instance)
      return instance
    }
    
    return existing
    //
    //        let instance = SurveyReference(id: id, title: title, description: description, startDate: startDate, topic: topic, type: type, likes: likes, views: views, isOwn: isOwn, isComplete: isComplete, isFavorite: isFavorite, isHot: isHot, survey: self, owner: owner, isAnonymous: isAnonymous, progress: progress, rating: rating)
    //        if let existing = SurveyReferences.shared.all.filter({ $0 == instance }).first {
    //            return existing
    //        }
    //        SurveyReferences.shared.all.append(instance)
    //        return instance
  }
  
  func getAnswerVotePercentage(_ answerVotesCount: Int) -> Int {
    return Int((Double(answerVotesCount) * Double(100) / Double(votesTotal)).rounded())
  }
  
  func getPercentForAnswer(_ answer: Answer) -> Int {
    if let _answer = answers.filter({ $0.id == answer.id }).first {
      return 100 * _answer.totalVotes / votesTotal
    }
    return 0
  }
}

extension Survey: Hashable {
  static func == (lhs: Survey, rhs: Survey) -> Bool {
    return lhs.hashValue == rhs.hashValue
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(title)
    hasher.combine(id)
    hasher.combine(topic)
  }
}

class Surveys {
  enum SurveyContainerType {
    case TopLinks, NewLinks, Categorized, OwnLinks, Favorite, Downloaded, Completed, Stack, Claim, AllLinks
  }
  private enum Category: String {
    case Top            = "top"
    case Own            = "own"
    case New            = "new"
    case Favorite       = "favorite"
    case Hot            = "hot"
    case Subscriptions  = "subscriptions"
    case Topic          = "by_category"
    case Userprofile    = "by_owner"
  }
  static let shared = Surveys()
  private init() {}
  private var timer:  Timer?
  
  //    var allReferences:           [SurveyReference] = []
  var topReferences:           [SurveyReference] = [] {
    didSet {
      guard oldValue.count != subscriptions.count else { return }
      Notification.send(names: [Notifications.Surveys.UpdateTopSurveys])
    }
  }
  
  var newReferences:           [SurveyReference] = [] {
    didSet {
      if oldValue.count != newReferences.count {
        let sorted = newReferences.sorted { $0.startDate > $1.startDate }
        newReferences = sorted
        //                Notification.send(names: [Notifications.Surveys.UpdateNewSurveys])
      }
    }
  }
  var ownReferences:           [SurveyReference] = [] {
    didSet {
      guard oldValue.count != subscriptions.count else { return }
      Notification.send(names: [Notifications.Surveys.UpdateOwn])
    }
  }
  var subscriptions:           [SurveyReference] = [] {
    didSet {
      guard oldValue.count != subscriptions.count else { return }
      Notification.send(names: [Notifications.Surveys.UpdateSubscriptions])
    }
  }
  //    var favoriteReferences:      [SurveyReference: Date] = [:]
  
  var favoriteReferences:      [SurveyReference] = [] {
    didSet {
      guard oldValue.count != subscriptions.count else { return }
      Notification.send(names: [Notifications.Surveys.UpdateFavorite])
    }
  }
  
  
  //    var categorizedLinks:   [Topic: [SurveyReference]] = [:]
  var completed:               [Survey] = [] {
    didSet {
      completed.forEach { $0.reference.isComplete = true }
    }
  }
  var all:                     [Survey] = []
  var hot:                     [Survey] = []
  //    var banned:                  [Survey] = [] {///Banned by user
  //        didSet {
  //            guard let instance = banned.last else { return }
  //            hot.remove(object: instance)
  //            hot.remove(object: instance)
  //            ///Remove from lists
  //            ///Top
  //            if topReferences.contains(instance.reference) {
  //                topReferences.remove(object: instance.reference)
  //            } else if let existing = topReferences.filter({ $0 == instance.reference }).first {
  //                topReferences.remove(object: existing)
  //            }
  //            ///New
  //            if newReferences.contains(instance.reference) {
  //                newReferences.remove(object: instance.reference)
  //            } else if let existing = newReferences.filter({ $0 == instance.reference }).first {
  //                newReferences.remove(object: existing)
  //            }
  //            NotificationCenter.default.post(name: Notifications.Surveys.Claim, object: instance.reference)
  ////            Notification.send(names: [Notifications.Surveys.Claimed])
  //        }
  //    }
  var rejected: [Survey]  = [] {//Local list of rejected surveys, should be cleared periodically
    didSet {
      guard let instance = rejected.last else { return }
      hot.remove(object: instance)
      ///Remove from lists
      ///Top
      if topReferences.contains(instance.reference) {
        topReferences.remove(object: instance.reference)
      } else if let existing = topReferences.filter({ $0 == instance.reference }).first {
        topReferences.remove(object: existing)
      }
      ///New
      if newReferences.contains(instance.reference) {
        newReferences.remove(object: instance.reference)
      } else if let existing = newReferences.filter({ $0 == instance.reference }).first {
        newReferences.remove(object: existing)
      }
      NotificationCenter.default.post(name: Notifications.Surveys.Rejected, object: instance.reference)
      //            Notification.send(names: [Notifications.Surveys.Rejected])
    }
  }
  //Publishers
  public let instancesPublisher = PassthroughSubject<[Survey], Never>()
  
  //Updates rating, progress and views count
  func updateStats(_ json: JSON) {
    for i in json {
      let instance: SurveyReference? = SurveyReferences.shared.all.filter({ $0.id == Int(i.0) }).first ?? Surveys.shared.all.filter({ $0.reference.id == Int(i.0)}).first?.reference
      guard let instance = instance,
            let progress = i.1["progress"].int,
            let comments = i.1["comments"].int,
            let rating = i.1["rating"].double,
            let active = i.1["active"].bool,
            let isBanned = i.1["is_banned"].bool,
            let views = i.1["views"].int else { return }
      instance.progress = progress
      instance.rating = rating
      instance.commentsTotal = comments
      instance.views = views
      instance.isActive = active
      instance.isBanned = isBanned
    }
  }
  
  func updateResultsStats(_ json: JSON) {
    guard let id = json["id"].int,
          let survey = Surveys.shared.all.filter({ $0.id == id }).first,
          let progress = json["progress"].int,
          let votesTotal = json["votes_total"].int,
          let rating = json["rating"].double,
          let answers = json["answers"].array,
          let isActive = json["active"].bool,
          let isBanned = json["is_banned"].bool,
          let commentsTotal = json["comments_total"].int,
          let comments = try? json["comments"].rawData()
    else { return }
    
    survey.rating = rating
    survey.progress = progress
    survey.commentsTotal = commentsTotal
    survey.votesTotal = votesTotal
    survey.isActive = isActive
    survey.isBanned = isBanned
    
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategyFormatters = [
      DateFormatter.ddMMyyyy,
      DateFormatter.dateTimeFormatter,
      DateFormatter.dateFormatter
    ]
    
    for answer in answers {
      guard let id = answer["id"].int,
            let instance = survey.answers.filter({ $0.id == id }).first,
            let totalVotes = answer["votes_total"].int
      else { return }
      
      do {
        let data = try answer["last_voters"].rawData()
        let userprofiles = try decoder.decode([Userprofile].self, from: data)
        userprofiles.forEach { userprofile in
          instance.voters.append(Userprofiles.shared.all.filter({ $0 == userprofile }).first ?? userprofile)
        }
      } catch {
#if DEBUG
        error.printLocalized(class: type(of: self), functionName: #function)
#endif
      }
      instance.totalVotes = totalVotes
    }
    
    //Comments
    let _ = try? decoder.decode([Comment].self, from: comments)
  }
  
  func load(_ json: JSON) {
    let decoder                                 = JSONDecoder()
    var notifications: [NSNotification.Name]    = []
    decoder.dateDecodingStrategyFormatters = [ DateFormatter.ddMMyyyy,
                                               DateFormatter.dateTimeFormatter,
                                               DateFormatter.dateFormatter ]
    //        decoder.keyDecodingStrategy                 = .convertFromSnakeCase
    do {
      //            if let dict = json.dictionary {
      //                if dict.isEmpty {
      //                    notifications.append(Notifications.Surveys.Empty)
      //                    Notification.send(names: notifications.uniqued())
      //                    return
      //                }
      //            }
      
      for (key, value) in json {
        if key == Category.Hot.rawValue {
          let instances = try decoder.decode([Survey].self, from: value.rawData())
          if instances.isEmpty {
//            fatalError()
            Surveys.shared.instancesPublisher.send([])
//            notifications.append(Notifications.Surveys.EmptyReceived)
            Notification.send(names: notifications.uniqued())
            //                        return
          }
          for instance in instances {
            if hot.filter({ $0.hashValue == instance.hashValue }).isEmpty {
              hot.append(Surveys.shared.all.filter({ $0 == instance }).first ?? instance)
              notifications.append(Notifications.Surveys.SwitchHot)
            }
          }
        } else {
          let instances = try decoder.decode([SurveyReference].self, from: value.rawData())
          
          if instances.isEmpty {
            SurveyReferences.shared.instancesPublisher.send([])
//            NotificationCenter.default.post(name: Notifications.Surveys.EmptyReceived, object: nil)
          }
          
          for instance in instances {
            let instance = SurveyReferences.shared.all.filter({ $0.hashValue == instance.hashValue }).first ?? instance
            
            if key == Category.Top.rawValue {
              if topReferences.filter({ $0 == instance }).isEmpty {
                NotificationCenter.default.post(name: Notifications.Surveys.TopAppend, object: instance)
                topReferences.append(instance)
              }
            } else if key == Category.New.rawValue {
              if newReferences.filter({ $0 == instance }).isEmpty {
                NotificationCenter.default.post(name: Notifications.Surveys.NewAppend, object: instance)
                newReferences.append(instance)
              }
            } else if key == Category.Own.rawValue {
              if ownReferences.filter({ $0 == instance }).isEmpty {
                NotificationCenter.default.post(name: Notifications.Surveys.OwnAppend, object: instance)
                ownReferences.append(instance)
              }
            } else if key == Category.Subscriptions.rawValue {
              if subscriptions.filter({ $0 == instance }).isEmpty {
                NotificationCenter.default.post(name: Notifications.Surveys.SubscriptionAppend, object: instance)
                subscriptions.append(instance)
              }
            } else if key == Category.Favorite.rawValue {
              if favoriteReferences.filter({ $0 == instance }).isEmpty {
                NotificationCenter.default.post(name: Notifications.Surveys.FavoriteAppend, object: instance)
                favoriteReferences.append(instance)
              }
            } else if key == Category.Topic.rawValue {
              NotificationCenter.default.post(name: Notifications.Surveys.TopicAppend, object: instance)
              SurveyReferences.shared.all.append(instance)
            } else if key == Category.Userprofile.rawValue {
              SurveyReferences.shared.all.append(instance)
            }
          }
        }
      }
      Notification.send(names: notifications.uniqued())
    } catch {
#if DEBUG
      fatalError("Survey init() threw error: \(error)")
#endif
    }
  }
  
  ///Remove from lists & notify
  func banSurvey(object: Survey) {
    guard let instance = hot.filter({$0.hashValue == object.hashValue}).first else { return }
    ///Clear new/top/hot
    newReferences.remove(object: instance.reference)
    newReferences.remove(object: instance.reference)
    hot.remove(object: instance)
    Notification.send(names: [Notifications.Surveys.UpdateNewSurveys, Notifications.Surveys.UpdateTopSurveys])
  }
  
  func eraseData() {
    topReferences.removeAll()
    newReferences.removeAll()
    //        categorizedLinks.removeAll()
    ownReferences.removeAll()
    favoriteReferences.removeAll()
    all.removeAll()
    hot.removeAll()
    rejected.removeAll()
  }
  
  subscript (ID: Int) -> Survey? {
    if let i = all.first(where: {$0.id == ID}) {
      return i
    } else {
      return nil
    }
  }
  
  @objc fileprivate func clearRejectedSurveys() {
    rejected.removeAll()
  }
  
  private func startTimer() {
    guard timer == nil else { return }
    
    timer = Timer.scheduledTimer(timeInterval: TimeIntervals.ClearRejectedSurveys,
                                 target: self,
                                 selector: #selector(Surveys.clearRejectedSurveys),
                                 userInfo: nil,
                                 repeats: true)
    timer?.fire()
  }
}
