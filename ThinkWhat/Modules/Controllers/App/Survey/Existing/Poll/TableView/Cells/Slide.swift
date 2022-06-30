//
//  Slide.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 19.03.2020.
//  Copyright © 2020 Pavel Bukharov. All rights reserved.
//

import UIKit

class Slide: UIView {
    
    deinit {
        print("Slide deinit")
    }
    
    @IBOutlet weak var imageView: CircularIndicatorImageView!
    
    var title = ""
    var color = K_COLOR_RED {
        didSet {
            guard !imageView.isNil else { return }
            imageView.color = color
        }
    }
}
