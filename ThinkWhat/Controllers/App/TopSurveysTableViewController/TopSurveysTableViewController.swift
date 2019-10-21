//
//  TopSurveysTableViewController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 18.10.2019.
//  Copyright © 2019 Pavel Bukharov. All rights reserved.
//

import UIKit

class TopSurveysTableViewController: UITableViewController {

    private var vc: TopSurveysViewController!
    private var isViewSetupCompleted = false
    private var loadingIndicator: LoadingIndicator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        vc = parent! as! TopSurveysViewController
        loadData()
        setupViews()
        NotificationCenter.default.addObserver(self,
                                       selector: #selector(TopSurveysTableViewController.updateTableView),
                                       name: kNotificationTopSurveysUpdated,
                                       object: nil)
    }
    
    private func setupViews() {
        tableView.register(UINib(nibName: "SurveyTableViewCell", bundle: nil), forCellReuseIdentifier: "topSurveyCell")
        DispatchQueue.main.async {
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
            self.navigationController?.navigationBar.shadowImage     = UIImage()
            self.navigationController?.navigationBar.isTranslucent   = false
            self.navigationController?.isNavigationBarHidden         = false
            self.navigationController?.navigationBar.barTintColor    = .white
            self.navigationItem.backBarButtonItem                    = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        }
    }

    override func viewDidLayoutSubviews() {
        tableView.layoutIfNeeded()
        if !isViewSetupCompleted {
            tableView.isUserInteractionEnabled = false
            loadingIndicator = LoadingIndicator(frame: CGRect(origin: .zero, size: CGSize(width: tableView.frame.width, height: tableView.frame.width)))
            loadingIndicator.layoutCentered(in: tableView,multiplier: 0.7)//addEquallyTo(to: tableView)
            isViewSetupCompleted = true
            loadingIndicator.addUntitled1Animation()
        }
    }
    
    @objc private func updateTableView() {
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if vc.control.selectedSegmentIndex == 0 {
            return Surveys.shared.topSurveys.count
        } else {
            return Surveys.shared.newSurveys.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "topSurveyCell", for: indexPath) as! SurveyTableViewCell
        var dataSource: [SurveyLink]
        if vc.control.selectedSegmentIndex == 0 {
            dataSource = Surveys.shared.topSurveys.count
        } else {
            dataSource = Surveys.shared.newSurveys.count
        }
        cell.title.text = dataSource[indexPath.row].title
        if let category = dataSource[indexPath.row].category {
            if let parent = category.parent {
                cell.category.text = parent.title + " - " + category.title
            } else {
                cell.category.text = category.title
            }
        }
//        cell.category.text = "\(Surveys.shared.surveys[indexPath.row].category)"
        cell.completionPercentage.text = "\(dataSource[indexPath.row].completionPercentage)"
        return cell
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension TopSurveysTableViewController: ServerInitializationProtocol {
    func initializeServerAPI() -> APIManagerProtocol {
        return ((self.navigationController as! NavigationControllerPreloaded).parent as! TabBarController).apiManager
    }
}

extension TopSurveysTableViewController: ServerProtocol {
    private func loadData() {
        apiManager.loadSurveyCategories() {
            json, error in
            if error != nil {
//                showAlert(type: .WrongCredentials, buttons: ["Ок": [CustomAlertView.ButtonType.Ok: nil]], text: error!.localizedDescription)
                //Retry unless successfull
                self.loadData()
            }
            if json != nil {
                SurveyCategories.shared.importJson(json!)
                self.updateTopSurveys()
            }
        }
    }
    
    private func updateTopSurveys() {
        self.apiManager.loadMainSurveys() {
            json, error in
            if error != nil {
//                showAlert(type: .WrongCredentials, buttons: ["Ок": [CustomAlertView.ButtonType.Ok: nil]], text: error!.localizedDescription)
                //Retry unless successfull
                self.updateTopSurveys()
            }
            if json != nil {
                Surveys.shared.importJson(json!)
                self.tableView.isUserInteractionEnabled = true
                UIView.animate(withDuration: 0.3, animations: {
                    self.loadingIndicator.alpha = 0
                }) {
                    comleted in
                    self.loadingIndicator.removeAllAnimations()
                }
            }
        }
    }
}
