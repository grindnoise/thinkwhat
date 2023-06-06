//
//  SurveyPreview.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 30.04.2020.
//  Copyright © 2020 Pavel Bukharov. All rights reserved.
//

import UIKit

class SurveyPreview: UIView {
    
    deinit {
        print("SurveyPreview deinit")
    }

    var survey: Survey! 
    weak fileprivate var delegate: CallbackObservable?
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var userImage: UIImageView! {
        didSet {
            let touch = UITapGestureRecognizer(target:self, action:#selector(self.callback(recognizer:)))
            touch.cancelsTouchesInView = false
            userImage.addGestureRecognizer(touch)
        }
    }
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var icon: Icon!
    @IBOutlet weak var category: UILabel!
    @IBOutlet weak var parentCategory: UILabel!
//    @IBOutlet weak var surveyDate: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var voteButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        if sender.tag ==  0 {
            sender.accessibilityIdentifier = "Vote"
        } else {
            sender.accessibilityIdentifier = "Reject"
        }
        delegate?.callbackReceived(sender as AnyObject)
    }
    init(frame: CGRect, survey _survey: Survey, delegate _delegate: CallbackObservable) {
        survey = _survey
        delegate = _delegate
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    private func commonInit() {
        
        Bundle.main.loadNibNamed("SurveyPreview", owner: self, options: nil)
        guard let content = contentView else {
            return
        }
        
        content.frame = self.bounds
        content.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        //content.backgroundColor = UIColor.lightGray.withAlphaComponent(0.09)
        self.addSubview(content)
        titleLabel.text = survey.title
        descriptionLabel.text = "   \(survey.detailsDescription)"
//        surveyDate.text = survey.startDate.toDateString()//.toDateTimeStringWithoutSeconds()
        
    }
    
    @objc fileprivate func callback(recognizer: UITapGestureRecognizer) {
        if recognizer.state == .ended {
//            _view.setValue("", forKey: "userProfile")
//            _view.setValue("123", forUndefinedKey: "test")
            delegate?.callbackReceived(survey.owner as AnyObject)
        }
    }
}
