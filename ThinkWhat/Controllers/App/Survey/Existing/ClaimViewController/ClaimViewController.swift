//
//  ClaimViewController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 08.06.2020.
//  Copyright © 2020 Pavel Bukharov. All rights reserved.
//

import UIKit

class ClaimViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    fileprivate enum ClaimButtonState: String {
        case Inactive, PostClaim, Close
    }
    fileprivate var claimButtonState: ClaimButtonState = .Inactive {
        didSet {
            if oldValue != claimButtonState {
                switch claimButtonState {
                case .Close:
                    self.claimButton.setAttributedTitle(NSAttributedString(string: "ПРОДОЛЖИТЬ", attributes:
                    [NSAttributedString.Key.font : UIFont(name: "OpenSans-Semibold", size: 19),
                    NSAttributedString.Key.foregroundColor: UIColor.white,
                    NSAttributedString.Key.backgroundColor: UIColor.clear]
                    ), for: .normal)
                default:
                    print("df")
                }
            }
        }
    }
    fileprivate var isViewSetupCompleted = false
    fileprivate var button = false
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var stackWidthConstraint: NSLayoutConstraint!
//    fileprivate var stackHeightConstraint: NSLayoutConstraint!
//    fileprivate var claimButtonRatioConstraint: NSLayoutConstraint!
    fileprivate var heightConstraint: NSLayoutConstraint!
    fileprivate var centerYConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var claimButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var stackView: UIStackView!
    @IBAction func buttonTapped(_ sender: UIButton) {
        if sender.tag == 0 {
            switch claimButtonState {
            case .Close:
                sender.accessibilityIdentifier = claimButtonState.rawValue//"Close"
                sender.layer.setValue(ClaimCategories.shared[selectedClaimID], forKey: "claimCategory")
                navigationController?.popViewController(animated: true)
            case .PostClaim:
                sender.layer.setValue(selectedClaimID, forKey: "claimID")
                sender.accessibilityIdentifier = claimButtonState.rawValue//"Claim"
                NSLayoutConstraint.deactivate([bottomConstraint])
                cancelButton.alpha = 0
                UIView.animate(withDuration: 0.15, animations: {
                    self.tableView.alpha = 0
                    self.label.alpha = 0
                }) {
                    _ in
                    self.label.text = "Благодарим за обратную связь!"
                    UIView.animate(withDuration: 0.3) {
                        self.label.alpha = 1
                    }
                }
                UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseInOut], animations: {
                    
                    self.view.setNeedsLayout()
                    self.heightConstraint.constant = 0
                    NSLayoutConstraint.activate([self.centerYConstraint])
                    //                self.claimButtonRatioConstraint.constant += 100
                    self.view.layoutIfNeeded()
                    self.claimButtonState = .Close
                }) {
                    _ in
                    //                print(self.claimButtonRatioConstraint.constant)
                    print(self.tableView.frame.height)
                    UIView.animate(withDuration: 0.1) {
                        sender.layer.cornerRadius = sender.frame.height / 2
                    }
                }
            default:
                showAlert(type: CustomAlertView.AlertType.Warning, buttons: [["Хорошо": [CustomAlertView.ButtonType.Ok: nil]]], text: "Выберите категорию")
            }
        } else {
            sender.accessibilityIdentifier = "Cancel"
            navigationController?.popViewController(animated: true)
        }
        delegate?.callbackReceived(sender)
    }
    fileprivate var selectedClaimID = 0 {
        didSet {
            if oldValue != selectedClaimID {
                //UI update
                UIView.animate(withDuration: 0.3) {
                    self.claimButton.backgroundColor = K_COLOR_RED
                }
                for cell in claimCells {
                    if cell.category.ID != selectedClaimID {
                        cell.isChecked = false
//                        let scaleAnim       = CABasicAnimation(keyPath: "transform.scale")
//                        scaleAnim.fromValue = 1.002
//                        scaleAnim.toValue   = 1
//                        scaleAnim.duration  = 0.15
//                        cell.label.layer.add(scaleAnim, forKey: nil)
                        UIView.animate(withDuration: 0.15) {
                            cell.descriptionLabel.transform = CGAffineTransform.identity
                        }
//                        UIView.transition(with: cell.label, duration: 0.15, options: .transitionCrossDissolve, animations: {
//                            cell.label.textColor = UIColor.gray
//                        })
                    }
                }
                claimButtonState = .PostClaim
            }
        }
    }
    fileprivate var claimCells: [ClaimCell]    = []
    var topConstraintConstant: CGFloat = 0
    weak var delegate: CallbackDelegate?
    
    deinit {
        print("deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self as UITableViewDelegate
        tableView.dataSource = self
        navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        navigationItem.setHidesBackButton(true, animated: false)
        claimButton.backgroundColor = K_COLOR_GRAY
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if !isViewSetupCompleted {
            topConstraint.constant = topConstraintConstant
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
            isViewSetupCompleted = true
            claimButton.layer.cornerRadius = claimButton.frame.height / 2
            isViewSetupCompleted = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        heightConstraint = NSLayoutConstraint(item: tableView, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: tableView, attribute: NSLayoutConstraint.Attribute.height, multiplier: 1, constant: 0)
        centerYConstraint = NSLayoutConstraint(item: label, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0)
//        claimButtonRatioConstraint = NSLayoutConstraint(item: claimButton, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: claimButton, attribute: NSLayoutConstraint.Attribute.height, multiplier: 1, constant: 0)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ClaimCategories.shared.container.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "claim", for: indexPath) as? ClaimCell {
            cell.setNeedsLayout()
            cell.layoutIfNeeded()
//            cell.dot.layer.cornerRadius = cell.dot.frame.width/2
//            cell.dot.backgroundColor = UIColor(red: 1.000, green: 0.538, blue: 0.000, alpha: 1.000)
            cell.category = ClaimCategories.shared.container[indexPath.row]
            if !claimCells.contains(cell) {
                claimCells.append(cell)
            }
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? ClaimCell {
            //            delegate?.signalReceived(claim)
            cell.isChecked = true
            let scaleAnim       = CABasicAnimation(keyPath: "transform.scale")
            scaleAnim.fromValue = 1
            scaleAnim.toValue   = 1.002
            scaleAnim.duration  = 0.15
            cell.descriptionLabel.layer.add(scaleAnim, forKey: nil)
            cell.descriptionLabel.layer.transform = CATransform3DMakeScale(1.002, 1.002, 1.002)
//            UIView.transition(with: cell.label, duration: 0.15, options: .transitionCrossDissolve, animations: {
//                cell.label.textColor = UIColor.black
//            })
            //Uncheck others
            selectedClaimID = cell.category.ID
        }
    }
}

class ClaimCell: UITableViewCell {
    @IBOutlet weak var checkBox: CheckBox!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var isChecked = false {
        didSet {
            if oldValue != isChecked, checkBox != nil {
                checkBox.isOn = isChecked
            }
        }
    }
//    @IBOutlet weak var dot: UIView!
    var category: ClaimCategory! {
        didSet {
            descriptionLabel.text = category.description
        }
    }
}
