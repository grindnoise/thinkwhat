//
//  NewSurveyViewController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 29.11.2019.
//  Copyright © 2019 Pavel Bukharov. All rights reserved.
//

import UIKit

class NewSurveyViewController: UIViewController {
    
//    var triggerView: UIView = UIView()
//    var mainView: UIView {
//        return view
//    }
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var bottomHeight: NSLayoutConstraint!
    @IBAction func cancelTapped(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func createTapped(_ sender: Any) {
        print("create")
    }
    @IBOutlet weak var tableView: UITableView!
    
    
    fileprivate var isViewSetupCompleted = false
    fileprivate let sections = ["Настройки", "Опрос"]
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("seg")
    }
    
    //@IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = false
        navigationController?.setNavigationBarHidden(true, animated: false)
        setupViews()
        tableView.delegate = self as UITableViewDelegate
        tableView.dataSource = self
    }
    
    private func setupViews() {
        DispatchQueue.main.async {
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
            self.navigationController?.navigationBar.shadowImage     = UIImage()
            self.navigationController?.navigationBar.isTranslucent   = false
            self.navigationController?.isNavigationBarHidden         = false
            self.navigationController?.navigationBar.barTintColor    = .white
            self.navigationItem.backBarButtonItem                    = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
            self.navigationItem.setHidesBackButton(true, animated: false)
            self.navigationController?.setNavigationBarHidden(true, animated: false)
            
        }
//        DispatchQueue.main.async {
//            self.addChild(self.tableVC)
//            self.tableVC.view.frame = CGRect(x: 0, y: 0, width: self.container.frame.width, height: self.container.frame.height)
//            self.tableVC.view.addEquallyTo(to: self.container)
//            self.tableVC.didMove(toParent: self)
//        }
//        DispatchQueue.main.async {
//            if let rbtn = self.navigationItem.rightBarButtonItem?.value(forKey: "view") as? UIView {
//                self.triggerView = rbtn
//            }
//        }
    }
    
    override func viewDidLayoutSubviews() {

    }
    
    override func viewWillAppear(_ animated: Bool) {
        if !isViewSetupCompleted {
//            bottomHeight.constant = navigationController!.navigationBar.bounds.height
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
            isViewSetupCompleted = true
            self.createButton.layer.cornerRadius = self.createButton.frame.height / 2
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
        print(self.view.frame)
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    //    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    //        self.lastContentOffset = scrollView.contentOffset.y
    //    }
    
}

extension NewSurveyViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25
    }
}

