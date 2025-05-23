//
//  HotView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 10.03.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

import UIKit
import Combine

class HotView: UIView {
  // MARK: - Public properties
  public weak var viewInput: (HotViewInput & UIViewController)? {
    didSet {
      guard !viewInput.isNil else { return }
      
      setTasks()
      setupUI()
    }
  }
  public var currentSurvey: Survey? {
    guard let hotCard = current as? HotCard else {
      return nil }
    
    return hotCard.item
  }
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  ///**Logic**
  public private(set) var current: Card?
  private var incoming: Card? {
    didSet {
      guard let hotCard = incoming as? HotCard else { return }
      //      guard let incoming = incoming else { return }
      //
      //      if let hotCard = incoming as? HotCard {
      hotCard.$action
        .filter { !$0.isNil }
      //          .throttle(for: .seconds(0.75), scheduler: DispatchQueue.main, latest: false)
        .sink { [unowned self] action in
          switch action {
          case .Vote:
            self.viewInput?.vote(hotCard.item)
          case .Next:
            self.viewInput?.reject(hotCard.item)
            self.next(self.viewInput?.deque())
          case .Claim:
            let popup = NewPopup(contentPadding: .uniform(size: self.padding*2))
            let content = ClaimPopupContent(parent: popup,
                                            object: hotCard.item.reference)
            //                                              surveyReference: hotCard.item.reference)
            content.$claim
              .filter { !$0.isNil && !$0!.isEmpty && $0!.keys.first is SurveyReference }
              .map { [$0!.keys.first as! SurveyReference: $0!.values.first!] }
              .sink { [unowned self] in self.viewInput?.claim($0!) }
              .store(in: &hotCard.subscriptions)
            
            
            //              content.$claim
            //                .filter { !$0.isNil }
            //                .sink { [unowned self] in self.viewInput?.claim($0!) }
            //                .store(in: &hotCard.subscriptions)
            popup.setContent(content)
            popup.didDisappearPublisher
              .sink { [unowned self] _ in
                popup.removeFromSuperview()
                
                ///Next if claimed
                guard hotCard.item.isClaimed else { return }
                
                delayAsync(delay: 0.25) { [unowned self] in
                  self.next(self.viewInput?.deque())
                }
              }
              .store(in: &self.subscriptions)
          case .none:
            fatalError()
          }
        }
        .store(in: &hotCard.subscriptions)
      //          .store(in: &incoming.subscriptions)
      //      } else {
      //        fatalError()
      //      }
    }
  }
  private var outgoing: Card?
  ///**UI**
  @IBOutlet var contentView: HotView!
  private let padding: CGFloat = 8
  
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
  override init(frame: CGRect) { super.init(frame: frame) }
  
  required init?(coder: NSCoder) { super.init(coder: coder) }
  
  // MARK: - Public methods
  func next(_ survey: Survey?) {
    guard let viewInput = viewInput else { return }
    
    // No need to continue if incoming is empty and current card is also empty
    if survey.isNil && current is EmptyHotCard {
      return
    }
    
    func push(_ instance: Survey?) {
      incoming = !instance.isNil ? {  HotCard(item: instance!, nextColor: viewInput.queue.peek?.topic.tagColor ?? instance!.topic.tagColor) }() : {
        let empty = EmptyHotCard()
        empty.buttonTapEvent
          .sink { [unowned self] in self.viewInput?.createPost() }
          .store(in: &subscriptions)
        
        return empty
      }()
      //      guard let instance = instance else {
      //        self.current = nil
      //
      //        return
      //      }
      //
      //      incoming = HotCard(item: instance, nextColor: viewInput.queue.peek?.topic.tagColor ?? instance.topic.tagColor)
      current = self.incoming
      addSubview(incoming!)
      incoming?.translatesAutoresizingMaskIntoConstraints = false
      incoming?.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: padding).isActive = true
      //      incoming?.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -padding).isActive = true
      //      incoming?.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -(padding + tabBarHeight)).isActive = true
      //      incoming?.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: padding).isActive = true
      //      incoming?.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -padding).isActive = true
      incoming?.widthAnchor.constraint(equalToConstant: appDelegate.window!.bounds.width - padding*2).isActive = true
      incoming?.heightAnchor.constraint(equalToConstant: bounds.height - (viewInput.navBarHeight + statusBarFrame.height + viewInput.tabBarHeight + padding*2)).isActive = true
      
      let constraint = incoming!.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor, constant: appDelegate.window!.bounds.width + padding*2)
      constraint.identifier = "centerXAnchor"
      constraint.isActive = true
      //      incoming?.placeXCentered(inside: self,
      //                               topInset: min(viewInput.navBarHeight, UINavigationController.Constants.NavBarHeightSmallState) + statusBarFrame.height + padding,
      //                               size: CGSize(width: bounds.width - padding*2,
      //                                            height: bounds.height - (viewInput.navBarHeight + statusBarFrame.height + viewInput.tabBarHeight + padding*2)))
      
