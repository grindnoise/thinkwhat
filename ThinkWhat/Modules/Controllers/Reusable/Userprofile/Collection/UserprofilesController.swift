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
    
    enum GridItemSize: CGFloat {
        case half = 0.5
        case third = 0.33333
        case quarter = 0.25
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
    private var gridItemSize: UserprofilesController.GridItemSize = .third {
        didSet {
            guard oldValue != gridItemSize else { return }
            
            self.controllerOutput?.gridItemSizePublisher.send(gridItemSize)
            
            guard let button = navigationItem.rightBarButtonItem else { return }
            
            button.menu = prepareMenu()
        }
    }
    
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
    
    func prepareMenu() -> UIMenu {
        let filter: UIAction = .init(title: "filter".localized.capitalized,
                                     image: UIImage(systemName: "slider.horizontal.3", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold)),
                                     identifier: nil,
                                     discoverabilityTitle: nil,
                                     attributes: .init(),
                                     state: .off,
                                     handler: { [weak self] _ in
            guard let self = self else { return }
            
            self.filter()
        })
        
        let half: UIAction = .init(title: "half".localized.capitalized,
                                     image: UIImage(systemName: "circle.grid.2x2.fill", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold)),
                                     identifier: nil,
                                     discoverabilityTitle: nil,
                                     attributes: .init(),
                                     state: gridItemSize == .half ? .on : .off,
                                     handler: { [weak self] _ in
            guard let self = self else { return }
            
            self.gridItemSize = .half
//            self.controllerOutput?.gridItemSizePublisher.send(.half)
        })
        
        let third: UIAction = .init(title: "third".localized.capitalized,
                                     image: UIImage(systemName: "circle.grid.3x3.fill", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold)),
                                     identifier: nil,
                                     discoverabilityTitle: nil,
                                     attributes: .init(),
                                     state: gridItemSize == .third ? .on : .off,
                                     handler: { [weak self] _ in
            guard let self = self else { return }
            
            self.gridItemSize = .third
//            self.controllerOutput?.gridItemSizePublisher.send(.third)
        })
        
//            let quarter: UIAction = .init(title: "filter".localized.capitalized,
//                                         image: UIImage(systemName: "slider.horizontal.3", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold)),
//                                         identifier: nil,
//                                         discoverabilityTitle: nil,
//                                         attributes: .init(),
//                                         state: .off,
//                                         handler: { [weak self] _ in
//                guard let self = self else { return }
//
//                self.filter()
//            })
        
        let inlineMenu = UIMenu(title: "appearance".localized,
                                image: UIImage(systemName: gridItemSize == .third ? "circle.grid.3x3.fill" : "circle.grid.2x2.fill",
                                               withConfiguration: UIImage.SymbolConfiguration(weight: .semibold)),
                                identifier: nil,
                                options: .init(),
                                children: [half, third])
        
        return UIMenu(title: "", children: [filter, inlineMenu])
    }
    
    func setRightBarButton() {
        
//        let button = UIBarButtonItem(image: UIImage(systemName: "ellipsis", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold)), style: .plain, target: self, action: #selector(self.handleTap), m)
        
        let button = UIBarButtonItem(title: "actions".localized.capitalized,
                        image: UIImage(systemName: "ellipsis", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold)),
                        primaryAction: nil,
                        menu: prepareMenu())
        
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
//        fatalError()
    }
    
    func filter() {
        
    }
}

extension UserprofilesController: UserprofilesViewInput {
    
    func loadUsers(for userprofile: Userprofile, mode: UserprofilesController.Mode) {
        controllerInput?.loadUsers(for: userprofile, mode: mode)
    }
    
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

