//
//  ImageSelectionCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 18.12.2019.
//  Copyright © 2019 Pavel Bukharov. All rights reserved.
//

import UIKit

class ImageSelectionCell: UITableViewCell {
    var indexPath: IndexPath!
    var delegate: CallbackDelegate?
    @IBOutlet weak var pictureView: UIImageView! {
        didSet {
            pictureView.layer.cornerRadius = pictureView.frame.height / 2
        }
    }
    @IBOutlet weak var trashIcon: TrashIcon! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(ImageSelectionCell.somethingTapped(recognizer:)))
            trashIcon.addGestureRecognizer(tap)
        }
    }
    @IBOutlet weak var textField: UITextField!

    @objc private func somethingTapped(recognizer: UITapGestureRecognizer) {
        if recognizer.state == .ended, let v = recognizer.view {
            delegate?.callbackReceived(self)
        }
    }
}
