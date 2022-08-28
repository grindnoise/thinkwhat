//
//  Shimmer.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 20.08.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class Shimmer: UIView {
    // MARK: - Private methods
    private lazy var subscriptions = Set<AnyCancellable>()
    private lazy var gradient: CAGradientLayer = {
        let light = UIColor.tertiarySystemBackground.cgColor//UIColor(red: 0, green: 0, blue: 0, alpha: 0.1).cgColor
        let dark = UIColor.secondarySystemBackground.cgColor//UIColor.black.cgColor

        let instance = CAGradientLayer()
        instance.colors = [dark, light, dark]
        instance.startPoint = CGPoint(x: 0.0, y: 0.5)
        instance.endPoint = CGPoint(x: 1.0, y: 0.5)
        instance.locations = [0.4, 0.55, 0.7]
        instance.zPosition = 100//.greatestFiniteMagnitude
        layer.addSublayer(instance)
        
        return instance
    }()
    private var isShimmering = false {
        didSet {
            if isShimmering {
                let animation: CABasicAnimation = CABasicAnimation(keyPath: "locations")
                animation.fromValue = [0.0, 0.1, 0.2]
                animation.toValue = [0.8, 0.9, 1.0]
                animation.isRemovedOnCompletion = false
                animation.duration = 1.5
                animation.repeatCount = 100//.greatestFiniteMagnitude
                gradient.add(animation, forKey: "shimmering")
            } else {
                gradient.removeAllAnimations()
                gradient.removeFromSuperlayer()
            }
        }
    }
    
    // MARK: - Destructor
    deinit {
        subscriptions.forEach { $0.cancel() }
#if DEBUG
        print("\(String(describing: type(of: self))).\(#function)")
#endif
    }
    
    public func startShimmering(lightColor: UIColor? = nil, darkColor: UIColor? = nil) {
        if let lightColor = lightColor, let darkColor = darkColor {
            gradient.colors = [darkColor, lightColor, darkColor]
        }
        
        isShimmering = true
        
        publisher(for: \.bounds, options: .new)
            .sink { [weak self] in
                guard let self = self else { return }
                
                self.gradient.frame = CGRect(x: -$0.size.width, y: 0, width: 3*$0.size.width, height: $0.height)
            }
            .store(in: &subscriptions)
    }

    func stopShimmering() {
        isShimmering = false
        subscriptions.forEach { $0.cancel() }
    }
    
    // MARK: - Overriden methods
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        
    }
}
