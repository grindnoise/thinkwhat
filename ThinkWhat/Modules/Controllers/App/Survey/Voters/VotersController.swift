//
//  VotersController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 19.04.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class VotersController: UIViewController {

    // MARK: - Properties
    public var controllerOutput: VotersControllerOutput?
    var controllerInput: VotersControllerInput?
    
    // MARK: - Private properties
    private var observers: [NSKeyValueObservation] = []
    private var notifications: [Task<Void, Never>?] = []
    private let _answer: Answer
    private let _color: UIColor
    private let filterButton = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: 32, height: 32)))
    private var isFilterEnabled = false
    private var filters: [String: AnyObject] = [:]
    private var requestAttempt = 0
    private lazy var titleLabel: InsetLabel = {
        let label = InsetLabel()
        label.insets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        label.backgroundColor = color
        label.textColor = .black
        label.text = answer.description
        label.textAlignment = .center
        label.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .headline)
        label.numberOfLines = 1
        label.accessibilityIdentifier = "titleLabel"
        
        return label
    }()
    private lazy var countLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.text = answer.totalVotes.roundedWithAbbreviations
        label.textAlignment = .center
        label.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Bold.rawValue, forTextStyle: .title3)
        label.numberOfLines = 1
        label.accessibilityIdentifier = "countLabel"
        
        return label
    }()
    private let padding: CGFloat = 8
    
    // MARK: - Destructor
    deinit {
        ///Destruct notifications
        notifications.forEach { $0?.cancel() }
        NotificationCenter.default.removeObserver(self)
#if DEBUG
        print("\(String(describing: type(of: self))).\(#function)")
#endif
    }

    // MARK: - Initialization
    init(answer _answer: Answer, color: UIColor) {
        self._answer = _answer
        self._color = color
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Private methods
    private func setupUI() {
//        title = "voted".localized + ": \(answer.totalVotes.roundedWithAbbreviations)"
        
        guard let navigationBar = self.navigationController?.navigationBar else { return }
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        
        let countWidth = min(answer.totalVotes.roundedWithAbbreviations.width(withConstrainedHeight: UINavigationController.Constants.ImageSizeForLargeState, font: countLabel.font), navigationBar.frame.width - UINavigationController.Constants.ImageRightMargin*2)
        let titleWidth = min(answer.description.width(withConstrainedHeight: UINavigationController.Constants.ImageSizeForLargeState, font: titleLabel.font) + titleLabel.insets.left*4, navigationBar.frame.width - UINavigationController.Constants.ImageRightMargin*2 - padding) - countWidth
        
        navigationBar.addSubview(titleLabel)
        navigationBar.addSubview(countLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: navigationBar.leadingAnchor, constant: UINavigationController.Constants.ImageRightMargin),
            titleLabel.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: -UINavigationController.Constants.ImageBottomMarginForLargeState/2),
//            label.topAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: UINavigationController.Constants.ImageBottomMarginForLargeState/2),
            titleLabel.heightAnchor.constraint(equalToConstant: UINavigationController.Constants.ImageSizeForLargeState),
            countLabel.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: padding),
            countLabel.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: -UINavigationController.Constants.ImageBottomMarginForLargeState/2),
//            label.topAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: UINavigationController.Constants.ImageBottomMarginForLargeState/2),
            countLabel.heightAnchor.constraint(equalToConstant: UINavigationController.Constants.ImageSizeForLargeState),
        ])
        
        let titleConstraint = titleLabel.widthAnchor.constraint(equalToConstant: titleWidth)
        titleConstraint.identifier = "width"
        titleConstraint.isActive = true
        
        let countConstraint = countLabel.widthAnchor.constraint(equalToConstant: countWidth)
        countConstraint.identifier = "width"
        countConstraint.isActive = true
        
        observers.append(titleLabel.observe(\InsetLabel.bounds, options: .new) { view, change in
            guard let newValue = change.newValue else { return }
            view.cornerRadius = newValue.height/2.25
        })
        
        observers.append(countLabel.observe(\UILabel.bounds, options: .new) { view, change in
            guard let newValue = change.newValue else { return }
            view.cornerRadius = newValue.height/2.25
        })
        
        self.titleLabel.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        self.countLabel.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        self.titleLabel.alpha = 0
        self.countLabel.alpha = 0
    }
    
    private func setObservers() {
        //Observe votes count
        notifications.append(Task { @MainActor [weak self] in
            for await notification in NotificationCenter.default.notifications(for: Notifications.SurveyAnswers.TotalVotes) {
                guard let self = self,
                      let instance = notification.object as? Answer,
                      self.answer == instance
                else { return }
                
//                self.title = "voted".localized + ": \(answer.totalVotes.roundedWithAbbreviations)"
            }
        })
    }
    
    private func setFilterButton() {
        guard answer.voters.count > 1 else { return }
        let gesture = UITapGestureRecognizer(target: self, action: #selector(VotersController.showFilter))
        filterButton.addGestureRecognizer(gesture)
        filterButton.contentMode = .scaleAspectFit
        filterButton.image = ImageSigns.filter.image
        filterButton.tintColor = .systemGray
        navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: filterButton)]
    }
    
    private func loadData() {
        requestAttempt += 1
        guard requestAttempt <= MAX_REQUEST_ATTEMPTS else {
            requestAttempt = 0
            controllerOutput?.onDataLoaded(.failure(AppError.server))
            return
        }
        controllerInput?.loadData()
    }
    
    @objc
    private func showFilter() {
        controllerOutput?.onFilterTapped()
    }
    
    // MARK: - Overriden methods
    override func viewDidLoad() {
        super.viewDidLoad()

        let model = VotersModel()
               
        self.controllerOutput = view as? VotersView
        self.controllerOutput?
            .viewInput = self
        self.controllerInput = model
        self.controllerInput?
            .modelOutput = self
        
        navigationController?.navigationBar.prefersLargeTitles = true
                navigationItem.largeTitleDisplayMode = .always

        
//        self.view = view as UIView
        setFilterButton()
        loadData()
        setupUI()
        setObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.25, delay: 0.1, options: .curveEaseInOut) {
            self.countLabel.transform = .identity
            self.titleLabel.transform = .identity
            self.countLabel.alpha = 1
            self.titleLabel.alpha = 1
        }
    }

    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        guard parent.isNil else { return }
//        clearNavigationBar(clear: true)
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.15, delay: 0, options: .curveEaseInOut) {
            self.titleLabel.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            self.countLabel.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            self.titleLabel.alpha = 0
            self.countLabel.alpha = 0
        } completion: { _ in
            self.titleLabel.removeFromSuperview()
            self.countLabel.removeFromSuperview()
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        guard !controllerOutput.isNil else { return }
        if isFilterEnabled {
            filterButton.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : .black
        } else {
            filterButton.tintColor = .systemGray
        }
    }
}

// MARK: - View Input
extension VotersController: VotersViewInput {
    func setFilterEnabled(_ isOn: Bool) {
        isFilterEnabled = isOn
        if isOn {
            filterButton.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : .black
        } else {
            filterButton.tintColor = .systemGray
        }
    }
    
//    var indexPath: IndexPath {
//        return _indexPath
//    }
    
    var answer: Answer {
        return _answer
    }
    
    var color: UIColor {
        return _color
    }
}

// MARK: - Model Output
extension VotersController: VotersModelOutput {
    func onDataLoaded(_ result: Result<[Userprofile], Error> ){
        switch result {
        case .success:
            controllerOutput?.onDataLoaded(result)
        case .failure(let error):
#if DEBUG
            print(error)
#endif
            loadData()
        }
    }
}

