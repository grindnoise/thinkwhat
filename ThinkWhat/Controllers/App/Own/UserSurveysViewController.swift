//
//  UserSurveysViewController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 18.11.2019.
//  Copyright © 2019 Pavel Bukharov. All rights reserved.
//

import UIKit

class UserSurveysViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var control: UISegmentedControl!
    @IBAction func addSurvey(_ sender: Any) {
        
    }
    
    fileprivate let tableVC: UserSurveysTableViewController = {
        let storyboard = UIStoryboard(name: "App", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "UserSurveysTableViewController") as! UserSurveysTableViewController
        return vc
    } ()
    fileprivate let statisticsVC: StatisticsViewController = {
        return StatisticsViewController(nibName :"StatisticsViewController",bundle : nil)
    } ()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
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
            self.setupScrollView()
        }
    }
    
    fileprivate func setupScrollView() {
        scrollView.setNeedsLayout()
        scrollView.layoutIfNeeded()
        addChild(tableVC)
        tableVC.view.frame = CGRect(x: 0, y: 0, width: scrollView.frame.width, height: scrollView.frame.height)
        scrollView.addSubview(tableVC.view)
        tableVC.didMove(toParent: self)
        addChild(statisticsVC)
        statisticsVC.view.frame = CGRect(x: scrollView.frame.width, y: 0, width: scrollView.frame.width, height: scrollView.frame.height)
        scrollView.addSubview(statisticsVC.view)
        statisticsVC.didMove(toParent: self)
        scrollView.contentSize = CGSize(width: scrollView.frame.width * 2, height: scrollView.frame.height)
        scrollView.isScrollEnabled = false
    }
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == kSegueAppUserSurveysToSurvey, let destinationVC = segue.destination as? SurveyViewController, let cell = tableVC.tableView.cellForRow(at: tableVC.tableView.indexPathForSelectedRow!) as? SurveyTableViewCell {
            destinationVC.surveyLink = cell.survey
        } else {
            showAlert(type: .Ok, buttons: ["Ок": [CustomAlertView.ButtonType.Ok: nil]], text: "Ошибка вызова сервера, пожалуйста, обновите список")
        }
    }
    
}
