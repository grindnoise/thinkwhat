//
//  AddBarButton.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 11.04.2020.
//  Copyright © 2020 Pavel Bukharov. All rights reserved.
//

import UIKit

@IBDesignable
class AddBarButton: UIBarButtonItem {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var addView: PlusIcon!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    private func commonInit() {
        
        Bundle.main.loadNibNamed("AddBarButton", owner: self, options: nil)
        guard let content = contentView else {
            return
        }
        customView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 25, height: 25)))
        content.frame = customView!.bounds
        content.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        customView!.addSubview(content)
    }
    
}
