//
//  VotersFilterController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 25.11.2021.
//  Copyright © 2021 Pavel Bukharov. All rights reserved.
//

import UIKit
import TTRangeSlider

class VotersFilterController: UITableViewController {
    deinit {
        print("---\(self) deinit()")
    }
    var filters: [String: AnyObject]? = [:]
    var voters: [Userprofile]? = []
    var filtered: [Userprofile]? = []
    private var minAge = 18
    private var maxAge = 99
    var gender: Gender = .Unassigned {
        didSet {
            if oldValue != gender {
                switch gender {
                case .Male:
                    genderControl.selectedSegmentIndex = 0
                    filters!["gender"] = gender as AnyObject
                case .Female:
                    genderControl.selectedSegmentIndex = 1
                    filters!["gender"] = gender as AnyObject
                default:
                    genderControl.selectedSegmentIndex = 2
                }
                fetchData()
            }
        }
    }
    private var isViewSetupComplete = false
    @IBOutlet weak var genderControl: UISegmentedControl! {
        didSet {
            genderControl.selectedSegmentIndex = 2
            genderControl.tintColor = K_COLOR_RED
        }
    }
    @IBAction func genderChanged(_ sender: UISegmentedControl) {
        switch genderControl.selectedSegmentIndex {
        case 0:
            gender = .Male
        case 1:
            gender = .Female
        default:
            gender = .Unassigned
        }
    }
    @IBOutlet weak var lowerAgeLabel: UILabel! {
        didSet {
            lowerAgeLabel.text = "\(minAge)"
        }
    }
    @IBOutlet weak var upperAgeLabel: UILabel! {
        didSet {
            upperAgeLabel.text = "\(maxAge)"
        }
    }
    @IBOutlet weak var rangeSlider: TTRangeSlider! {
        didSet {
            rangeSlider.hideLabels = true
            rangeSlider.handleColor = K_COLOR_RED
            rangeSlider.tintColorBetweenHandles = K_COLOR_RED.withAlphaComponent(0.6)
            rangeSlider.lineBorderWidth = 16
            rangeSlider.lineHeight = 2
            rangeSlider.lineBorderColor = .lightGray
            rangeSlider.handleDiameter = 24
            rangeSlider.selectedHandleDiameterMultiplier = 1.3
        }
    }
    @IBAction func rangeSliderChanged(_ sender: TTRangeSlider) {
        guard isViewSetupComplete else { return }
        if lowerAgeLabel != nil, upperAgeLabel != nil {
            lowerAgeLabel.text = "\(Int(sender.selectedMinimum))"
            upperAgeLabel.text = "\(Int(sender.selectedMaximum))"
        }
        filters!["lowerAge"] = Int(sender.selectedMinimum) as AnyObject
        filters!["upperAge"] = Int(sender.selectedMaximum) as AnyObject
        fetchData()
//        lowerAge = Int(sender.selectedMinimum)
//        upperAge = Int(sender.selectedMaximum)
    }
    @IBAction func clearTapped(_ sender: Any) {
        isViewSetupComplete = false
        rangeSlider.selectedMinimum = Float(minAge)
        rangeSlider.selectedMaximum = Float(maxAge)
        gender = .Unassigned
        isViewSetupComplete = true
        filters?.removeAll()
        fetchData()
    }
    
//    var rangeSlider: RangeSlider!
    weak var delegate: CallbackDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate      = self
        tableView.dataSource    = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupUI()
    }
    
    private func setupUI() {
        if rangeSlider != nil {
            if let sorted = voters!.sorted(by: { $0.age < $1.age }) as? [Userprofile], let minValue = sorted.first as? Userprofile, let maxValue = sorted.last as? Userprofile {
                minAge = minValue.age
                maxAge = maxValue.age
                rangeSlider.minValue = Float(minAge)
                rangeSlider.maxValue = Float(maxAge)
                lowerAgeLabel.text = "\(minAge)"
                upperAgeLabel.text = "\(maxAge)"
            }
            if filters != nil, let lowerAge = filters!["lowerAge"] as? Int, let upperAge = filters!["upperAge"] as? Int {
                rangeSlider.selectedMinimum = Float(lowerAge)
                rangeSlider.selectedMaximum = Float(upperAge)
                lowerAgeLabel.text = "\(lowerAge)"
                upperAgeLabel.text = "\(upperAge)"
                if let _gender = filters!["gender"] as? Gender {
                    gender = _gender
                    switch _gender {
                    case .Male:
                        genderControl.selectedSegmentIndex = 0
                    case .Female:
                        genderControl.selectedSegmentIndex = 1
                    default:
                        genderControl.selectedSegmentIndex = 2
                    }
                }
            }
            isViewSetupComplete = true
            fetchData()
        }
    }
    
    private func callback() {
        
        var dict:[String: AnyObject] = [:]
        dict["filters"] = filters as AnyObject
        dict["filtered"] = filtered as AnyObject
//        dict["filtered"] = filtered as AnyObject
//        delegate?.callbackReceived(filtered.count as AnyObject)
        delegate?.callbackReceived(dict as AnyObject)
    }
    
    private func fetchData() {
        guard isViewSetupComplete, voters != nil, rangeSlider != nil else { return }
        var _filtered: [Userprofile] = []
        if gender != .Unassigned {
            _filtered = voters!.filter({ $0.age >= Int(rangeSlider.selectedMinimum)}).filter({$0.age <= Int(rangeSlider.selectedMaximum)}).filter({$0.gender == gender})
        } else {
            _filtered = voters!.filter({ $0.age >= Int(rangeSlider.selectedMinimum)}).filter({$0.age <= Int(rangeSlider.selectedMaximum)})
        }
        filtered = _filtered
        callback()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 2 {
            return 40
        }
        return tableView.frame.size.height / CGFloat(2) - 20
    }
}
