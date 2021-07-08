//
//  PrivacySelectionTableViewController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 14.01.2020.
//  Copyright © 2020 Pavel Bukharov. All rights reserved.
//

import UIKit

class AnonymitySettingsTableViewController: UITableViewController {

    fileprivate var selectedIndex: IndexPath!
    var anonymity: SurveyAnonymity!      //[SurveyAnonymity] = []
    weak var delegate: CallbackDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        delegate?.callbackReceived(self)
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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SurveyAnonymity.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "case", for: indexPath) as? AnonymitySettingsTableViewCell {
            var text = ""
//            var isSelected = false
            if let option = SurveyAnonymity(rawValue: indexPath.row) {
                cell.option = option
//                isSelected = anonymity.contains(option)
                switch option {
                case .AllowAnonymousVoting:
                    text = "Возможность анонимного голоса"
                case .Full:
                    text = "Скрыт автор и респондент"
                case .Host:
                    text = "Скрыт автор"
                case .Responder:
                    text = "Скрыт респондент"
                case .Disabled:
                    text = "Виден автор и респондент"
                }
            }
            cell.sign.alpha = 0
            if anonymity == nil || anonymity! != cell.option {
                cell.isMarked = false
            } else {
                cell.isMarked = true
            }
            cell.label.text = text
            return cell
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? AnonymitySettingsTableViewCell {
            if !cell.isMarked {
                cell.isMarked = true
                anonymity = cell.option
                for c in tableView.visibleCells {
                    if let _cell = c as? AnonymitySettingsTableViewCell, _cell.isMarked, _cell != cell {
                        _cell.isMarked = false
                    }
                }
            }
            //                if cell.isMarked {
            //                    anonymity.append(cell.option)
            //                } else {
            //                    for (index, opt) in anonymity.enumerated() {
            //                        if opt == cell.option {
            //                            anonymity.remove(at: index)
            //                        }
            //                    }
            //                    anonymity.remove(object: cell.option)
            //                }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

class AnonymitySettingsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var sign: ValidSign!
    var option: SurveyAnonymity!
    var isMarked = false {
        didSet {
            if isMarked != oldValue {
                UIView.animate(withDuration: 0.05) {
                    self.sign.alpha             = self.isMarked ? 1 : 0
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
