//
//  HotCard.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 23.05.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

protocol HotCard: class {
    var callbackDelegate: CallbackObservable? { get set }
    var survey: Survey! { get set }
    var background: UIView! { get set }
    var voteButton: UIButton! { get set }
    var nextButton: UIButton! { get set }
}
