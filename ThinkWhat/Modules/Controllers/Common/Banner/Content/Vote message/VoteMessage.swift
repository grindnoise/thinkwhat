//
//  VoteMessage.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 11.04.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class VoteMessage: UIView {

    deinit {
        print("VoteMessage deinit")
    }
    
    init(imageContent _imageContent: UIView, color _color: UIColor, callbackDelegate _callbackDelegate: CallbackObservable) {
        self.callbackDelegate = _callbackDelegate
        self.imageContent = _imageContent
        self.color = _color
        super.init(frame: CGRect.zero)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Initialization
    private func commonInit() {
        guard let contentView = self.fromNib() else { fatalError("View could not load from nib") }
        backgroundColor = .clear
        bounds = UIScreen.main.bounds
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        addSubview(contentView)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        switch traitCollection.userInterfaceStyle {
        case .dark:
            self.btn.backgroundColor = .systemBlue
        default:
            self.btn.backgroundColor = self.color
        }
    }
    
    // MARK: - IB Outlets
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var imageContainer: UIView! {
        didSet {
            imageContent.addEquallyTo(to: imageContainer)
        }
    }
    @IBOutlet weak var btn: UIButton! {
        didSet {
            btn.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
            btn.setTitle("results".localized.uppercased(), for: .normal)
        }
    }
    @IBAction func btnTapped(_ sender: UIButton) {
        callbackDelegate?.callbackReceived(self)
    }
    
    override var frame: CGRect {
        didSet {
            guard !btn.isNil else { return }
            btn.cornerRadius = btn.frame.height / 2.25
        }
    }
    override var bounds: CGRect {
        didSet {
            guard !btn.isNil else { return }
            btn.cornerRadius = btn.frame.height / 2.25
        }
    }
    private let imageContent: UIView
    private weak var callbackDelegate: CallbackObservable?
    private let color: UIColor
}
