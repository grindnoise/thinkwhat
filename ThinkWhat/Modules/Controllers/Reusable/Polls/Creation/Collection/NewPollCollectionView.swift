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
      
//      isScrollEnabled = stage == .Ready
    }
  }
  @Published public private(set) var topic: Topic! {
    didSet {
      guard oldValue.isNil,
            !topic.isNil,
            let stage = stage.next()
      else { return }
      
      self.stage = stage
    }
  }
  @Published public private(set) var title: String! {
    didSet {
      guard oldValue.isNil,
            !title.isNil,
            let stage = stage.next()
      else { return }
      
      self.stage = stage
    }
  }
  @Published public private(set) var pollDescription: String! {
    didSet {
      guard oldValue.isNil,
            !pollDescription.isNil,
            let stage = stage.next()
      else { return }
      
      self.stage = stage
    }
  }
  @Published public private(set) var question: String! {
    didSet {
      guard oldValue.isNil,
            !question.isNil,
            let stage = stage.next()
      else { return }
      
      self.stage = stage
    }
  }
    @Published public private(set) var choices: [NewPollChoice] = (0...0).map { NewPollChoice(text: "new_poll_choice_placeholder".localized + String(describing: $0 + 1)) }
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
  @Published public private(set) var images = [NewPollImage]()
  @Published public private(set) var hyperlink: String = "" //{
//    didSet {
//      guard oldValue.isEmpty,
////            hyperlink != oldValue,
//            stage.rawValue <= NewPollController.Stage.Hyperlink.rawValue,
//            let stage = stage.next()
//      else { return }
//
//      self.stage = stage
//    }
//  }
  @Published public private(set) var commentsEnabled: Bool? //{
//    didSet {
//      guard oldValue.isNil,
//            commentsEnabled != oldValue,
//            stage.rawValue <= NewPollController.Stage.Comments.rawValue,
//            let stage = stage.next()
//      else { return }
//
//      self.stage = stage
//    }
//  }
  @Published public private(set) var anonimityEnabled: Bool?
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  ///**Logic**
  private var source: Source!
  private var isFirstAnswerSelection = true
  ///**UI**
  private let padding: CGFloat = 8
  ///**Publishers**
  @Published private(set) var stageAnimationFinished: NewPollController.Stage!
  
  
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
}

private extension NewPollCollectionView {
  @MainActor
  func setupUI() {
//    isScrollEnabled = false
    delegate = self
    collectionViewLayout = UICollectionViewCompositionalLayout { section, env -> NSCollectionLayoutSection? in
      var layoutConfig = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
      layoutConfig.backgroundColor = .clear
      layoutConfig.showsSeparators = false
      
      let sectionLayout = NSCollectionLayoutSection.list(using: layoutConfig, layoutEnvironment: env)
      sectionLayout.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: section == NewPollController.Stage.allCases.count-1 ? 30 : 0, trailing: 0)
      sectionLayout.interGroupSpacing = 8
      return sectionLayout
    }
    
    let topicCellRegistration = UICollectionView.CellRegistration<NewPollTopicCell, AnyHashable> { [unowned self] cell, _, _ in
      cell.stage = .Topic
      cell.stageGlobal = self.stage
      cell.topic = self.topic
      cell.$topic
        .filter { !$0.isNil }
        .receive(on: DispatchQueue.main)
//        .delay(for: .milliseconds(, scheduler: <#T##Scheduler#>)
        .sink { [unowned self] in self.topic = $0 }
        .store(in: &self.subscriptions)
      cell.$isAnimationComplete
        .filter { !$0.isNil }
        .receive(on: DispatchQueue.main)
        .sink { [unowned self] _ in self.stageAnimationFinished = .Topic }
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
      
      cell.present(seconds: 0.5)
    }
    
