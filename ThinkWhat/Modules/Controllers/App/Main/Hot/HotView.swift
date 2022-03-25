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
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(contentView)
        setupUI()
    }
    
    override func layoutSubviews() {
        
    }
    
    // MARK: - Properties
    weak var viewInput: HotViewInput?
    weak var tabBarController: UITabBarController? {
        return parentController?.tabBarController
    }
    weak var navigationController: UINavigationController? {
        return parentController?.navigationController
    }
    var surveyStack: [Survey] = []
//    var surveyStack: [Survey] {
//        get {
//            return viewInput?.surveyStack ?? []
//        }
//        set {
//            viewInput?.surveyStack = newValue
//        }
//    }
    private var surveyPreviewInitialRect: CGRect {
        let indent: CGFloat = 10
        let origin = navigationController.isNil ? frame.origin : CGPoint(x: indent + frame.origin.x + frame.size.width,
                                                                         y: indent + navigationController!.navigationBar.frame.height + statusBarFrame.height)
        let size = tabBarController.isNil ? frame.size : CGSize(width: frame.size.width - indent*2,
                                                                height: frame.size.height - (tabBarController!.tabBar.isHidden ? 0 : tabBarController!.tabBar.frame.height) - origin.y - indent)
        return CGRect(origin: origin, size: size)
    }
    private var surveyPreviewCurrentOrigin: CGPoint {
        let indent: CGFloat = 10
        return navigationController.isNil ? frame.origin : CGPoint(x: indent + frame.origin.x,
                                                                   y: indent + navigationController!.navigationBar.frame.height + statusBarFrame.height)
    }
    private var previousCard: CardView?
    private var currentCard: CardView!
    private var nextCard: CardView?
    private lazy var loadingView: EmptySurvey = self.createLoadingView()
    
    // MARK: - IB outlets
    @IBOutlet var contentView: UIView!
}

// MARK: - Controller Output
extension HotView: HotControllerOutput {
    func onLoad() {
//        Surveys.shared.hot.filter({ $0 })
        
        guard currentCard.isNil || nextCard.isNil else {
            return
        }
        guard let card = getCard() else {
            return
        }
        onNext(card)
    }
    
    func getCard() -> CardView? {
        guard !Surveys.shared.hot.isEmpty, let survey = Surveys.shared.hot.filter({$0 != self.surveyStack.map({$0}).last}).first else { return nil }
        if surveyStack.filter({ $0.hashValue == survey.hashValue }).isEmpty {
            surveyStack.append(survey)
        }
        let card = CardView(frame: surveyPreviewInitialRect, survey: survey, delegate: self)
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
    
    func onNext(_ card: CardView?) {
        func nextFrame() {
            UIView.animate(withDuration: 0.32, delay: 0, options: .curveEaseInOut, animations: {
                card!.transform  = .identity
                card!.frame.origin = self.surveyPreviewCurrentOrigin
                if !self.previousCard.isNil {
                    self.previousCard!.alpha = 0
                    self.previousCard!.voteButton.backgroundColor = K_COLOR_GRAY
                    self.previousCard!.nextButton.tintColor = K_COLOR_GRAY
                    self.previousCard!.frame.origin.x -= self.frame.width
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
        
        guard card.isNil else {
            card!.transform = card!.transform.scaledBy(x: 0.85, y: 0.85)
            addSubview(card!)
            loadingView.setEnabled(false) { _ in
                nextFrame()
            }
            return
        }
        UIView.animate(withDuration: 0.32, delay: 0, options: .curveEaseInOut, animations: {
            if !self.previousCard.isNil {
                self.previousCard!.alpha = 0
                self.previousCard!.voteButton.backgroundColor = K_COLOR_GRAY
                self.previousCard!.nextButton.tintColor = K_COLOR_GRAY
                self.previousCard!.frame.origin.x -= self.frame.width
                self.previousCard!.transform = self.previousCard!.transform.scaledBy(x: 0.85, y: 0.85)
            }
        }) {
            _ in
            self.currentCard.removeFromSuperview()
            self.surveyStack.remove(object: self.currentCard.survey)
            self.currentCard = nil
            Surveys.shared.hot.removeAll()
            self.viewInput?.onEmptyStack()
            self.loadingView.setEnabled(true) {
                completed in
                self.loadingView.createButton.layer.cornerRadius = self.loadingView.createButton.frame.height / 2
            }
            guard !self.previousCard.isNil else { return }
            self.previousCard!.removeFromSuperview()
        }
        return
    }
    
    func onDidLayout() {
        
    }
}

// MARK: - UI Setup
extension HotView {
    private func setupUI() {
        // Add subviews and set constraints here
    }
    
    private func createLoadingView() -> EmptySurvey {
        let loadingView = EmptySurvey(frame: surveyPreviewInitialRect, delegate: self)
        loadingView.alpha = 0
        loadingView.center = center
        loadingView.setNeedsLayout()
        loadingView.layoutIfNeeded()
        loadingView.createButton.layer.cornerRadius = loadingView.createButton.frame.height / 2
        addSubview(loadingView)
        return loadingView
    }
}

extension HotView: CallbackDelegate {
    func callbackReceived(_ sender: Any) {
        if let button = sender as? UIButton, let accessibilityIdentifier = button.accessibilityIdentifier {
            if accessibilityIdentifier == "Vote" {//Vote
//                delegate.performSegue(withIdentifier: Segues.App.FeedToSurveyFromTop, sender: self)
            } else if accessibilityIdentifier == "Reject" {//Reject
                Surveys.shared.rejected.append(currentCard.survey)
                API.shared.rejectSurvey(survey: currentCard.survey) { result in
                    switch result {
                    case .success(let json):
                        Surveys.shared.load(json)
                    case .failure(let error):
                        showAlert(type: .Warning, buttons: [["Закрыть": [CustomAlertView.ButtonType.Ok: nil]]], text: error.localizedDescription)
                    }
                }
                previousCard = currentCard
                onNext(nextCard)
            }
        } else if sender is Userprofile {
//            delegate.performSegue(withIdentifier: Segues.App.FeedToUser, sender: sender)
        } else if let _view = sender as? EmptySurvey  {
//            isMakingStackPaused = true
            _view.startingPoint = convert(_view.createButton.center, to: tabBarController?.view)

//            delegate.performSegue(withIdentifier: Segues.App.FeedToNewSurvey, sender: _view)
        } else if sender is Claim { //Claim
            previousCard = currentCard
            delay(seconds: 0.5) {
//                self.nextSurvey(self.nextCardView)
            }
        } else if sender is Survey { //Voted
            delay(seconds: 0.4) {
                self.previousCard = self.currentCard
//                self.nextSurvey(self.nextCardView)
            }
        }
    }
}
