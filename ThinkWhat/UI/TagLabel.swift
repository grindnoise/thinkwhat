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
    
    init(frame: CGRect, surveyCategory: SurveyCategory?) {
        self.surveyCategory = surveyCategory
        super.init(frame: frame)
        if surveyCategory?.parent == nil {
            self.text = surveyCategory?.title.uppercased()
        } else {
            self.text = surveyCategory?.title.lowercased()
        }
        self.commonInit()
    }
    
    func commonInit(){
        self.layer.cornerRadius = self.bounds.height/2
        var tagColor: UIColor = UIColor.lightGray
        if let color = surveyCategory?.tagColor {
            tagColor = color
        } else if let color = surveyCategory?.parent?.tagColor {
            tagColor = color
        }
        self.layer.backgroundColor = tagColor.cgColor
        self.clipsToBounds = true
        self.textColor = UIColor.white
        self.font = UIFont(name: "OpenSans-Semibold", size: 10)
        self.textAlignment = .center
        self.frame.size.width = self.intrinsicContentSize.width + 10
    }
    
    func setProperties(borderWidth: Float, borderColor: UIColor) {
        self.layer.borderWidth = CGFloat(borderWidth)
        self.layer.borderColor = borderColor.cgColor
    }
    
    deinit {
//        print("deinit Tag")
    }

}
