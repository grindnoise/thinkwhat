//
//  InfoViewController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 15.10.2019.
//  Copyright © 2019 Pavel Bukharov. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController {

    @IBOutlet weak var container: UIView!
    
    private let tableVC: InfoTableViewController = {
        return Storyboards.controllers.instantiateViewController(withIdentifier: "InfoTableViewController") as! InfoTableViewController
    } ()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewDidLayoutSubviews() {
        container.setNeedsLayout()
        container.layoutIfNeeded()
    }
    
    private func setupViews() {
        if let appName = Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String, let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            title = "\(appName) \(appVersion)"
        }
        DispatchQueue.main.async {
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
            self.navigationController?.navigationBar.shadowImage     = UIImage()
            self.navigationController?.navigationBar.isTranslucent   = false
            self.navigationController?.isNavigationBarHidden         = false
            self.navigationController?.navigationBar.barTintColor    = .white
            self.navigationItem.backBarButtonItem                    = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        }
        DispatchQueue.main.async {
            self.addChild(self.tableVC)
            self.tableVC.view.frame = CGRect(x: 0, y: 0, width: self.container.frame.width, height: self.container.frame.height)
            self.tableVC.view.addEquallyTo(to: self.container)
            self.tableVC.didMove(toParent: self)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
