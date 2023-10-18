//
//  NewPollCollectionView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 17.03.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class NewPollCollectionView: UICollectionView {
  
  typealias Source = UICollectionViewDiffableDataSource<NewPollController.Stage, Int>
  typealias Snapshot = NSDiffableDataSourceSnapshot<NewPollController.Stage, Int>
  
  // MARK: - Public properties
  ///**Publishers**
  public let progressPublisher = PassthroughSubject<Double, Never>()
  public private(set) var addImagePublisher = PassthroughSubject<Void, Never>()
//  public let profileTapPublisher = PassthroughSubject<Bool, Never>()
//  public var imagePublisher = PassthroughSubject<Mediafile, Never>()
//  public var webPublisher = PassthroughSubject<URL, Never>()
  ///**Logic**
  @Published public var isMovingToParent: Bool?
  @Published public var isKeyboardOnScreen: Bool = false
  @Published public private(set) var stage: NewPollController.Stage = .Topic {
    didSet {
      guard oldValue != stage else { return }
      
      progressPublisher.send(stage.percent())
      
      isScrollEnabled = stage == .Ready
    }
  }
//  @Published public private(set) var topic: Topic! {
  public private(set) var topic: Topic! {
    didSet {
      if oldValue != topic {
        topicPublisher.send(topic)
      }
      
      guard oldValue.isNil,
            !topic.isNil
      else { return }
    
      _preview?.topic = topic
    
      guard let stage = stage.next() else { return }
      
      self.stage = stage
    }
  }
  public private(set) var topicPublisher = CurrentValueSubject<Topic?, Never>(nil)
  @Published public private(set) var title: String! {
    didSet {
      guard let title = title else { return }
      
      _preview?.title = title
      
      guard oldValue.isNil,
            let stage = stage.next()
      else { return }
      
      self.stage = stage
    }
  }
  @Published public private(set) var pollDescription: String! {
    didSet {
      guard let pollDescription = pollDescription else { return }
      
      _preview?.detailsDescription = pollDescription
      
      guard oldValue.isNil,
            let stage = stage.next()
      else { return }
      
      self.stage = stage
    }
  }
  @Published public private(set) var question: String! {
    didSet {
      guard !question.isNil else { return }
      
      _preview?.question = question
      
      guard oldValue.isNil,
            let stage = stage.next()
      else { return }
      
      self.stage = stage
    }
  }
//    @Published
  public private(set) var choices: [NewPollChoice] = (0...0).map { NewPollChoice(text: "new_poll_choice_placeholder".localized + String(describing: $0 + 1)) } {
    didSet {
      choicesPublisher.send(choices)
      
      guard !_preview.isNil else { return }
      
      _preview?.answers = choices.map { $0.text }.enumerated().map({ (index,title) in return Answer(description: "", title: title, survey: _preview!, order: index) })
    }
  }
  private let choicesPublisher = PassthroughSubject<[NewPollChoice], Never>()
//  @Published public private(set) var choices: [NewPollChoice] = (0...1).map { NewPollChoice(text: "new_poll_survey_choice_placeholder".localized + String(describing: $0 + 1)) } {
//    didSet {
//      guard oldValue.isNil,
//            !question.isNil,
//            let stage = stage.next()
//      else { return }
//
//      self.stage = stage
//    }
//  }
  @Published public private(set) var images = [NewPollImage]() {
    didSet {
      guard !_preview.isNil else { return }
      
      _preview?.media =  images.enumerated().map { order, item in Mediafile(title: item.text, order: order, survey: _preview!, image: item.image) }
    }
  }
  @Published public private(set) var hyperlink: String = "" {
    didSet {
      _preview?.url = URL(string: hyperlink)
//      guard oldValue.isEmpty,
////            hyperlink != oldValue,
//            stage.rawValue <= NewPollController.Stage.Hyperlink.rawValue,
//            let stage = stage.next()
//      else { return }
//
//      self.stage = stage
    }
  }
  @Published public private(set) var commentsEnabled: Bool? {
    didSet {
      guard let commentsEnabled = commentsEnabled else { return }
      
      _preview?.isCommentingAllowed = commentsEnabled
    }
  }
  @Published public private(set) var anonymityEnabled: Bool? {
    didSet {
      guard let anonymityEnabled = anonymityEnabled else { return }
      
      _preview?.isAnonymous = anonymityEnabled
    }
  }
  @Published public private(set) var isHot: Bool? {
    didSet {
      guard let value = isHot,
            oldValue != value,
            let balance = costItems.filter({ $0.title == "balance".localized }).first,
            let limit = costItems.filter({ $0.title == "voters_option".localized }).first,
            let total = costItems.filter({ $0.title == "total_bill".localized }).first
      else { return }
      
      _preview?.isHot = value
      
      if value {
        let hot = costItems.filter({ $0.title == "hot_option".localized }).first ?? {
          let item = CostItem(type: .Expense, title: "hot_option".localized, cost: PriceList.shared.hotPost)
          costItems.append(item)
          return item
        }()
        
        hot.cost = PriceList.shared.hotPost
        total.cost = limit.cost + hot.cost
      } else {
        if let hot = costItems.filter({ $0.title == "hot_option".localized }).first {
          costItems.remove(object: hot)
        }
        
        total.cost = limit.cost
      }
      shortage = balance.cost - total.cost
      hasEnoughtBudget = (balance.cost - total.cost) >= 0
    }
  }
  @Published public private(set) var limit: Int? {
    didSet {
      guard let value = limit,
            oldValue != value,
            let balance = costItems.filter({ $0.title == "balance".localized }).first,
            let limit = costItems.filter({ $0.title == "voters_option".localized }).first,
            let total = costItems.filter({ $0.title == "total_bill".localized }).first
      else { return }
      
      _preview?.votesLimit = value
      
      limit.cost = value
      total.cost = limit.cost + (costItems.filter({ $0.title == "hot_option".localized }).first?.cost ?? 0)
      shortage = balance.cost - total.cost
      hasEnoughtBudget = (balance.cost - total.cost) >= 0
    }
  }
  @Published public private(set) var costItems: [CostItem] = {
    [CostItem(type: .Balance, title: "balance".localized, cost: Userprofiles.shared.current!.balance),
     CostItem(type: .Expense, title: "voters_option".localized, cost: 100),
     CostItem(type: .Total, title: "total_bill".localized, cost: Userprofiles.shared.current!.balance - 100)]
  }()
  
  
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  ///**Logic**
  private var source: Source!
  @Published public private(set) var hasEnoughtBudget = true {
    didSet {
      guard let total = costItems.filter({ $0.title == "total_bill".localized }).first else { return }
      
      total.isNegative = !hasEnoughtBudget
    }
  }
  public private(set) var shortage = 0
  ///**UI**
  private let padding: CGFloat = 8
  ///**Publishers**
