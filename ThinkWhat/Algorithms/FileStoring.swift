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

protocol FileStoringProtocol {
    func storeImage(_ image: UIImage, fullFileName: String, questionID: String) -> URL?
}

class FileStorage: FileStoringProtocol {
    
    func getImagesDirectoryPath() -> String {
        
        var imagesDirectoryPath = ""
        
        let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
        if let documentDirectoryPath = documentDirectoryPath {
            // create the custom folder path
            imagesDirectoryPath = documentDirectoryPath.appending("/images")
            let fileManager = FileManager.default
            if !fileManager.fileExists(atPath: imagesDirectoryPath) {
                do {
                    try fileManager.createDirectory(atPath: imagesDirectoryPath,
                                                    withIntermediateDirectories: false,
                                                    attributes: nil)
                    return imagesDirectoryPath
                } catch {
                    fatalError("Error creating images folder in documents dir: \(error.localizedDescription)")
                }
            }
            print("**********Image subfolder at \(imagesDirectoryPath) exists: \(fileManager.fileExists(atPath: imagesDirectoryPath))")
        }
        return imagesDirectoryPath
    }
    
    func storeImage(_ image: UIImage, fullFileName: String, questionID: String) -> URL? {
        
        let imagesDirectoryPath = getImagesDirectoryPath()
        let fileName            = fullFileName.fileName()
        let fileExtension       = ImageExtension(rawValue: fullFileName.fileExtension())
        let separator           = "/"
        var imageName           = fileName.isEmpty ? generateUniqueFilename() : fileName
        var imagePath           = imagesDirectoryPath + separator + fullFileName
        
        //Existence check
        prepareFilePath(filePath: &imagePath, fileName: &imageName, fileExtension: fileExtension!, filesDirectoryPath: imagesDirectoryPath)
        
        let imageURL            = URL(fileURLWithPath: imagePath)
//        switch fileExtension! {
//        case .JPEG:
//            do {
//                try UIImageJPEGRepresentation(image, 0.5)?.write(to: imageURL)
//                let context         = appDelegate.persistentContainer.viewContext
//                context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
//                let entity          = NSEntityDescription.entity(forEntityName: "QuestionImages", in: context)!
//                let record          = QuestionImages(entity: entity, insertInto: context)
//                record.imageURL     = imagePath
//                record.questionID   = questionID
//                try? context.save()
//                return imageURL
//            } catch {
//                print(error)
//                return nil
//            }
//        case .PNG:
//            do {
//                try UIImagePNGRepresentation(image)?.write(to: imageURL)//(image, 0.5)?.write(to: imageURL)
//                let context         = appDelegate.persistentContainer.viewContext
//                context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
//                let entity          = NSEntityDescription.entity(forEntityName: "QuestionImages", in: context)!
//                let record          = QuestionImages(entity: entity, insertInto: context)
//                record.imageURL     = imagePath
//                record.questionID   = questionID
//                try? context.save()
//                return imageURL
//            } catch {
//                print(error)
//                return nil
//            }
//        default:
//            print("")
//        }
        
        return imageURL
    }
    
    fileprivate func prepareFilePath(filePath: inout String, fileName: inout String, fileExtension: ImageExtension, filesDirectoryPath: String) {
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

