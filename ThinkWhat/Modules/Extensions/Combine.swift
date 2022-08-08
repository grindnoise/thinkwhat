//
//  Combine.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 05.08.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import Combine
import UIKit

final class ColorSubscriber: Subscriber {
    
    typealias Failure = Never
    typealias Input = UIColor
    
    func receive(subscription: Subscription) {
        subscription.request(.none)
    }
    
    func receive(_ input: UIColor) -> Subscribers.Demand {
        print("Received value", input)
        return .none
    }
    
    func receive(completion: Subscribers.Completion<Never>) {
        print("Received completion", completion)
    }
    
}