//  @Published private(set) var stageAnimationFinished: NewPollController.Stage! {
//    didSet {
//      print(stageAnimationFinished.rawValue)
//    }
//  }
  private(set) var stageAnimationFinished = CurrentValueSubject<NewPollController.Stage?, Never>(nil)
  private(set) var topicStageAnimationFinished = PassthroughSubject<Void, Never>()
  private(set) var titleStageAnimationFinished = PassthroughSubject<Void, Never>()
  private(set) var descriptionStageAnimationFinished = PassthroughSubject<Void, Never>()
  private(set) var questionStageAnimationFinished = PassthroughSubject<Void, Never>()
  private(set) var choicesStageAnimationFinished = PassthroughSubject<Void, Never>()
  private(set) var imagesStageAnimationFinished = PassthroughSubject<Void, Never>()
  private(set) var hyperlinkStageAnimationFinished = PassthroughSubject<Void, Never>()
  private(set) var commentsStageAnimationFinished = PassthroughSubject<Void, Never>()
  private(set) var anonStageAnimationFinished = PassthroughSubject<Void, Never>()
  private(set) var limitsStageAnimationFinished = PassthroughSubject<Void, Never>()
  private(set) var hotStageAnimationFinished = PassthroughSubject<Void, Never>()
  private(set) var costPublisher = PassthroughSubject<Void, Never>()
  private var _preview: Survey?
  
  
  // MARK: - Initialization
  init() {
    super.init(frame: .zero, collectionViewLayout: UICollectionViewLayout())

    setupUI()
    setTasks()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  
  // MARK: - Destructor
  deinit {
    if let instance = _preview {
      SurveyReferences.shared.all.remove(object: instance.reference)
      Surveys.shared.all.remove(object: instance)
    }
    observers.forEach { $0.invalidate() }
    tasks.forEach { $0?.cancel() }
    subscriptions.forEach { $0.cancel() }
    NotificationCenter.default.removeObserver(self)
#if DEBUG
    print("\(String(describing: type(of: self))).\(#function)")
#endif
  }
  
  // MARK: - Public methods
  public func onImageScroll(_ index: Int) {
    guard let cell = cellForItem(at: IndexPath(row: 0, section: 2)) as? ImageCell else { return }
    
    cell.scrollToImage(at: index)
  }
  
  public func addImage(_ image: UIImage) {
    images.append(NewPollImage(image: image, text: ""))
  }
  
  public func makePreview() -> Survey {
    if let oldValue = _preview {
      SurveyReferences.shared.all.remove(object: oldValue.reference)
      Surveys.shared.all.remove(object: oldValue)
    }
    let instance = Survey(type: .Poll,
                          title: title,
                          topic: topic,
                          description: pollDescription,
                          question: question,
                          answers: choices.map { $0.text },
                          media: images,
                          url: URL(string: hyperlink),
                          voteCapacity: limit!,
                          isPrivate: false,
                          isAnonymous: anonymityEnabled!,
                          isCommentingAllowed: commentsEnabled!,
                          isHot: isHot!,
                          isFavorite: false,
                          isOwn: true,
                          isNew: true,
                          isTop: true,
                          isBanned: false,
                          commentsTotal: 0,
                          shareLink: .init(hash: "", enc: ""))
    Surveys.shared.append([instance])
    _preview = instance
    
    return instance
  }
}

private extension NewPollCollectionView {
  @MainActor
  func setupUI() {
    isScrollEnabled = false
    collectionViewLayout = UICollectionViewCompositionalLayout { section, env -> NSCollectionLayoutSection? in
      var layoutConfig = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
      layoutConfig.backgroundColor = .clear
      layoutConfig.showsSeparators = false
      
      let sectionLayout = NSCollectionLayoutSection.list(using: layoutConfig, layoutEnvironment: env)
      sectionLayout.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: section == NewPollController.Stage.allCases.count-1 ? 80 : 0, trailing: 0)
      sectionLayout.interGroupSpacing = 8
      return sectionLayout
    }
    
    let topicCellRegistration = UICollectionView.CellRegistration<NewPollTopicCell, AnyHashable> { [unowned self] cell, indexPath, _ in
      cell.stageGlobal = self.stage
      cell.stage = .Topic
      cell.topic = self.topic
      cell.$topic
        .filter { !$0.isNil }
        .receive(on: DispatchQueue.main)
//        .delay(for: .milliseconds(, scheduler: <#T##Scheduler#>)
        .sink { [unowned self] in self.topic = $0 }
        .store(in: &self.subscriptions)
      cell.animationCompletePublisher
        .receive(on: DispatchQueue.main)
        .sink { [unowned self] _ in
//          self.stageAnimationFinished.send(.Topic)
          self.topicStageAnimationFinished.send()
          self.topicStageAnimationFinished.send(completion: .finished)
        }// = .Topic }
        .store(in: &self.subscriptions)
      cell.stageCompletePublisher
        .delay(for: .seconds(0.5), scheduler: DispatchQueue.main)
        .receive(on: DispatchQueue.main)
        .sink { [unowned self] _ in self.scrollToItem(at: IndexPath(row: 0, section: indexPath.section+1), at: .top, animated: true) }
        .store(in: &self.subscriptions)
      
      self.$stage
        .sink { cell.stageGlobal = $0 }
        .store(in: &self.subscriptions)
      
      var config = UIBackgroundConfiguration.listPlainCell()
      config.backgroundColor = .clear
      cell.backgroundConfiguration = config
      cell.clipsToBounds = false
      cell.automaticallyUpdatesBackgroundConfiguration = false
      
      guard self.stage == .Topic else { return }
      
      delay(seconds: 0.5) {
        cell.present(seconds: 1.5)
      }
    }
    
    let titleCellRegistration = UICollectionView.CellRegistration<NewPollTextCell, AnyHashable> { [unowned self] cell, indexPath, _ in
      cell.textAlignment = .center
//      cell.topicColor = self.topic.isNil ? .systemGray4 : self.topic!.tagColor
      cell.minHeight = 0//60
      cell.stageGlobal = self.stage
      cell.stage = .Title
      cell.placeholderFont = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .title1)
      cell.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Bold.rawValue, forTextStyle: .title1)
      cell.text = self.title
      self.$stage
        .sink { cell.stageGlobal = $0 }
        .store(in: &self.subscriptions)
      self.$isKeyboardOnScreen
        .receive(on: DispatchQueue.main)
        .sink { cell.isKeyboardOnScreen = $0 }
        .store(in: &self.subscriptions)
