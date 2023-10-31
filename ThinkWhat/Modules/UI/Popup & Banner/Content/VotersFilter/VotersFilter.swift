//
//  VotersFilter.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 20.04.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import TTRangeSlider

class VotersFilter: UIView {
    
    deinit {
        print("VotersFilter deinit")
    }
    
    init(imageContent _imageContent: UIView, color _color: UIColor, callbackDelegate _callbackDelegate: CallbackObservable, voters: [Userprofile]?, filters: [String : AnyObject]?) {
        self.callbackDelegate = _callbackDelegate
        self.imageContent = _imageContent
        self.color = _color
        super.init(frame: CGRect.zero)
        self.voters = voters
        self.filters = filters
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Initialization
    private func commonInit() {
        guard let contentView = self.fromNib() else { fatalError("View could not load from nib") }
        backgroundColor = .clear
        bounds = UIScreen.main.bounds
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        addSubview(contentView)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        btn.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
        rangeSlider.handleColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
        rangeSlider.tintColorBetweenHandles = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color.withAlphaComponent(0.6)
        genderControl.selectedSegmentTintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
        guard let imageView = imageContainer.subviews.filter({$0 is UIImageView}).first as? UIImageView else { return }
        imageView.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
    }
    
    private func setupUI() {
        if rangeSlider != nil {
            if let sorted = voters!.sorted(by: { $0.age < $1.age }) as? [Userprofile], let minValue = sorted.first as? Userprofile, let maxValue = sorted.last as? Userprofile {
                minAge = minValue.age
                maxAge = maxValue.age
            }
            if !filters.isNil, let lowerAge = filters!["lowerAge"] as? Int, let upperAge = filters!["upperAge"] as? Int {
                rangeSlider.selectedMinimum = Float(lowerAge)
                rangeSlider.selectedMaximum = Float(upperAge)
                rangeSlider.minValue = Float(minAge)
                rangeSlider.maxValue = Float(maxAge)
                lowerAgeLabel.text = "\(lowerAge)"
                upperAgeLabel.text = "\(upperAge)"
              if let _gender = filters!["gender"] as? Enums.User.Gender {
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
            } else {
                rangeSlider.minValue = Float(minAge)
                rangeSlider.maxValue = Float(maxAge)
                lowerAgeLabel.text = "\(minAge)"
                upperAgeLabel.text = "\(maxAge)"
            }
            fetchData()
        }
    }
        
    private func fetchData() {
        guard voters != nil, rangeSlider != nil else { return }
        var _filtered: [Userprofile] = []
        if gender != .Unassigned {
            _filtered = voters!.filter({ $0.age >= Int(rangeSlider.selectedMinimum)}).filter({$0.age <= Int(rangeSlider.selectedMaximum)}).filter({$0.gender == gender})
        } else {
            _filtered = voters!.filter({Int(rangeSlider.selectedMinimum)...Int(rangeSlider.selectedMaximum) ~= $0.age})
        }
        filtered = _filtered
        guard let count = filtered?.count else { return }
        UIView.performWithoutAnimation {
            self.btn.setTitle( "show".localized.uppercased() + " \(count)", for: .normal)
            self.btn.layoutIfNeeded()
        }
    }
    
    public func getData() -> [String: AnyObject] {
        var dict:[String: AnyObject] = [:]
        dict["filters"] = filters as AnyObject
        dict["filtered"] = filtered as AnyObject
        return dict
    }
    
    // MARK: - IB Outlets
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var imageContainer: UIView! {
        didSet {
            imageContent.addEquallyTo(to: imageContainer)
            imageContent.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
        }
    }
    
    @IBOutlet weak var clearBtn: UIButton! {
        didSet {
            clearBtn.setTitle("reset".localized.uppercased(), for: .normal)
        }
    }
    @IBAction func clearBtnTapped(_ sender: UIButton) {
        gender = .Unassigned
        rangeSlider.selectedMinimum = Float(minAge)
        rangeSlider.selectedMaximum = Float(maxAge)
    }
    
    @IBOutlet weak var btn: UIButton! {
        didSet {
            btn.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
            btn.setTitle("results".localized.uppercased(), for: .normal)
        }
    }
    @IBAction func btnTapped(_ sender: UIButton) {
        callbackDelegate?.callbackReceived(self)
    }
    @IBOutlet weak var genderControl: UISegmentedControl! {
        didSet {
            genderControl.selectedSegmentIndex = 2
            genderControl.selectedSegmentTintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
//            genderControl.setTitleTextAttributes(, for: .selected)
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
            rangeSlider.handleColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
            rangeSlider.tintColorBetweenHandles = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color.withAlphaComponent(0.6)
            rangeSlider.lineBorderWidth = 16
            rangeSlider.lineHeight = 2
            rangeSlider.lineBorderColor = .lightGray
            rangeSlider.handleDiameter = 24
            rangeSlider.selectedHandleDiameterMultiplier = 1.3
        }
    }
    @IBAction func rangeSliderChanged(_ sender: TTRangeSlider) {
//        guard isViewSetupComplete else { return }
        if lowerAgeLabel != nil, upperAgeLabel != nil {
            lowerAgeLabel.text = "\(Int(sender.selectedMinimum))"
            upperAgeLabel.text = "\(Int(sender.selectedMaximum))"
        }
        filters!["lowerAge"] = Int(sender.selectedMinimum) as AnyObject
        filters!["upperAge"] = Int(sender.selectedMaximum) as AnyObject
        fetchData()
    }
    
    override var frame: CGRect {
        didSet {
            guard !btn.isNil else { return }
            btn.cornerRadius = btn.frame.height / 2.25
            setupUI()
        }
    }
    override var bounds: CGRect {
        didSet {
            guard !btn.isNil else { return }
            btn.cornerRadius = btn.frame.height / 2.25
            setupUI()
        }
    }
    private let imageContent: UIView
    private weak var callbackDelegate: CallbackObservable?
    private let color: UIColor
    private var filters: [String: AnyObject]? = [:]
    private var voters: [Userprofile]? = []
    private var filtered: [Userprofile]? = []
    private var minAge = 18
    private var maxAge = 99
  private var gender: Enums.User.Gender = .Unassigned {
        didSet {
            if oldValue != gender {
                filters!["gender"] = gender as AnyObject
                switch gender {
                case .Male:
                    genderControl.selectedSegmentIndex = 0
//                    filters!["gender"] = gender as AnyObject
                case .Female:
                    genderControl.selectedSegmentIndex = 1
                    
                default:
                    genderControl.selectedSegmentIndex = 2
                }
                fetchData()
            }
        }
    }
}
