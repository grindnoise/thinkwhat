//
//  CircularIndicatorImageView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 23.03.2020.
//  Copyright © 2020 Pavel Bukharov. All rights reserved.
//

import UIKit

class CircularIndicatorImageView: UIImageView {
    
  public var color: UIColor = Constants.UI.Colors.main {
        didSet {
            progressIndicatorView.color = color
            layer.backgroundColor = traitCollection.userInterfaceStyle == .dark ? UIColor.secondarySystemBackground.cgColor : color.withAlphaComponent(0.2).cgColor
        }
    }
    
    public var progressIndicatorView: CameraLoadingIndicator!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        progressIndicatorView = CameraLoadingIndicator(color: color)
        layer.backgroundColor = traitCollection.userInterfaceStyle == .dark ? UIColor.secondarySystemBackground.cgColor : color.withAlphaComponent(0.1).cgColor
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
