//
//  ProfileSettingsTableViewController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 04.10.2019.
//  Copyright © 2019 Pavel Bukharov. All rights reserved.
//

import UIKit

class ProfileSettingsTableViewController: UITableViewController {
    
    @IBOutlet weak var notificationsSwitch: UISwitch!
    @IBOutlet weak var anonymousVoteSwitch: UISwitch!
    @IBOutlet weak var logoutButton:        UIButton!
//    @IBOutlet weak var deleteAccountButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate      = self
        tableView.dataSource    = self
//        DispatchQueue.main.async {
//            self.genderTF.text = "\(yearsBetweenDate(startDate: AppData.shared.userProfile.birthDate, endDate: Date())), \(AppData.shared.userProfile.)"
//        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            if let vc = (parent as? ProfileViewController) {
                if cell.reuseIdentifier == "credit" {
                    vc.performSegue(withIdentifier: kSegueProfileSettingsSelection, sender: nil)
                }
            }
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.size.height / CGFloat(5) - 5.6//
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 28
    }
    
}

