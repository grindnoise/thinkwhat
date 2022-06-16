//
//  ChoiceProvider.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 10.06.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

struct ChoiceItem: Hashable {
    var index: Int = 0
    var text: String
    var shouldBeDeleted = false
    let id: UUID = UUID()
}

protocol ChoiceProvider: class {
    var dataItems: [ChoiceItem] { get }
    var callbackDelegate: CallbackObservable? { get set }
    var listener: ChoiceListener! { get }
    
    func reload()
    func append(_: ChoiceItem)
}

protocol ChoiceListener: class {
    var choiceItems: [ChoiceItem] { get set }
    
    func onChoicesHeightChange(_: CGFloat)
    func deleteChoice(_: ChoiceItem)
    func editChoice(_: ChoiceItem)
}
