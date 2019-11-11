//
//  CategoryTableViewCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 24.10.2019.
//  Copyright © 2019 Pavel Bukharov. All rights reserved.
//

import UIKit

class CategoryTableViewCell: UITableViewCell {

//    var color: UIColor?
//    private let circlePathLayer = CAShapeLayer()
//    @IBOutlet weak var circleTag: UIView!
//    @IBOutlet weak var title: TagLabel!
    @IBOutlet weak var total: UILabel!
    @IBOutlet weak var active: UILabel!
    @IBOutlet weak var title: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        configure()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        circlePathLayer.frame = bounds
//        circlePathLayer.path = circlePath().cgPath
//        circlePathLayer.fillColor = color == nil ? UIColor.lightGray.cgColor : color!.cgColor
//    }
//
//    private func configure() {
//        circlePathLayer.frame = circleTag.bounds
//        circlePathLayer.fillColor = UIColor(red:1.00, green: 0.72, blue:0.22, alpha:1.0).cgColor//K_COLOR_RED.withAlphaComponent(0.5).cgColor
//        layer.addSublayer(circlePathLayer)
//    }
//
//    private func circlePath() -> UIBezierPath {
//        let radius = circleTag.frame.size.height / 4
//        let path = UIBezierPath(arcCenter: circleTag.center, radius: radius, startAngle: CGFloat(-Double.pi/2), endAngle: CGFloat(3*Double.pi/2), clockwise: true)
//        return path
//    }
}
