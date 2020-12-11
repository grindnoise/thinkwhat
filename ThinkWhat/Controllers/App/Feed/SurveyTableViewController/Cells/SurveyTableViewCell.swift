//
//  SurveyTableViewCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 21.10.2019.
//  Copyright © 2019 Pavel Bukharov. All rights reserved.
//

import UIKit

class SurveyTableViewCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
//    @IBOutlet weak var tags: UIView!
//    @IBOutlet weak var completionPercentage: ProgressCirle!
    @IBOutlet weak var join: UIView!
    @IBOutlet weak var icon: SurveyCategoryIcon! {
        didSet {
            print("icon didSet")
        }
    }
    @IBOutlet weak var join_2: UIView!
    //    @IBOutlet weak var icon: UIView!// {
//        didSet {
//            if icon.subviews.isEmpty, survey != nil, let _icon = survey.category!.icon {
//                _icon.isOpaque = false
//                _icon.addEquallyTo(to: icon)
//            } else {
//                if survey != nil, let _icon = survey.category!.icon {
//                    _icon.isOpaque = false
//                    _icon.addEquallyTo(to: icon)
//                }
//            }
//        }
//    }
    @IBOutlet weak var category: UILabel!
//    @IBOutlet weak var subCategory: UILabel!
    @IBOutlet weak var duration: UILabel!
    @IBOutlet weak var hotBadge: FlameBadge!
    var survey: ShortSurvey! {
        didSet {
            icon.tagColor = survey.category?.parent?.tagColor
            icon.categoryID = SurveyCategoryIcon.CategoryID(rawValue: survey.category!.ID) ?? .Null
            hotBadge.alpha = Surveys.shared.stackObjects.filter({ $0.ID == survey.ID }).isEmpty ? 0 : 1
        }
    }// {
//        didSet {
//            if icon != nil {
//                if icon.subviews.isEmpty, survey != nil, let _icon = survey.category!.icon {
//                    _icon.isOpaque = false
//                    _icon.addEquallyTo(to: icon)
//                } else {
//                    if survey != nil, let _icon = survey.category!.icon {
//                        _icon.isOpaque = false
//                        _icon.addEquallyTo(to: icon)
//                    }
//                }
//            }
////            if title != nil, icon != nil, category != nil, subCategory != nil {
////                title.text = survey.title
////                survey.category!.icon.isOpaque = false
////                survey.category!.icon.addEquallyTo(to: icon)
////                subCategory.text = survey.category!.title
////                category.text = survey.category!.parent!.title
////            }
//        }
//    }
    
//    var surveyLink: SurveyLink?
    
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func prepareForReuse() {
        print("")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    deinit {
        print("deinit \(self)")
    }
}
