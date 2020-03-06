//
//  ParentLoginBi.swift
//  SpamGuard
//
//  Created by Pavel Bukharov on 24.12.2018.
//  Copyright © 2018 Pavel Bukharov. All rights reserved.
//

import UIKit

class LoginButton: StateButton {
    
    var authVariant: AuthVariant!
}

class StateButton: UIView, AnimationsRemover, StateSwitchable {
    
    var state: State = .enabled
    
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

protocol StateSwitchable {
    var state: State { get set }
}

protocol AnimationsRemover {
    func removeAllAnimations()
}