    let titleCellRegistration = UICollectionView.CellRegistration<NewPollTextCell, AnyHashable> { [unowned self] cell, _, _ in
      cell.textAlignment = .center
      cell.topicColor = self.topic.isNil ? .systemGray4 : self.topic!.tagColor
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
      self.$topic
        .filter { !$0.isNil }
        .receive(on: DispatchQueue.main)
        .sink { cell.color = $0!.tagColor }
        .store(in: &self.subscriptions)
      self.$topic
        .filter { !$0.isNil }
        .receive(on: DispatchQueue.main)
        .sink { cell.topicColor = $0!.tagColor }
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
      cell.$isAnimationComplete
        .filter { !$0.isNil }
        .receive(on: DispatchQueue.main)
        .sink { [unowned self] _ in self.stageAnimationFinished = .Title }
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
      
      self.$stageAnimationFinished
        .filter { $0 == .Topic }
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
    
    let descriptionCellRegistration = UICollectionView.CellRegistration<NewPollTextCell, AnyHashable> { [unowned self] cell, _, _ in
      cell.textAlignment = .natural
      cell.topicColor = self.topic.isNil ? .systemGray4 : self.topic!.tagColor
      cell.stage = .Description
      cell.stageGlobal = self.stage
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
      self.$topic
        .filter { !$0.isNil }
        .receive(on: DispatchQueue.main)
        .sink { cell.topicColor = $0!.tagColor }
        .store(in: &self.subscriptions)
      self.$topic
        .filter { [unowned self] in !$0.isNil && self.stage.rawValue >= NewPollController.Stage.Description.rawValue }
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
      cell.$isAnimationComplete
        .filter { !$0.isNil }
        .receive(on: DispatchQueue.main)
        .sink { [unowned self] _ in self.stageAnimationFinished = .Description }
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
      
      self.$stageAnimationFinished
        .filter { $0 == .Title }
        .receive(on: DispatchQueue.main)
        .sink { [unowned self] _ in cell.color = self.topic.tagColor }
        .store(in: &self.subscriptions)
      self.$stage
        .filter { $0 == .Description }
        .filter { _ in cell.text.isNil || cell.text.isEmpty }
        .delay(for: .seconds(0.75), scheduler: DispatchQueue.main)
        .sink { _ in cell.present() }
        .store(in: &self.subscriptions)
    }
    
    let questionCellRegistration = UICollectionView.CellRegistration<NewPollTextCell, AnyHashable> { [unowned self] cell, _, _ in
      cell.textAlignment = .natural
      cell.topicColor = self.topic.isNil ? .systemGray4 : self.topic!.tagColor
      cell.minHeight = 0//60
      cell.stage = .Question
      cell.stageGlobal = self.stage
      cell.placeholderFont = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .title1)
      cell.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .body)
      cell.text = self.pollDescription
      self.$topic
        .filter { !$0.isNil }
        .receive(on: DispatchQueue.main)
        .sink { cell.topicColor = $0!.tagColor }
        .store(in: &self.subscriptions)
      self.$stage
        .sink { cell.stageGlobal = $0 }
        .store(in: &self.subscriptions)
      self.$isKeyboardOnScreen
        .receive(on: DispatchQueue.main)
        .sink { cell.isKeyboardOnScreen = $0 }
        .store(in: &self.subscriptions)
      self.$topic
        .filter { [unowned self] in !$0.isNil && self.stage.rawValue >= NewPollController.Stage.Question.rawValue }
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
      cell.$isAnimationComplete
        .filter { !$0.isNil }
        .receive(on: DispatchQueue.main)
        .sink { [unowned self] _ in self.stageAnimationFinished = .Question }
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
      
