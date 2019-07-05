//
//  ParentLoginBi.swift
//  SpamGuard
//
//  Created by Pavel Bukharov on 24.12.2018.
//  Copyright © 2018 Pavel Bukharov. All rights reserved.
//

import UIKit

@IBDesignable
class ParentLoginButton: UIView, AnimationsRemover {
    
    public enum State {
        case enabled, disabled
    }
    
    var state: State = .disabled
    var authVariant: AuthVariant!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //setup()
    }
    
    func removeAllAnimations() {
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        //fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
        //setup()
    }
    
}

protocol AnimationsRemover {
    func removeAllAnimations()
}
