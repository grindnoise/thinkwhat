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
        return mode == .Topic ? .lightContent : .default
    }
    
    
    
    // MARK: - Public properties
    var controllerOutput: SurveysControllerOutput?
    var controllerInput: SurveysControllerInput?
    public private(set) var topic: Topic?
    public private(set) var mode: Survey.SurveyCategory
    
    
    
    // MARK: - Private properties
    private var observers: [NSKeyValueObservation] = []
    private var subscriptions = Set<AnyCancellable>()
    private var tasks: [Task<Void, Never>?] = []
    //UI
    private lazy var titleLabel: UILabel = {
        let instance = UILabel()
        instance.font = UIFont(name: Fonts.Bold,
                               size: 32)
//        instance.text = topic?.localized
        instance.textAlignment = .left
        instance.adjustsFontSizeToFitWidth = true
        instance.minimumScaleFactor = 0.4
        instance.textColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .label

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
    init(_ topic: Topic) {
        self.mode = .Topic
        self.topic = topic
        super.init(nibName: nil, bundle: nil)
    }
    
    init(_ mode: Survey.SurveyCategory) {
        self.mode = mode
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public methods
    
    // MARK: - Private methods
    
    // MARK: - Overridden methods
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.2, delay: 0) { [weak self] in
            guard let self = self else { return }

            self.titleLabel.alpha = 0
            self.titleLabel.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.setNeedsLayout()
        navigationItem.largeTitleDisplayMode = .never
//        tabBarController?.setTabBarVisible(visible: true, animated: true)
        
        titleLabel.alpha = 1
        titleLabel.transform = .identity
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        titleLabel.removeFromSuperview()
    }

    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        print(isMovingToParent)
        print(isMovingFromParent)
//        guard parent.isNil else { return }

//        clearNavigationBar(clear: true)
//        tabBarController?.setTabBarVisible(visible: true, animated: true)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        titleLabel.textColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .label
    }
}

extension SurveysController: SurveysViewInput {
    func openUserprofile(_ userprofile: Userprofile) {
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        
        navigationController?.pushViewController(UserprofileController(userprofile: userprofile), animated: true)
//        tabBarController?.setTabBarVisible(visible: false, animated: true)
    }
    
    func unsubscribe(from userprofile: Userprofile) {
        controllerInput?.unsubscribe(from: userprofile)
    }
    
    func subscribe(to userprofile: Userprofile) {
        controllerInput?.subscribe(to: userprofile)
    }
    
    func share(_ surveyReference: SurveyReference) {
        // Setting description
        let firstActivityItem = surveyReference.title
        
        // Setting url
        let queryItems = [URLQueryItem(name: "hash", value: surveyReference.shareHash), URLQueryItem(name: "enc", value: surveyReference.shareEncryptedString)]
        var urlComps = URLComponents(string: API_URLS.Surveys.share!.absoluteString)!
        urlComps.queryItems = queryItems
        
        let secondActivityItem: URL = urlComps.url!
        
        // If you want to use an image
        let image : UIImage = UIImage(named: "anon")!
        let activityViewController : UIActivityViewController = UIActivityViewController(
            activityItems: [firstActivityItem, secondActivityItem, image], applicationActivities: nil)
        
        // This lines is for the popover you need to show in iPad
        activityViewController.popoverPresentationController?.sourceView = self.view
        
        // This line remove the arrow of the popover to show in iPad
        activityViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.down
        activityViewController.popoverPresentationController?.sourceRect = CGRect(x: 150, y: 150, width: 0, height: 0)
        
        // Pre-configuring activity items
        activityViewController.activityItemsConfiguration = [
            UIActivity.ActivityType.message
        ] as? UIActivityItemsConfigurationReading
        
        // Anything you want to exclude
        activityViewController.excludedActivityTypes = [
            UIActivity.ActivityType.postToWeibo,
            UIActivity.ActivityType.print,
            UIActivity.ActivityType.assignToContact,
            UIActivity.ActivityType.saveToCameraRoll,
            UIActivity.ActivityType.addToReadingList,
            UIActivity.ActivityType.postToFlickr,
            UIActivity.ActivityType.postToVimeo,
            UIActivity.ActivityType.postToTencentWeibo,
            UIActivity.ActivityType.postToFacebook
        ]
        
        activityViewController.isModalInPresentation = false
        self.present(activityViewController,
                     animated: true,
                     completion: nil)
    }
    
