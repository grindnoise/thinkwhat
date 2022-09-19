//
//  SurveysViewController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 18.09.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class SurveysController: UIViewController {

    // MARK: - Overridden properties
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Public properties
    var controllerOutput: SurveysControllerOutput?
    var controllerInput: SurveysControllerInput?
    public private(set) var topic: Topic
    
    // MARK: - Private properties
    private var observers: [NSKeyValueObservation] = []
    private var subscriptions = Set<AnyCancellable>()
    private var tasks: [Task<Void, Never>?] = []
    
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
    init(_ topic: Topic) {
        self.topic = topic
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public methods
    
    // MARK: - Private methods
    
    // MARK: - Overridden methods
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        let view = SurveysView()
        let model = SurveysModel()
               
        self.controllerOutput = view
        self.controllerOutput?
            .viewInput = self
        self.controllerInput = model
        self.controllerInput?
            .modelOutput = self
        
        self.view = view as UIView
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setNavigationBarAppearance()
        setRightBarButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.setNeedsLayout()
    }
}

extension SurveysController: SurveysViewInput {
    // Implement methods
}

extension SurveysController: SurveysModelOutput {
    // Implement methods
}

private extension SurveysController {
 
    func setupUI() {
        
        title = topic.title
        navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        
        //Setup nav bar
        setNavigationBarAppearance(titleColor: .clear)
    }
    
    @objc
    private func handleTap() {
        print("Tap")
    }
    
    private func setNavigationBarAppearance(titleColor: UIColor = .white) {
        guard let navigationBar = navigationController?.navigationBar else { return }
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = topic.tagColor
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.scaledFont(fontName: Fonts.Bold, forTextStyle: .largeTitle) as Any
        ]
        appearance.titleTextAttributes = [
            .foregroundColor: titleColor,
            .font: UIFont.scaledFont(fontName: Fonts.Bold, forTextStyle: .title3) as Any
        ]
        appearance.shadowColor = nil
        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        navigationBar.tintColor = .white
        navigationBar.prefersLargeTitles = true
        navigationBar.barTintColor = .white
        
        
        if #available(iOS 15.0, *) {
            navigationBar.compactScrollEdgeAppearance = appearance
        }
    }
    
    private func setRightBarButton() {
        let button = UIBarButtonItem(image: UIImage(systemName: "slider.horizontal.3", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold)), style: .plain, target: self, action: #selector(self.handleTap))
        
        navigationItem.setRightBarButton(button, animated: true)
    }
}
