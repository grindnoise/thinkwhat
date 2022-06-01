//
//  ImageSelectionCellContent.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 01.06.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

@available(iOS 14.0, *)
class ImageSelectionCellContent: UIView {

    init(configuration: ImageSelectionCellConfiguration) {
        super.init(frame: .zero)
        commonInit()
        setupUI()
        apply(configuration: configuration)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
    }
    
    private var currentConfiguration: ImageSelectionCellConfiguration!
    var configuration: UIContentConfiguration {
        get {
            currentConfiguration
        }
        set {
            guard let newConfiguration = newValue as? ImageSelectionCellConfiguration else {
                return
            }
            apply(configuration: newConfiguration)
        }
    }
    
    
    // MARK: - IB outlets
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
}

@available(iOS 14.0, *)
extension ImageSelectionCellContent: UIContentView {
    func apply(configuration: ImageSelectionCellConfiguration) {
        guard currentConfiguration != configuration else { return }
        currentConfiguration = configuration
        imageView.image = currentConfiguration.image
        textView.text = currentConfiguration.title
    }
    
    private func setupUI() {
        
    }
}