//      self.$topic
      self.topicPublisher
        .filter { !$0.isNil }
        .filter { cell.color != $0!.tagColor }
        .receive(on: DispatchQueue.main)
        .sink { cell.color = $0!.tagColor }
        .store(in: &self.subscriptions)
      self.$isMovingToParent
        .filter { !$0.isNil }
        .receive(on: DispatchQueue.main)
        .sink { cell.isMovingToParent = $0! }
        .store(in: &self.subscriptions)
      cell.$text
        .filter { !$0.isNil }
        .receive(on: DispatchQueue.main)
        .sink { [unowned self] in self.title = $0 }
        .store(in: &self.subscriptions)
      cell.firstResponderPublisher
        .filter { [unowned self] _ in self.stage == .Ready }
        .receive(on: DispatchQueue.main)
        .sink { [unowned self] _ in self.scrollToItem(at: IndexPath(row: 0, section: NewPollController.Stage.Title.rawValue), at: .top, animated: true) }
        .store(in: &self.subscriptions)
      cell.stageCompletePublisher
        .delay(for: .seconds(0.5), scheduler: DispatchQueue.main)
        .receive(on: DispatchQueue.main)
        .sink { [unowned self] _ in
          //          self.contentOffset.y = 0
//                    UIView.animate(withDuration: 0.75) {
//                      guard let _cell = self.cellForItem(at: IndexPath(row: 0, section: indexPath.section+1)) else { return }
//                      let location = _cell.convert(_cell.frame.origin, to: self)
//                      self.contentOffset.y = location.y
//                    }
          self.scrollToItem(at: IndexPath(row: 0, section: indexPath.section+1), at: .top, animated: true)
        }
        .store(in: &self.subscriptions)
      cell.animationCompletePublisher
        .receive(on: DispatchQueue.main)
        .sink { [unowned self] _ in
          self.titleStageAnimationFinished.send()
          self.titleStageAnimationFinished.send(completion: .finished)
        }
//        .sink { [unowned self] _ in self.stageAnimationFinished.send(.Title) }// = .Title }
        .store(in: &self.subscriptions)
      cell.boundsPublisher
        .eraseToAnyPublisher()
        .sink { [unowned self] _ in
          self.source.refresh() }
        .store(in: &self.subscriptions)
      var config = UIBackgroundConfiguration.listPlainCell()
      config.backgroundColor = .clear
      cell.backgroundConfiguration = config
      cell.automaticallyUpdatesBackgroundConfiguration = false
      
//      self.stageAnimationFinished
//        .filter { $0 == .Topic }
//        .receive(on: DispatchQueue.main)
//        .sink { [unowned self] _ in cell.color = self.topic.tagColor }
//        .store(in: &self.subscriptions)
      self.topicStageAnimationFinished
        .receive(on: DispatchQueue.main)
        .sink { [unowned self] _ in cell.color = self.topic.tagColor }
        .store(in: &self.subscriptions)
      self.$stage
        .filter { $0 == .Title }
        .filter { _ in cell.text.isNil || cell.text.isEmpty }
        .delay(for: .seconds(0.75), scheduler: DispatchQueue.main)
        .sink { _ in cell.present() }
        .store(in: &self.subscriptions)
    }
    
    let descriptionCellRegistration = UICollectionView.CellRegistration<NewPollTextCell, AnyHashable> { [unowned self] cell, indexPath, _ in
      cell.textAlignment = .natural
//      cell.topicColor = self.topic.isNil ? .systemGray4 : self.topic!.tagColor
      cell.stageGlobal = self.stage
      cell.stage = .Description
      cell.placeholderFont = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .title1)
      cell.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .body)
      cell.text = self.pollDescription
      self.$stage
        .sink { cell.stageGlobal = $0 }
        .store(in: &self.subscriptions)
      self.$isKeyboardOnScreen
        .receive(on: DispatchQueue.main)
        .sink { cell.isKeyboardOnScreen = $0 }
        .store(in: &self.subscriptions)
