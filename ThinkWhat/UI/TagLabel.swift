//
//  TagLabel.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 22.10.2019.
//  Copyright © 2019 Pavel Bukharov. All rights reserved.
//

import UIKit

class TagLabel: UILabel {

    public var surveyCategory: SurveyCategory?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
//        self.commonInit()
        
    }
    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        self.commonInit()
//    }
    
    init(frame: CGRect, surveyCategory: SurveyCategory) {
        self.surveyCategory = surveyCategory
        super.init(frame: frame)
        self.text = surveyCategory.title
        self.commonInit()
    }
    
    func commonInit(){
        self.layer.cornerRadius = self.bounds.height/2
        self.layer.backgroundColor = UIColor(red: 0.624, green: 0.525, blue: 0.686, alpha: 1.000).cgColor
        self.clipsToBounds = true
        self.textColor = UIColor.white
        self.font = UIFont(name: "OpenSans-Semibold", size: 11)
        self.textAlignment = .center
        self.frame.size.width = self.intrinsicContentSize.width + 10
    }
    
    func setProperties(borderWidth: Float, borderColor: UIColor) {
        self.layer.borderWidth = CGFloat(borderWidth)
        self.layer.borderColor = borderColor.cgColor
    }

}
