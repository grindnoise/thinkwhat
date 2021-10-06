//
//  NewSurveyTitle.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 01.06.2021.
//  Copyright © 2021 Pavel Bukharov. All rights reserved.
//

import UIKit

class NewSurveyTitle: UIView {
//    private var category: SurveyCategoryIcon.Category = .Null
//    private var color: UIColor = .clear
//    private var text: String = "String"
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var icon: Icon!
    @IBOutlet weak var label: UILabel!
    
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("NewSurveyTitle", owner: self, options: nil)
        guard let content = contentView else {
            return
        }
        content.frame = self.bounds
        content.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(content)
        setNeedsLayout()
        layoutIfNeeded()
        self.backgroundColor = .clear
    }
    
    init(size: CGSize, text: String, category: Icon.Category, color: UIColor = K_COLOR_RED) {
        super.init(frame: CGRect(origin: .zero, size: size))
        self.commonInit()
        icon.iconColor = color
        icon.category = category
        label.text = text
    }
}
