//
//  Answer.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 28.10.2021.
//  Copyright © 2021 Pavel Bukharov. All rights reserved.
//

import Foundation
import SwiftyJSON
import Combine

class Answer: Decodable {
  private enum CodingKeys: String, CodingKey {
    case description, title, totalVotes = "votes_total", id, voters, survey = "survey_id", image, order, file, url = "hlink"
  }
  var id: Int
  var description: String
  var totalVotes: Int = 0 {
    didSet {
      guard oldValue != totalVotes else { return }
      
      votesPublisher.send(totalVotes)
      NotificationCenter.default.post(name: Notifications.SurveyAnswers.TotalVotes, object: self)
    }
  }
  var title: String
  var order: Int
  var voters: [Userprofile] = [] {
    didSet {
//      //Check for duplicates
//      guard let lastInstance = voters.last else { return }
//
//      guard oldValue.filter({ $0 == lastInstance }).isEmpty else {
//        voters.remove(object: lastInstance)
//
//        return
//      }
      votersPublisher.send(voters)
//      NotificationCenter.default.post(name: Notifications.SurveyAnswers.VotersAppend, object: self)
    }
  }
  var surveyID : Int
  var survey: Survey? {
    return Surveys.shared.all.filter({ $0.id == surveyID }).first
  }
  var url: URL?
  var imageURL: URL?
  var image: UIImage?
  var fileURL: URL?
  var file: Data?
  //0..1 max
  var percent: Double {
    guard let survey = survey else { return 0 }
    if survey.votesTotal == 0 || totalVotes == 0 {
      return 0
    }
    return Double(totalVotes)/Double(survey.votesTotal)
  }
  var percentString: String {
    //    guard percent != .zero else { return "" }
    return "\(Int(floor(percent*100)))%"
  }
  private let tempId = 999999
  //Publishers
  public let votesPublisher = PassthroughSubject<Int, Never>()
  public let votersPublisher = PassthroughSubject<[Userprofile], Never>()
  
  
  
  //MARK: - Initialization
  required init(from decoder: Decoder) throws {
    do {
      let container   = try decoder.container(keyedBy: CodingKeys.self)
      surveyID    = try container.decode(Int.self, forKey: .survey)
      id          = try container.decode(Int.self, forKey: .id)
      title       = try container.decode(String.self, forKey: .title)
      totalVotes  = try container.decodeIfPresent(Int.self, forKey: .totalVotes) ?? 0
      description = try container.decode(String.self, forKey: .description)
      order       = try container.decode(Int.self, forKey: .order)
      let instances = try container.decode([Userprofile].self, forKey: .voters)
      
      appendVoters(instances)
//      instances.forEach { instance in
//        //                if voters.filter({ $0 == instance }).isEmpty {
//        voters.append(Userprofiles.shared.all.filter({ $0 == instance }).first ?? instance)
//        //                }
//      }
      url         = URL(string:try container.decode(String.self, forKey: .title))
      imageURL    = URL(string: try container.decodeIfPresent(String.self, forKey: .image) ?? "")
      fileURL     = URL(string: try container.decodeIfPresent(String.self, forKey: .file) ?? "")
    } catch {
      throw error
    }
  }
  
  init(description _description: String, title _title: String, survey _survey: Survey, order _order: Int) {
    id = tempId
    description = _description
    title = _title
    surveyID = _survey.id
    order = _order
  }
  
  func update(from json: JSON) {
    do {
      title       = json[CodingKeys.title.rawValue].stringValue
      totalVotes  = json[CodingKeys.totalVotes.rawValue].intValue
      order        = json[CodingKeys.order.rawValue].intValue
      description = json[CodingKeys.title.rawValue].stringValue
      if json.first?.0 == CodingKeys.voters.rawValue, let data = try json.first?.1.rawData() {
        let instances = try JSONDecoder().decode([Userprofile].self, from: data)
        appendVoters(instances)
//        instances.forEach { instance in
//          if voters.filter({ $0.hashValue == instance.hashValue }).isEmpty {
//            voters.append(Userprofiles.shared.all.filter({ $0 == instance }).first ?? instance)
//          }
//        }
      }
      url         = URL(string: json[CodingKeys.url.rawValue].stringValue) ?? url
      imageURL    = URL(string: json[CodingKeys.image.rawValue].stringValue) ?? imageURL
      fileURL     = URL(string: json[CodingKeys.file.rawValue].stringValue) ?? fileURL
    } catch {
      fatalError(error.localizedDescription)
    }
  }
  
  func appendVoters(_ instances: [Userprofile]) {
    let currentSet = Set(voters)
    
    var new: [Userprofile] = []
    instances.forEach { instance in
      if instance.isCurrent {
        new.append(Userprofiles.shared.current!)
      } else {
        new.append(Userprofiles.shared.all.filter({ $0 == instance }).first ?? instance)
      }
    }
    
    let newSet = Set(new)
    
    guard !currentSet.isEmpty else {
      voters.append(contentsOf: newSet)
      return
    }
    
    let appendingSet = newSet.subtracting(currentSet)
//    newSet.map { $0.id }
//    currentSet.map { $0.id }
//    appendingSet.map { $0.id }
    guard !appendingSet.isEmpty else { return }
    
    voters.append(contentsOf: appendingSet)
  }
}

extension Answer: Hashable {
    static func == (lhs: Answer, rhs: Answer) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(description)
        hasher.combine(title)
        hasher.combine(surveyID)
    }
}

class Answers {
  
  private var shouldImportUserDefaults = false
  static let shared = Answers()
  var all: [Answer] = [] {
    didSet {
      guard !oldValue.isEmpty else {
        instancesPublisher.send(all)
        return
      }
      
      let existingSet = Set(oldValue)
      let appendingSet = Set(all)
      
      ///Difference
      instancesPublisher.send(Array(appendingSet.subtracting(existingSet)))
    }
  }
  ///**Publishers**
  public let instancesPublisher = PassthroughSubject<[Answer], Never>()
  
  func append(_ instances: [Answer]) {
    guard !instances.isEmpty else {
      instancesPublisher.send([]);
      return
    }
    
    guard !all.isEmpty else { all.append(contentsOf: instances); return }
    
    let existingSet = Set(all)
    let appendingSet = Set(replaceWithExisting(all, instances))
    let difference = Array(appendingSet.subtracting(existingSet))
    
    guard !difference.isEmpty else { return }
    
    all.append(contentsOf: difference)
  }
  
  subscript(_ id: Int) -> Answer? { all.filter({ $0.id == id }).first }
}
