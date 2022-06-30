//
//  HotView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 10.03.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class HotView: UIView {
    
    deinit {
        print("HotView deinit")
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
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        setupUI()
        setObservers()
    }
    
    override func layoutSubviews() {
        
    }
    
    private func setObservers() {
        let remove = [Notifications.Surveys.Claimed,
                           Notifications.Surveys.Completed,
                           Notifications.Surveys.Rejected]
        remove.forEach { NotificationCenter.default.addObserver(self, selector: #selector(self.onRemove), name: $0, object: nil) }
    }
    
    @objc
    private func onRemove(_ notification: Notification) {
        guard let instance = notification.object as? SurveyReference,
              let survey = instance.survey else { return }
        if currentCard.survey == survey {
            skipCard()
        }
        else {
            surveyStack.remove(object: survey)
        }
    }
    
    // MARK: - Properties
    weak var viewInput: HotViewInput?
    weak var tabBarController: UITabBarController? {
        return parentController?.tabBarController
    }
    weak var navigationController: UINavigationController? {
        return parentController?.navigationController
    }
    var surveyStack: [Survey] = [] {
        didSet {
            var stack = surveyStack.uniqued()
            if !currentCard.isNil, let current = currentCard.survey {
                stack.remove(object: current)
            }
            if !nextCard.isNil, let next = nextCard?.survey {
                stack.remove(object: next)
            }
            surveyStack = stack
            guard surveyStack.isEmpty else { return }
            viewInput?.onEmptyStack()
        }
    }
    private var surveyPreviewInitialRect: CGRect {
        let indent: CGFloat = 10
        let origin = navigationController.isNil ? frame.origin : CGPoint(x: indent + frame.origin.x + frame.size.width,
                                                                         y: indent + (deviceType == .iPhoneSE ? UINavigationController.Constants.NavBarHeightSmallState : UINavigationController.Constants.NavBarHeightLargeState) + statusBarFrame.height)
//                                                                         y: indent + navigationController!.navigationBar.frame.height + statusBarFrame.height)
        let size = tabBarController.isNil ? frame.size : CGSize(width: frame.size.width - indent*2,
                                                                height: frame.size.height - tabBarController!.tabBar.frame.height - origin.y - indent)
//    height: frame.size.height - (tabBarController!.tabBar.isHidden ? 0 : tabBarController!.tabBar.frame.height) - origin.y - indent)
        return CGRect(origin: origin, size: size)
    }
    private var surveyPreviewCurrentOrigin: CGPoint {
        let indent: CGFloat = 10
        return navigationController.isNil ? frame.origin : CGPoint(x: indent + frame.origin.x,
                                                                   y: indent + (deviceType == .iPhoneSE ? UINavigationController.Constants.NavBarHeightSmallState : UINavigationController.Constants.NavBarHeightLargeState) + statusBarFrame.height)
    }
    private var previousCard: (HotCard & UIView)?
    private var currentCard: (HotCard & UIView)!
    private var nextCard: (HotCard & UIView)?
    private lazy var emptyCard: EmptyCard = self.createLoadingView()
    
    // MARK: - IB outlets
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var destinationView: UIView!
}

// MARK: - Controller Output
extension HotView: HotControllerOutput {
    func onDidAppear() {
        guard !Topics.shared.all.isEmpty, surveyStack.isEmpty else { return }
        viewInput?.onEmptyStack()
    }
    
    
    func skipCard() {
        setObservers()
        previousCard = currentCard
        onNext(nextCard)
    }
    
    func populateStack() {
        let stackSet: Set<Survey>    = Set(surveyStack)
        var hotSet: Set<Survey>      = Set(Surveys.shared.hot)
        let rejectedSet: Set<Survey> = Set(Surveys.shared.rejected)
        let completedSet: Set<Survey> = Set(Surveys.shared.all.filter({ $0.isComplete }))//Surveys.shared.completed)
        
        hotSet.subtract(rejectedSet)
        hotSet.subtract(completedSet)
        let diff = stackSet.symmetricDifference(hotSet)
        
        surveyStack.append(contentsOf: diff)
        onLoad()
    }
    
    func onLoad() {
        guard currentCard.isNil || nextCard.isNil else {
            return
        }
        
        if let card = getCard() {
            if !currentCard.isNil, nextCard.isNil {
                nextCard = card
            } else {
                if emptyCard.isEnabled {
                    self.emptyCard.setEnabled(false) { _ in
                        self.onNext(card)
                    }
                } else {
                    guard currentCard.isNil else { return }
                    onNext(card)
                }
            }
        } else {
            emptyCard.setEnabled(true) { _ in }
        }
    }
    
    func getCard() -> (HotCard & UIView)? {
        guard !surveyStack.isEmpty, let survey = surveyStack.removeFirst() as? Survey else { return nil }
        let card: (UIView & HotCard) = LargeCard(frame: destinationView.bounds, survey: survey, delegate: self)
        addSubview(card)
        card.translatesAutoresizingMaskIntoConstraints = false
        card.widthAnchor.constraint(equalTo: destinationView.widthAnchor).isActive = true
        card.heightAnchor.constraint(equalTo: destinationView.heightAnchor).isActive = true
//        card.centerXAnchor.constraint(equalTo: destinationView.centerXAnchor).isActive = true
        card.centerYAnchor.constraint(equalTo: destinationView.centerYAnchor).isActive = true
        
        let centerX = card.centerXAnchor.constraint(equalTo: destinationView.centerXAnchor, constant: destinationView.bounds.width + 10)
        centerX.identifier = "centerX"
        centerX.isActive = true
        self.setNeedsLayout()
        self.layoutIfNeeded()

        card.background.layer.masksToBounds = true
        card.background.layer.cornerRadius = card.frame.width * 0.05
        ///Add shadow
        card.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.6).cgColor
        card.layer.shadowPath = UIBezierPath(roundedRect: card.bounds, cornerRadius: card.frame.width * 0.05).cgPath
        card.layer.shadowRadius = 7
        card.layer.shadowOffset = .zero
        card.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
        return card
    }
    
    func onNext(_ card: (HotCard & UIView)?) {
        func nextFrame() {
            UIView.animate(withDuration: 0.32, delay: 0, options: .curveEaseInOut, animations: {
                card!.transform  = .identity
                if let constraint = card?.getAllConstraints().filter({$0.identifier == "centerX"}).first {
                    self.setNeedsLayout()
                    constraint.constant = 0
                    self.layoutIfNeeded()
                }
//                self.setNeedsLayout()
//                card!.centerXAnchor.constraint(equalTo: self.destinationView.centerXAnchor).isActive = true
//                self.layoutIfNeeded()
//                card!.frame.origin = self.surveyPreviewCurrentOrigin
                if !self.previousCard.isNil {
                    if let constraint = self.previousCard!.getAllConstraints().filter({$0.identifier == "centerX"}).first {
                        self.setNeedsLayout()
                        constraint.constant -= self.destinationView.bounds.width + 10
                        self.layoutIfNeeded()
                    }
                    self.previousCard!.alpha = 0
//                    self.previousCard!.voteButton.backgroundColor = K_COLOR_GRAY
//                    self.previousCard!.nextButton.tintColor = K_COLOR_GRAY
                    self.previousCard!.transform = self.previousCard!.transform.scaledBy(x: 0.85, y: 0.85)
                    self.surveyStack.remove(object: self.previousCard!.survey)
                }
            }) {
                _ in
                self.currentCard = card
                if !self.previousCard.isNil {
                    self.previousCard!.removeFromSuperview()
                }
                
                if let _nextPreview = self.getCard() {
                    self.nextCard = _nextPreview
                } else {
                    self.nextCard = nil
                }
            }
        }
        
        if !card.isNil {
            card!.transform = card!.transform.scaledBy(x: 0.85, y: 0.85)
            emptyCard.setEnabled(false) { _ in
                nextFrame()
            }
            return
        } else if card.isNil, let card = getCard() {
            if emptyCard.isEnabled {
                self.emptyCard.setEnabled(false) { _ in
                    self.onNext(card)
                }
            } else {
                guard currentCard.isNil else { return }
                onNext(card)
            }
        } else {
        
//        guard card.isNil else {
//            card!.transform = card!.transform.scaledBy(x: 0.85, y: 0.85)
////            addSubview(card!)
//            emptyCard.setEnabled(false) { _ in
//                nextFrame()
//            }
//            return
//        }
        UIView.animate(withDuration: 0.32, delay: 0, options: .curveEaseInOut, animations: {
            if !self.previousCard.isNil {
                self.previousCard!.alpha = 0
                self.previousCard!.frame.origin.x -= self.frame.width
                self.previousCard!.transform = self.previousCard!.transform.scaledBy(x: 0.85, y: 0.85)
            }
        }) {
            _ in
            if !self.currentCard.isNil {
                self.currentCard.removeFromSuperview()
                self.surveyStack.remove(object: self.currentCard.survey)
                self.currentCard = nil
            }
            self.emptyCard.setEnabled(true) { _ in }
            guard !self.previousCard.isNil else { return }
            self.previousCard!.removeFromSuperview()
        }
        return
        }
    }
    
    func onDidLayout() { }
}

