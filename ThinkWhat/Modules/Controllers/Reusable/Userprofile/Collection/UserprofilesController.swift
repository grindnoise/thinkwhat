//
//  UserprofilesController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 22.09.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class UserprofilesController: UIViewController {
    
    enum Mode: String {
        case Subscribers, Subscriptions, Voters
    }
    
    // MARK: - Overridden properties
    
    
    
    // MARK: - Public properties
    var controllerOutput: UserprofilesControllerOutput?
    var controllerInput: UserprofilesControllerInput?
    //Logic
    public private(set) var mode: Mode
    public private(set) var userprofile: Userprofile?
    
    
    // MARK: - Private properties
    private var observers: [NSKeyValueObservation] = []
    private var subscriptions = Set<AnyCancellable>()
    private var tasks: [Task<Void, Never>?] = []
    
    //UI
    private let color: UIColor
    
    
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
    init(mode: Mode, userprofile: Userprofile, color: UIColor = .clear) {
        self.color = color
        self.mode = mode
        self.userprofile = userprofile
        
        super.init(nibName: nil, bundle: nil)
        
        setupUI()
        setTasks()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    // MARK: - Public methods
    
    
    
    // MARK: - Overridden methods
    override func viewDidLoad() {
        super.viewDidLoad()
       
        let view = UserprofilesView()
        let model = UserprofilesModel()
               
        self.controllerOutput = view
        self.controllerOutput?
            .viewInput = self
        self.controllerInput = model
        self.controllerInput?
            .modelOutput = self
        
        self.view = view as UIView
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setNavigationBarAppearance(largeTitleColor: mode == .Voters ? .white : .label, smallTitleColor: mode == .Voters ? .white : .label)
        setRightBarButton()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
    }
}

private extension UserprofilesController {
    
    func setupUI() {
        title = mode.rawValue.lowercased().localized
        
        setNavigationBarAppearance(largeTitleColor: mode == .Voters ? .white : .label, smallTitleColor: .clear)
    }
    
    func setNavigationBarAppearance(largeTitleColor: UIColor, smallTitleColor: UIColor) {
        guard let navigationBar = navigationController?.navigationBar else { return }
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.largeTitleTextAttributes = [
            .foregroundColor: largeTitleColor,
            .font: UIFont.scaledFont(fontName: Fonts.Bold, forTextStyle: .largeTitle) as Any
        ]
        appearance.titleTextAttributes = [
            .foregroundColor: smallTitleColor,
            .font: UIFont.scaledFont(fontName: Fonts.Bold, forTextStyle: .title3) as Any
        ]
        appearance.shadowColor = nil
        
        switch mode {
        case .Voters:
            appearance.backgroundColor = color
            navigationBar.tintColor = .white
            navigationBar.barTintColor = .white
        default:
            navigationBar.tintColor = .label
            navigationBar.barTintColor = .label
        }
        
        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        navigationBar.prefersLargeTitles = true
        
        if #available(iOS 15.0, *) {
            navigationBar.compactScrollEdgeAppearance = appearance
        }
    }
    
    func setRightBarButton() {
        let button = UIBarButtonItem(image: UIImage(systemName: "slider.horizontal.3", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold)), style: .plain, target: self, action: #selector(self.handleTap))
        
        navigationItem.setRightBarButton(button, animated: true)
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
    
    @objc
    func handleTap() {
        fatalError()
    }
}

extension UserprofilesController: UserprofilesViewInput {
    func onUserprofileTap(_ userprofile: Userprofile) {
        let backItem = UIBarButtonItem()
        backItem.title = ""
        
        navigationItem.backBarButtonItem = backItem
        navigationController?.pushViewController(UserprofileController(userpofile: userprofile), animated: true)
        tabBarController?.setTabBarVisible(visible: false, animated: true)
    }
}

extension UserprofilesController: UserprofilesModelOutput {
    // Implement methods
}

