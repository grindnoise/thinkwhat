//
//  ImageHeaderCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 18.12.2019.
//  Copyright © 2019 Pavel Bukharov. All rights reserved.
//

import UIKit

class ImageHeaderCell: UITableViewCell {

    var delegate: CellButtonDelegate?
    @IBOutlet weak var cameraIcon: CameraIcon! {
        didSet {
            let touch = UITapGestureRecognizer(target:self, action:#selector(ImageHeaderCell.addImage))
            touch.cancelsTouchesInView = false
            cameraIcon.addGestureRecognizer(touch)
        }
    }
    @IBOutlet weak var galleryIcon: GalleryIcon! {
        didSet {
            let touch = UITapGestureRecognizer(target:self, action:#selector(ImageHeaderCell.addImage))
            touch.cancelsTouchesInView = false
            galleryIcon.addGestureRecognizer(touch)
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
    
    @objc fileprivate func addImage(recognizer: UITapGestureRecognizer) {
        if recognizer.state == .ended, recognizer.view != nil {
            delegate?.cellSubviewTapped(recognizer.view!)
        }
    }

}
