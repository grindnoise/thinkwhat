//
//  TotalCost.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 09.08.2021.
//  Copyright © 2021 Pavel Bukharov. All rights reserved.
//

import UIKit

class TotalCost: UIView, BannerContent {
    var frameRatio: CGFloat = 1.5
    var foldable: Bool = true
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var paymentIcon: SurveyCategoryIcon! {
        didSet {
            paymentIcon.category = .Balance
            paymentIcon.iconColor = .white
        }
    }
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var costLabel: UILabel!
    //    weak var delegate: CallbackDelegate?
    var balance = 0
    var cost    = 0
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    init(width: CGFloat) {
        let _frame = CGRect(origin: .zero, size: CGSize(width: width, height: width*frameRatio))
        super.init(frame: _frame)
        self.commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("TotalCost", owner: self, options: nil)
        guard let content = contentView else {
            return
        }
        content.frame = self.bounds
        content.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(content)
        self.backgroundColor = .clear
    }
    //
    //    func callbackReceived(_ sender: AnyObject) {
    //        delegate?.callbackReceived(<#T##sender: AnyObject##AnyObject#>)
    //    }}
}
