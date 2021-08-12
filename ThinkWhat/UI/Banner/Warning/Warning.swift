//
//  Warning.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 11.08.2021.
//  Copyright © 2021 Pavel Bukharov. All rights reserved.
//

import UIKit

class Warning: UIView, BannerContent {
    
    enum Level {
        case Info, Warning, Error, Success
        func color() -> UIColor {
            switch self {
            case .Info:
                return Colors.Banner.Info
            case .Success:
                return Colors.Banner.Success
            case .Warning:
                return Colors.Banner.Warning
            case .Error:
                return Colors.Banner.Error
            }
        }
        func category() -> SurveyCategoryIcon.Category {
            switch self {
            case .Info:
                return SurveyCategoryIcon.Category.Info
            case .Success:
                return SurveyCategoryIcon.Category.Success
            case .Warning:
                return SurveyCategoryIcon.Category.Warning
            case .Error:
                return SurveyCategoryIcon.Category.Error
            }
        }
    }
    
    deinit {
        print("Warning banner deinit")
    }
    var level: Level = .Info {
        didSet {
            if oldValue != level, icon != nil {
                icon.backgroundColor = level.color()
                icon.category = level.category()
            }
        }
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
    @IBOutlet weak var icon: SurveyCategoryIcon! {
        didSet {
            icon.backgroundColor = level.color()
            icon.iconColor = .white
            icon.category = level.category()
        }
    }

    @IBOutlet weak var label: UILabel! {
        didSet {
            label.text = text
        }
    }
    
    var text = "" {
        didSet {
            label.text = text
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
        Bundle.main.loadNibNamed("Warning", owner: self, options: nil)
        guard let content = contentView else {
            return
        }
        content.frame = self.bounds
        content.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(content)
        self.backgroundColor = .clear
    }
}

