//
//  UserNotificationContent.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 28.10.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class UserNotificationContent: UIView {
    
    enum Mode: String {
        case Subscribe = "subscribe_to_user_notification"
        case Unsubscribe = "unsubscribe_from_user_notification"
        case NotifyOnPublication = "user_publication_notification_on"
        case DontNotifyOnPublication = "user_publication_notification_off"
        
        func localizedDescription(userprofile: Userprofile) -> String {
            switch self {
            case .Subscribe:
                return self.rawValue.localized + " " + userprofile.name + " ✅"
            case .Unsubscribe:
                return self.rawValue.localized + " " + userprofile.name + " ⛔️"
            case .NotifyOnPublication:
                return "user_publication_notification_begin".localized + userprofile.name + self.rawValue.localized + " 🔔"
            case .DontNotifyOnPublication:
                return "user_publication_notification_begin".localized + userprofile.name + self.rawValue.localized + " 🔕"
            }
        }
    }
    
    
    
    // MARK: - Overridden properties
    
    
    
    // MARK: - Public properties
    
    
    
    // MARK: - Private properties
    private var observers: [NSKeyValueObservation] = []
    private var subscriptions = Set<AnyCancellable>()
    private var tasks: [Task<Void, Never>?] = []
    //UI
    private let mode: Mode
    private let textColor: UIColor
    private weak var userprofile: Userprofile!
    private lazy var imageView: UIImageView = {
        let instance = UIImageView(image: userprofile.image)
        instance.contentMode = .scaleAspectFill
        instance.clipsToBounds = true
        instance.heightAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 1/1).isActive = true
        instance.publisher(for: \.bounds)
            .sink { rect in
                instance.cornerRadius = rect.height/2
            }
            .store(in: &subscriptions)
        
        return instance
    }()
    private lazy var label: UILabel = {
        let instance = UILabel()
        instance.textColor = textColor
        instance.numberOfLines = 0
        instance.font = UIFont.scaledFont(fontName: Fonts.Semibold, forTextStyle: .headline)
        instance.text = mode.localizedDescription(userprofile: userprofile)
        instance.textAlignment = instance.numberOfTotatLines == 1 ? .center : .left
        
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
        
        return instance
    }()
    
    
    
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
    init(mode: Mode, userprofile: Userprofile, textColor: UIColor = .label) {
        self.mode = mode
        self.userprofile = userprofile
        self.textColor = textColor
        
        super.init(frame: .zero)
        
        setupUI()
        setTasks()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    // MARK: - Public methods
    
    
    
    // MARK: - Overridden methods
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
    }
}

private extension UserNotificationContent {
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

