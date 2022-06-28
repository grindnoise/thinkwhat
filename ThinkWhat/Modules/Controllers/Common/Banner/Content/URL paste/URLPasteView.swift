//
//  URLPasteView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 28.06.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class URLPasteView: UIView {
    
    deinit {
        print("URLPasteView deinit")
    }
    
    init(delegate: CallbackObservable?, url: URL, color _color: UIColor) {
        self.url = url
        self.color = _color
        super.init(frame: CGRect.zero)
        self.callbackDelegate = delegate
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
    
    // MARK: - IB Outlets
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var imageContainer: UIView! {
        didSet {
            imageContent.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
            imageContent.addEquallyTo(to: imageContainer)
            guard imageContent.isKind(of: UIImageView.self) else { return }
            (imageContent as! UIImageView).contentMode = .scaleAspectFit
        }
    }
    @IBOutlet weak var pasteButton: UIButton! {
        didSet {
            pasteButton.setTitle("paste_url".localized, for: .normal)
        }
    }
    @IBAction func pasteButtonTapped(_ sender: Any) {
        callbackDelegate?.callbackReceived(url)
    }
    @IBAction func cancelButtonTapped(_ sender: Any) {
        callbackDelegate?.callbackReceived("dismiss")
    }
    @IBOutlet weak var cancelButton: UIButton! {
        didSet {
            cancelButton.setTitle("cancel".localized, for: .normal)
        }
    }
    
    
    // MARK: - IB Outlets
    private let url: URL
    private let imageContent: UIView = {
        return UIImageView(image: UIImage(systemName: "link.circle.fill"))
    }()
    private let color: UIColor
    private weak var callbackDelegate: CallbackObservable?
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        imageContent.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
    }
}

