//
//  AuthNavigationController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 18.03.2019.
//  Copyright © 2019 Pavel Bukharov. All rights reserved.
//

import UIKit

class AuthNavigationController: UINavigationController {
    
    internal lazy var apiManagerProtocol: APIManagerProtocol    = initializeAPIManagerProtocol()
    internal lazy var storeManagerProtocol: FileStoringProtocol = initializeFileStoringProtocol()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.async {
            self.viewControllers.forEach { $0.view }
        }
    }
    
    private func initializeAPIManagerProtocol() -> APIManagerProtocol {
        return appDelegate.container.resolve(APIManagerProtocol.self)!
    }
    
    private func initializeFileStoringProtocol() -> FileStoringProtocol {
        return appDelegate.container.resolve(FileStoringProtocol.self)!
    }
}