//      self.$topic
//        .filter { !$0.isNil }
//        .receive(on: DispatchQueue.main)
//        .sink { cell.topicColor = $0!.tagColor }
//        .store(in: &self.subscriptions)
      //      self.$topic
            self.topicPublisher
        .filter { [unowned self] in !$0.isNil && self.stage.rawValue >= NewPollController.Stage.Description.rawValue }
        .filter { cell.color != $0!.tagColor }
        .receive(on: DispatchQueue.main)
        .sink { cell.color = $0!.tagColor }
        .store(in: &self.subscriptions)
      self.$isMovingToParent
        .filter { !$0.isNil }
        .receive(on: DispatchQueue.main)
        .sink { cell.isMovingToParent = $0! }
        .store(in: &self.subscriptions)
      cell.$text
        .filter { !$0.isNil }
        .receive(on: DispatchQueue.main)
        .sink { [unowned self] in self.pollDescription = $0 }
        .store(in: &self.subscriptions)
      cell.firstResponderPublisher
        .filter { [unowned self] _ in self.stage == .Ready }
        .receive(on: DispatchQueue.main)
        .sink { [unowned self] _ in self.scrollToItem(at: IndexPath(row: 0, section: NewPollController.Stage.Description.rawValue), at: .top, animated: true) }
        .store(in: &self.subscriptions)
      cell.stageCompletePublisher
        .delay(for: .seconds(0.5), scheduler: DispatchQueue.main)
        .receive(on: DispatchQueue.main)
        .sink { [unowned self] _ in  self.scrollToItem(at: IndexPath(row: 0, section: indexPath.section+1), at: .top, animated: true) }
        .store(in: &self.subscriptions)
      cell.animationCompletePublisher
        .receive(on: DispatchQueue.main)
        .sink { [unowned self] _ in
          self.descriptionStageAnimationFinished.send()
          self.descriptionStageAnimationFinished.send(completion: .finished)
        }
        .store(in: &self.subscriptions)
      cell.boundsPublisher
        .eraseToAnyPublisher()
        .receive(on: DispatchQueue.main)
        .sink { [unowned self] _ in
          self.source.refresh() }
        .store(in: &self.subscriptions)
      var config = UIBackgroundConfiguration.listPlainCell()
      config.backgroundColor = .clear
      cell.backgroundConfiguration = config
      cell.automaticallyUpdatesBackgroundConfiguration = false
      
      self.titleStageAnimationFinished
        .receive(on: DispatchQueue.main)
        .sink { [unowned self] _ in cell.color = self.topic.tagColor }
        .store(in: &self.subscriptions)
      self.$stage
        .filter { $0 == .Description }
        .filter { _ in cell.text.isNil || cell.text.isEmpty }
        .delay(for: .seconds(0.5), scheduler: DispatchQueue.main)
        .sink { _ in cell.present(seconds: 0.5) }
        .store(in: &self.subscriptions)
    }
    
    let imagesCellRegistration = UICollectionView.CellRegistration<NewPollImagesCell, AnyHashable> { [unowned self] cell, indexPath, _ in
      cell.topicColor = self.topic.isNil ? .systemGray4 : self.topic!.tagColor
      cell.images = self.images
      cell.stageGlobal = self.stage
      cell.stage = .Images
      cell.addImagePublisher
        .receive(on: DispatchQueue.main)
//        .sink { [unowned self] in self.addImage() }
        .sink { [unowned self] in
          self.addImagePublisher.send()
          
          guard self.stage == .Ready else { return }
          
          self.scrollToItem(at: IndexPath(row: 0, section: NewPollController.Stage.Images.rawValue), at: .top, animated: true)
        }
        .store(in: &self.subscriptions)
      cell.$removedImage
        .filter { !$0.isNil }
        .sink { [unowned self] in self.images.remove(object: $0!) }
        .store(in: &self.subscriptions)
      self.$images
        .receive(on: DispatchQueue.main)
        .sink { cell.update($0) }
        .store(in: &self.subscriptions)
      self.$stage
        .sink { cell.stageGlobal = $0 }
        .store(in: &self.subscriptions)
      //      self.$topic
            self.topicPublisher
        .filter { [unowned self] in !$0.isNil && self.stage.rawValue >= NewPollController.Stage.Images.rawValue }
        .filter { cell.color != $0!.tagColor }
        .receive(on: DispatchQueue.main)
        .sink { cell.color = $0!.tagColor }
        .store(in: &self.subscriptions)
      self.$isMovingToParent
        .filter { !$0.isNil }
        .receive(on: DispatchQueue.main)
        .sink { cell.isMovingToParent = $0! }
        .store(in: &self.subscriptions)
      self.$isKeyboardOnScreen
        .receive(on: DispatchQueue.main)
        .sink { cell.isKeyboardOnScreen = $0 }
        .store(in: &self.subscriptions)
      cell.stageCompletePublisher
        .delay(for: .seconds(0.5), scheduler: DispatchQueue.main)
        .receive(on: DispatchQueue.main)
        .sink { [unowned self] _ in  self.scrollToItem(at: IndexPath(row: 0, section: indexPath.section+1), at: .top, animated: true) }
        .store(in: &self.subscriptions)
      cell.animationCompletePublisher
        .receive(on: DispatchQueue.main)
        .sink { [unowned self] _ in
          self.imagesStageAnimationFinished.send()
          self.imagesStageAnimationFinished.send(completion: .finished)
          self.stage = .Hyperlink
        }//  = .Images; self.stage = .Hyperlink }
        .store(in: &self.subscriptions)
      cell.boundsPublisher
        .eraseToAnyPublisher()
        .receive(on: DispatchQueue.main)
        .sink { [unowned self] _ in
          self.source.refresh() }
        .store(in: &self.subscriptions)
      var config = UIBackgroundConfiguration.listPlainCell()
      config.backgroundColor = .clear
      cell.backgroundConfiguration = config
      cell.automaticallyUpdatesBackgroundConfiguration = false
      
      self.descriptionStageAnimationFinished
        .receive(on: DispatchQueue.main)
        .delay(for: .seconds(0.5), scheduler: DispatchQueue.main)
        .sink { [unowned self] _ in cell.color = self.topic.tagColor; cell.present() }
        .store(in: &self.subscriptions)    }
    
    let hyperlinkCellRegistration = UICollectionView.CellRegistration<NewPollHyperlinkCell, AnyHashable> { [unowned self] cell, indexPath, _ in
      cell.color = self.stage.rawValue >= NewPollController.Stage.Hyperlink.rawValue ? self.topic!.tagColor : .systemGray4
      cell.minHeight = 40
      cell.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .body)
      cell.text = self.hyperlink
      cell.stageGlobal = self.stage
      cell.stage = .Hyperlink
      self.$stage
        .sink { cell.stageGlobal = $0 }
        .store(in: &self.subscriptions)
//      self.$isKeyboardOnScreen
//        .receive(on: DispatchQueue.main)
//        .sink { cell.isKeyboardOnScreen = $0 }
//        .store(in: &self.subscriptions)
      //      self.$topic
            self.topicPublisher
        .filter { [unowned self] in !$0.isNil && self.stage.rawValue >= NewPollController.Stage.Hyperlink.rawValue }
        .filter { cell.color != $0!.tagColor }
        .receive(on: DispatchQueue.main)
        .sink { cell.color = $0!.tagColor }
        .store(in: &self.subscriptions)
      self.$isMovingToParent
        .filter { !$0.isNil }
        .receive(on: DispatchQueue.main)
        .sink { cell.isMovingToParent = $0! }
        .store(in: &self.subscriptions)
      cell.$text
        .filter { !$0.isNil && !$0!.isEmpty }
        .receive(on: DispatchQueue.main)
        .sink { [unowned self] in self.hyperlink = $0! }
        .store(in: &self.subscriptions)
      cell.stageCompletePublisher
        .delay(for: .seconds(0.5), scheduler: DispatchQueue.main)
        .receive(on: DispatchQueue.main)
        .sink { [unowned self] _ in self.scrollToItem(at: IndexPath(row: 0, section: indexPath.section+1), at: .top, animated: true) }
        .store(in: &self.subscriptions)
      cell.animationCompletePublisher
        .receive(on: DispatchQueue.main)
        .sink { [unowned self] _ in
          self.hyperlinkStageAnimationFinished.send()
          self.hyperlinkStageAnimationFinished.send(completion: .finished)
        }//  = .Hyperlink }
        .store(in: &self.subscriptions)
      cell.boundsPublisher
        .eraseToAnyPublisher()
        .receive(on: DispatchQueue.main)
        .sink { [unowned self] _ in self.source.refresh() }
        .store(in: &self.subscriptions)
      cell.nextPublisher
        .receive(on: DispatchQueue.main)
        .sink { [unowned self] _ in self.stage = .Question }
        .store(in: &self.subscriptions)
      var config = UIBackgroundConfiguration.listPlainCell()
      config.backgroundColor = .clear
      cell.backgroundConfiguration = config
      cell.automaticallyUpdatesBackgroundConfiguration = false
      
      self.imagesStageAnimationFinished
        .receive(on: DispatchQueue.main)
        .delay(for: .seconds(0.5), scheduler: DispatchQueue.main)
        .sink { [unowned self] _ in cell.color = self.topic.tagColor; cell.present() }
        .store(in: &self.subscriptions)
//      self.$stage
//        .filter { $0 == .Hyperlink }
//        .delay(for: .seconds(0.75), scheduler: DispatchQueue.main)
//        .sink { _ in cell.present() }
//        .store(in: &self.subscriptions)
    }
    
    let questionCellRegistration = UICollectionView.CellRegistration<NewPollTextCell, AnyHashable> { [unowned self] cell, indexPath, _ in
      cell.textAlignment = .natural
//      cell.topicColor = self.topic.isNil ? .systemGray4 : self.topic!.tagColor
      cell.minHeight = 0//60
      cell.stageGlobal = self.stage
      cell.stage = .Question
      cell.placeholderFont = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .title1)
      cell.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .body)
      cell.text = self.pollDescription