// MARK: - UI Setup
extension HotView {
    private func setupUI() {
        // Add subviews and set constraints here
    }
    
    private func createLoadingView() -> EmptyCard {
        func getFrame() -> CGRect {
            let indent: CGFloat = 10
            let origin = navigationController.isNil ? frame.origin : CGPoint(x: indent + frame.origin.x,
                                                                             y: indent + navigationController!.navigationBar.frame.height + statusBarFrame.height)
            let size = tabBarController.isNil ? frame.size : CGSize(width: frame.size.width - indent*2,
                                                                    height: frame.size.height - (tabBarController!.tabBar.isHidden ? 0 : tabBarController!.tabBar.frame.height) - origin.y - indent)
            return CGRect(origin: origin, size: size)
        }
        
        let loadingView = EmptyCard(frame: getFrame(), delegate: self)
        loadingView.alpha = 0
        loadingView.background.layer.masksToBounds = true
        loadingView.background.layer.cornerRadius = loadingView.frame.width * 0.05
        ///Add shadow
        loadingView.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.6).cgColor
        loadingView.layer.shadowPath = UIBezierPath(roundedRect: loadingView.bounds, cornerRadius: loadingView.frame.width * 0.05).cgPath
        loadingView.layer.shadowRadius = 7
        loadingView.layer.shadowOffset = .zero
        loadingView.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
        addSubview(loadingView)
        return loadingView
    }
}