      //      guard let constraint = incoming?.getConstraint(identifier: "centerXAnchor" ) else { return }
      
      setNeedsLayout()
      layoutIfNeeded()
      
      //      setNeedsLayout()
      //      constraint.constant += incoming!.bounds.width + padding*2
      //      layoutIfNeeded()
      
      incoming?.transform = .init(scaleX: 0.75, y: 0.75)
      
      UIView.animate(
        withDuration: 0.5,
        delay: 0,
        usingSpringWithDamping: 0.8,
        initialSpringVelocity: 0.3,
        options: [.curveEaseInOut],
        animations: { [unowned self] in
          self.setNeedsLayout()
          constraint.constant = .zero
          self.layoutIfNeeded()
          self.incoming?.transform = .identity
        }) { [unowned self] _ in
          //          self.current = self.incoming
          self.incoming = nil
          //          delayAsync(delay: 3) { [unowned self] in
          //            self.outgoing = current
          //            pop(self.outgoing!)
          //          }
        }
    }
    
    func pop(_ instance: Card) {
      guard let constraint = instance.getConstraint(identifier: "centerXAnchor") else { return }
      
      UIView.animate(
        withDuration: 0.5,
        delay: 0,
        usingSpringWithDamping: 0.8,
        initialSpringVelocity: 0.3,
        options: [.curveEaseInOut],
        animations: { [unowned self] in
          self.setNeedsLayout()
          constraint.constant -= instance.bounds.width + self.padding*2
          instance.transform = .init(scaleX: 0.75, y: 0.75)
          instance.alpha = 0
          self.layoutIfNeeded()
        }) { [unowned self] _ in
          if let card = instance as? EmptyHotCard {
            card.toggleAnimations(false)
          }
          instance.subscriptions.forEach { $0.cancel() }
          instance.removeFromSuperview()
          self.outgoing = nil
        }
    }
    
    ///**Pop outgoing**
    if let current = current {
      outgoing = current
      self.current = nil
      pop(outgoing!)
    }
    push(survey)
  }
  
  // MARK: - Overridden methods
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    
  }
}

private extension HotView {
  @MainActor
  func setupUI() {
    backgroundColor = .systemBackground
  }
  
  @MainActor
  func updateUI() {
    
  }
  
  func setTasks() {
    ///Check if current card gets banned
    Timer.publish(every: 1, on: .main, in: .common)
      .autoconnect()
      .filter { [unowned self] _ in self.viewInput?.isOnScreen == true }
      .filter { [unowned self] _ in !self.current.isNil && self.current!.isKind(of: HotCard.self) }
      .filter { [unowned self] _ in !(self.current! as! HotCard).isBanned }
      .filter { [unowned self] _ in (self.current! as! HotCard).item.isBanned }
      .delay(for: .seconds(1), scheduler: DispatchQueue.main)
      .sink { [unowned self] _ in
        if let hotCard = self.current as? HotCard {
          hotCard.setBanned() { [unowned self] in self.next(self.viewInput?.deque()) }
//        } else {
//          self.next(self.viewInput?.deque())
        }
      }
      .store(in: &subscriptions)
  }
}

