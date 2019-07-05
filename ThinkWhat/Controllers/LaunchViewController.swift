//
//  LaunchViewController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 18.03.2019.
//  Copyright © 2019 Pavel Bukharov. All rights reserved.
//

import UIKit

class LaunchViewController: UIViewController {
    
    @IBOutlet weak var logo: LogoAnimView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        delay(seconds: 1) {
        self.logo.addUntitled1Animation() { (completed) in
            if appData.session == .unauthorized {
                self.performSegue(withIdentifier: kSegueAuth, sender: nil)
                //Временная заглушка для тестирования
            } else {
                self.performSegue(withIdentifier: kSegueAuth, sender: nil)
            }
        }
        }
    }
}

