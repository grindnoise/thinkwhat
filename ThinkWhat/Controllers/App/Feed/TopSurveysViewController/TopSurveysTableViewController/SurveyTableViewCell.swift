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
    @IBOutlet weak var tags: UIView!
    @IBOutlet weak var completionPercentage: ProgressCirle!
    @IBOutlet weak var duration: UILabel!
    
    var survey: SurveyLink?
    
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