//      self.$topic
//        .filter { !$0.isNil }
//        .receive(on: DispatchQueue.main)
//        .sink { cell.topicColor = $0!.tagColor }
//        .store(in: &self.subscriptions)
      self.$stage
        .sink { cell.stageGlobal = $0 }
        .store(in: &self.subscriptions)
      self.$isKeyboardOnScreen
        .receive(on: DispatchQueue.main)
        .sink { cell.isKeyboardOnScreen = $0 }
        .store(in: &self.subscriptions)
      //      self.$topic
            self.topicPublisher
        .filter { [unowned self] in !$0.isNil && self.stage.rawValue >= NewPollController.Stage.Question.rawValue }
        .filter { cell.color != $0!.tagColor }
        .receive(on: DispatchQueue.main)
        .sink { cell.color = $0!.tagColor }
        .store(in: &self.subscriptions)
      self.$isMovingToParent
        .filter { !$0.isNil }
        .receive(on: DispatchQueue.main)
        .sink { cell.isMovingToParent = $0! }
        .store(in: &self.subscriptions)
      cell.$text
        .filter { !$0.isNil }
        .receive(on: DispatchQueue.main)
        .sink { [unowned self] in self.question = $0 }
        .store(in: &self.subscriptions)
      cell.animationCompletePublisher
        .receive(on: DispatchQueue.main)
        .sink { [unowned self] _ in
          self.questionStageAnimationFinished.send()
          self.questionStageAnimationFinished.send(completion: .finished)
        }//  = .Question }
        .store(in: &self.subscriptions)
      cell.firstResponderPublisher
        .filter { [unowned self] _ in self.stage == .Ready }
        .receive(on: DispatchQueue.main)
        .sink { [unowned self] _ in self.scrollToItem(at: IndexPath(row: 0, section: NewPollController.Stage.Question.rawValue), at: .top, animated: true) }
        .store(in: &self.subscriptions)
      cell.stageCompletePublisher
        .delay(for: .seconds(0.5), scheduler: DispatchQueue.main)
        .receive(on: DispatchQueue.main)
        .sink { [unowned self] _ in  self.scrollToItem(at: IndexPath(row: 0, section: indexPath.section+1), at: .top, animated: true) }
        .store(in: &self.subscriptions)
      cell.boundsPublisher
        .eraseToAnyPublisher()
        .receive(on: DispatchQueue.main)
        .sink { [unowned self] _ in self.source.refresh() }
        .store(in: &self.subscriptions)
      var config = UIBackgroundConfiguration.listPlainCell()
      config.backgroundColor = .clear
      cell.backgroundConfiguration = config
      cell.automaticallyUpdatesBackgroundConfiguration = false
      
      self.hyperlinkStageAnimationFinished
        .receive(on: DispatchQueue.main)
        .sink { [unowned self] _ in cell.color = self.topic.tagColor }
        .store(in: &self.subscriptions)
      self.$stage
        .filter { $0 == .Question }
        .filter { _ in cell.text.isNil || cell.text.isEmpty }
        .delay(for: .seconds(0.5), scheduler: DispatchQueue.main)
        .sink { _ in cell.present(seconds: 0.25) }
        .store(in: &self.subscriptions)
    }
    
    let choicesCellRegistration = UICollectionView.CellRegistration<NewPollChoicesCell, AnyHashable> { [unowned self] cell, indexPath, _ in
      cell.topicColor = self.topic.isNil ? .systemGray4 : self.topic!.tagColor
      cell.choices = self.choices
      cell.stageGlobal = self.stage
      cell.stage = .Choices
      cell.addChoicePublisher
        .filter { !$0.isNil }
        .throttle(for: .seconds(0.5), scheduler: DispatchQueue.main, latest: false)
        .receive(on: DispatchQueue.main)
        .sink { [unowned self] _ in
          self.addChoice()
          
          guard self.stage == .Ready else { return }
          
          self.scrollToItem(at: IndexPath(row: 0, section: 6), at: .top, animated: true)
        }
        .store(in: &self.subscriptions)
      cell.$removedChoice
        .filter { !$0.isNil }
        .sink { [unowned self] in self.choices.remove(object: $0!) }
        .store(in: &self.subscriptions)
      ///Monitor 1st choice to add 2nd - necessary
      cell.$wasEdited
        .receive(on: DispatchQueue.main)
        .filter { !$0.isNil }
        .filter { [unowned self] _ in self.choices.count == 1 }
        .sink { _ in cell.addSecondChoice() }
        .store(in: &self.subscriptions)
      cell.stageCompletePublisher
        .delay(for: .seconds(0.5), scheduler: DispatchQueue.main)
        .receive(on: DispatchQueue.main)
        .sink { [unowned self] _ in  self.scrollToItem(at: IndexPath(row: 0, section: indexPath.section+1), at: .top, animated: true) }
        .store(in: &self.subscriptions)
//      self.$topic
      //      self.$topic
            self.topicPublisher
        .filter { !$0.isNil }
        .filter { cell.color != $0!.tagColor }
        .receive(on: DispatchQueue.main)
        .sink { cell.topicColor = $0!.tagColor }
        .store(in: &self.subscriptions)
//      self.$choices
//        .filter { [unowned self] _ in self.stage.rawValue >= NewPollController.Stage.Choices.rawValue }
//        .receive(on: DispatchQueue.main)
//        .sink {
//          cell.refreshChoices($0)
//          cell.present(index: $0.count-1, seconds: $0.count == 2 ? 0.5 : 0)
////          guard  $0.count == 2 else { return }
////
////          cell.present(first: false, seconds: 0.5)
//        }
      self.choicesPublisher
        .filter { [unowned self] _ in self.stage.rawValue >= NewPollController.Stage.Choices.rawValue }
        .receive(on: DispatchQueue.main)
        .sink {
          cell.refreshChoices($0)
          cell.present(index: $0.count-1, seconds: $0.count == 2 ? 0.5 : 0)
//          guard  $0.count == 2 else { return }
//
//          cell.present(first: false, seconds: 0.5)
        }
        .store(in: &self.subscriptions)
//      self.$choices
//        .filter { [unowned self] _ in self.choices.count == 2 }
//        .receive(on: DispatchQueue.main)
//        .delay(for: .seconds(0.5), scheduler: DispatchQueue.main)
//        .sink { _ in cell.present(first: false) }
//        .store(in: &self.subscriptions)
      self.$stage
        .sink { cell.stageGlobal = $0 }
        .store(in: &self.subscriptions)
      //      self.$topic
            self.topicPublisher
        .filter { [unowned self] in !$0.isNil && self.stage.rawValue >= NewPollController.Stage.Choices.rawValue }
        .filter { cell.color != $0!.tagColor }
        .receive(on: DispatchQueue.main)
        .sink { cell.color = $0!.tagColor }
        .store(in: &self.subscriptions)
      self.$isMovingToParent
        .filter { !$0.isNil }
        .receive(on: DispatchQueue.main)
        .sink { cell.isMovingToParent = $0! }
        .store(in: &self.subscriptions)
      self.$isKeyboardOnScreen
        .receive(on: DispatchQueue.main)
        .sink { cell.isKeyboardOnScreen = $0 }
        .store(in: &self.subscriptions)
//      cell.$text
//        .filter { !$0.isNil }
//        .receive(on: DispatchQueue.main)
//        .sink { [unowned self] in self.question = $0 }
//        .store(in: &self.subscriptions)
      cell.animationCompletePublisher
        .receive(on: DispatchQueue.main)
        .sink { [unowned self] _ in
          self.stage = .Comments
          self.choicesStageAnimationFinished.send()
          self.choicesStageAnimationFinished.send(completion: .finished)
        }//  = .Choices }
        .store(in: &self.subscriptions)
      cell.boundsPublisher
        .eraseToAnyPublisher()
        .receive(on: DispatchQueue.main)
        .sink { [unowned self] _ in
          self.source.refresh() }
        .store(in: &self.subscriptions)
      var config = UIBackgroundConfiguration.listPlainCell()
      config.backgroundColor = .clear
      cell.backgroundConfiguration = config
      cell.automaticallyUpdatesBackgroundConfiguration = false
      
      self.questionStageAnimationFinished
        .receive(on: DispatchQueue.main)
        .sink { [unowned self] _ in cell.color = self.topic.tagColor }
        .store(in: &self.subscriptions)
      self.$stage
        .filter { $0 == .Choices }
        .filter { [unowned self] _ in self.choices.count == 1 }
        .delay(for: .seconds(0.5), scheduler: DispatchQueue.main)
        .sink { _ in cell.present(index: 0, seconds: 0.5) }
        .store(in: &self.subscriptions)
    }
    
    let commentsCellRegistration = UICollectionView.CellRegistration<NewPollCommentsCell, AnyHashable> { [unowned self] cell, indexPath, _ in
      cell.stage = .Comments
      cell.color = self.stage.rawValue >= NewPollController.Stage.Comments.rawValue ? self.topic!.tagColor : .systemGray4
      cell.stageGlobal = self.stage
      if !self.commentsEnabled.isNil {
        cell.commentsEnabled = self.commentsEnabled!
      }
      self.$stage
        .sink { cell.stageGlobal = $0 }
        .store(in: &self.subscriptions)
      //      self.$topic
      
        self.topicPublisher
        .filter { [unowned self] in !$0.isNil && self.stage.rawValue >= NewPollController.Stage.Comments.rawValue }
        .filter { cell.color != $0!.tagColor }
        .receive(on: DispatchQueue.main)
        .sink { cell.color = $0!.tagColor }
        .store(in: &self.subscriptions)
      cell.$commentsEnabled
        .filter { !$0.isNil }
        .receive(on: DispatchQueue.main)
        .sink { [unowned self] in self.commentsEnabled = $0! }
        .store(in: &self.subscriptions)
      cell.animationCompletePublisher
        .receive(on: DispatchQueue.main)
        .sink { [unowned self] _ in
          self.commentsStageAnimationFinished.send()
          self.commentsStageAnimationFinished.send(completion: .finished)
        }
        .store(in: &self.subscriptions)
      cell.boundsPublisher
        .eraseToAnyPublisher()
        .receive(on: DispatchQueue.main)
        .sink { [unowned self] _ in self.source.refresh() }
        .store(in: &self.subscriptions)
      cell.stageCompletePublisher
        .receive(on: DispatchQueue.main)
        .sink { [unowned self] _ in self.stage = .Anonymity; self.scrollToItem(at: IndexPath(row: 0, section: indexPath.section+1), at: .top, animated: true) }
        .store(in: &self.subscriptions)
      var config = UIBackgroundConfiguration.listPlainCell()
      config.backgroundColor = .clear
      cell.backgroundConfiguration = config
      cell.automaticallyUpdatesBackgroundConfiguration = false
      
      self.choicesStageAnimationFinished
        .receive(on: DispatchQueue.main)
        .delay(for: .seconds(0.5), scheduler: DispatchQueue.main)
        .sink { [unowned self] _ in cell.color = self.topic.tagColor; cell.present() }
        .store(in: &self.subscriptions)
    }
    
    let anonCellRegistration = UICollectionView.CellRegistration<NewPollAnonimityCell, AnyHashable> { [unowned self] cell, indexPath, _ in
      cell.stage = .Anonymity
      cell.color = self.stage.rawValue >= NewPollController.Stage.Anonymity.rawValue ? self.topic!.tagColor : .systemGray4
      cell.stageGlobal = self.stage
      if !self.anonymityEnabled.isNil {
        cell.anonymityEnabled = self.anonymityEnabled!
      }
      self.$stage
        .sink { cell.stageGlobal = $0 }
        .store(in: &self.subscriptions)
      //      self.$topic
            self.topicPublisher
        .filter { [unowned self] in !$0.isNil && self.stage.rawValue >= NewPollController.Stage.Anonymity.rawValue }
        .filter { cell.color != $0!.tagColor }
        .receive(on: DispatchQueue.main)
        .sink { cell.color = $0!.tagColor }
        .store(in: &self.subscriptions)
      cell.$anonymityEnabled
        .filter { !$0.isNil }
        .receive(on: DispatchQueue.main)
        .sink { [unowned self] in self.anonymityEnabled = $0! }
        .store(in: &self.subscriptions)
      cell.animationCompletePublisher
        .receive(on: DispatchQueue.main)
        .sink { [unowned self] _ in
          self.anonStageAnimationFinished.send()
          self.anonStageAnimationFinished.send(completion: .finished)
        }
        .store(in: &self.subscriptions)
      cell.boundsPublisher
        .eraseToAnyPublisher()
        .receive(on: DispatchQueue.main)
        .sink { [unowned self] _ in self.source.refresh() }
        .store(in: &self.subscriptions)
      cell.stageCompletePublisher
        .receive(on: DispatchQueue.main)
        .sink { [unowned self] _ in self.stage = .Limits; self.scrollToItem(at: IndexPath(row: 0, section: indexPath.section+1), at: .top, animated: true) }
        .store(in: &self.subscriptions)
      var config = UIBackgroundConfiguration.listPlainCell()
      config.backgroundColor = .clear
      cell.backgroundConfiguration = config
      cell.automaticallyUpdatesBackgroundConfiguration = false
      
      self.commentsStageAnimationFinished
        .receive(on: DispatchQueue.main)
        .delay(for: .seconds(0.5), scheduler: DispatchQueue.main)
        .sink { [unowned self] _ in cell.color = self.topic.tagColor; cell.present() }
        .store(in: &self.subscriptions)
    }
    
    let limitsCellRegistration = UICollectionView.CellRegistration<NewPollLimitsCell, AnyHashable> { [unowned self] cell, indexPath, _ in
      cell.stage = .Limits
      cell.color = self.stage.rawValue >= NewPollController.Stage.Limits.rawValue ? self.topic!.tagColor : .systemGray4
      cell.stageGlobal = self.stage
      cell.limit = self.limit
      self.$stage
        .sink { cell.stageGlobal = $0 }
        .store(in: &self.subscriptions)
      //      self.$topic
            self.topicPublisher
        .filter { [unowned self] in !$0.isNil && self.stage.rawValue >= NewPollController.Stage.Limits.rawValue }
        .filter { cell.color != $0!.tagColor }
        .receive(on: DispatchQueue.main)
        .sink { cell.color = $0!.tagColor }
        .store(in: &self.subscriptions)
      cell.$limit
        .filter { !$0.isNil }
        .receive(on: DispatchQueue.main)
        .sink { [unowned self] in self.limit = $0! }
        .store(in: &self.subscriptions)
      cell.animationCompletePublisher
        .receive(on: DispatchQueue.main)
        .sink { [unowned self] _ in
          self.limitsStageAnimationFinished.send()
          self.limitsStageAnimationFinished.send(completion: .finished)
        }
        .store(in: &self.subscriptions)
      cell.boundsPublisher
        .eraseToAnyPublisher()
        .receive(on: DispatchQueue.main)
        .sink { [unowned self] _ in self.source.refresh() }
        .store(in: &self.subscriptions)
      cell.stageCompletePublisher
        .receive(on: DispatchQueue.main)
        .sink { [unowned self] _ in self.stage = .Hot; self.scrollToItem(at: IndexPath(row: 0, section: indexPath.section+1), at: .top, animated: true) }
        .store(in: &self.subscriptions)
      var config = UIBackgroundConfiguration.listPlainCell()
      config.backgroundColor = .clear
      cell.backgroundConfiguration = config
      cell.automaticallyUpdatesBackgroundConfiguration = false
      
      self.anonStageAnimationFinished
        .first()
        .receive(on: DispatchQueue.main)
        .delay(for: .seconds(0.5), scheduler: DispatchQueue.main)
        .sink { [unowned self] _ in cell.color = self.topic.tagColor; cell.present(seconds: 1) }
        .store(in: &cell.externalSubscriptions)
    }
    
    let hotCellRegistration = UICollectionView.CellRegistration<NewPollHotCell, AnyHashable> { [unowned self] cell, indexPath, _ in
      cell.stage = .Hot
      cell.color = self.stage.rawValue >= NewPollController.Stage.Hot.rawValue ? self.topic!.tagColor : .systemGray4
      cell.stageGlobal = self.stage
      cell.isHot = self.isHot
      
      self.$stage
        .sink { cell.stageGlobal = $0 }
        .store(in: &self.subscriptions)
      //      self.$topic
            self.topicPublisher
        .filter { [unowned self] in !$0.isNil && self.stage.rawValue >= NewPollController.Stage.Hot.rawValue }
        .filter { cell.color != $0!.tagColor }
        .receive(on: DispatchQueue.main)
        .sink { cell.color = $0!.tagColor }
        .store(in: &self.subscriptions)
      cell.$isHot
        .filter { !$0.isNil }
        .receive(on: DispatchQueue.main)
        .sink { [unowned self] in self.isHot = $0! }
        .store(in: &self.subscriptions)
      cell.animationCompletePublisher
        .receive(on: DispatchQueue.main)
        .sink { [unowned self] _ in
          self.hotStageAnimationFinished.send()
          self.hotStageAnimationFinished.send(completion: .finished)
        }
        .store(in: &self.subscriptions)
      cell.boundsPublisher
        .eraseToAnyPublisher()
        .receive(on: DispatchQueue.main)
        .sink { [unowned self] _ in self.source.refresh() }
        .store(in: &self.subscriptions)
      cell.stageCompletePublisher
        .receive(on: DispatchQueue.main)
        .sink { [unowned self] _ in self.stage = .Ready; self.scrollToItem(at: IndexPath(row: 0, section: indexPath.section+1), at: .top, animated: true) }
        .store(in: &self.subscriptions)
      var config = UIBackgroundConfiguration.listPlainCell()
      config.backgroundColor = .clear
      cell.backgroundConfiguration = config
      cell.automaticallyUpdatesBackgroundConfiguration = false
      
      self.limitsStageAnimationFinished
        .receive(on: DispatchQueue.main)
        .delay(for: .seconds(0.5), scheduler: DispatchQueue.main)
        .sink { [unowned self] _ in cell.color = self.topic.tagColor; cell.present() }
        .store(in: &self.subscriptions)
    }
    
    let costCellRegistration = UICollectionView.CellRegistration<NewPollCostCell, AnyHashable> { [unowned self] cell, indexPath, _ in
      cell.costItems = self.costItems
      cell.stageGlobal = self.stage
      cell.stage = .Ready
      cell.color = self.stage.rawValue >= NewPollController.Stage.Ready.rawValue ? self.topic!.tagColor : .systemGray4
      cell.isPresented = self.stage.rawValue == NewPollController.Stage.Ready.rawValue
      self.$stage
        .sink { cell.stageGlobal = $0 }
        .store(in: &self.subscriptions)
      //      self.$topic
            self.topicPublisher
        .filter { [unowned self] in !$0.isNil && self.stage.rawValue >= NewPollController.Stage.Hot.rawValue }
        .filter { cell.color != $0!.tagColor }
        .receive(on: DispatchQueue.main)
        .sink { cell.color = $0!.tagColor }
        .store(in: &self.subscriptions)
//      self.costPublisher
//        .receive(on: DispatchQueue.main)
//        .sink { [unowned self] in cell.update(self.costItems)}
//        .store(in: &self.subscriptions)
      self.$costItems
        .receive(on: DispatchQueue.main)
        .sink { cell.update($0) }
        .store(in: &self.subscriptions)
      cell.boundsPublisher
        .eraseToAnyPublisher()
        .receive(on: DispatchQueue.main)
        .sink { [unowned self] _ in self.source.refresh() }
        .store(in: &self.subscriptions)
//      cell.stageCompletePublisher
//        .receive(on: DispatchQueue.main)
//        .sink { [unowned self] _ in self.stage = .Hot; }//self.scrollToItem(at: IndexPath(row: 0, section: indexPath.section+1), at: .top, animated: true) }
//        .store(in: &self.subscriptions)
      var config = UIBackgroundConfiguration.listPlainCell()
      config.backgroundColor = .clear
      cell.backgroundConfiguration = config
      cell.automaticallyUpdatesBackgroundConfiguration = false
      
      self.hotStageAnimationFinished
        .receive(on: DispatchQueue.main)
//        .delay(for: .seconds(0.5), scheduler: DispatchQueue.main)
        .sink { [unowned self] _ in cell.color = self.topic.tagColor; cell.present() }
        .store(in: &self.subscriptions)
    }
    
    source = Source(collectionView: self) { collectionView, indexPath, identifier -> UICollectionViewCell? in
      guard let section = NewPollController.Stage(rawValue: identifier) else { return UICollectionViewCell() }
      
      if section == .Topic {
        return collectionView.dequeueConfiguredReusableCell(using: topicCellRegistration,
                                                            for: indexPath,
                                                            item: identifier)
      } else if section == .Title {
        return collectionView.dequeueConfiguredReusableCell(using: titleCellRegistration,
                                                            for: indexPath,
                                                            item: identifier)
      } else if section == .Description {
        return collectionView.dequeueConfiguredReusableCell(using: descriptionCellRegistration,
                                                            for: indexPath,
                                                            item: identifier)
      } else if section == .Question {
        return collectionView.dequeueConfiguredReusableCell(using: questionCellRegistration,
                                                            for: indexPath,
                                                            item: identifier)
      } else if section == .Choices {
        return collectionView.dequeueConfiguredReusableCell(using: choicesCellRegistration,
                                                            for: indexPath,
                                                            item: identifier)
      } else if section == .Images {
        return collectionView.dequeueConfiguredReusableCell(using: imagesCellRegistration,
                                                            for: indexPath,
                                                            item: identifier)
      } else if section == .Hyperlink {
        return collectionView.dequeueConfiguredReusableCell(using: hyperlinkCellRegistration,
                                                            for: indexPath,
                                                            item: identifier)
      } else if section == .Comments {
        return collectionView.dequeueConfiguredReusableCell(using: commentsCellRegistration,
                                                            for: indexPath,
                                                            item: identifier)
      } else if section == .Anonymity {
        return collectionView.dequeueConfiguredReusableCell(using: anonCellRegistration,
                                                            for: indexPath,
                                                            item: identifier)
      } else if section == .Limits {
        return collectionView.dequeueConfiguredReusableCell(using: limitsCellRegistration,
                                                            for: indexPath,
                                                            item: identifier)
      } else if section == .Hot {
        return collectionView.dequeueConfiguredReusableCell(using: hotCellRegistration,
                                                            for: indexPath,
                                                            item: identifier)
      } else if section == .Ready {
        return collectionView.dequeueConfiguredReusableCell(using: costCellRegistration,
                                                            for: indexPath,
                                                            item: identifier)
      }
      return UICollectionViewCell()
    }
    
    var snapshot = Snapshot()
    snapshot.appendSections([.Topic,
                             .Title,
                             .Description,
                             .Images,
                             .Hyperlink,
                             .Question,
                             .Choices,
                             .Comments,
                             .Anonymity,
                             .Limits,
                             .Hot,
                             .Ready])
    snapshot.appendItems([0], toSection: .Topic)
    snapshot.appendItems([1], toSection: .Title)
    snapshot.appendItems([2], toSection: .Description)
    snapshot.appendItems([3], toSection: .Images)
    snapshot.appendItems([4], toSection: .Hyperlink)
    snapshot.appendItems([5], toSection: .Question)
    snapshot.appendItems([6], toSection: .Choices)
    snapshot.appendItems([7], toSection: .Comments)
    snapshot.appendItems([8], toSection: .Anonymity)
    snapshot.appendItems([9], toSection: .Limits)
    snapshot.appendItems([10], toSection: .Hot)
    snapshot.appendItems([11], toSection: .Ready)
    source.apply(snapshot, animatingDifferences: false) { [unowned self] in self.contentOffset.y = 0 }
  }
  
  func setTasks() {
    tasks.append( Task {@MainActor [weak self] in
      for await _ in NotificationCenter.default.notifications(for: UIApplication.keyboardWillHideNotification) {
        guard let self = self else { return }

        self.isKeyboardOnScreen = false
      }
    })
    tasks.append( Task {@MainActor [weak self] in
      for await _ in NotificationCenter.default.notifications(for: UIApplication.keyboardWillShowNotification) {
        guard let self = self else { return }
        
        self.isKeyboardOnScreen = true
      }
    })
  }
  