      self.$stageAnimationFinished
        .filter { $0 == .Description }
        .receive(on: DispatchQueue.main)
        .sink { [unowned self] _ in cell.color = self.topic.tagColor }
        .store(in: &self.subscriptions)
      self.$stage
        .filter { $0 == .Question }
        .filter { _ in cell.text.isNil || cell.text.isEmpty }
        .delay(for: .seconds(0.75), scheduler: DispatchQueue.main)
        .sink { _ in cell.present() }
        .store(in: &self.subscriptions)
    }
    
    let choicesCellRegistration = UICollectionView.CellRegistration<NewPollChoicesCell, AnyHashable> { [unowned self] cell, _, _ in
      cell.topicColor = self.topic.isNil ? .systemGray4 : self.topic!.tagColor
      cell.stage = .Choices
      cell.stageGlobal = self.stage
//      cell.topicColor = self.topic.isNil ? .systemGray : self.topic!.tagColor
      cell.choices = self.choices
      cell.addChoicePublisher
        .receive(on: DispatchQueue.main)
        .sink { [unowned self] in self.addChoice() }
        .store(in: &self.subscriptions)
      cell.$removedChoice
        .filter { !$0.isNil }
        .sink { [unowned self] in self.choices.remove(object: $0!) }
        .store(in: &self.subscriptions)
      ///Monitor 1st choice to add 2nd - necessary
      cell.$wasEdited
        .filter { !$0.isNil }
        .filter { [unowned self] _ in self.choices.count == 1 }
        .sink { _ in cell.addSecondChoice() }
        .store(in: &self.subscriptions)
      self.$topic
        .filter { !$0.isNil }
        .receive(on: DispatchQueue.main)
        .sink { cell.topicColor = $0!.tagColor }
        .store(in: &self.subscriptions)
      self.$choices
        .filter { [unowned self] _ in self.stage.rawValue >= NewPollController.Stage.Choices.rawValue }
        .receive(on: DispatchQueue.main)
        .sink {
          cell.refreshChoices($0)
          cell.present(index: $0.count-1, seconds: 0)
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
      self.$topic
        .filter { [unowned self] in !$0.isNil && self.stage.rawValue >= NewPollController.Stage.Choices.rawValue }
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
      cell.$isAnimationComplete
        .filter { !$0.isNil }
        .receive(on: DispatchQueue.main)
        .sink { [unowned self] _ in self.stage = .Images; self.stageAnimationFinished = .Choices }
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
      
      self.$stageAnimationFinished
        .filter { $0 == .Question }
        .receive(on: DispatchQueue.main)
        .sink { [unowned self] _ in cell.color = self.topic.tagColor }
        .store(in: &self.subscriptions)
      self.$stage
        .filter { $0 == .Choices }
        .filter { [unowned self] _ in self.choices.count == 1 }
        .delay(for: .seconds(0.75), scheduler: DispatchQueue.main)
        .sink { _ in cell.present(index: 0) }
        .store(in: &self.subscriptions)
    }
    
    let imagesCellRegistration = UICollectionView.CellRegistration<NewPollImagesCell, AnyHashable> { [unowned self] cell, _, _ in
      cell.topicColor = self.topic.isNil ? .systemGray4 : self.topic!.tagColor
      cell.stage = .Images
      cell.stageGlobal = self.stage
      cell.images = self.images
      cell.addImagePublisher
        .receive(on: DispatchQueue.main)
//        .sink { [unowned self] in self.addImage() }
        .sink { [unowned self] in self.addImagePublisher.send() }
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
      self.$topic
        .filter { [unowned self] in !$0.isNil && self.stage.rawValue >= NewPollController.Stage.Images.rawValue }
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
      cell.$isAnimationComplete
        .filter { !$0.isNil }
        .receive(on: DispatchQueue.main)
        .sink { [unowned self] _ in self.stageAnimationFinished = .Images; self.stage = .Hyperlink }
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
      
      self.$stageAnimationFinished
        .filter { $0 == .Choices }
        .receive(on: DispatchQueue.main)
        .sink { [unowned self] _ in cell.color = self.topic.tagColor; cell.present() }
        .store(in: &self.subscriptions)    }
    
    let hyperlinkCellRegistration = UICollectionView.CellRegistration<NewPollHyperlinkCell, AnyHashable> { [unowned self] cell, _, _ in
      cell.color = self.stage.rawValue >= NewPollController.Stage.Hyperlink.rawValue ? self.topic!.tagColor : .systemGray4
      cell.minHeight = 40
      cell.stage = .Hyperlink
      cell.stageGlobal = self.stage
      cell.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .body)
      cell.text = self.hyperlink
      self.$stage
        .sink { cell.stageGlobal = $0 }
        .store(in: &self.subscriptions)
//      self.$isKeyboardOnScreen
//        .receive(on: DispatchQueue.main)
//        .sink { cell.isKeyboardOnScreen = $0 }
//        .store(in: &self.subscriptions)
      self.$topic
        .filter { [unowned self] in !$0.isNil && self.stage.rawValue >= NewPollController.Stage.Hyperlink.rawValue }
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
      cell.$isAnimationComplete
        .filter { !$0.isNil }
        .receive(on: DispatchQueue.main)
        .sink { [unowned self] _ in self.stageAnimationFinished = .Hyperlink }
        .store(in: &self.subscriptions)
      cell.boundsPublisher
        .eraseToAnyPublisher()
        .receive(on: DispatchQueue.main)
        .sink { [unowned self] _ in self.source.refresh() }
        .store(in: &self.subscriptions)
      cell.$skip
        .filter { !$0.isNil }
        .receive(on: DispatchQueue.main)
        .sink { [unowned self] _ in
          guard let next = self.stage.next() else { return }
          self.stage = next }
        .store(in: &self.subscriptions)
      var config = UIBackgroundConfiguration.listPlainCell()
      config.backgroundColor = .clear
      cell.backgroundConfiguration = config
      cell.automaticallyUpdatesBackgroundConfiguration = false
      
      self.$stageAnimationFinished
        .filter { $0 == .Images }
        .receive(on: DispatchQueue.main)
        .sink { [unowned self] _ in cell.color = self.topic.tagColor; cell.present() }
        .store(in: &self.subscriptions)
//      self.$stage
//        .filter { $0 == .Hyperlink }
//        .delay(for: .seconds(0.75), scheduler: DispatchQueue.main)
//        .sink { _ in cell.present() }
//        .store(in: &self.subscriptions)
    }
    
    let commentsCellRegistration = UICollectionView.CellRegistration<NewPollCommentsCell, AnyHashable> { [unowned self] cell, _, _ in
      cell.stage = .Comments
      cell.color = self.stage.rawValue >= NewPollController.Stage.Comments.rawValue ? self.topic!.tagColor : .systemGray4
      cell.stageGlobal = self.stage
      if !self.commentsEnabled.isNil {
        cell.commentsEnabled = self.commentsEnabled!
      }
      self.$stage
        .sink { cell.stageGlobal = $0 }
        .store(in: &self.subscriptions)
      self.$topic
        .filter { [unowned self] in !$0.isNil && self.stage.rawValue >= NewPollController.Stage.Comments.rawValue }
        .receive(on: DispatchQueue.main)
        .sink { cell.color = $0!.tagColor }
        .store(in: &self.subscriptions)
      cell.$commentsEnabled
        .filter { !$0.isNil }
        .receive(on: DispatchQueue.main)
        .sink { [unowned self] in self.commentsEnabled = $0! }
        .store(in: &self.subscriptions)
      cell.$isAnimationComplete
        .filter { !$0.isNil }
        .receive(on: DispatchQueue.main)
        .sink { [unowned self] _ in self.stageAnimationFinished = .Comments }
        .store(in: &self.subscriptions)
      cell.boundsPublisher
        .eraseToAnyPublisher()
        .receive(on: DispatchQueue.main)
        .sink { [unowned self] _ in self.source.refresh() }
        .store(in: &self.subscriptions)
      cell.$isStageComplete
        .filter { !$0.isNil }
        .receive(on: DispatchQueue.main)
        .sink { [unowned self] _ in
          guard let next = self.stage.next() else { return }
          self.stage = next }
        .store(in: &self.subscriptions)
      var config = UIBackgroundConfiguration.listPlainCell()
      config.backgroundColor = .clear
      cell.backgroundConfiguration = config
      cell.automaticallyUpdatesBackgroundConfiguration = false
      
      self.$stageAnimationFinished
        .filter { $0 == .Hyperlink }
        .receive(on: DispatchQueue.main)
        .sink { [unowned self] _ in cell.color = self.topic.tagColor }
        .store(in: &self.subscriptions)
    }
    
    let anonCellRegistration = UICollectionView.CellRegistration<NewPollAnonimityCell, AnyHashable> { [unowned self] cell, _, _ in
      cell.stage = .Anonymity
      cell.color = self.stage.rawValue >= NewPollController.Stage.Anonymity.rawValue ? self.topic!.tagColor : .systemGray4
      cell.stageGlobal = self.stage
      if !self.anonimityEnabled.isNil {
        cell.anonimityEnabled = self.anonimityEnabled!
      }
      self.$stage
        .sink { cell.stageGlobal = $0 }
        .store(in: &self.subscriptions)
      self.$topic
        .filter { [unowned self] in !$0.isNil && self.stage.rawValue >= NewPollController.Stage.Anonymity.rawValue }
        .receive(on: DispatchQueue.main)
        .sink { cell.color = $0!.tagColor }
        .store(in: &self.subscriptions)
      cell.$anonimityEnabled
        .filter { !$0.isNil }
        .receive(on: DispatchQueue.main)
        .sink { [unowned self] in self.anonimityEnabled = $0! }
        .store(in: &self.subscriptions)
      cell.$isAnimationComplete
        .filter { !$0.isNil }
        .receive(on: DispatchQueue.main)
        .sink { [unowned self] _ in self.stageAnimationFinished = .Anonymity }
        .store(in: &self.subscriptions)
      cell.boundsPublisher
        .eraseToAnyPublisher()
        .receive(on: DispatchQueue.main)
        .sink { [unowned self] _ in self.source.refresh() }
        .store(in: &self.subscriptions)
      cell.$isStageComplete
        .filter { !$0.isNil }
        .receive(on: DispatchQueue.main)
        .sink { [unowned self] _ in
          guard let next = self.stage.next() else { return }
          self.stage = next }
        .store(in: &self.subscriptions)
      var config = UIBackgroundConfiguration.listPlainCell()
      config.backgroundColor = .clear
      cell.backgroundConfiguration = config
      cell.automaticallyUpdatesBackgroundConfiguration = false
      
      self.$stageAnimationFinished
        .filter { $0 == .Comments }
        .receive(on: DispatchQueue.main)
        .sink { [unowned self] _ in cell.color = self.topic.tagColor }
        .store(in: &self.subscriptions)
    }
    
    let hotCellRegistration = UICollectionView.CellRegistration<NewPollHotCell, AnyHashable> { [unowned self] cell, _, _ in
      cell.stage = .Anonymity
      cell.color = self.stage.rawValue >= NewPollController.Stage.Hot.rawValue ? self.topic!.tagColor : .systemGray4
      cell.stageGlobal = self.stage
//      if !self.anonimityEnabled.isNil {
//        cell.anonimityEnabled = self.anonimityEnabled!
//      }
      self.$stage
        .sink { cell.stageGlobal = $0 }
        .store(in: &self.subscriptions)
      self.$topic
        .filter { [unowned self] in !$0.isNil && self.stage.rawValue >= NewPollController.Stage.Hot.rawValue }
        .receive(on: DispatchQueue.main)
        .sink { cell.color = $0!.tagColor }
        .store(in: &self.subscriptions)
//      cell.$anonimityEnabled
//        .filter { !$0.isNil }
//        .receive(on: DispatchQueue.main)
//        .sink { [unowned self] in self.anonimityEnabled = $0! }
//        .store(in: &self.subscriptions)
      cell.$isAnimationComplete
        .filter { !$0.isNil }
        .receive(on: DispatchQueue.main)
        .sink { [unowned self] _ in self.stageAnimationFinished = .Hot }
        .store(in: &self.subscriptions)
      cell.boundsPublisher
        .eraseToAnyPublisher()
        .receive(on: DispatchQueue.main)
        .sink { [unowned self] _ in self.source.refresh() }
        .store(in: &self.subscriptions)
//      cell.$isStageComplete
//        .filter { !$0.isNil }
//        .receive(on: DispatchQueue.main)
//        .sink { [unowned self] _ in
//          guard let next = self.stage.next() else { return }
//          self.stage = next }
//        .store(in: &self.subscriptions)
      var config = UIBackgroundConfiguration.listPlainCell()
      config.backgroundColor = .clear
      cell.backgroundConfiguration = config
      cell.automaticallyUpdatesBackgroundConfiguration = false
      
      self.$stageAnimationFinished
        .filter { $0 == .Anonymity }
        .receive(on: DispatchQueue.main)
        .sink { [unowned self] _ in cell.color = self.topic.tagColor }
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
      } else if section == .Hot {
        return collectionView.dequeueConfiguredReusableCell(using: hotCellRegistration,
                                                            for: indexPath,
                                                            item: identifier)
      }
      return UICollectionViewCell()
    }
    
    var snapshot = Snapshot()
    snapshot.appendSections([.Topic,
                             .Title,
                             .Description,
                             .Question,
                             .Choices,
                             .Images,
                             .Hyperlink,
                             .Comments,
                             .Anonymity,
                             .Hot])
    snapshot.appendItems([0], toSection: .Topic)
    snapshot.appendItems([1], toSection: .Title)
    snapshot.appendItems([2], toSection: .Description)
    snapshot.appendItems([3], toSection: .Question)
    snapshot.appendItems([4], toSection: .Choices)
    snapshot.appendItems([5], toSection: .Images)
    snapshot.appendItems([6], toSection: .Hyperlink)
    snapshot.appendItems([7], toSection: .Comments)
    snapshot.appendItems([8], toSection: .Anonymity)
    snapshot.appendItems([9], toSection: .Hot)
    source.apply(snapshot, animatingDifferences: false)
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

