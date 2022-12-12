//
//  TextBannerContent.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 12.12.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class TextBannerContent: UIView {
    
    // MARK: - Private properties
    private var observers: [NSKeyValueObservation] = []
    private var subscriptions = Set<AnyCancellable>()
    private var tasks: [Task<Void, Never>?] = []
    //UI
    private weak var userprofile: Userprofile!
    private lazy var imageView: UIImageView = {
        let instance = UIImageView(image: image)
        instance.contentMode = .scaleAspectFit
        instance.clipsToBounds = true
        instance.heightAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 1/1).isActive = true
        instance.tintColor = imageTintColor
        
        return instance
    }()
    private lazy var label: UILabel = {
        let instance = UILabel()
        instance.textColor = .label
        instance.numberOfLines = 0
        instance.font = UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .subheadline)
        instance.text = text.localized
        instance.textAlignment = .natural
        
        return instance
    }()
    private lazy var stack: UIStackView = {
        let instance = UIStackView(arrangedSubviews: [
            imageView,
            label
       ])
        instance.axis = .horizontal
        instance.alignment = .center
        instance.spacing = 8
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.heightAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 0.75).isActive = true
        
        return instance
    }()
    private let image: UIImage
    private let text: String
    private let imageTintColor: UIColor
    
    
    
    // MARK: - Deinitialization
    deinit {
        observers.forEach { $0.invalidate() }
        tasks.forEach { $0?.cancel() }
        subscriptions.forEach { $0.cancel() }
        NotificationCenter.default.removeObserver(self)
#if DEBUG
        print("\(String(describing: type(of: self))).\(#function)")
#endif
    }
    
    
    
    // MARK: - Initialization
    init(image: UIImage, text: String, tintColor: UIColor) {
        self.image = image
        self.text = text
        self.imageTintColor = tintColor
        
        super.init(frame: .zero)
        
        setupUI()
        setTasks()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Overridden methods
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
    }
}

private extension TextBannerContent {
    func setupUI() {
        backgroundColor = .clear
        stack.place(inside: self)
    }
    
    func setTasks() {
//        tasks.append( Task {@MainActor [weak self] in
//            for await notification in NotificationCenter.default.notifications(for: <# notification #>) {
//                guard let self = self else { return }
//
//
//            }
//        })
    }
}


