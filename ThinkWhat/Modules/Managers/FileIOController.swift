//
//  FileStoring.swift
//  Burb
//
//  Created by Pavel Bukharov on 26.04.2018.
//  Copyright © 2018 Pavel Bukharov. All rights reserved.
//

import Foundation
import UIKit
import CoreData

enum FileError: Error {
    case notFound(path: String?)
    case unexpected
}

extension FileError {
    var isFatal: Bool {
        if case FileError.unexpected = self { return true }
        else { return false }
    }
}

extension FileError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .notFound(path):
            return NSLocalizedString(
                "File not found at path: \(String(describing: path))",
                comment: "Not found"
            )
        case .unexpected:
            return NSLocalizedString(
                "Unexpected error occured during file operation",
                comment: "Unexpected Error"
            )
        }
    }
}

struct FileIOController {
    static let manager = FileManager.default
    
    enum DirectoryPath: String {
        case Profiles = "profiles/"
        case Surveys = "surveys/"
    }
    
    enum DirectoryType: String {
        case Images = "images/"
        case Media = "media/"
    }
    
    static func delete(dataPath path: String) throws {
        guard manager.fileExists(atPath: path) else { throw FileError.notFound(path: path) }
        do {
            try manager.removeItem(atPath: path)
        } catch { throw error }
    }

    static func write(data: Data, toPath path: DirectoryPath, ofType type: DirectoryType, id: String, toDocumentNamed documentName: String) throws -> URL {
        let rootFolderURL = try manager.url(
            for: .documentDirectory,
               in: .userDomainMask,
               appropriateFor: nil,
               create: false
        )
        let nestedFolderURL = rootFolderURL.appendingPathComponent("/Data/\(path.rawValue)\(type.rawValue)\(id)/")
        if !manager.fileExists(atPath: nestedFolderURL.relativePath) {
            try manager.createDirectory(
                at: nestedFolderURL,
                withIntermediateDirectories: true,
                attributes: nil
            )
        }
        let fileURL = nestedFolderURL.appendingPathComponent(documentName)
        do {
            try data.write(to: fileURL)
            return fileURL
        } catch { throw error }
//
//
//        let imageDirectory = getDocumentsDirectory().appendingPathComponent("/Data\(path)\(type)\(id)/")
////        let imageDirectory =  NSHomeDirectory().appending("/Data\(path)\(type)\(id)/")
//        if !manager.fileExists(atPath: imageDirectory.absoluteString) {
//            do {
//                try FileManager.default.createDirectory(at: NSURL.fileURL(withPath: imageDirectory.absoluteString), withIntermediateDirectories: true, attributes: nil)
//            } catch {
//                throw error
//            }
//        }
//
    }
}

//    func storeImage(type: ImageType, image: UIImage, fileName: String?, fileFormat: FileFormat, surveyID: String?) -> String? {
//        var imagePath: String?
////        var imageURL: URL?
////        let imageDirectory      = getImagesDirectoryPath()
//        let imageDirectory =  NSHomeDirectory().appending("/Documents/")
//        if !FileManager.default.fileExists(atPath: imageDirectory) {
//            do {
//                try FileManager.default.createDirectory(at: NSURL.fileURL(withPath: imageDirectory), withIntermediateDirectories: true, attributes: nil)
//            } catch {
//                print(error)
//            }
//        }
//        let separator           = "/"
//        let dot                 = "."
//        var _fileName           = ""
//
//        switch type {
//        case .Profile:
//            _fileName           = type.rawValue
////            imageURL            = imageDirectory.appendingPathComponent(_fileName + dot + fileFormat.rawValue.lowercased())
//            imagePath            = imageDirectory.appending(_fileName + dot + fileFormat.rawValue.lowercased())
//            let imageURL = NSURL.fileURL(withPath: imagePath!)
//            switch fileFormat {
//            case .JPEG:
//                do {
//                    try image.jpegData(compressionQuality: 1)?.write(to: imageURL, options: .atomic)
//                    if FileManager.default.fileExists(atPath: imagePath!) {
//                        print("FILE AVAILABLE")
//                    } else {
//                        print("FILE NOT AVAILABLE")
//                    }
//                } catch let error {
//                    fatalError(error.localizedDescription)
//                }
//            case .PNG:
//                do {
//                    try image.pngData()?.write(to: imageURL, options: .atomic)
//                } catch let error {
//                    fatalError(error.localizedDescription)
//                }
//            default:
//                fatalError()
//            }
//        default:
//            print("TODO Store survey images")
//        }
//        return imagePath
//    }
    
