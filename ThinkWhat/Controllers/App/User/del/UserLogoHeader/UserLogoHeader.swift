//
//  UserLogoHeader.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 21.07.2020.
//  Copyright © 2020 Pavel Bukharov. All rights reserved.
//

import UIKit

class UserLogoHeader: UIView {

    deinit {
        print("EmptySurvey deinit")
    }
    
    weak fileprivate var delegate: CallbackObservable?
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameTF: UITextField! {
        didSet {
            nameTF.isUserInteractionEnabled = isEditable
        }
    }
    @IBOutlet weak var ageGenderTF: UITextField!{
        didSet {
            ageGenderTF.isUserInteractionEnabled = isEditable
        }
    }
    @IBOutlet weak var stackView: UIStackView!
    
    var isEditable = false
    
    @IBAction func buttonTapped(_ sender: Any) {
        delegate?.callbackReceived(self)
    }
    init(frame: CGRect, delegate _delegate: CallbackObservable) {
        delegate = _delegate
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    private func commonInit() {
        
        Bundle.main.loadNibNamed("UserLogoHeader", owner: self, options: nil)
        guard let content = contentView else {
            return
        }
        
        content.frame = self.bounds
        content.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(content)
    }
    
    func decrementAlpha(offset: CGFloat, denominator: CGFloat) {
        if stackView.alpha >= 0 {
            let alphaOffset = max((offset - 100)/denominator, 0)
            stackView.alpha = alphaOffset
        }
    }

    func incrementAlpha(offset: CGFloat, denominator: CGFloat) {
        if stackView.alpha <= 1 {
            let alphaOffset = max((offset - 100)/denominator, 0)
            stackView.alpha = alphaOffset
        }
    }
}
