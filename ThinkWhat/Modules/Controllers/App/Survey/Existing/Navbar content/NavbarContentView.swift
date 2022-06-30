//
//  NavbarContentView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 30.06.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class NavbarContentView: UIView {
    
    // MARK: - Private properties
    private let topic: Topic!
    private var observers: [NSKeyValueObservation] = []
    
    // MARK: - IB Outlets
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var indicator: CircleButton!
    @IBOutlet weak var title: UILabel!
    
    // MARK: - Initialization
    init(topic: Topic) {
        self.topic = topic
        super.init(frame: .zero)
        commonInit()
    }
    
    override init(frame: CGRect) {
        fatalError("init(frame:) has not been implemented")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Private methods
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
        setObservers()
        setupUI()
    }
    
    private func setupUI() {

    }
    
    private func setObservers() {
        observers.append(title.observe(\UILabel.bounds, options: [NSKeyValueObservingOptions.new]) { [weak self] view, change in
            guard !self.isNil, let newValue = change.newValue else { return }
            
        })
    }
}
