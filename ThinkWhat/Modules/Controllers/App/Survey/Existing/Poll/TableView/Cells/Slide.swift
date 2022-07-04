//
//  Slide.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 19.03.2020.
//  Copyright © 2020 Pavel Bukharov. All rights reserved.
//

import UIKit

class Slide: UIView {
   
    // MARK: - Private Properties
    private var observers: [NSKeyValueObservation] = []
    private var titleLabel: InsetLabel?
    
    // MARK: - Public properties
    public var title = ""
    public var color = K_COLOR_RED {
        didSet {
            guard !imageView.isNil else { return }
            imageView.color = color
        }
    }
    public var mediafile: Mediafile?
    
    
    deinit {
        print("Slide deinit")
    }
    
    // MARK: - IB
    @IBOutlet weak var imageView: CircularIndicatorImageView!
    
    // MARK: - Private Properties
    private func setObservers() {
        guard !titleLabel.isNil else { return }
        observers.append(titleLabel!.observe(\InsetLabel.bounds, options: .new) { view, change in
            guard let newValue = change.newValue else { return }
            view.cornerRadius = newValue.height * 0.25
            view.insets = UIEdgeInsets(top: view.insets.top, left: view.cornerRadius, bottom: view.insets.top, right: view.cornerRadius)
            view.font = UIFont(name: Fonts.Regular, size: newValue.height * 0.5)
        })
    }
    
    // MARK: - Private Properties
    public func showTitle() {
        guard !mediafile.isNil, !imageView.isNil else { return }
        titleLabel = InsetLabel()
        setObservers()
        titleLabel?.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        titleLabel?.alpha = 0
        titleLabel?.textColor = .white
        titleLabel?.text = mediafile?.title
        imageView.addSubview(titleLabel!)
        titleLabel!.translatesAutoresizingMaskIntoConstraints = false
        titleLabel?.numberOfLines = 0
        NSLayoutConstraint.activate([
            titleLabel!.leadingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: 16),
            titleLabel!.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -16),
            titleLabel!.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -16),
            titleLabel!.heightAnchor.constraint(equalTo: titleLabel!.widthAnchor, multiplier: 1/8.0),
        ])
        titleLabel!.backgroundColor = .black.withAlphaComponent(0.8)
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.2, delay: 0) {
            guard let label = self.titleLabel else { return }
            label.alpha = 1
            label.transform = .identity
        }
    }
}
