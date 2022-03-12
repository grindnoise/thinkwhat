//
//  ListView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 11.03.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class ListView: UIView {
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        guard let contentView = self.fromNib() else { fatalError("View could not load from nib") }
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(contentView)
        setupUI()
    }
    
    override func layoutSubviews() {
        
    }
    
    // MARK: - Properties
    weak var viewInput: ListViewInput?
    
    // MARK: - IB outlets
    @IBOutlet var contentView: UIView!
}

// MARK: - Controller Output
extension ListView: ListControllerOutput {
    func onDidLayout() {
        
    }
}

// MARK: - UI Setup
extension ListView {
    private func setupUI() {
        // Add subviews and set constraints here
    }
}


