//
//  SurveysView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 18.09.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class SurveysView: UIView {
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        
    }
    
    // MARK: - Properties
    weak var viewInput: SurveysViewInput?
}

// MARK: - Controller Output
extension SurveysView: SurveysControllerOutput {
    
    // Implement methods
    
}

// MARK: - UI Setup
extension SurveysView {
    private func setupUI() {
        // Add subviews and set constraints here
    }
}


