//
//  ImageSelectionCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 18.12.2019.
//  Copyright © 2019 Pavel Bukharov. All rights reserved.
//

import UIKit

class ImageSelectionCell: UITableViewCell {

    @IBOutlet weak var pictureView: UIImageView! {
        didSet {
            pictureView.layer.cornerRadius = pictureView.frame.height / 2
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
