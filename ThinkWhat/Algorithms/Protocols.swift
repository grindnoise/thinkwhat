//
//  Protocols.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 02.10.2019.
//  Copyright © 2019 Pavel Bukharov. All rights reserved.
//

import Foundation

//protocol ServerProtocol {
//    var apiManager: APIManagerProtocol { get }
//}
//
//extension ServerProtocol {
//    var apiManager: APIManagerProtocol {
//        get {
//            return appDelegate.container.resolve(APIManagerProtocol.self)!
//        }
//    }
//}

protocol StorageProtocol {
    var storeManager: FileStorageProtocol { get }
}

extension StorageProtocol {
    var storeManager: FileStorageProtocol {
        get {
            return appDelegate.container.resolve(FileStorageProtocol.self)!
        }
    }
}

//protocol ServerInitializationProtocol {
//    func initializeServerAPI() -> APIManagerProtocol
//}

protocol StorageInitializationProtocol {
    func initializeStorageManager() -> FileStorageProtocol
}

import UIKit
protocol CallbackDelegate: class {
    func callbackReceived(_ sender: Any)
}
