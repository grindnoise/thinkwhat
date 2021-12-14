//
//  UsersCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 10.11.2021.
//  Copyright © 2021 Pavel Bukharov. All rights reserved.
//

import UIKit

class UserCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var ageLabel: UILabel! {
        didSet {
            ageLabel.text = ", \(age)"
        }
    }
//    @IBOutlet weak var genderLabel: UILabel! {
//        didSet {
//            genderLabel.text = gender == .Male ? "мужчина" : "женщина"
//        }
//    }
    @IBOutlet weak var genderIcon: Icon! {
        didSet {
//            genderIcon.scaleMultiplicator = 0.8
            genderIcon.isRounded = false
            genderIcon.layer.masksToBounds = false
            genderIcon.backgroundColor = .clear
            genderIcon.iconColor = gender == .Male ? "06bac3".hexColor! : "f388a3".hexColor!//UIColor.red).withAlphaComponent(0.6)
            genderIcon.category = gender == .Male ? .MaleSign : .FemaleSign
//            genderIcon.layer.masksToBounds = false
//            genderIcon.clipsToBounds = false
            genderIcon.scaleMultiplicator = 1
        }
    }
    var age = 0 {
        didSet {
            if ageLabel != nil {
                ageLabel.text = ", \(age)"
            }
        }
    }
    var gender: Gender = .Male {
        didSet {
            if genderIcon != nil {
//            if genderLabel != nil, genderIcon != nil {
                genderIcon.isRounded = false
                genderIcon.iconColor = gender == .Male ? "06bac3".hexColor! : "f388a3".hexColor!//(gender == .Male ? UIColor.blue : UIColor.red).withAlphaComponent(0.6)
                genderIcon.category = gender == .Male ? .MaleSign : .FemaleSign
                genderIcon.scaleMultiplicator = 1
//                genderIcon.layer.masksToBounds = false
//                genderIcon.clipsToBounds = false
//                genderLabel.text = gender == .Male ? "мужчина" : "женщина"
            }
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
    }

}


