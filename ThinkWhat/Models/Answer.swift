//
//  Answer.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 28.10.2021.
//  Copyright © 2021 Pavel Bukharov. All rights reserved.
//

import Foundation
import SwiftyJSON

class Answer: Decodable {
    private enum CodingKeys: String, CodingKey {
        case description, title, totalVotes = "total_votes", id, voters, survey = "survey_id", image, file, url = "hlink"
    }
    var id: Int
    var description: String
    var totalVotes: Int = 0
    var title: String
    var voters: [Userprofile] = []
    var surveyID : Int
    var survey: Survey? {
        return Surveys.shared.all.filter({ $0.id == surveyID }).first
    }
    var url: URL?
    var imageURL: URL?
    var image: UIImage?
    var fileURL: URL?
    var file: Data?
    private let tempId = 999999
    
    required init(from decoder: Decoder) throws {
        do {
            let container   = try decoder.container(keyedBy: CodingKeys.self)
            surveyID    = try container.decode(Int.self, forKey: .survey)
            id          = try container.decode(Int.self, forKey: .id)
            title       = try container.decode(String.self, forKey: .title)
            totalVotes  = try container.decodeIfPresent(Int.self, forKey: .totalVotes) ?? 0
            description = try container.decode(String.self, forKey: .description)
            let instances = try container.decode([Userprofile].self, forKey: .voters)
            instances.forEach { instance in
                if voters.filter({ $0.hashValue == instance.hashValue }).isEmpty {
                    voters.append(Userprofiles.shared.all.filter({ $0 == instance }).first ?? instance)
                }
            }
            url         = URL(string:try container.decode(String.self, forKey: .title))
            imageURL    = URL(string: try container.decodeIfPresent(String.self, forKey: .image) ?? "")
            fileURL     = URL(string: try container.decodeIfPresent(String.self, forKey: .file) ?? "")
        } catch {
            throw error
        }
    }
    
    init(description _description: String, title _title: String, survey _survey: Survey) {
        id = tempId
        description = _description
        title = _title
        surveyID = _survey.id
    }
    
    
    func update(from json: JSON) {
        do {
            title       = json[CodingKeys.title.rawValue].stringValue
            totalVotes  = json[CodingKeys.totalVotes.rawValue].intValue
            description = json[CodingKeys.title.rawValue].stringValue
            if json.first?.0 == CodingKeys.voters.rawValue, let data = try json.first?.1.rawData() {
                let instances = try JSONDecoder().decode([Userprofile].self, from: data)
                instances.forEach { instance in
                    if voters.filter({ $0.hashValue == instance.hashValue }).isEmpty {
                        voters.append(Userprofiles.shared.all.filter({ $0 == instance }).first ?? instance)
                    }
                }
            }
            url         = URL(string: json[CodingKeys.url.rawValue].stringValue) ?? url
            imageURL    = URL(string: json[CodingKeys.image.rawValue].stringValue) ?? imageURL
            fileURL     = URL(string: json[CodingKeys.file.rawValue].stringValue) ?? fileURL
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func addVoter(_ userprofile: Userprofile) {
        if voters.filter({ $0.hashValue == userprofile.hashValue }).isEmpty {
            voters.append(userprofile)
        }
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
