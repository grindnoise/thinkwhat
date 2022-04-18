//
//  DataCleanOnTerminateObservable.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 13.04.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import Foundation

protocol AppTerminateObservable {
    
    func subscribeAppTerminateObservable()
    
    /**
     Class-defined implementation.
     */
    func onAppTerminated()
}
