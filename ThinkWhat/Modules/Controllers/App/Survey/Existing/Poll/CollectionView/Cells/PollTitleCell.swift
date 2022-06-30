//
//  PollTitleCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 30.06.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class PollTitleCell: UICollectionViewCell {
    
    // MARK: - Private properties
    private let item: Survey
    private lazy var titleLabel: UILabel = {
        let instance = UILabel()
        instance.textColor = .label
        instance.text = item.title
        return instance
    }()
    private lazy var verticalStack: UIStackView = {
        let verticalStack = UIStackView(arrangedSubviews: [titleLabel, ])
        verticalStack.axis = .vertical
        verticalStack.spacing = padding
        return verticalStack
    }()
    private var observers: [NSKeyValueObservation] = []
    private let padding: CGFloat = 8
    private var constraint: NSLayoutConstraint?
    
    // MARK: - Initialization
    init(_ item: Survey) {
        self.item = item
        super.init(frame: .zero)
    }
    
    override init(frame: CGRect) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI methods
    private func setupUI() {
        backgroundColor = .clear
        clipsToBounds = true
        verticalStack.heightAnchor.constraint(equalToConstant: 40).isActive = true
        contentView.addSubview(verticalStack)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            verticalStack.topAnchor.constraint(equalTo: contentView.topAnchor),//, constant: padding),
            verticalStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            verticalStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
        ])
        

        constraint = titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding)
        constraint?.priority = .defaultLow
    }
    
    private func setObservers() {
        observers.append(titleLabel.observe(\UILabel.bounds, options: [.new]) { [weak self] view, change in
            guard !self.isNil, let newValue = change.newValue else { return }
            //set font & size
        })
    }
}
