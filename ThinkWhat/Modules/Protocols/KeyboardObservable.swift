//
//  KeyboardObservable.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 19.02.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

protocol KeyboardObservable {
    var textFields: [UITextField] { get set }
    
    func subscribeForKeyboardNotifications()
    func keyboardWillShow(_ notification: Notification)
    func keyboardWillHide(_ notification: Notification)
}

protocol KeyboardScrollable: KeyboardObservable, UIScrollViewDelegate {
    var keyboardHeight: CGFloat { get set }
    var scrollView: UIScrollView { get }
    var activeTextField: UITextField? { get set }
    
    func onTextFieldActivated(_: UITextField)
    func findFirstResponder() -> UITextField?
    func setScreenInsets(zero: Bool)
}
