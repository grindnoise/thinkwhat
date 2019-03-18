//
//  AuthNavigationController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 18.03.2019.
//  Copyright © 2019 Pavel Bukharov. All rights reserved.
//

import UIKit

class AuthNavigationController: UINavigationController {
    
    internal lazy var serverAPI:     APIServerProtocol          = self.initializeServerAPI()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.async {
            self.viewControllers.forEach { $0.view }
        }
    }
    
    private func initializeServerAPI() -> APIServerProtocol {
        return appDelegate.container.resolve(APIServerProtocol.self)!
    }
}
