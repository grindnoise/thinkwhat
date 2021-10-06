//
//  VotesFormula.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 11.08.2021.
//  Copyright © 2021 Pavel Bukharov. All rights reserved.
//
import UIKit

class VotesFormula: UIView, BannerContent {
    deinit {
        print("VotesFormula banner deinit")
    }
    var minHeigth: CGFloat {
        return topView.frame.height
    }
    
    var maxHeigth: CGFloat {
        return topView.frame.height
    }
    var foldable: Bool = false
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var icon: Icon! {
        didSet {
            icon.backgroundColor = Colors.UpperButtons.Avocado
            icon.iconColor = .white
            icon.category = .Balance
        }
    }
    @IBOutlet weak var votesLabel: UILabel! {
        didSet {
            votesLabel.text = "\(votes)"
        }
    }
    @IBOutlet weak var priceLabel: UILabel! {
        didSet {
            priceLabel.text = "\(price)"
        }
    }
    @IBOutlet weak var costLabel: UILabel! {
        didSet {
            costLabel.text = "\(cost.formattedWithSeparator)"
        }
    }

    var color: UIColor = Colors.UpperButtons.VioletBlueCrayola
    var votes = 0 {
        didSet {
            cost = votes * price
            votesLabel.text = "\(votes)"
        }
    }
    var price = 1 {
        didSet {
            cost = votes * price
            priceLabel.text = "\(price)"
        }
    }
    var cost    = 0 {
        didSet {
            costLabel.text = "\(cost)"//".formattedWithSeparator)"
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
        Bundle.main.loadNibNamed("VotesFormula", owner: self, options: nil)
        guard let content = contentView else {
            return
        }
        content.frame = self.bounds
        content.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(content)
        self.backgroundColor = .clear
    }
}
