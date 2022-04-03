//
//  VoteCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 30.03.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class VoteCell: UITableViewCell {
    
    @IBOutlet weak var claimIcon: Icon! {
        didSet {
            claimIcon.backgroundColor = .clear
            claimIcon.isRounded = false
            claimIcon.iconColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : .systemOrange
            claimIcon.scaleMultiplicator = 1.35
            claimIcon.category = .Caution
        }
    }
    @IBOutlet weak var claimButton: UIButton! {
        didSet {
            claimButton.setTitleColor(traitCollection.userInterfaceStyle == .dark ? .systemBlue : .label, for: .normal)
        }
    }
    @IBAction func claimTapped(_ sender: Any) {
        delegate?.callbackReceived("claim" as AnyObject)
    }
    @IBOutlet weak var btn: UIButton! {
        didSet {
            btn.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
        }
    }
    @IBAction func btnTapped(_ sender: Any) {
        delegate?.callbackReceived("vote" as AnyObject)
    }
    
    private var isSetupComplete = false
    private weak var delegate: CallbackObservable?
    private var isEnabled = false
    
    public func setupUI(delegate callbackDelegate: CallbackObservable) {
        guard !isSetupComplete else { return }
        setNeedsLayout()
        layoutIfNeeded()
        delegate = callbackDelegate
        btn.cornerRadius = btn.frame.height / 2.25
        btn.backgroundColor = K_COLOR_GRAY
        btn.isUserInteractionEnabled = false
        isSetupComplete = true
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        guard !claimIcon.isNil, !claimButton.isNil, !btn.isNil else { return }
        switch traitCollection.userInterfaceStyle {
        case .dark:
            claimIcon.setIconColor(UIColor.systemBlue)
            claimButton.setTitleColor(.systemBlue, for: .normal)
            if isEnabled {
                btn.backgroundColor = .systemBlue
            }
        default:
            claimIcon.setIconColor(UIColor.systemOrange)
            claimButton.setTitleColor(.label, for: .normal)
            if isEnabled {
                btn.backgroundColor = K_COLOR_RED
            }
        }
    }
    
    public func enable() {
        UIView.animate(withDuration: 0.3, animations: {
            self.btn.backgroundColor = self.traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
        }) {
            _ in
            self.isEnabled = true
            self.btn.isUserInteractionEnabled = true
        }
    }
}