extension HotView: CallbackObservable {
    func callbackReceived(_ sender: Any) {
        if let string = sender as? String {
            if string == "claim" {
                let banner = Popup(frame: UIScreen.main.bounds, callbackDelegate: self, bannerDelegate: self, heightScaleFactor: deviceType == .iPhoneSE ? 0.8 : 0.6)
                banner.accessibilityIdentifier = "claim"
                banner.present(content: ClaimSelection(callbackDelegate: banner))
            } else if string == "next" {
                NotificationCenter.default.removeObserver(self)
                Surveys.shared.rejected.append(currentCard.survey)
                viewInput?.onReject(currentCard.survey)
                
//                API.shared.rejectSurvey(survey: currentCard.survey) { result in
//                    switch result {
//                    case .success(let json):
//                        Surveys.shared.load(json)
//                    case .failure(let error):
//                        showAlert(type: .Warning, buttons: [["Закрыть": [CustomAlertView.ButtonType.Ok: nil]]], text: error.localizedDescription)
//                    }
//                }
                previousCard = currentCard
                if nextCard.isNil, !surveyStack.isEmpty, let card = getCard() {
                    nextCard = card
                }
                onNext(nextCard)
            }
        } else if sender is Userprofile {
//            delegate.performSegue(withIdentifier: Segues.App.FeedToUser, sender: sender)
        } else if let _view = sender as? EmptyCard  {
            _view.startingPoint = convert(_view.createButton.center, to: tabBarController?.view)
        } else if let claim = sender as? Claim {
            NotificationCenter.default.removeObserver(self)
            viewInput?.onClaim(survey: currentCard.survey, reason: claim)
        } else if let survey = sender as? Survey {
            NotificationCenter.default.removeObserver(self)
            viewInput?.onVote(survey: survey)
        }
    }
}

extension HotView: BannerObservable {
    func onBannerWillAppear(_ sender: Any) {}
    
    func onBannerWillDisappear(_ sender: Any) {}
    
    func onBannerDidAppear(_ sender: Any) {}
    
    func onBannerDidDisappear(_ sender: Any) {
        if let banner = sender as? Banner {
            banner.removeFromSuperview()
        } else if let popup = sender as? Popup {
            popup.removeFromSuperview()
            if popup.accessibilityIdentifier == "exit" {
                skipCard()
            }
        }
    }
}
