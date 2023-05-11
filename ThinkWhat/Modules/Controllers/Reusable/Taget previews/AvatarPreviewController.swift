//
//  AvatarPreviewController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 27.10.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class AvatarPreviewController: UIViewController {
    
    // MARK: - Private properties
    private var observers: [NSKeyValueObservation] = []
    private var subscriptions = Set<AnyCancellable>()
    private var tasks: [Task<Void, Never>?] = []
    //UI
    private let userprofile: Userprofile
    private lazy var imageView: UIImageView = {
        let instance = UIImageView()
        instance.backgroundColor = .clear
        instance.heightAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 1/1).isActive = true
        instance.image = userprofile.image
        instance.widthAnchor.constraint(equalToConstant: 200 - padding*2).isActive = true
        instance.clipsToBounds = true
        instance.contentMode = .scaleAspectFill
        instance.publisher(for: \.bounds)
            .sink { rect in
                instance.cornerRadius = rect.height/2
            }
            .store(in: &subscriptions)
        
        return instance
    }()
    private lazy var label: UILabel = {
        let instance = UILabel()
        instance.backgroundColor = .clear
        instance.numberOfLines = 2
        instance.text = userprofile.firstNameSingleWord + (userprofile.lastNameSingleWord.isEmpty ? "" : " \(userprofile.lastNameSingleWord)")
        instance.font = UIFont.scaledFont(fontName: Fonts.Semibold,
                                          forTextStyle: .title2)
        instance.heightAnchor.constraint(equalToConstant: instance.text!.height(withConstrainedWidth: 200 - padding*2,
                                                                                font: instance.font)).isActive = true
        
        return instance
    }()
    private lazy var stack: UIStackView = {
        let instance = UIStackView(arrangedSubviews: [
            imageView,
            label
        ])
        instance.spacing = 8
        instance.axis = .vertical
        instance.alignment = .center
        
        return instance
    }()
    private let padding: CGFloat = 16
    private var height: CGFloat {
        return stack.spacing +
        padding*2 +
        200 - padding*2 +
        label.text!.height(withConstrainedWidth: 200 - padding*2, font: label.font)
    }
    
    // MARK: - Destructor
    deinit {
#if DEBUG
        print("\(String(describing: type(of: self))).\(#function)")
#endif
    }
    
    
    
    // MARK: - Initialization
    init(userprofile: Userprofile) {
        self.userprofile = userprofile
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    // MARK: - Overridden methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .secondarySystemBackground
        preferredContentSize = CGSize(width: 200,
                                      height: height)
        stack.place(inside: view, insets: .uniform(size: 16))
    }
}
