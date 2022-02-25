//
//  Avatar.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 24.02.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class Avatar: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var border: UIView!
    @IBOutlet weak var imageView: UIImageView! {
        didSet {
            imageView.isUserInteractionEnabled = true
            imageView.contentMode = .scaleAspectFit
        }
    }
    
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
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(contentView)
        setupUI()
    }
    
    override func layoutSubviews() {
        if !border.isNil { border.cornerRadius = border.frame.height/2 }
        if !imageView.isNil { imageView.cornerRadius = imageView.frame.width/2 }
    }
    
    override var frame: CGRect {
        didSet {
            layoutSubviews()
        }
    }
    
    override var bounds: CGRect {
        didSet {
            layoutSubviews()
        }
    }
    
    private var lightColor = K_COLOR_RED
    private var darkColor = UIColor.systemBlue
    weak var delegate: CallbackDelegate?
    
    private func setupUI() {
        border.backgroundColor = UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor.systemBlue
            default:
                return K_COLOR_RED
            }
        }
        let touch = UITapGestureRecognizer(target:self, action:#selector(Avatar.handleTap))
        imageView.addGestureRecognizer(touch)
    }
    
    @objc
    private func handleTap() {
        delegate?.callbackReceived(self)
    }
    
    public func setImage(_ image: UIImage) {
        guard !imageView.isNil else { return }
        imageView.image = image
    }
}
