//
//  LostConnectionView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 10.04.2020.
//  Copyright © 2020 Pavel Bukharov. All rights reserved.
//

import UIKit

class LostConnectionView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var animationView: LostConnectionAnimation!
    @IBOutlet weak var retryButton: UIButton! {
        didSet {
//            retryButton.layer.cornerRadius = retryButton.frame.height / 2
        }
    }
    @IBAction func retryTapped(_ sender: Any) {
        delegate?.signalReceived(self)
    }
    weak var delegate: ButtonDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    private func commonInit() {
        
        Bundle.main.loadNibNamed("LostConnectionView", owner: self, options: nil)
        guard let content = contentView else {
            return
        }
        
        content.frame = self.bounds
        content.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(content)
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
