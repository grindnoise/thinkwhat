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

protocol FileStorageProtocol {
    func storeImage(type: ImageType, image: UIImage, fileName: String?, fileFormat: FileFormat, surveyID: String?) -> String?
    func deleteFile(path: String)
}

class FileStorageManager: FileStorageProtocol {
    func deleteFile(path: String) {
        if FileManager.default.fileExists(atPath: path) {
            do {
                try FileManager.default.removeItem(atPath: path)
                
            } catch let error {
                fatalError(error.localizedDescription)
            }
        } else {
            print("FILE DOESN'T EXIST")
        }
    }
    
    
    func getImagesDirectoryPath() -> URL {
        var imagesDirectoryPath = ""
        let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
        
        if let documentDirectoryPath = documentDirectoryPath {
            imagesDirectoryPath = documentDirectoryPath.appending("/images")
            let fileManager = FileManager.default
            if !fileManager.fileExists(atPath: imagesDirectoryPath) {
                do {
                    try fileManager.createDirectory(atPath: imagesDirectoryPath,
                                                    withIntermediateDirectories: false,
                                                    attributes: nil)
                    if fileManager.fileExists(atPath: imagesDirectoryPath) {
                        print("FILE AVAILABLE")
                    } else {
                        print("FILE NOT AVAILABLE")
                    }
                    return URL(fileURLWithPath: imagesDirectoryPath)
                } catch {
                    fatalError("Error creating images folder in documents dir: \(error.localizedDescription)")
                }
            }
        }
        return URL(fileURLWithPath: imagesDirectoryPath)
    }
    
    func storeImage(type: ImageType, image: UIImage, fileName: String?, fileFormat: FileFormat, surveyID: String?) -> String? {
        var imagePath: String?
//        var imageURL: URL?
//        let imageDirectory      = getImagesDirectoryPath()
        let imageDirectory =  NSHomeDirectory().appending("/Documents/")
        if !FileManager.default.fileExists(atPath: imageDirectory) {
            do {
                try FileManager.default.createDirectory(at: NSURL.fileURL(withPath: imageDirectory), withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error)
            }
        }
        let separator           = "/"
        let dot                 = "."
        var _fileName           = ""
        
        switch type {
        case .Profile:
            _fileName           = type.rawValue
//            imageURL            = imageDirectory.appendingPathComponent(_fileName + dot + fileFormat.rawValue.lowercased())
            imagePath            = imageDirectory.appending(_fileName + dot + fileFormat.rawValue.lowercased())
            let imageURL = NSURL.fileURL(withPath: imagePath!)
            switch fileFormat {
            case .JPEG:
                do {
                    try image.jpegData(compressionQuality: 1)?.write(to: imageURL, options: .atomic)
                    if FileManager.default.fileExists(atPath: imagePath!) {
                        print("FILE AVAILABLE")
                    } else {
                        print("FILE NOT AVAILABLE")
                    }
                } catch let error {
                    fatalError(error.localizedDescription)
                }
            case .PNG:
                do {
                    try image.pngData()?.write(to: imageURL, options: .atomic)
                } catch let error {
                    fatalError(error.localizedDescription)
                }
            default:
                print("default")
            }
        default:
            print("TODO Store survey images")
        }
        return imagePath
    }
    
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
    
    fileprivate func prepareFilePath(filePath: inout String, fileName: inout String, fileExtension: FileFormat, filesDirectoryPath: String) {
        //Проверяем, существует ли файл по данному пути, если да, тогда генерируем новое имя
        guard !FileManager.default.fileExists(atPath: filePath) else {
            fileName = generateUniqueFilename()
            filePath = filesDirectoryPath + "/" + fileName + String(".") + fileExtension.rawValue
            return
        }
    }
    
    fileprivate func generateUniqueFilename() -> String {
        
        let guid = ProcessInfo.processInfo.globallyUniqueString
        let uniqueFileName = ("image_\(guid)")
        return uniqueFileName
        
    }
    
}