extension HotView: HotControllerOutput {
  func setSurvey(_ instance: Survey?) {
//    let aaaa = Surveys.shared.all.first!
//    let test = HotCard(item: aaaa, nextColor: aaaa.topic.tagColor)
//    addSubview(test)
//    delay(seconds: 1) { [weak self] in
//      guard let self = self else { return }
//      
//      self.next(nil)
//    }
    
    next(instance)
  }
  
  
  func willAppear() {
    if let instance = current as? EmptyHotCard {
      instance.toggleAnimations(true)
    } else if let instance = current as? HotCard {
      instance.animateButtons()
      didLoad()
    }
  }
  
  func didDisappear() {
    guard let card = current as? EmptyHotCard else { return }
    
    card.toggleAnimations(false)
  }
  
  func didLoad() {
    ///Check up
    guard let current = current as? HotCard,
          (current.item.isBanned || current.item.isClaimed || current.item.isComplete)
    else { return }
    
//    delay(seconds: 0.5) { [weak self] in
//      guard let self = self else { return }
      
      if current.item.isComplete {
        current.setComplete() { [unowned self] in
          self.next(self.viewInput?.deque())
        }
      } else {
        next(viewInput?.deque())
      }
//    }
  }
}


//class HotView: UIView {
//
//    deinit {
//        print("HotView deinit")
//    }
//
//    // MARK: - Initialization
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        commonInit()
//    }
//
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//        commonInit()
//    }
//
//    private func commonInit() {
//        guard let contentView = self.fromNib() else { fatalError("View could not load from nib") }
//        addSubview(contentView)
//        contentView.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            contentView.topAnchor.constraint(equalTo: topAnchor),
//            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
//            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
//            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
//        ])
//        setupUI()
//        setObservers()
//    }
//
//    override func layoutSubviews() {
//
//    }
//
//    private func setObservers() {
//        let remove = [Notifications.Surveys.Claim,
//                           Notifications.Surveys.Completed,
//                           Notifications.Surveys.Rejected]
//        remove.forEach { NotificationCenter.default.addObserver(self, selector: #selector(self.onRemove), name: $0, object: nil) }
//    }
//
//    @objc
//    private func onRemove(_ notification: Notification) {
//        guard let instance = notification.object as? SurveyReference,
//              let survey = instance.survey,
//              !currentCard.isNil else { return }
//        if currentCard.survey == survey {
//            skipCard()
//        }
//        else {
//            surveyStack.remove(object: survey)
//        }
//    }
//
//    // MARK: - Properties
//    weak var viewInput: HotViewInput?
//    weak var tabBarController: UITabBarController? {
//        return parentController?.tabBarController
//    }
//    weak var navigationController: UINavigationController? {
//        return parentController?.navigationController
//    }
//    var surveyStack: [Survey] = [] {
//        didSet {
//            var stack = surveyStack.uniqued()
//            if !currentCard.isNil, let current = currentCard.survey {
//                stack.remove(object: current)
//            }
//            if !nextCard.isNil, let next = nextCard?.survey {
//                stack.remove(object: next)
//            }
//            surveyStack = stack
//            guard surveyStack.isEmpty else { return }
//            viewInput?.onEmptyStack()
//        }
//    }
//    private var surveyPreviewInitialRect: CGRect {
//        let indent: CGFloat = 10
//        let origin = navigationController.isNil ? frame.origin : CGPoint(x: indent + frame.origin.x + frame.size.width,
//                                                                         y: indent + (deviceType == .iPhoneSE ? UINavigationController.Constants.NavBarHeightSmallState : UINavigationController.Constants.NavBarHeightLargeState) + statusBarFrame.height)
////                                                                         y: indent + navigationController!.navigationBar.frame.height + statusBarFrame.height)
//        let size = tabBarController.isNil ? frame.size : CGSize(width: frame.size.width - indent*2,
//                                                                height: frame.size.height - tabBarController!.tabBar.frame.height - origin.y - indent)
////    height: frame.size.height - (tabBarController!.tabBar.isHidden ? 0 : tabBarController!.tabBar.frame.height) - origin.y - indent)
//        return CGRect(origin: origin, size: size)
//    }
//    private var surveyPreviewCurrentOrigin: CGPoint {
//        let indent: CGFloat = 10
//        return navigationController.isNil ? frame.origin : CGPoint(x: indent + frame.origin.x,
//                                                                   y: indent + (deviceType == .iPhoneSE ? UINavigationController.Constants.NavBarHeightSmallState : UINavigationController.Constants.NavBarHeightLargeState) + statusBarFrame.height)
//    }
//    private var previousCard: (HotCard & UIView)?
//    private var currentCard: (HotCard & UIView)!
//    private var nextCard: (HotCard & UIView)?
//    private lazy var emptyCard: EmptyCard = self.createLoadingView()
//
//    // MARK: - IB outlets
//    @IBOutlet var contentView: UIView!
//    @IBOutlet weak var destinationView: UIView!
//}
//
//// MARK: - Controller Output
//extension HotView: HotControllerOutput {
//    func onDidAppear() {
//
//        guard !Topics.shared.all.isEmpty, surveyStack.isEmpty else { return }
//        viewInput?.onEmptyStack()
//    }
//
//
//    func skipCard() {
//        setObservers()
//        previousCard = currentCard
//        onNext(nextCard)
//    }
//
//    func populateStack() {
//        let stackSet: Set<Survey>    = Set(surveyStack)
//        var hotSet: Set<Survey>      = Set(Surveys.shared.hot)
//        let rejectedSet: Set<Survey> = Set(Surveys.shared.rejected)
//        let completedSet: Set<Survey> = Set(Surveys.shared.all.filter({ $0.isComplete }))//Surveys.shared.completed)
//
//        hotSet.subtract(rejectedSet)
//        hotSet.subtract(completedSet)
//        let diff = stackSet.symmetricDifference(hotSet)
//
//        surveyStack.append(contentsOf: diff)
//        onLoad()
//    }
//
//    func onLoad() {
//
//#if DEBUG
//
//#endif
//
//        guard currentCard.isNil || nextCard.isNil else {
//            return
//        }
//
//        if let card = getCard() {
//            if !currentCard.isNil, nextCard.isNil {
//                nextCard = card
//            } else {
//                if emptyCard.isEnabled {
//                    self.emptyCard.setEnabled(false) { _ in
//                        self.onNext(card)
//                    }
//                } else {
//                    guard currentCard.isNil else { return }
//                    onNext(card)
//                }
//            }
//        } else {
//            emptyCard.setEnabled(true) { _ in }
//        }
//    }
//
//    func getCard() -> (HotCard & UIView)? {
//        guard !surveyStack.isEmpty, let survey = surveyStack.removeFirst() as? Survey else { return nil }
//        let card: (UIView & HotCard) = LargeCard(frame: destinationView.bounds, survey: survey, delegate: self)
//        addSubview(card)
//        card.translatesAutoresizingMaskIntoConstraints = false
//        card.widthAnchor.constraint(equalTo: destinationView.widthAnchor).isActive = true
//        card.heightAnchor.constraint(equalTo: destinationView.heightAnchor).isActive = true
////        card.centerXAnchor.constraint(equalTo: destinationView.centerXAnchor).isActive = true
//        card.centerYAnchor.constraint(equalTo: destinationView.centerYAnchor).isActive = true
//
//        let centerX = card.centerXAnchor.constraint(equalTo: destinationView.centerXAnchor, constant: destinationView.bounds.width + 10)
//        centerX.identifier = "centerX"
//        centerX.isActive = true
//        self.setNeedsLayout()
//        self.layoutIfNeeded()
//
//        card.background.layer.masksToBounds = true
//        card.background.layer.cornerRadius = card.frame.width * 0.05
//        ///Add shadow
//        card.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.6).cgColor
//        card.layer.shadowPath = UIBezierPath(roundedRect: card.bounds, cornerRadius: card.frame.width * 0.05).cgPath
//        card.layer.shadowRadius = 7
//        card.layer.shadowOffset = .zero
//        card.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
//        return card
//    }
//
//    func onNext(_ card: (HotCard & UIView)?) {
////        func nextFrame() {
////            UIView.animate(withDuration: 0.32, delay: 0, options: .curveEaseInOut, animations: {
////                card!.transform  = .identity
////                if let constraint = card?.getAllConstraints().filter({$0.identifier == "centerX"}).first {
////                    self.setNeedsLayout()
////                    constraint.constant = 0
////                    self.layoutIfNeeded()
////                }
//////                self.setNeedsLayout()
//////                card!.centerXAnchor.constraint(equalTo: self.destinationView.centerXAnchor).isActive = true
//////                self.layoutIfNeeded()
//////                card!.frame.origin = self.surveyPreviewCurrentOrigin
////                if !self.previousCard.isNil {
////                    if let constraint = self.previousCard!.getAllConstraints().filter({$0.identifier == "centerX"}).first {
////                        self.setNeedsLayout()
////                        constraint.constant -= self.destinationView.bounds.width + 10
////                        self.layoutIfNeeded()
////                    }
////                    self.previousCard!.alpha = 0
//////                    self.previousCard!.voteButton.backgroundColor = K_COLOR_GRAY
//////                    self.previousCard!.nextButton.tintColor = K_COLOR_GRAY
////                    self.previousCard!.transform = self.previousCard!.transform.scaledBy(x: 0.85, y: 0.85)
////                    self.surveyStack.remove(object: self.previousCard!.survey)
////                }
////            }) {
////                _ in
////                self.currentCard = card
////                if !self.previousCard.isNil {
////                    self.previousCard!.removeFromSuperview()
////                }
////
////                if let _nextPreview = self.getCard() {
////                    self.nextCard = _nextPreview
////                } else {
////                    self.nextCard = nil
////                }
////            }
////        }
////
////        if !card.isNil {
////            card!.transform = card!.transform.scaledBy(x: 0.85, y: 0.85)
////            emptyCard.setEnabled(false) { _ in
////                nextFrame()
////            }
////            return
////        } else if card.isNil, let card = getCard() {
////            if emptyCard.isEnabled {
////                self.emptyCard.setEnabled(false) { _ in
////                    self.onNext(card)
////                }
////            } else {
////                guard currentCard.isNil else { return }
////                onNext(card)
////            }
////        } else {
////
//////        guard card.isNil else {
//////            card!.transform = card!.transform.scaledBy(x: 0.85, y: 0.85)
////////            addSubview(card!)
//////            emptyCard.setEnabled(false) { _ in
//////                nextFrame()
//////            }
//////            return
//////        }
////        UIView.animate(withDuration: 0.32, delay: 0, options: .curveEaseInOut, animations: {
////            if !self.previousCard.isNil {
////                self.previousCard!.alpha = 0
////                self.previousCard!.frame.origin.x -= self.frame.width
////                self.previousCard!.transform = self.previousCard!.transform.scaledBy(x: 0.85, y: 0.85)
////            }
////        }) {
////            _ in
////            if !self.currentCard.isNil {
////                self.currentCard.removeFromSuperview()
////                self.surveyStack.remove(object: self.currentCard.survey)
////                self.currentCard = nil
////            }
////            self.emptyCard.setEnabled(true) { _ in }
////            guard !self.previousCard.isNil else { return }
////            self.previousCard!.removeFromSuperview()
////        }
////        return
////        }
//    }
//
//    func onDidLayout() { }
//}
//
//// MARK: - UI Setup
//extension HotView {
//    private func setupUI() {
//        // Add subviews and set constraints here
//    }
//
//    private func createLoadingView() -> EmptyCard {
//        func getFrame() -> CGRect {
//            let indent: CGFloat = 10
//            let origin = navigationController.isNil ? frame.origin : CGPoint(x: indent + frame.origin.x,
//                                                                             y: indent + navigationController!.navigationBar.frame.height + statusBarFrame.height)
//            let size = tabBarController.isNil ? frame.size : CGSize(width: frame.size.width - indent*2,
//                                                                    height: frame.size.height - (tabBarController!.tabBar.isHidden ? 0 : tabBarController!.tabBar.frame.height) - origin.y - indent)
//            return CGRect(origin: origin, size: size)
//        }
//
//        let loadingView = EmptyCard(frame: getFrame(), delegate: self)
//        loadingView.alpha = 0
//        loadingView.background.layer.masksToBounds = true
//        loadingView.background.layer.cornerRadius = loadingView.frame.width * 0.05
//        ///Add shadow
//        loadingView.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.6).cgColor
//        loadingView.layer.shadowPath = UIBezierPath(roundedRect: loadingView.bounds, cornerRadius: loadingView.frame.width * 0.05).cgPath
//        loadingView.layer.shadowRadius = 7
//        loadingView.layer.shadowOffset = .zero
//        loadingView.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
//        addSubview(loadingView)
//        return loadingView
//    }
//}
//
//extension HotView: CallbackObservable {
//    func callbackReceived(_ sender: Any) {
//        if let string = sender as? String {
//            if string == "claim" {
//                fatalError()
////                let banner = Popup(callbackDelegate: self, bannerDelegate: self, heightScaleFactor: deviceType == .iPhoneSE ? 0.8 : 0.6)
////                banner.accessibilityIdentifier = "claim"
////                banner.present(content: ClaimSelection(callbackDelegate: banner))
//            } else if string == "next" {
//                NotificationCenter.default.removeObserver(self)
//                Surveys.shared.rejected.append(currentCard.survey)
//                viewInput?.onReject(currentCard.survey)
//
////                API.shared.rejectSurvey(survey: currentCard.survey) { result in
////                    switch result {
////                    case .success(let json):
////                        Surveys.shared.load(json)
////                    case .failure(let error):
////                        showAlert(type: .Warning, buttons: [["Закрыть": [CustomAlertView.ButtonType.Ok: nil]]], text: error.localizedDescription)
////                    }
////                }
//                previousCard = currentCard
//                if nextCard.isNil, !surveyStack.isEmpty, let card = getCard() {
//                    nextCard = card
//                }
//                onNext(nextCard)
//            }
//        } else if sender is Userprofile {
////            delegate.performSegue(withIdentifier: Segues.App.FeedToUser, sender: sender)
//        } else if let _view = sender as? EmptyCard  {
//            _view.startingPoint = convert(_view.createButton.center, to: tabBarController?.view)
//        } else if let claim = sender as? Claim {
//            NotificationCenter.default.removeObserver(self)
//            viewInput?.onClaim(survey: currentCard.survey, reason: claim)
//        } else if let survey = sender as? Survey {
//            NotificationCenter.default.removeObserver(self)
//            viewInput?.onVote(survey: survey)
//        }
//    }
//}
//
//extension HotView: BannerObservable {
//    func onBannerWillAppear(_ sender: Any) {}
//
//    func onBannerWillDisappear(_ sender: Any) {}
//
//    func onBannerDidAppear(_ sender: Any) {}
//
//    func onBannerDidDisappear(_ sender: Any) {
//        if let banner = sender as? Banner {
//            banner.removeFromSuperview()
//        } else if let popup = sender as? Popup {
//            popup.removeFromSuperview()
//            if popup.accessibilityIdentifier == "exit" {
//                skipCard()
//            }
//        }
//    }
//}
