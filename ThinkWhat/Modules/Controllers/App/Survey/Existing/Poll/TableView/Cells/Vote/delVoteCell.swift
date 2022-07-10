//
//  VoteCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 30.03.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class delVoteCell: UITableViewCell {
    
    @IBOutlet weak var claimButton: UIButton! {
        didSet {
            claimButton.accessibilityIdentifier = "claim"
            claimButton.setTitleColor(traitCollection.userInterfaceStyle == .dark ? .systemBlue : .label, for: .normal)
        }
    }
    @IBAction func claimTapped(_ sender: Any) {
        delegate?.callbackReceived(claimButton)
    }
    @IBOutlet weak var btn: UIButton! {
        didSet {
            btn.setTitle("vote".localized.uppercased(), for: .normal)
            btn.accessibilityIdentifier = "vote"
        }
    }
    @IBAction func btnTapped(_ sender: Any) {
        delegate?.callbackReceived(btn)
    }
    
    private var isSetupComplete = false
    private weak var delegate: CallbackObservable?
    private var isEnabled = false
    private var color = K_COLOR_RED
    public var isLoading = false {
        didSet {
            guard oldValue != isLoading else { return }
            animate(isLoading)
        }
    }
    
    public func setupUI(delegate callbackDelegate: CallbackObservable, color _color: UIColor) {
        guard !isSetupComplete else { return }
        setNeedsLayout()
        layoutIfNeeded()
        delegate = callbackDelegate
        btn.cornerRadius = btn.frame.height / 2.25
        btn.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .darkGray : K_COLOR_GRAY
        isSetupComplete = true
        color = _color
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        guard !claimButton.isNil, !btn.isNil else { return }
        switch traitCollection.userInterfaceStyle {
        case .dark:
            claimButton.setTitleColor(.systemBlue, for: .normal)
            if isEnabled {
                btn.backgroundColor = .systemBlue
            } else {
                btn.backgroundColor = .darkGray
            }
        default:
            claimButton.setTitleColor(.label, for: .normal)
            if isEnabled {
                btn.backgroundColor = color
            } else {
                btn.backgroundColor = K_COLOR_GRAY
            }
        }
    }
    
    private func animate(_ isOn: Bool) {
        if isOn {
            btn.setTitle("", for: .normal)
            let indicator = UIActivityIndicatorView(frame: CGRect(origin: .zero,
                                                                  size: CGSize(width: btn.frame.height,
                                                                               height: btn.frame.height)))
            indicator.alpha = 0
            indicator.layoutCentered(in: btn)
            indicator.startAnimating()
            indicator.color = .white
            UIView.animate(withDuration: 0.2) { indicator.alpha = 1 }
        } else {
            guard let indicator = btn.subviews.filter({ $0.isKind(of: UIActivityIndicatorView.self)}).first as? UIActivityIndicatorView else { return }
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveLinear) {
                indicator.alpha = 0
            } completion: { _ in
                indicator.removeFromSuperview()
                self.btn.setTitle("vote".localized.uppercased(), for: .normal)
            }
        }
    }
    
    public func enable() {
        guard !isEnabled else { return }
        UIView.animate(withDuration: 0.3, animations: {
            self.btn.backgroundColor = self.traitCollection.userInterfaceStyle == .dark ? .systemBlue : self.color
        }) {
            _ in
            self.isEnabled = true
        }
    }
}
