//
//  ImagePasteView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 28.06.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class ImagePasteView: UIView {
    
    deinit {
        print("URLPasteView deinit")
    }
    
    init(delegate: CallbackObservable?, image: UIImage) {
        self.image = image
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
        observers.append(imageContainer.observe(\UIImageView.bounds, options: [NSKeyValueObservingOptions.new]) { [weak self] (view: UIView, change: NSKeyValueObservedChange<CGRect>) in
            guard let self = self,
            let rect = change.newValue else { return }
            self.imageContainer.cornerRadius = rect.height * 0.25
        })
        imageContainer.image = image
    }
    
    // MARK: - IB Outlets
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var imageContainer: UIImageView! {
        didSet {
            imageContainer.contentMode = .scaleAspectFill
        }
    }
    @IBOutlet weak var pasteButton: UIButton! {
        didSet {
            pasteButton.setTitle("add_image".localized, for: .normal)
        }
    }
    @IBAction func pasteButtonTapped(_ sender: Any) {
        callbackDelegate?.callbackReceived(image)
    }
    @IBAction func cancelButtonTapped(_ sender: Any) {
        callbackDelegate?.callbackReceived("dismiss")
    }
    @IBOutlet weak var cancelButton: UIButton! {
        didSet {
            cancelButton.setTitle("cancel".localized, for: .normal)
        }
    }
    
    
    // MARK: - Properties
    private let image: UIImage
    private weak var callbackDelegate: CallbackObservable?
    private var observers: [NSKeyValueObservation] = []
}


