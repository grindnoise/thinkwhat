//
//  EmptySurvey.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 27.05.2020.
//  Copyright © 2020 Pavel Bukharov. All rights reserved.
//

import UIKit

class EmptySurvey: UIView {

    deinit {
        print("EmptySurvey deinit")
    }
    
    var startingPoint: CGPoint!
    var isEnabled = false
    weak fileprivate var delegate: CallbackDelegate?
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var loadingIndicator: LoadingIndicator!
    
    @IBOutlet weak var createButton: UIButton!

    @IBAction func buttonTapped(_ sender: Any) {
        delegate?.callbackReceived(self)
    }
    init(frame: CGRect, delegate _delegate: CallbackDelegate) {
        delegate = _delegate
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    private func commonInit() {
        
        Bundle.main.loadNibNamed("EmptySurvey", owner: self, options: nil)
        guard let content = contentView else {
            return
        }
        
        content.frame = self.bounds
        content.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        content.backgroundColor = .white//UIColor.lightGray.withAlphaComponent(0.09)
        self.addSubview(content)
    }
    
    @objc fileprivate func callback(recognizer: UITapGestureRecognizer) {
        if recognizer.state == .ended {
            delegate?.callbackReceived(self)
        }
    }
    
    func setEnabled(_ newValue: Bool, completion: @escaping(Bool)->()) {
        if newValue != isEnabled {
            isEnabled = newValue
            if isEnabled {
                loadingIndicator.addEnableAnimation()
                createButton.transform = createButton.transform.scaledBy(x: 0.75, y: 0.75)
                createButton.alpha = 0
                createButton.backgroundColor = K_COLOR_GRAY
                UIView.animate(withDuration: 0.5) {
                    self.alpha = 1
                }
                UIView.animate(
                    withDuration: 0.5,
                    delay: 0.1,
                    usingSpringWithDamping: 0.5,
                    initialSpringVelocity: 3,
                    options: [.curveEaseInOut],
                    animations: {
                        self.createButton.alpha = 1
                        self.createButton.backgroundColor = K_COLOR_RED
                        self.createButton.transform = .identity
                }) {
                    _ in
//                    self.createButton.cornerRadius = self.createButton.frame.height / 2
                    self.createButton.layer.cornerRadius = self.createButton.frame.height / 2
                    completion(true)
                }
            } else {
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
                    self.createButton.transform = self.createButton.transform.scaledBy(x: 0.75, y: 0.75)
                    self.createButton.alpha = 0
                }) {
                    _ in
                    UIView.animate(withDuration: 0.2, animations: {
                        self.alpha = 0
                    }) {
                        _ in completion(true)
                    }
                }

            }
        } else {
            completion(true)
        }
    }

}
