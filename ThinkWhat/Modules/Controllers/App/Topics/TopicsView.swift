//
//  TopicsView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 11.03.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class TopicsView: UIView {
    
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
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        setupUI()
    }

    
    override func layoutSubviews() {
        
    }
    
    // MARK: - Properties
    weak var viewInput: TopicsViewInput?
    
    // MARK: - IB outlets
    @IBOutlet var contentView: UIView!
}

// MARK: - Controller Output
extension TopicsView: TopicsControllerOutput {
    func onDidLayout() {
        
    }
}

// MARK: - UI Setup
extension TopicsView {
    private func setupUI() {
        // Add subviews and set constraints here
    }
}


