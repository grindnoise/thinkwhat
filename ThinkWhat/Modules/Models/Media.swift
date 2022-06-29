//
//  Media.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 03.01.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import SwiftyJSON

class Mediafile: Decodable {
    private enum CodingKeys: String, CodingKey {
        case id, title, image, file, survey = "survey_id", order, url
    }
    var id: Int
    var title: String
    var url: URL?
    var imageURL: URL?
    var image: UIImage?
    var fileURL: URL?
    var file: Data?
    var surveyID: Int
    var survey: Survey? {
        return Surveys.shared.all.filter({ $0.id == surveyID }).first
    }
    var order: Int
    private let tempId = 999999
    
    required init(from decoder: Decoder) throws {
        do {
            
            let container   = try decoder.container(keyedBy: CodingKeys.self)
            surveyID = try container.decode(Int.self, forKey: .survey)
            id       = try container.decode(Int.self, forKey: .id)
            title    = try container.decode(String.self, forKey: .title)
            url      = URL(string:try container.decode(String.self, forKey: .title))
            order    = try container.decode(Int.self, forKey: .order)
            imageURL = URL(string: try container.decodeIfPresent(String.self, forKey: .image) ?? "")
            fileURL  = URL(string: try container.decodeIfPresent(String.self, forKey: .file) ?? "")
            if Mediafiles.shared.all.filter({ $0.hashValue == hashValue }).isEmpty {
                Mediafiles.shared.all.append(self)
            }
        } catch {
            throw error
        }
    }
    
    init(title _title: String = "", order _order: Int, survey _survey: Survey, image _image: UIImage? = nil, file _file: Data? = nil) {
        id          = tempId
        title       = _title
        order       = _order
        surveyID    = _survey.id
        image       = _image
        file        = _file
    }
    
//    func downloadImage(progress: @escaping (CGFloat) -> ()) throws -> UIImage? {
//        guard imageURL != nil else {
//            throw NSError(domain:"", code: 500, userInfo:[ NSLocalizedDescriptionKey: "Invalid URL"]) as Error
//        }
//
//        API.shared.downloadImage(url: imageURL!.absoluteString, progressClosure: {
//            _progress in
//            progress(_progress)
//        }) {
//            (image, error) in
//            return image
//        }
//    }
}

extension Mediafile: Hashable {
    static func == (lhs: Mediafile, rhs: Mediafile) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(order)
        hasher.combine(surveyID)
    }
}

class Mediafiles {
    static let shared = Mediafiles()
    var all: [Mediafile] = []
    private init() {}
    
    func load(_ data: Data) {
        let decoder = JSONDecoder()
        do {
            _ = try decoder.decode([Mediafile].self, from: data)
            print(all.count)
        } catch {
            fatalError("Media init() threw error: \(error)")
        }
    }
    
    subscript (id: Int) -> Mediafile? {
        if let i = all.first(where: {$0.id == id}) {
            return i
        } else {
            return nil
        }
    }
}