extension NewPollCollectionView: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView,
                      shouldSelectItemAt indexPath: IndexPath) -> Bool {
    if let cell = cellForItem(at: indexPath) as? CommentsSectionCell {
      guard cell.item.isComplete else {
        let banner = NewBanner(contentView: TextBannerContent(image: UIImage(systemName: "exclamationmark.triangle.fill")!,
                                                              text: "vote_to_view_comments",
                                                              tintColor: .systemOrange),
                               contentPadding: UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8),
                               isModal: false,
                               useContentViewHeight: true,
                               shouldDismissAfter: 2)
        banner.didDisappearPublisher
          .sink { _ in banner.removeFromSuperview() }
          .store(in: &self.subscriptions)
        
        return false
      }
      
      collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [.bottom])
      source.refresh()
      collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
      return true
    }
    //        // Allows for closing an already open cell
    //        if collectionView.indexPathsForSelectedItems?.contains(indexPath) ?? false {
    //            collectionView.deselectItem(at: indexPath, animated: true)
    //        } else {
    //            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
    //        }
    //
    //        source.refresh()
    //
    //        return false // The selecting or deselecting is already performed above
    
    //        guard let cell = collectionView.cellForItem(at: indexPath), !cell.isSelected else {
    //            collectionView.deselectItem(at: indexPath, animated: true)
    //            source.refresh()
    //            return false
    //        }
    collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
    source.refresh()
    return true
  }
  
  func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
    collectionView.deselectItem(at: indexPath, animated: true)
    source.refresh()
    return false
  }
}
