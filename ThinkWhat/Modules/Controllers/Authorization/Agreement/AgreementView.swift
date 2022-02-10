//
//  AgreementView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 10.02.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class AgreementView: UIView {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var agreeButton: UIButton!
    @IBAction func agreeButtonTapped(_ sender: Any) {
        
    }
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
    weak var viewInput: AgreementViewInput?
}

// MARK: - Controller Output
extension AgreementView: AgreementControllerOutput {
    
    // Implement methods
    
}

// MARK: - UI Setup
extension AgreementView {
    private func setupUI() {
        // Add subviews and set constraints here
    }
}


