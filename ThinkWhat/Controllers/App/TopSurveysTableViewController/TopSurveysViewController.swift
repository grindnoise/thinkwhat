//
//  TopSurveysViewController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 21.10.2019.
//  Copyright © 2019 Pavel Bukharov. All rights reserved.
//

import UIKit

class TopSurveysViewController: UIViewController {
    
    private let attrs     = [NSAttributedString.Key.font : UIFont(name: "OpenSans-Light", size: 13)]//,
//                                   NSAttributedString.Key.foregroundColor: K_COLOR_RED,
//                                   NSAttributedString.Key.backgroundColor: UIColor.clear]
    private var isViewSetupCompleted = false
    private let tableVC: TopSurveysTableViewController = {
        let storyboard = UIStoryboard(name: "App", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "TopSurveysTableViewController") as! TopSurveysTableViewController
        return vc
    } ()
    
    @IBAction func controlChanged(_ sender: UISegmentedControl) {
        tableVC.tableView.reloadData()
    }
    @IBOutlet weak var control: UISegmentedControl!
    @IBOutlet weak var container: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        // Do any additional setup after loading the view.
    }
    
    private func setupViews() {
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
        control.setTitleTextAttributes(attrs, for: .normal)
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