//    func storeImage(_ image: UIImage, fullFileName: String, questionID: String) -> URL? {
//
//        let imagesDirectoryPath = getImagesDirectoryPath()
//        let fileName            = fullFileName.fileName()
//        let fileExtension       = ImageExtension(rawValue: fullFileName.fileExtension())
//        let separator           = "/"
//        var imageName           = fileName.isEmpty ? generateUniqueFilename() : fileName
//        var imagePath           = imagesDirectoryPath + separator + fullFileName
//
//        //Existence check
//        prepareFilePath(filePath: &imagePath, fileName: &imageName, fileExtension: fileExtension!, filesDirectoryPath: imagesDirectoryPath)
//
//        let imageURL            = URL(fileURLWithPath: imagePath)
////        switch fileExtension! {
////        case .JPEG:
////            do {
////                try UIImageJPEGRepresentation(image, 0.5)?.write(to: imageURL)
////                let context         = appDelegate.persistentContainer.viewContext
////                context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
////                let entity          = NSEntityDescription.entity(forEntityName: "QuestionImages", in: context)!
////                let record          = QuestionImages(entity: entity, insertInto: context)
////                record.imageURL     = imagePath
////                record.questionID   = questionID
////                try? context.save()
////                return imageURL
////            } catch {
////                print(error)
////                return nil
////            }
////        case .PNG:
////            do {
////                try UIImagePNGRepresentation(image)?.write(to: imageURL)//(image, 0.5)?.write(to: imageURL)
////                let context         = appDelegate.persistentContainer.viewContext
////                context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
////                let entity          = NSEntityDescription.entity(forEntityName: "QuestionImages", in: context)!
////                let record          = QuestionImages(entity: entity, insertInto: context)
////                record.imageURL     = imagePath
////                record.questionID   = questionID
////                try? context.save()
////                return imageURL
////            } catch {
////                print(error)
////                return nil
////            }
////        default:
////            print("")
////        }
//
//        return imageURL
//    }
    
//    fileprivate func prepareFilePath(filePath: inout String, fileName: inout String, fileExtension: FileFormat, filesDirectoryPath: String) {
//        //Проверяем, существует ли файл по данному пути, если да, тогда генерируем новое имя
//        guard !FileManager.default.fileExists(atPath: filePath) else {
//            fileName = generateUniqueFilename()
//            filePath = filesDirectoryPath + "/" + fileName + String(".") + fileExtension.rawValue
//            return
//        }
//    }
    
//    fileprivate func generateName() -> String {
//
//        let guid = ProcessInfo.processInfo.globallyUniqueString
//        let uniqueFileName = ("image_\(guid)")
//        return uniqueFileName
//
//    }
//    func getImagesDirectoryPath() -> URL {
//        var imagesDirectoryPath = ""
//        let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
//
//        if let documentDirectoryPath = documentDirectoryPath {
//            imagesDirectoryPath = documentDirectoryPath.appending("/images")
//            let fileManager = FileManager.default
//            if !fileManager.fileExists(atPath: imagesDirectoryPath) {
//                do {
//                    try fileManager.createDirectory(atPath: imagesDirectoryPath,
//                                                    withIntermediateDirectories: false,
//                                                    attributes: nil)
//                    if fileManager.fileExists(atPath: imagesDirectoryPath) {
//                        print("FILE AVAILABLE")
//                    } else {
//                        print("FILE NOT AVAILABLE")
//                    }
//                    return URL(fileURLWithPath: imagesDirectoryPath)
//                } catch {
//                    fatalError("Error creating images folder in documents dir: \(error.localizedDescription)")
//                }
//            }
//        }
//        return URL(fileURLWithPath: imagesDirectoryPath)
//    }
//
//    func getDocumentsDirectory() -> URL {
//        return manager.urls(for: .documentDirectory, in: .userDomainMask).first!
//    }
