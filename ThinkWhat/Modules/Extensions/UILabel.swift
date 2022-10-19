//
//  UILabel.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 12.04.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit


extension UILabel {
    //Typewriter effect text animation
    func setTextWithTypeAnimation(typedText: String, characterDelay: TimeInterval = 5.0) {
        text = ""
        var writingTask: DispatchWorkItem?
        writingTask = DispatchWorkItem { [weak weakSelf = self] in
            for character in typedText {
                DispatchQueue.main.async {
                    weakSelf?.text!.append(character)
                }
                Thread.sleep(forTimeInterval: characterDelay/100)
            }
        }
        
        if let task = writingTask {
            let queue = DispatchQueue(label: "typespeed", qos: DispatchQoS.userInteractive)
            queue.asyncAfter(deadline: .now() + 0.05, execute: task)
        }
    }
    
    var numberOfTotatLines: Int {
        let maxSize = CGSize(width: frame.size.width, height: CGFloat(MAXFLOAT))
        let text = (self.text ?? "") as NSString
        let textHeight = text.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil).height
        let lineHeight = font.lineHeight
        return Int(ceil(textHeight / lineHeight))
    }
    
    var numberOfVisibleLines: Int {
        let maxSize = CGSize(width: frame.size.width, height: CGFloat(MAXFLOAT))
        let textHeight = sizeThatFits(maxSize).height
        let lineHeight = font.lineHeight
        return Int(ceil(textHeight / lineHeight))
    }
    
    func updateWidthConstraint(priority: UILayoutPriority = .required, height: CGFloat = CGFloat.greatestFiniteMagnitude) {
        guard let text = self.text,
              let font = self.font
        else { return }
        
        let constraint = self.getConstraint(identifier: "width") ?? {
            let instance = self.widthAnchor.constraint(equalToConstant: 0)
            instance.identifier = "width"
            instance.priority = priority
            instance.isActive = true
            
            return instance
        }()
        
        constraint.constant = text.width(withConstrainedHeight: height, font: font)
    }
    
    func updateHeightConstraint(priority: UILayoutPriority = .required, width: CGFloat = CGFloat.greatestFiniteMagnitude) {
        guard let text = self.text,
              let font = self.font
        else { return }
        
        let constraint = self.getConstraint(identifier: "height") ?? {
            let instance = self.heightAnchor.constraint(equalToConstant: 0)
            instance.identifier = "height"
            instance.priority = priority
            instance.isActive = true
            
            return instance
        }()
        
        constraint.constant = text.height(withConstrainedWidth: width, font: font)
    }
    
    func setConstraints(priority: UILayoutPriority = .required) {
        self.updateHeightConstraint(priority: priority)
        self.updateHeightConstraint(priority: priority)
    }
}

