//
//  StarView.swift
//  Burb
//
//  Created by Pavel Bukharov on 12.07.2018.
//  Copyright © 2018 Pavel Bukharov. All rights reserved.
//

import UIKit

class StarView: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var star_1: UIView!
    @IBOutlet weak var star_2: UIView!
    @IBOutlet weak var star_3: UIView!
    @IBOutlet weak var star_4: UIView!
    @IBOutlet weak var star_5: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("StarView", owner: self, options: nil)
        guard let content = contentView else {
            return
        }
        
        content.frame = self.bounds
        content.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(content)
    }
    
    public var color = UIColor.systemYellow {
        didSet {
            
        }
    }
    open var rating: Double = 0.0 {
        didSet {
            let emptyStar = Star(frame: star_1.frame, state: .Empty, color: color)
            emptyStar.isOpaque = false
            emptyStar.backgroundColor = .clear
            let halfStar  = Star(frame: star_1.frame, state: .Half, color: color)
            halfStar.isOpaque = false
            halfStar.backgroundColor = .clear
            let fullStar  = Star(frame: star_1.frame, state: .Full, color: color)
            fullStar.isOpaque = false
            fullStar.backgroundColor = .clear
            if rating < 0.5 {
                if let star1 = emptyStar.copyView(),
                    let star2 = emptyStar.copyView(),
                    let star3 = emptyStar.copyView(),
                    let star4 = emptyStar.copyView(),
                    let star5 = emptyStar.copyView() {
                    star1.addEquallyTo(to: star_1)
                    star2.addEquallyTo(to: star_2)
                    star3.addEquallyTo(to: star_3)
                    star4.addEquallyTo(to: star_4)
                    star5.addEquallyTo(to: star_5)
                }
            } else if rating < 1.0 {
                if let star1 = halfStar.copyView(),
                    let star2 = emptyStar.copyView(),
                    let star3 = emptyStar.copyView(),
                    let star4 = emptyStar.copyView(),
                    let star5 = emptyStar.copyView() {
                    star1.addEquallyTo(to: star_1)
                    star2.addEquallyTo(to: star_2)
                    star3.addEquallyTo(to: star_3)
                    star4.addEquallyTo(to: star_4)
                    star5.addEquallyTo(to: star_5)
                }
            } else if rating < 1.5 {
                if let star1 = fullStar.copyView(),
                    let star2 = emptyStar.copyView(),
                    let star3 = emptyStar.copyView(),
                    let star4 = emptyStar.copyView(),
                    let star5 = emptyStar.copyView() {
                    star1.addEquallyTo(to: star_1)
                    star2.addEquallyTo(to: star_2)
                    star3.addEquallyTo(to: star_3)
                    star4.addEquallyTo(to: star_4)
                    star5.addEquallyTo(to: star_5)
                }
            } else if rating < 2 {
                if let star1 = fullStar.copyView(),
                    let star2 = halfStar.copyView(),
                    let star3 = emptyStar.copyView(),
                    let star4 = emptyStar.copyView(),
                    let star5 = emptyStar.copyView() {
                    star1.addEquallyTo(to: star_1)
                    star2.addEquallyTo(to: star_2)
                    star3.addEquallyTo(to: star_3)
                    star4.addEquallyTo(to: star_4)
                    star5.addEquallyTo(to: star_5)
                }
            } else if rating < 2.5 {
                if let star1 = fullStar.copyView(),
                    let star2 = fullStar.copyView(),
                    let star3 = emptyStar.copyView(),
                    let star4 = emptyStar.copyView(),
                    let star5 = emptyStar.copyView() {
                    star1.addEquallyTo(to: star_1)
                    star2.addEquallyTo(to: star_2)
                    star3.addEquallyTo(to: star_3)
                    star4.addEquallyTo(to: star_4)
                    star5.addEquallyTo(to: star_5)
                }
            } else if rating < 3 {
                if let star1 = fullStar.copyView(),
                    let star2 = fullStar.copyView(),
                    let star3 = halfStar.copyView(),
                    let star4 = emptyStar.copyView(),
                    let star5 = emptyStar.copyView() {
                    star1.addEquallyTo(to: star_1)
                    star2.addEquallyTo(to: star_2)
                    star3.addEquallyTo(to: star_3)
                    star4.addEquallyTo(to: star_4)
                    star5.addEquallyTo(to: star_5)
                }
            } else if rating < 3.5 {
                if let star1 = fullStar.copyView(),
                    let star2 = fullStar.copyView(),
                    let star3 = fullStar.copyView(),
                    let star4 = emptyStar.copyView(),
                    let star5 = emptyStar.copyView() {
                    star1.addEquallyTo(to: star_1)
                    star2.addEquallyTo(to: star_2)
                    star3.addEquallyTo(to: star_3)
                    star4.addEquallyTo(to: star_4)
                    star5.addEquallyTo(to: star_5)
                }
            } else if rating < 4 {
                if let star1 = fullStar.copyView(),
                    let star2 = fullStar.copyView(),
                    let star3 = fullStar.copyView(),
                    let star4 = halfStar.copyView(),
                    let star5 = emptyStar.copyView() {
                    star1.addEquallyTo(to: star_1)
                    star2.addEquallyTo(to: star_2)
                    star3.addEquallyTo(to: star_3)
                    star4.addEquallyTo(to: star_4)
                    star5.addEquallyTo(to: star_5)
                }
            } else if rating < 4.5 {
                if let star1 = fullStar.copyView(),
                    let star2 = fullStar.copyView(),
                    let star3 = fullStar.copyView(),
                    let star4 = fullStar.copyView(),
                    let star5 = emptyStar.copyView() {
                    star1.addEquallyTo(to: star_1)
                    star2.addEquallyTo(to: star_2)
                    star3.addEquallyTo(to: star_3)
                    star4.addEquallyTo(to: star_4)
                    star5.addEquallyTo(to: star_5)
                }
            } else if rating < 5 {
                if let star1 = fullStar.copyView(),
                    let star2 = fullStar.copyView(),
                    let star3 = fullStar.copyView(),
                    let star4 = fullStar.copyView(),
                    let star5 = halfStar.copyView() {
                    star1.addEquallyTo(to: star_1)
                    star2.addEquallyTo(to: star_2)
                    star3.addEquallyTo(to: star_3)
                    star4.addEquallyTo(to: star_4)
                    star5.addEquallyTo(to: star_5)
                }
            } else {
                if let star1 = fullStar.copyView(),
                    let star2 = fullStar.copyView(),
                    let star3 = fullStar.copyView(),
                    let star4 = fullStar.copyView(),
                    let star5 = fullStar.copyView() {
                    star1.addEquallyTo(to: star_1)
                    star2.addEquallyTo(to: star_2)
                    star3.addEquallyTo(to: star_3)
                    star4.addEquallyTo(to: star_4)
                    star5.addEquallyTo(to: star_5)
                }
            }
        }
    }
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
}
