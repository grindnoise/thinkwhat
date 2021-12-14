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
    
    @IBAction func logoutButtonTapped(_ sender: Any) {
        showAlert(type: .Warning, buttons: [["Отмена": [CustomAlertView.ButtonType.Cancel: nil]], ["Выйти": [CustomAlertView.ButtonType.Ok: { (self.parent as? ProfileViewController)?.apiManager.logout() { _tokenState in print(tokenState)/*tokenState = _tokenState*/}; tokenState = .Revoked }]]], text: "Выйти из учетной записи?")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate      = self
        tableView.dataSource    = self
//        DispatchQueue.main.async {
//            self.genderTF.text = "\(yearsBetweenDate(startDate: AppData.shared.userProfile.birthDate, endDate: Date())), \(AppData.shared.userProfile.)"
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        appDelegate.center.getNotificationSettings(completionHandler: { settings in
            switch settings.authorizationStatus {
            case .authorized, .provisional:
                DispatchQueue.main.async {
                    self.notificationsSwitch.setOn(true, animated: false)
                }
                print("authorized")
            case .denied:
                DispatchQueue.main.async {
                    self.notificationsSwitch.setOn(false, animated: false)
                }
                print("denied")
            case .notDetermined:
                DispatchQueue.main.async {
                    print("not determined, ask user for permission now")
                }
                self.notificationsSwitch.setOn(false, animated: false)
            default:
                print("")
            }
        })
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            if let vc = (parent as? ProfileViewController) {
                if cell.reuseIdentifier == "credit" {
                    vc.performSegue(withIdentifier: Segues.App.ProfileToSettingsSelection, sender: nil)
                } else if cell.reuseIdentifier == "info" {
                    vc.performSegue(withIdentifier: Segues.App.ProfileToInfo, sender: nil)
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

