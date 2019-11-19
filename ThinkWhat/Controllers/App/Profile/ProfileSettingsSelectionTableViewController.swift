//
//  ProfileSettingsSelectionTableViewController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 07.10.2019.
//  Copyright © 2019 Pavel Bukharov. All rights reserved.
//

import UIKit

class ProfileSettingsSelectionTableViewController: UITableViewController {
    
    private var selectedIndex: IndexPath!
    
//    var state: ClientSettingsMode! {
//        didSet {
//            if oldValue != state {
//                tableView.reloadData()
//                if state == .Reminder {
//                    title = "Напоминания"
//                } else {
//                    title = "Язык"
//                }
//            }
//        }
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        tableView.delegate      = self
        tableView.dataSource    = self
    }
    
    private func setupViews() {
        DispatchQueue.main.async {
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
            self.navigationController?.navigationBar.shadowImage     = UIImage()
            self.navigationController?.navigationBar.isTranslucent   = false
            self.navigationController?.isNavigationBarHidden         = false
            self.navigationController?.navigationBar.barTintColor    = .white
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if state == .Reminder {
//            return appData.reminderSettings.count
//        } else {
//            return appData.languages.count
//        }
//    }
    
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! CustomerSettingsTableViewCell
//        if state == .Reminder {
//            cell.label.text = appData.reminderSettings[indexPath.row].first?.key
//            let isSelected = appData.reminderSettings[indexPath.row].first?.value == appData.reminder
//            cell.sign.alpha = isSelected ? 1 : 0
//            cell.label.textColor = isSelected ? UIColor.black : UIColor.lightGray
//            if isSelected { selectedIndex = indexPath }
//        } else {
//            cell.label.text = appData.languages[indexPath.row].rawValue
//            let isSelected = appData.languages[indexPath.row] == appData.language
//            cell.sign.alpha = isSelected ? 1 : 0
//            cell.label.textColor = isSelected ? UIColor.black : UIColor.lightGray
//            if isSelected { selectedIndex = indexPath }
//        }
//        cell.selectionStyle = .none
//        return cell
//    }
//
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if indexPath.row != selectedIndex.row {
//            if let cell = tableView.cellForRow(at: indexPath) as? ProfileSettingsTableViewCell, let prevCell = tableView.cellForRow(at: self.selectedIndex) as? ProfileSettingsTableViewCell {
//                UIView.animate(withDuration: 0.1, animations: {
//                    cell.sign.alpha             = 1
//                    prevCell.sign.alpha         = 0
//                    cell.label.textColor        = UIColor.black
//                    prevCell.label.textColor    = UIColor.lightGray
//                }, completion: {
//                    _ in
//                    self.selectedIndex = indexPath
//                })
//            }
//        }
//        tableView.deselectRow(at: indexPath, animated: true)
//    }
    
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
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

class ProfileSettingsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var sign: ValidSign!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

