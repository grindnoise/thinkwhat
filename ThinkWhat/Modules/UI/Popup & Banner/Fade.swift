//
//  Fade.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 11.08.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class Fade: UIView {
    
    static let shared = Fade()
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        self.frame = UIScreen.main.bounds
        self.alpha = 0
        self.isUserInteractionEnabled = false
    }
    
    // MARK: - Destructor
    deinit {
#if DEBUG
        print("\(String(describing: type(of: self))).\(#function)")
#endif
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func present(duration: TimeInterval = 0.25) {
        
        appDelegate.window?.addSubview(self)
        
        UIView.animate(withDuration: duration, delay: 0, options: [.curveEaseInOut], animations: {
            self.alpha = 1
        })
    }
    
    func dismiss(duration: TimeInterval = 0.25) {
        UIView.animate(withDuration: duration, delay: 0, options: [.curveEaseInOut], animations: {
            self.alpha = 0
        })
    }
}
