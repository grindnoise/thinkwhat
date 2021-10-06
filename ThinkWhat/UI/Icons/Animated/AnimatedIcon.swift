//
//  Icon.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 21.11.2019.
//  Copyright © 2019 Pavel Bukharov. All rights reserved.
//

import UIKit

@IBDesignable
class AnimatedIcon: UIView, AnimationsRemover {
    
    enum State {
        case enabled, disabled
    }
    
    var state: State = .disabled
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //setup()
    }
    
    func removeAllAnimations() {
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