//  func applySnapshot(animated: Bool = false) {
//    var snapshot = Snapshot()
//    snapshot.appendSections([.title, .description,])
//    snapshot.appendItems([0], toSection: .title)
//    snapshot.appendItems([1], toSection: .description)
//    if item.imagesCount != 0 {
//      snapshot.appendSections([.image])
//      snapshot.appendItems([2], toSection: .image)
//    }
//    if let url = item.url {
//      if url.absoluteString.isYoutubeLink {
//        snapshot.appendSections([.youtube])
//        snapshot.appendItems([3], toSection: .youtube)
//      } else {
//        snapshot.appendSections([.web])
//        snapshot.appendItems([4], toSection: .web)
//      }
//    }
//    snapshot.appendSections([.question])
//    snapshot.appendItems([5], toSection: .question)
//    if mode == .Default {
//      snapshot.appendSections([.answers])
//      snapshot.appendItems([6], toSection: .answers)
//      snapshot.appendSections([.comments])
//      snapshot.appendItems([7], toSection: .comments)
//    }
//    source.apply(snapshot, animatingDifferences: false)
////    source.refresh(animatingDifferences: false)
//
//    //        snapshot.appendSections([.title, .description,])
//    //        snapshot.appendItems([0], toSection: .title)
//    //        snapshot.appendItems([1], toSection: .description)
//    //        if poll.imagesCount != 0 {
//    //            snapshot.appendSections([.image])
//    //            snapshot.appendItems([2], toSection: .image)
//    //        }
//    //        if let url = poll.url {
//    //            if url.absoluteString.isYoutubeLink {
//    //                snapshot.appendSections([.youtube])
//    //                snapshot.appendItems([3], toSection: .youtube)
//    //            } else {
//    //                snapshot.appendSections([.web])
//    //                snapshot.appendItems([4], toSection: .web)
//    //            }
  //    //        }
  //    //        snapshot.appendSections([.question])
  //    //        snapshot.appendItems([5], toSection: .question)
  //    //        ////        snapshot.appendSections([.choices])
  //    //        ////        snapshot.appendItems([6], toSection: .choices)
  //    //        snapshot.appendSections([.comments])
  //    //        snapshot.appendItems([8], toSection: .comments)
  //  }
  func addChoice() {
    choices.append(NewPollChoice(text: "new_poll_choice_placeholder".localized + String(describing: choices.count + 1)))
  }
}
