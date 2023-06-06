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
    
//    override var preferredStatusBarStyle: UIStatusBarStyle {
//        return .lightContent
//    }
//    
//    override var childForStatusBarStyle: UIViewController? {
//        return tabBarController?.viewControllers
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        delay(seconds: 1) {
            self.logo.addUntitled1Animation() { (completed) in
                //TODO: переделать на проверку наличия токена и его срока годности, обновить данные с сервера
//                if AppData.shared.system.session == .unauthorized {
//                    self.performSegue(withIdentifier: Segues.Launch.Auth, sender: nil)
//                } else {
//                    self.performSegue(withIdentifier: Segues.Launch.App, sender: nil)
//                }
////                self.performSegue(withIdentifier: kSegueApp, sender: nil)
            }
        }
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == Segues.Launch.App {
//            segue.destination.modalPresentationStyle = .fullScreen
//        }
//    }
}