    func claim(surveyReference: SurveyReference, claim: Claim) {
        controllerInput?.claim(surveyReference: surveyReference, claim: claim)
    }
    
    func addFavorite(_ surveyReference: SurveyReference) {
        controllerInput?.addFavorite(surveyReference: surveyReference)
    }
    
    func updateSurveyStats(_ instances: [SurveyReference]) {
        controllerInput?.updateSurveyStats(instances)
    }
    
    func onSurveyTapped(_ instance: SurveyReference) {
        let backItem = UIBarButtonItem()
            backItem.title = ""
            navigationItem.backBarButtonItem = backItem
        navigationController?.pushViewController(PollController(surveyReference: instance, showNext: false), animated: true)
//        tabBarController?.setTabBarVisible(visible: false, animated: true)
    }
    
    func onDataSourceRequest(source: Survey.SurveyCategory, topic: Topic?) {
        controllerInput?.onDataSourceRequest(source: source, topic: topic)
    }
}

extension SurveysController: SurveysModelOutput {
    func onRequestCompleted(_ result: Result<Bool, Error>) {
        controllerOutput?.onRequestCompleted(result)
    }
}

private extension SurveysController {
 
    func setupUI() {
        
        switch mode {
        case .Topic:
            guard let topic = topic else { return }
            
            title = ""//topic.localized
            titleLabel.text = topic.localized
        case .Own:
            title = "my_publications".localized
        case .Favorite:
            title = "watching".localized
        default:
#if DEBUG
            print("")
#endif
        }
            
        navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        
        //Setup nav bar
        navigationItem.title = ""
        
        guard let navigationBar = self.navigationController?.navigationBar else { return }
        
        navigationBar.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleLabel.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: -2),
            titleLabel.topAnchor.constraint(equalTo: navigationBar.topAnchor, constant: 2),
            titleLabel.trailingAnchor.constraint(equalTo: navigationBar.trailingAnchor, constant: -(44+10)),
            titleLabel.leadingAnchor.constraint(equalTo: navigationBar.leadingAnchor, constant: 44+10)
        ])
//        setNavigationBarAppearance(largeTitleColor: mode == .Topic ? .white : .label, smallTitleColor: .clear)
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.shadowColor = nil
        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        navigationBar.prefersLargeTitles = false
        
        if #available(iOS 15.0, *) {
            navigationBar.compactScrollEdgeAppearance = appearance
        }
        setNavigationBarTintColor(traitCollection.userInterfaceStyle == .dark ? .systemBlue : .label)
    }
    
    @objc
    private func handleTap() {
        fatalError()
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
        case .Topic:
            guard let topic = topic else { return }
            
            appearance.backgroundColor = topic.tagColor
            navigationBar.tintColor = .white
            navigationBar.barTintColor = .white
        case .Own:
            navigationBar.tintColor = .label
            navigationBar.barTintColor = .label
        default:
#if DEBUG
            print("")
#endif
        }
        
        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        navigationBar.prefersLargeTitles = true
        
        if #available(iOS 15.0, *) {
            navigationBar.compactScrollEdgeAppearance = appearance
        }
    }
    
    private func setRightBarButton() {
        let button = UIBarButtonItem(image: UIImage(systemName: "slider.horizontal.3", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold)), style: .plain, target: self, action: #selector(self.handleTap))
        
        navigationItem.setRightBarButton(button, animated: true)
    }
}
