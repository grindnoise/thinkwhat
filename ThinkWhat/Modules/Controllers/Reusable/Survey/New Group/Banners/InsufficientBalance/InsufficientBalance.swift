//
//  InsufficientBalance.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 10.08.2021.
//  Copyright © 2021 Pavel Bukharov. All rights reserved.
//

import UIKit

class InsufficientBalance: UIView {
    var minHeigth: CGFloat {
        return topView.frame.height
    }
    
    var maxHeigth: CGFloat {
        return topView.frame.height + bottomView.frame.height
    }
    var foldable: Bool = true
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var bankruptcyIcon: Icon! {
        didSet {
            bankruptcyIcon.backgroundColor = K_COLOR_RED
            bankruptcyIcon.iconColor = .white
            bankruptcyIcon.category = .Bankruptcy
        }
    }
    @IBOutlet weak var paymentIcon: Icon! {
        didSet {
            paymentIcon.backgroundColor = color
            paymentIcon.category = .Plus
            paymentIcon.iconColor = .white
        }
    }
    @IBOutlet weak var balanceLabel: UILabel! {
        didSet {
            balanceLabel.textColor = color
        }
    }
    weak var delegate: CallbackObservable?
    var color: UIColor = Colors.System.Red.rawValue//Colors.UpperButtons.VioletBlueCrayola
    var balance = 0 {
        didSet {
            if oldValue != balance, balanceLabel != nil {
                balanceLabel.text = "$\(balance.formattedWithSeparator)"
            }
        }
    }
    var cost    = 0 {
        didSet {
//            if oldValue != cost, costLabel != nil {
//                costLabel.alpha = cost == 0 ? 0 : 1
//                costLabel.text = "-$\(cost.formattedWithSeparator) публикация"
//            }
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    init(width: CGFloat) {
        let _frame = CGRect(origin: .zero, size: CGSize(width: width, height: width))///frameRatio))
        super.init(frame: _frame)
        self.commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("InsufficientBalance", owner: self, options: nil)
        guard let content = contentView else {
            return
        }
        content.frame = self.bounds
        content.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(content)
        self.backgroundColor = .clear
        
    }
    
    func callbackReceived(_ sender: AnyObject) {
        //        delegate?.callbackReceived(<#T##sender: AnyObject##AnyObject#>)
    }
}
