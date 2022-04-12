//
//  CircularIndicatorImageView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 23.03.2020.
//  Copyright © 2020 Pavel Bukharov. All rights reserved.
//

import UIKit

class CircularIndicatorImageView: UIImageView {
    
    public var color: UIColor = K_COLOR_RED {
        didSet {
            progressIndicatorView.color = color
        }
    }
    
    let progressIndicatorView = CameraLoadingIndicator(frame: .zero)
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        layer.backgroundColor = UIColor.white.cgColor//UIColor(white: 1, alpha: 0.05).cgColor
        addSubview(progressIndicatorView)
        
        addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|[v]|", options: .init(),
            metrics: nil, views: ["v": progressIndicatorView]))
        addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:|[v]|", options: .init(),
            metrics: nil, views:  ["v": progressIndicatorView]))
        progressIndicatorView.translatesAutoresizingMaskIntoConstraints = false
    }
}
