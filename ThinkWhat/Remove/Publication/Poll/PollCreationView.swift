//
//  PollCreationView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 26.05.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class PollCreationView: UIView, UINavigationControllerDelegate {
    
    deinit {
#if DEBUG
        print("PollCreationView deinit")
#endif
        NotificationCenter.default.removeObserver(self)
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
    
    // MARK: - Properties
    weak var viewInput: (PollCreationViewInput & UIViewController)?
    private var newInstance: Survey?
    private var topic: Topic! {
        didSet {
            guard oldValue != topic else { return }
            Task {
                try await Task.sleep(nanoseconds: UInt64(0.1 * 1_000_000_000))
                await MainActor.run {
                    let destinationPath = (topicButton.icon.getLayer(Icon.Category(rawValue: topic.id) ?? .Null) as! CAShapeLayer).path!
                    let pathAnim = Animations.get(property: .Path,
                                                  fromValue: (topicButton.icon.icon as! CAShapeLayer).path as Any,
                                                  toValue: destinationPath as Any,
                                                  duration: 0.3,
                                                  delay: 0,
                                                  repeatCount: 0,
                                                  autoreverses: false,
                                                  timingFunction: CAMediaTimingFunctionName.easeInEaseOut,
                                                  delegate: nil,
                                                  isRemovedOnCompletion: true)
                    topicButton.icon.icon.add(pathAnim, forKey: nil)
                    (topicButton.icon.icon as! CAShapeLayer).path = destinationPath
                    UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                        self.setText()
                        self.color = self.topic.tagColor
                    } completion: { _ in
                        self.viewInput?.onStageCompleted()
                    }
                }
            }
        }
    }
    private var option: PollCreationController.Option = .Null {
        didSet {
            guard oldValue != option else { return }
            Task {
                try await Task.sleep(nanoseconds: UInt64(0.1 * 1_000_000_000))
                await MainActor.run {
                    var destinationPath: CGPath!
                    switch option{
                    case .Private:
                        destinationPath = (optionsButton.icon.getLayer(Icon.Category.Locked) as! CAShapeLayer).path!
                    case .Ordinary:
                        destinationPath = (optionsButton.icon.getLayer(Icon.Category.Unlocked) as! CAShapeLayer).path!
                    case .Anon:
                        destinationPath = (optionsButton.icon.getLayer(Icon.Category.Anon) as! CAShapeLayer).path!
                    default:
                        destinationPath = (optionsButton.icon.icon as! CAShapeLayer).path
                    }
                    let pathAnim = Animations.get(property: .Path,
                                                  fromValue: (optionsButton.icon.icon as! CAShapeLayer).path as Any,
                                                  toValue: destinationPath as Any,
                                                  duration: 0.3,
                                                  delay: 0,
                                                  repeatCount: 0,
                                                  autoreverses: false,
                                                  timingFunction: CAMediaTimingFunctionName.easeInEaseOut,
                                                  delegate: nil,
                                                  isRemovedOnCompletion: true)
                    optionsButton.icon.icon.add(pathAnim, forKey: nil)
                    (optionsButton.icon.icon as! CAShapeLayer).path = destinationPath
                    UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                        self.setText()
                    } completion: { [weak self] _ in
                        guard let self = self else { return }
                        guard self.option == .Private,
                              self.viewInput?.stage == .Ready,
                              !self.hotOptionButton.isNil else {
//                            self.hotOptionButton.isUserInteractionEnabled = true
                            self.hotOptionButton.color = self.traitCollection.userInterfaceStyle == .dark ? .systemBlue : self.color
                            self.hotOptionButton.icon.backgroundColor = self.traitCollection.userInterfaceStyle == .dark ? .systemBlue : self.color
                            return
                        }
                        self.hot = .Off
//                        self.hotOptionButton.isUserInteractionEnabled = false
                        self.hotOptionButton.color = .systemGray
                        self.hotOptionButton.icon.backgroundColor = .systemGray
                    }
                }
                try await Task.sleep(nanoseconds: UInt64(0.25 * 1_000_000_000))
                await MainActor.run {
                    viewInput?.onStageCompleted()
                }
            }
        }
    }
    private var comments: PollCreationController.Comments = .On {
        didSet {
            //            guard oldValue != comments else { return }
            if oldValue != comments {
                Task {
                    try await Task.sleep(nanoseconds: UInt64(0.1 * 1_000_000_000))
                    await MainActor.run {
                        var destinationPath: CGPath!
                        switch comments{
                        case .On:
                            destinationPath = (commentsButton.icon.getLayer(Icon.Category.Comments) as! CAShapeLayer).path!
                        case .Off:
                            destinationPath = (commentsButton.icon.getLayer(Icon.Category.CommentsDisabled) as! CAShapeLayer).path!
                        }
                        let pathAnim = Animations.get(property: .Path,
                                                      fromValue: (commentsButton.icon.icon as! CAShapeLayer).path as Any,
                                                      toValue: destinationPath as Any,
                                                      duration: 0.3,
                                                      delay: 0,
                                                      repeatCount: 0,
                                                      autoreverses: false,
                                                      timingFunction: CAMediaTimingFunctionName.easeInEaseOut,
                                                      delegate: nil,
                                                      isRemovedOnCompletion: true)
                        commentsButton.icon.icon.add(pathAnim, forKey: nil)
                        (commentsButton.icon.icon as! CAShapeLayer).path = destinationPath
                        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                            self.setText()
                        } completion: { _ in }
                    }
                    guard viewInput?.stage == .Comments else { return }
                    try await Task.sleep(nanoseconds: UInt64(0.25 * 1_000_000_000))
                    await MainActor.run {
                        viewInput?.onStageCompleted()
                    }
                }
            } else {
                guard viewInput?.stage == .Comments else { return }
                viewInput?.onStageCompleted()
            }
        }
    }
    private var limits = 50 {
        didSet {
            setText()
            guard viewInput?.stage == .Limits else { return }
            viewInput?.onStageCompleted()
        }
    }
    private var hot: PollCreationController.Hot = .Off {
        didSet {
            if oldValue != hot {
                Task {
                    try await Task.sleep(nanoseconds: UInt64(0.1 * 1_000_000_000))
                    await MainActor.run {
                        var destinationPath: CGPath!
                        switch hot{
                        case .On:
                            destinationPath = (hotOptionButton.icon.getLayer(Icon.Category.Hot) as! CAShapeLayer).path!
                        case .Off:
                            destinationPath = (hotOptionButton.icon.getLayer(Icon.Category.HotDisabled) as! CAShapeLayer).path!
                        }
                        let pathAnim = Animations.get(property: .Path,
                                                      fromValue: (hotOptionButton.icon.icon as! CAShapeLayer).path as Any,
                                                      toValue: destinationPath as Any,
                                                      duration: 0.3,
                                                      delay: 0,
                                                      repeatCount: 0,
                                                      autoreverses: false,
                                                      timingFunction: CAMediaTimingFunctionName.easeInEaseOut,
                                                      delegate: nil,
                                                      isRemovedOnCompletion: true)
                        hotOptionButton.icon.icon.add(pathAnim, forKey: nil)
                        (hotOptionButton.icon.icon as! CAShapeLayer).path = destinationPath
                        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                            self.setText()
                        } completion: { _ in
                            guard self.viewInput?.stage == .Hot else { return }
                                self.viewInput?.onStageCompleted()
                        }
                    }
                    guard viewInput?.stage != .Hot else { return }
                    try await Task.sleep(nanoseconds: UInt64(0.3 * 1_000_000_000))
                    await MainActor.run {
                        viewInput?.onStageCompleted()
                    }
                }
            } else {
                guard viewInput?.stage == .Hot else { return }
                viewInput?.onStageCompleted()
            }
        }
    }
    
    var costItems: [CostItem] = [
//        CostItem(title: "One", cost: 12),
//        CostItem(title: "Two", cost: 36),
//        CostItem(title: "Two", cost: 982),
//        CostItem(title: "Two", cost: 982),
//        CostItem(title: "Two", cost: 982),
//        CostItem(title: "Two", cost: 982),
//        CostItem(title: "Two", cost: 982),
//        CostItem(title: "Two", cost: 982),
    ]
    var balance: Int {
        return viewInput?.balance ?? 0
    }
    
    var imageItems: [ImageItem] = [
//                ImageItem(title: "One", image: UIImage(systemName: "mic.fill")!),
//                ImageItem(title: "Two", image: UIImage(systemName: "sunset.fill")!),
    ] {
        didSet {
            guard !pollImagesHeaderLabel.isNil else { return }
            pollImagesHeaderLabel.text = "total_images".localized.capitalized +  ": \(imageItems.count)"
        }
    }
    var choiceItems: [ChoiceItem] = [
        ChoiceItem(text: ""),
    ] {
        didSet {
            if choiceItems.count == 1 {
                let item = ChoiceItem(text: "")
                choiceItems.append(item)
                delay(seconds: 0.5) {
                    fatalError()
//                    let banner = Popup(callbackDelegate: self, bannerDelegate: self, heightScaleFactor: deviceType == .iPhoneSE ? 0.8 : 0.5)
//
//                    banner.present(content: ChoiceEditingPopup(callbackDelegate: banner, item: item, index: self.choiceItems.firstIndex(of: self.choiceItems.last!)! + 1 , forceEditing: true, mode: .Create))
                }
                if viewInput?.stage != .Choices {
                    delay(seconds: 0.75) {
                        showBanner(bannerDelegate: self,
                                   text: AppError.minimumChoices.localizedDescription,
                                   content: ImageSigns.exclamationMark,
                                   color: self.color,
                                   dismissAfter: 1)
                    }
                }
            }
            //            choiceItems.enumerated().forEach { (index, item) in
            //                guard var existing = choiceItems.filter({ $0.id == item.id }).first else { return }
            //                existing.index = index
//            }
            guard !pollChoicesHeaderLabel.isNil else { return }
            pollChoicesHeaderLabel.text = "total_choices".localized.capitalized +  ": \(choiceItems.count)"
        }
    }
//    private var callback: Closure? = {
//        fatalError()
//    }
    public var result: Result<Bool, Error>! {
        didSet {
            completed = true
        }
    }
//    private let resultKeyPath = \PollCreationView.result
//
    @objc dynamic var completed: Bool = false
    
//    private let completedKeyPath = \PollCreationView.completed
//    weak var poll: Survey?
    
    // MARK: - Private properties
    private var fontSize: CGFloat = .zero
    private var color: UIColor = .systemGray {
        didSet {
            guard !scrollContentView.isNil, oldValue != color else { return }
            
            scrollContentView.get(all: [CircleButton.self]).forEach {
                guard let v =  $0 as? CircleButton else { return }
                v.color = self.traitCollection.userInterfaceStyle == .dark ? .systemBlue : self.color
                v.icon.backgroundColor = self.traitCollection.userInterfaceStyle == .dark ? .systemBlue : self.color
            }
            
            scrollContentView.get(all: [UIView.self]).filter({
                $0.accessibilityIdentifier == "line"
            }).forEach({ [weak self] in
                guard let self = self else { return }
                $0.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : self.color
            })
            
            scrollContentView.get(all: [UIImageView.self]).filter({
                $0.accessibilityIdentifier == "skip"
            }).forEach {
                $0.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
            }
            
            scrollContentView.get(all: [UITextView.self]).forEach {
                guard let v =  $0 as? UITextView else { return }
                v.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
            }
            
            pollURLSkip.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
            pollChoicesHeaderButton.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
            pollImagesHeaderButton.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
            pollChoicesSkip.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
            pollImagesSkip.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
            choiceContainer?.color = color
            publicationButton.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
            guard let v = imagesContainer as? ImageSelectionCollectionView else { return }
            v.color = color
        }
    }
    private var lines: [Line] = []
    private var lineWidth: CGFloat = .zero {
        didSet {
            scrollContentView.get(all: [UIView.self]).filter({
                $0.accessibilityIdentifier == "line"
            }).forEach({
                $0.cornerRadius = lineWidth/2
                $0.getAllConstraints().filter({
                    constraint in constraint.identifier == "width"
                }).forEach({
                    value in value.constant = lineWidth
                })
            })
        }
    }
    private var lineAnimationDuration = 0.25
    private var lastContentOffsetY = CGFloat.zero
//    private var titleObserver: NSKeyValueObservation?
//    private var descriptionObserver: NSKeyValueObservation?
//    private var questionObserver: NSKeyValueObservation?
    private var observers: [NSKeyValueObservation] = []
    private var isTextFieldEditingEnabled = true
    private weak var imagesContainer: (UIScrollView & ImageSelectionProvider)?
    private weak var choiceContainer: (UIScrollView & ChoiceProvider)?
    private lazy var imagePicker: UIImagePickerController = {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        return picker
    }()
    
    // MARK: - IB outlets
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.delegate = self
        }
    }
    @IBOutlet weak var scrollContentView: UIView!
    
    ///Topic
    @IBOutlet weak var topicView: UIView!
    @IBOutlet weak var topicStaticLabel: ArcLabel!
    @IBOutlet weak var topicLabel: ArcLabel!
    @IBOutlet weak var topicButton: CircleButton! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
            topicButton.addGestureRecognizer(tap)
//            topicButton.icon.alpha = 0
            topicButton.state = .On
            topicButton.color = color
            topicButton.text = "РАЗДЕЛ"
            topicButton.category = .Topics
            topicButton.accessibilityIdentifier = "button"
        }
    }
    @IBOutlet weak var topicLine: UIView! {
        didSet {
            topicLine.accessibilityIdentifier = "line"
        }
    }
    
    
    ///Options
    @IBOutlet weak var optionsView: UIView!
    @IBOutlet weak var optionsStaticLabel: ArcLabel!
    @IBOutlet weak var optionsLabel: ArcLabel!
    @IBOutlet weak var optionsButton: CircleButton! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
            optionsButton.addGestureRecognizer(tap)
//            optionsButton.icon.alpha = 0
            optionsButton.state = .On
            optionsButton.color = color
            optionsButton.category = .Accessibility
            optionsButton.accessibilityIdentifier = "button"
        }
    }
    @IBOutlet weak var optionsLine: UIView! {
        didSet {
            optionsLine.accessibilityIdentifier = "line"
        }
    }
    
    ///Poll title
    @IBOutlet weak var pollTitleView: UIView!
    @IBOutlet weak var pollTitleStaticLabel: ArcLabel!
    @IBOutlet weak var pollTitleButton: CircleButton! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
            pollTitleButton.addGestureRecognizer(tap)
//            optionsButton.icon.alpha = 0
            pollTitleButton.state = .On
            pollTitleButton.color = color
            pollTitleButton.text = "РАЗДЕЛ"
            pollTitleButton.category = .Abc
            pollTitleButton.accessibilityIdentifier = "button"
        }
    }
    @IBOutlet weak var pollTitleBg: UIView! {
        didSet {
            pollTitleBg.accessibilityIdentifier = "shadow"
            pollTitleBg.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
            pollTitleBg.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.6).cgColor
            pollTitleBg.layer.shadowRadius = 7
            pollTitleBg.layer.shadowOffset = .zero

        }
    }
    @IBOutlet weak var pollTitleFg: UIView! {
        didSet {
            pollTitleFg.accessibilityIdentifier = "front"
            pollTitleFg.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .systemBackground
        }
    }
    @IBOutlet weak var pollTitleHeight: NSLayoutConstraint! {
        didSet {
            pollDescriptionHeight.constant = 90
        }
    }
    @IBOutlet weak var pollTitleTextView: UITextView! {
        didSet {
            pollTitleTextView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
            pollTitleTextView.delegate = self
            pollTitleTextView.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
            pollTitleTextView.text = ""
        }
    }
    @IBOutlet weak var pollTitleTemp: UIView!
    @IBOutlet weak var pollTitleSkip: UIImageView! {
        didSet {
            pollTitleSkip.contentMode = .center
            pollTitleSkip.image = UIImage(systemName: "arrow.down")
            pollTitleSkip.accessibilityIdentifier = "skip"
            pollTitleSkip.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
            pollTitleSkip.addGestureRecognizer(tap)
            pollTitleSkip.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
        }
    }
    @IBOutlet weak var pollTitleLine: UIView! {
        didSet {
            pollTitleLine.accessibilityIdentifier = "line"
        }
    }
    
    ///Poll description
    @IBOutlet weak var pollDescriptionView: UIView!
    @IBOutlet weak var pollDescriptionStaticLabel: ArcLabel!
    @IBOutlet weak var pollDescriptionButton: CircleButton! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
            pollDescriptionButton.addGestureRecognizer(tap)
//            optionsButton.icon.alpha = 0
            pollDescriptionButton.state = .On
            pollDescriptionButton.color = color
            pollDescriptionButton.category = .Paragraph
            pollDescriptionButton.accessibilityIdentifier = "button"
        }
    }
    @IBOutlet weak var pollDescriptionBg: UIView! {
        didSet {
            pollDescriptionBg.accessibilityIdentifier = "shadow"
            pollDescriptionBg.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
            pollDescriptionBg.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.6).cgColor
            pollDescriptionBg.layer.shadowRadius = 7
            pollDescriptionBg.layer.shadowOffset = .zero
        }
    }
    @IBOutlet weak var pollDescriptionFg: UIView! {
        didSet {
            pollDescriptionFg.accessibilityIdentifier = "front"
            pollDescriptionFg.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .systemBackground
        }
    }
    @IBOutlet weak var pollDescriptionHeight: NSLayoutConstraint! {
        didSet {
            pollDescriptionHeight.constant = 90
        }
    }
    @IBOutlet weak var pollDescriptionTextView: UITextView! {
        didSet {
            pollDescriptionTextView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
            pollDescriptionTextView.delegate = self
            pollDescriptionTextView.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
            pollDescriptionTextView.text = ""
//            pollDescriptionTextView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        }
    }
    @IBOutlet weak var pollDescriptionTemp: UIView!
    @IBOutlet weak var pollDescriptionSkip: UIImageView! {
        didSet {
            pollDescriptionSkip.contentMode = .center
            pollDescriptionSkip.image = UIImage(systemName: "arrow.down")
            pollDescriptionSkip.accessibilityIdentifier = "skip"
            pollDescriptionSkip.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
            pollDescriptionSkip.addGestureRecognizer(tap)
            pollDescriptionSkip.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
        }
    }
//    @IBOutlet weak var pollDescriptionOptionalLabel: UILabel!
    @IBOutlet weak var pollDescriptionLine: UIView! {
        didSet {
            pollDescriptionLine.accessibilityIdentifier = "line"
        }
    }

//    @IBOutlet weak var pollDescriptionSkip: UIImageView! {
//        didSet {
//            pollDescriptionSkip.accessibilityIdentifier = "skip"
//            pollDescriptionSkip.isUserInteractionEnabled = true
//            let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
//            pollDescriptionSkip.addGestureRecognizer(tap)
//            pollDescriptionSkip.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
//        }
//    }

    ///Poll question
    @IBOutlet weak var pollQuestionView: UIView!
    @IBOutlet weak var pollQuestionStaticLabel: ArcLabel!
    @IBOutlet weak var pollQuestionButton: CircleButton! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
            pollQuestionButton.addGestureRecognizer(tap)
//            optionsButton.icon.alpha = 0
            pollQuestionButton.state = .On
            pollQuestionButton.color = color
            pollQuestionButton.category = .QuestionMark
            pollQuestionButton.accessibilityIdentifier = "button"
        }
    }
    @IBOutlet weak var pollQuestionBg: UIView! {
        didSet {
            pollQuestionBg.accessibilityIdentifier = "shadow"
            pollQuestionBg.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
            pollQuestionBg.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.6).cgColor
            pollQuestionBg.layer.shadowRadius = 7
            pollQuestionBg.layer.shadowOffset = .zero
        }
    }
    @IBOutlet weak var pollQuestionFg: UIView! {
        didSet {
            pollQuestionFg.accessibilityIdentifier = "front"
            pollQuestionFg.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .systemBackground
        }
    }
    @IBOutlet weak var pollQuestionHeight: NSLayoutConstraint! {
        didSet {
            pollQuestionHeight.constant = 90
        }
    }
    @IBOutlet weak var pollQuestionTextView: UITextView! {
        didSet {
            pollQuestionTextView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
            pollQuestionTextView.delegate = self
            pollQuestionTextView.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
            pollQuestionTextView.text = ""
//            pollQuestionTextView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        }
    }
    @IBOutlet weak var pollQuestionTemp: UIView!
    @IBOutlet weak var pollQuestionSkip: UIImageView! {
        didSet {
            pollQuestionSkip.contentMode = .center
            pollQuestionSkip.image = UIImage(systemName: "arrow.down")
            pollQuestionSkip.accessibilityIdentifier = "skip"
            pollQuestionSkip.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
            pollQuestionSkip.addGestureRecognizer(tap)
            pollQuestionSkip.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
        }
    }
    @IBOutlet weak var pollQuestionLine: UIView! {
        didSet {
            pollQuestionLine.accessibilityIdentifier = "line"
        }
    }
    @IBOutlet weak var pollQuestionStandartQuestion: UIButton! {
        didSet {
            pollQuestionStandartQuestion.tintColor = .systemBlue
            pollQuestionStandartQuestion.setTitle("poll_standart_question_button".localized, for: .normal)
        }
    }
    @IBAction func pollQuestionStandartQuestionTapped(_ sender: Any) {
        pollQuestionTextView.text = "poll_standart_question".localized
    }
    
    ///Poll URL
    @IBOutlet weak var pollURLView: UIView!
    @IBOutlet weak var pollURLStaticLabel: ArcLabel!
    @IBOutlet weak var pollURLButton: CircleButton! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
            pollURLButton.addGestureRecognizer(tap)
//            optionsButton.icon.alpha = 0
            pollURLButton.state = .On
            pollURLButton.color = color
            pollURLButton.category = .Hyperlink
            pollURLButton.accessibilityIdentifier = "button"
        }
    }
    @IBOutlet weak var pollURLBg: UIView! {
        didSet {
            pollURLBg.accessibilityIdentifier = "shadow"
            pollURLBg.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
        }
    }
    @IBOutlet weak var pollURLContainerView: UIView! {
        didSet {
            pollURLContainerView.accessibilityIdentifier = "front"
            pollURLContainerView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .systemBackground
        }
    }
    @IBOutlet weak var pollURLTextField: InsetTextField! {
        didSet {
            pollURLTextField.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
            pollURLTextField.delegate = self
            pollURLTextField.placeholder = "url_placeholder".localized
            pollURLTextField.textColor = .systemBlue
        }
    }
    @IBOutlet weak var pollURLBrowserButton: UIButton! {
        didSet {
            pollURLBrowserButton.tintColor = .systemBlue
            pollURLBrowserButton.setTitle("open_safari".localized, for: .normal)
        }
    }
    @IBAction func pollURLBrowserButtonTapped(_ sender: Any) {
        guard let text = pollURLTextField.text else { return }
        viewInput?.onURLTapped(URL(string: text))
    }
    @IBOutlet weak var pollURLOptionalLabel: UILabel!
    @IBOutlet weak var pollURLSkip: UIImageView! {
        didSet {
            pollURLSkip.contentMode = .center
            pollURLSkip.image = UIImage(systemName: "arrow.down")
            pollURLSkip.accessibilityIdentifier = "skip"
            pollURLSkip.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
            pollURLSkip.addGestureRecognizer(tap)
            pollURLSkip.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
        }
    }
    @IBOutlet weak var pollURLLine: UIView! {
        didSet {
            pollURLLine.accessibilityIdentifier = "line"
        }
    }
    
    ///Poll images
    @IBOutlet weak var pollImagesView: UIView!
    @IBOutlet weak var pollImagesStaticLabel: ArcLabel!
    @IBOutlet weak var pollImagesButton: CircleButton! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
            pollImagesButton.addGestureRecognizer(tap)
//            optionsButton.icon.alpha = 0
            pollImagesButton.state = .On
            pollImagesButton.color = color
            pollImagesButton.category = .Picture
        }
    }
    @IBOutlet weak var pollImagesBg: UIView! {
        didSet {
            pollImagesBg.accessibilityIdentifier = "shadow"
            pollImagesBg.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
            pollImagesBg.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.6).cgColor
            pollImagesBg.layer.shadowRadius = 7
            pollImagesBg.layer.shadowOffset = .zero
        }
    }
    @IBOutlet weak var pollImagesFg: UIView! {
        didSet {
            pollImagesFg.accessibilityIdentifier = "front"
            pollImagesFg.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .systemBackground
        }
    }
    @IBOutlet weak var pollImagesTemp: UIView!
    @IBOutlet weak var pollImagesHeader: UIView!
    @IBOutlet weak var pollImagesHeaderLabel: UILabel! {
        didSet {
            pollImagesHeaderLabel.text = "total_images".localized.capitalized +  ": \(imageItems.count)"
        }
    }
    @IBOutlet weak var pollImagesHeaderButton: UIImageView! {
        didSet {
            pollImagesHeaderButton.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
            pollImagesHeaderButton.addGestureRecognizer(tap)
            pollImagesHeaderButton.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
        }
    }
    @IBOutlet weak var pollImagesContainerView: UIView!
    @IBOutlet weak var pollImagesSkip: UIImageView! {
        didSet {
            pollImagesSkip.contentMode = .center
            pollImagesSkip.image = UIImage(systemName: "arrow.down")
            pollImagesSkip.accessibilityIdentifier = "skip"
            pollImagesSkip.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
            pollImagesSkip.addGestureRecognizer(tap)
            pollImagesSkip.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
        }
    }
    @IBOutlet weak var pollImagesOptionalLabel: UILabel!
    @IBOutlet weak var pollImagesLine: UIView! {
        didSet {
            pollImagesLine.accessibilityIdentifier = "line"
        }
    }
    
    ///Poll description
    @IBOutlet weak var pollChoicesView: UIView!
    @IBOutlet weak var pollChoicesStaticLabel: ArcLabel!
    @IBOutlet weak var pollChoicesButton: CircleButton! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
            pollChoicesButton.addGestureRecognizer(tap)
//            optionsButton.icon.alpha = 0
            pollChoicesButton.state = .On
            pollChoicesButton.color = color
            pollChoicesButton.category = .List
        }
    }
    @IBOutlet weak var pollChoicesBg: UIView! {
        didSet {
            pollChoicesBg.accessibilityIdentifier = "shadow"
            pollChoicesBg.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
            pollChoicesBg.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.6).cgColor
            pollChoicesBg.layer.shadowRadius = 7
            pollChoicesBg.layer.shadowOffset = .zero
        }
    }
    @IBOutlet weak var pollChoicesFg: UIView! {
        didSet {
            pollChoicesFg.accessibilityIdentifier = "front"
            pollChoicesFg.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .systemBackground
        }
    }
    @IBOutlet weak var pollChoicesHeader: UIView!
    @IBOutlet weak var pollChoicesHeaderLabel: UILabel! {
        didSet {
            pollChoicesHeaderLabel.text = "total_choices".localized.capitalized +  ": \(choiceItems.count)"
        }
    }
    @IBOutlet weak var pollChoicesHeaderButton: UIImageView! {
        didSet {
            pollChoicesHeaderButton.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
            pollChoicesHeaderButton.addGestureRecognizer(tap)
            pollChoicesHeaderButton.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
        }
    }
    @IBOutlet weak var pollChoicesTemp: UIView!
    @IBOutlet weak var pollChoicesContainerView: UIView! {
        didSet {
            pollChoicesContainerView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .systemBackground
        }
    }
    @IBOutlet weak var pollChoicesSkip: UIImageView! {
        didSet {
            pollChoicesSkip.contentMode = .center
            pollChoicesSkip.image = UIImage(systemName: "arrow.down")
            pollChoicesSkip.accessibilityIdentifier = "skip"
            pollChoicesSkip.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
            pollChoicesSkip.addGestureRecognizer(tap)
            pollChoicesSkip.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
        }
    }
    @IBOutlet weak var pollChoicesLine: UIView! {
        didSet {
            pollChoicesLine.accessibilityIdentifier = "line"
        }
    }
    
    ///Limits
    @IBOutlet weak var limitsView: UIView!
    @IBOutlet weak var limitsStaticLabel: ArcLabel!
    @IBOutlet weak var limitsLabel: ArcLabel!
    @IBOutlet weak var limitsButton: CircleButton! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
            limitsButton.addGestureRecognizer(tap)
            limitsButton.state = .On
            limitsButton.color = color
            limitsButton.category = .Speedometer
            limitsButton.accessibilityIdentifier = "button"
        }
    }
    @IBOutlet weak var limitsLine: UIView! {
        didSet {
            limitsLine.accessibilityIdentifier = "line"
        }
    }
    
    ///Comments
    @IBOutlet weak var commentsView: UIView!
    @IBOutlet weak var commentsStaticLabel: ArcLabel!
    @IBOutlet weak var commentsLabel: ArcLabel!
    @IBOutlet weak var commentsButton: CircleButton! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
            commentsButton.addGestureRecognizer(tap)
//            topicButton.icon.alpha = 0
            commentsButton.state = .On
            commentsButton.color = color
            commentsButton.category = .Comments
            commentsButton.accessibilityIdentifier = "button"
        }
    }
    @IBOutlet weak var commentsLine: UIView! {
        didSet {
            commentsLine.accessibilityIdentifier = "line"
        }
    }
    
    ///Hot option
    @IBOutlet weak var hotOptionView: UIView!
    @IBOutlet weak var hotOptionStaticLabel: ArcLabel!
    @IBOutlet weak var hotOptionLabel: ArcLabel!
    @IBOutlet weak var hotOptionButton: CircleButton! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
            hotOptionButton.addGestureRecognizer(tap)
//            topicButton.icon.alpha = 0
            hotOptionButton.state = .Off
            hotOptionButton.color = color
            hotOptionButton.category = .HotDisabled
            hotOptionButton.accessibilityIdentifier = "button"
        }
    }
    @IBOutlet weak var publicationButton: UIButton! {
        didSet {
            publicationButton.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
            publicationButton.alpha = 0
            publicationButton.setTitle("post_poll".localized.uppercased(), for: .normal)
        }
    }
    @IBAction func publicationButtonTapped(_ sender: Any) {
        costItems.removeAll()
//        if hot == .On {
//            costItems.append(CostItem(title: "hot_option".localized, cost: PriceList.shared.hotPost))
//        }
//        costItems.append(CostItem(title: "voters_option".localized, cost: limits))
//        
        fatalError()
//        let banner = Popup(callbackDelegate: self, bannerDelegate: self, heightScaleFactor: deviceType == .iPhoneSE ? 0.8 : 0.6)
//        if viewInput?.balance ?? 0 <  costItems.reduce(into: 0) { $0 += $1.cost } {
//            banner.accessibilityIdentifier = "insufficient_balance"
//        }
//        banner.present(content: CostView(callbackDelegate: banner, dataProvider: self, parent: banner))//, result: result))
    }
}





// MARK: - Controller Output
extension PollCreationView: PollCreationControllerOutput {
    func onImageCopiedToPasteBoard(_ image: UIImage) {
        guard imageItems.count < 3 else { return }
        let banner = Banner(callbackDelegate: self, bannerDelegate: self, fadeBackground: false)
        banner.present(content: ImagePasteView(delegate: banner, image: image))
    }
    
    func onURLCopiedToPasteBoard(_ url: URL) {
        let banner = Banner(callbackDelegate: self, bannerDelegate: self, fadeBackground: false)
        banner.present(content: URLPasteView(delegate: banner, url: url, color: K_COLOR_TABBAR))
    }
    
    func onSuccess() {
        result = .success(true)
    }
    
    func onError(_ error: Error) {
        result = .failure(error)
    }
    
    func post() {
        viewInput?.post(prepareDict())
    }
    
    func onDeinit() {
        observers.forEach{ $0.invalidate() }
    }
    
    func onNextStage(_ stage: PollCreationController.Stage) {
        func animate(button: CircleButton, completionBlocks: [Closure]) {
            button.present(completionBlocks: completionBlocks)
            button.superview!.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
            UIView.animate(withDuration: 0.2) {
                button.superview!.alpha = 1
            }
            
            UIView.animate(
                withDuration: 0.3,
                delay: 0,
                usingSpringWithDamping: 0.55,
                initialSpringVelocity: 2.5,
                options: [.curveEaseInOut],
                animations: {
                    button.superview!.transform = .identity
                }) { _ in }
        }
        
        func animateTransition(lineStart: CGPoint, lineEnd: CGPoint, lineCompletionBlocks: [Closure], animationBlocks animations: [Closure], completionBlocks completion: [Closure], animationDuration: TimeInterval = 0) {
            let line     = drawLine(fromPoint: lineStart, endPoint: lineEnd, lineCap: .round)
            let lineAnim = getLineAnimation(line: line, duration: animationDuration)
            let duration = animationDuration
            
            scrollContentView.layer.insertSublayer(line.layer, at: 0)
//            lineAnim.delegate = self
            lineAnim.setValue(lineCompletionBlocks, forKey: "completionBlocks")
            line.layer.add(lineAnim, forKey: "animEnd")
            
            UIView.animate(withDuration: duration, delay: lineAnimationDuration , options: [.curveEaseInOut], animations:
                {
                    DispatchQueue.main.async {
                        animations.forEach { $0() }
                    }
            }) {
                _ in
                DispatchQueue.main.async {
                    completion.forEach { $0() }
                }
            }
            line.layer.strokeEnd = 1
        }
        
        func animateLine(line: UIView, lineCompletionBlocks: [Closure], animationBlocks animations: [Closure], completionBlocks completion: [Closure], duration: TimeInterval = 0, delay: TimeInterval = 0) {
//            let line     = drawLine(fromPoint: lineStart, endPoint: lineEnd, lineCap: .round)
//            let lineAnim = getLineAnimation(line: line, duration: animationDuration)
//            let duration = animationDuration
//
//            scrollContentView.layer.insertSublayer(line.layer, at: 0)
////            lineAnim.delegate = self
//            lineAnim.setValue(lineCompletionBlocks, forKey: "completionBlocks")
//            line.layer.add(lineAnim, forKey: "animEnd")
            
            reveal(view: line, duration: duration, completionBlocks: completion)
            
//            UIView.animate(withDuration: duration, delay: delay, options: [.curveEaseInOut], animations:
//                {
                    DispatchQueue.main.async {
                        animations.forEach { $0() }
                    }
//            }) {
//                _ in
//                DispatchQueue.main.async {
//                    completion.forEach { $0() }
//                }
//            }
//            line.layer.strokeEnd = 1
        }
        
        func drawLine(fromPoint: CGPoint, endPoint: CGPoint, lineCap: CAShapeLayerLineCap) -> Line {
            let line = Line()
            line.path = UIBezierPath()
            
            line.path.move(to: fromPoint)
            line.path.addLine(to: endPoint)
            
            let interfaceDirection = UIView.userInterfaceLayoutDirection(for: UISemanticContentAttribute.unspecified)
            let path = interfaceDirection == .rightToLeft ? line.path.reversing() : line.path
            
            line.layer.strokeStart = 0
            line.layer.strokeEnd = 0
            line.layer.lineWidth = lineWidth
            line.layer.strokeColor = color.withAlphaComponent(0.3).cgColor//K_COLOR_RED.withAlphaComponent(0.1).cgColor
            line.layer.lineCap = lineCap
            
            line.layer.path = path.cgPath
            lines.append(line)
            return line
        }
        
        func getLineAnimation(line: Line, duration: TimeInterval = 0) -> CAAnimationGroup {
            let strokeEndAnimation      = CABasicAnimation(path: #keyPath(CAShapeLayer.strokeEnd), fromValue: line.layer.strokeEnd, toValue: 1, duration: duration == 0 ? lineAnimationDuration : duration)
            //            let strokeWidthAnimation    = CAKeyframeAnimation(keyPath:"lineWidth")
            //            strokeWidthAnimation.values   = [lineWidth * 2, lineWidth]
            //            strokeWidthAnimation.keyTimes = [0, 1]
            //            strokeWidthAnimation.duration = lineAnimationDuration
            //            let pathFillColorAnim      = CAKeyframeAnimation(keyPath:"strokeColor")
            //            pathFillColorAnim.values   = [selectedColor.withAlphaComponent(0.8).cgColor, selectedColor.withAlphaComponent(0.3).cgColor]
            //            pathFillColorAnim.keyTimes = [0, 1]
            //            pathFillColorAnim.duration = lineAnimationDuration
            
            let groupAnimation = CAAnimationGroup()
            groupAnimation.animations = [strokeEndAnimation]//, strokeWidthAnimation, pathFillColorAnim]
            groupAnimation.duration = duration == 0 ? lineAnimationDuration : duration
            
            return groupAnimation
        }
        
        func reveal(view animatedView: UIView, duration: TimeInterval, completionBlocks: [Closure]) {
            
            let circlePathLayer = CAShapeLayer()
            var _completionBlocks = completionBlocks
            func circleFrameTopCenter() -> CGRect {
                var circleFrame = CGRect(x: 0, y: 0, width: 0, height: 0)
                let circlePathBounds = circlePathLayer.bounds
                circleFrame.origin.x = circlePathBounds.midX - circleFrame.midX
                circleFrame.origin.y = circlePathBounds.minY - circleFrame.minY
                return circleFrame
            }
            
            func circleFrameTop() -> CGRect {
                var circleFrame = CGRect(x: 0, y: 0, width: 0, height: 0)
                let circlePathBounds = circlePathLayer.bounds
                circleFrame.origin.x = circlePathBounds.midX - circleFrame.midX
                circleFrame.origin.y = circlePathBounds.midY - circleFrame.midY
                return circleFrame
            }
            
            func circlePath() -> UIBezierPath {
                return UIBezierPath(ovalIn: circleFrameTopCenter())
            }
            
            circlePathLayer.frame = animatedView.bounds
            circlePathLayer.path = circlePath().cgPath
            animatedView.layer.mask = circlePathLayer
            animatedView.alpha = 1
            
            let center = CGPoint(x: animatedView.bounds.midX, y: animatedView.bounds.midY)
            
            let finalRadius = sqrt((center.x*center.x) + (center.y*center.y))
            
            let radiusInset = finalRadius
            
            let outerRect = circleFrameTop().insetBy(dx: -radiusInset, dy: -radiusInset)
            
            let toPath = UIBezierPath(ovalIn: outerRect).cgPath
            
            let fromPath = circlePathLayer.path
            
            let maskLayerAnimation = CABasicAnimation(keyPath: "path")
            
            maskLayerAnimation.fromValue = fromPath
            maskLayerAnimation.toValue = toPath
            maskLayerAnimation.duration = duration
            maskLayerAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
            maskLayerAnimation.isRemovedOnCompletion = true
            _completionBlocks.append({ animatedView.layer.mask = nil })
            maskLayerAnimation.delegate = self
            maskLayerAnimation.setValue(_completionBlocks, forKey: "maskCompletionBlocks")
            circlePathLayer.add(maskLayerAnimation, forKey: "path")
            circlePathLayer.path = toPath
        }
        
        switch stage {
        case .Topic:
            
//            let banner = Popup(callbackDelegate: self, bannerDelegate: self, heightScaleFactor: deviceType == .iPhoneSE ? 0.8 : 0.6)
//            banner.present(subview: CostView(callbackDelegate: banner, dataProvider: self, parent: banner))
            
            animate(button: topicButton, completionBlocks: [
                { [weak self] in guard let self = self else { return }; self.topicButton.state = .On},
                { [weak self] in guard let self = self else { return }
                    fatalError()
//                    let banner = Popup(callbackDelegate: self, bannerDelegate: self, heightScaleFactor: deviceType == .iPhoneSE ? 0.8 : 0.6)
//                    banner.accessibilityIdentifier = "topic_tip"
//                    banner.present(content: TopicSelectionModernContainer(isModal: true, callbackDelegate: banner))
                }
            ])
        case .Options:
            animate(button: optionsButton, completionBlocks: [
                { [weak self] in guard let self = self else { return }; self.optionsButton.state = .On},
                { [weak self] in guard let self = self else { return };
                    fatalError()
//                    let banner = Popup(callbackDelegate: self, bannerDelegate: self, heightScaleFactor: deviceType == .iPhoneSE ? 0.8 : 0.6)
//                    banner.accessibilityIdentifier = "options_tip"
//                    banner.present(content: OptionSelection(isModal: true, option: .Ordinary, callbackDelegate: banner))
                }
            ])
            var startPoint = topicView.superview!.convert(topicView.center, to: scrollContentView)
            startPoint.y += (topicView.bounds.height + lineWidth)/2//delta
            var endPoint = optionsView.superview!.convert(optionsView.center, to: scrollContentView)
            endPoint.y -= (optionsStaticLabel.bounds.height + lineWidth)/2//delta
            animateLine(line: topicLine, lineCompletionBlocks: [], animationBlocks: [], completionBlocks: [])
        case .Title:
            let scrollPoint = pollTitleView.superview!.convert(pollTitleView.frame.origin, to: scrollContentView)
            scrollVerticalToPoint(y: scrollPoint.y - 30, completionBlocks: [
            ])
            
            animate(button: self.pollTitleButton, completionBlocks: [])
            reveal(view: self.pollTitleBg, duration: 0.3, completionBlocks: [])
            delayAsync(delay: 0.1) { [weak self] in
                guard let self = self else {return}
                self.pollTitleTextView.becomeFirstResponder()
                showTip(delegate: self, identifier: "title_tip")
            }
            var startPoint = optionsView.superview!.convert(optionsView.center, to: scrollContentView)
            startPoint.y += (optionsView.bounds.height + lineWidth)/2
            var endPoint = pollTitleView.superview!.convert(pollTitleView.center, to: scrollContentView)
            endPoint.y -= (pollTitleStaticLabel.bounds.height + lineWidth)/2
            animateLine(line: optionsLine, lineCompletionBlocks: [], animationBlocks: [], completionBlocks: [])
        case .Description:
            let scrollPoint = pollDescriptionView.superview!.convert(pollDescriptionView.frame.origin, to: scrollContentView)
            scrollVerticalToPoint(y: scrollPoint.y - 30, completionBlocks: [
//                {
//                    [weak self] in guard let self = self else { return }
//                    animate(button: self.pollDescriptionButton, completionBlocks: [
//
//                    ])
//                },
//                {
//                    [weak self] in guard let self = self else { return }
//                    reveal(view: self.pollDescriptionBg, duration: 0.3, completionBlocks: [])
//                },
//                {
//                    [weak self] in guard let self = self else { return }
//                    self.pollDescriptionTextView.becomeFirstResponder()
//                }
            ])
            
            animate(button: self.pollDescriptionButton, completionBlocks: [])
            reveal(view: self.pollDescriptionBg, duration: 0.3, completionBlocks: [])
            delayAsync(delay: 0.1) { [weak self] in
                guard let self = self else {return}
                self.pollDescriptionTextView.becomeFirstResponder()
                showTip(delegate: self, identifier: "description_tip")
            }
            
            var startPoint = pollTitleBg.superview!.convert(pollTitleBg.center, to: scrollContentView)
            startPoint.y += (pollTitleBg.bounds.height + lineWidth + 30)/2
            var endPoint = pollDescriptionView.superview!.convert(pollDescriptionView.center, to: scrollContentView)
            endPoint.y -= (pollDescriptionStaticLabel.bounds.height + lineWidth)/2
//            animateTransition(lineStart: startPoint, lineEnd: endPoint, lineCompletionBlocks: [], animationBlocks: [], completionBlocks: [])
            animateLine(line: pollTitleLine, lineCompletionBlocks: [], animationBlocks: [], completionBlocks: [])
        case .Question:
            let scrollPoint = pollQuestionView.superview!.convert(pollQuestionView.frame.origin, to: scrollContentView)
            scrollVerticalToPoint(y: scrollPoint.y - 30, completionBlocks: [
//                {
//                    [weak self] in guard let self = self else { return }
//                    animate(button: self.pollQuestionButton, completionBlocks: [
//
//                    ])
//                },
//                {
//                    [weak self] in guard let self = self else { return }
//                    reveal(view: self.pollQuestionBg, duration: 0.3, completionBlocks: [])
//                },
//                {
//                    [weak self] in guard let self = self else { return }
//                    self.pollQuestionTextView.becomeFirstResponder()
//                }
            ])
            
            
            animate(button: self.pollQuestionButton, completionBlocks: [])
            reveal(view: self.pollQuestionBg, duration: 0.3, completionBlocks: [])
            delayAsync(delay: 0.1) { [weak self] in
                guard let self = self else {return}
                self.pollQuestionTextView.becomeFirstResponder()
                showTip(delegate: self, identifier: "question_tip")
            }
            
            var startPoint = pollDescriptionBg.superview!.convert(pollDescriptionBg.center, to: scrollContentView)
            startPoint.y += (pollDescriptionBg.bounds.height + lineWidth + 30)/2
            var endPoint = pollQuestionView.superview!.convert(pollQuestionView.center, to: scrollContentView)
            endPoint.y -= (pollDescriptionStaticLabel.bounds.height + lineWidth)/2
//            animateTransition(lineStart: startPoint, lineEnd: endPoint, lineCompletionBlocks: [], animationBlocks: [], completionBlocks: [])
            animateLine(line: pollDescriptionLine, lineCompletionBlocks: [], animationBlocks: [], completionBlocks: [])
        case .Hyperlink:
            let scrollPoint = pollURLView.superview!.convert(pollURLView.frame.origin, to: scrollContentView)
            scrollVerticalToPoint(y: scrollPoint.y - 30, completionBlocks: [
//                {
//                    [weak self] in guard let self = self else { return }
//                    animate(button: self.pollURLButton, completionBlocks: [
////                        {
////                            [weak self] in guard let self = self else { return }
////                            reveal(view: self.pollURLBg, duration: 0.2, completionBlocks: [])
////                        }
//                    ])
//                },
//                {
//                    [weak self] in guard let self = self else { return }
//                    reveal(view: self.pollURLBg, duration: 0.3, completionBlocks: [])
//                },
//                {
//                    [weak self] in guard let self = self else { return }
//                    self.pollURLTextField.becomeFirstResponder()
//                }
            ])
            
            animate(button: self.pollURLButton, completionBlocks: [])
            reveal(view: self.pollURLBg, duration: 0.3, completionBlocks: [])
            delayAsync(delay: 0.1) { [weak self] in
                guard let self = self else {return}
                self.pollURLTextField.becomeFirstResponder()
                showTip(delegate: self, identifier: "url_tip")
            }
            
            var startPoint = pollQuestionBg.superview!.convert(pollQuestionBg.center, to: scrollContentView)
            startPoint.y += (pollQuestionBg.bounds.height + lineWidth + 30)/2
            var endPoint = pollURLView.superview!.convert(pollURLView.center, to: scrollContentView)
            endPoint.y -= (pollURLStaticLabel.bounds.height + lineWidth)/2
//            animateTransition(lineStart: startPoint, lineEnd: endPoint, lineCompletionBlocks: [], animationBlocks: [], completionBlocks: [])
            animateLine(line: pollQuestionLine, lineCompletionBlocks: [], animationBlocks: [], completionBlocks: [])
        case .Images:
            let scrollPoint = pollImagesView.superview!.convert(pollImagesView.frame.origin, to: scrollContentView)
            scrollVerticalToPoint(y: scrollPoint.y - 30, completionBlocks: [
//                {
//                    [weak self] in guard let self = self else { return }
//                    animate(button: self.pollImagesButton, completionBlocks: [])
//                },
//                {
//                    [weak self] in guard let self = self else { return }
//                    reveal(view: self.pollImagesBg, duration: 0.3, completionBlocks: [])
//                }
            ])
            
            animate(button: self.pollImagesButton, completionBlocks: [])
            reveal(view: self.pollImagesBg, duration: 0.3, completionBlocks: [
                {
                    [weak self] in guard let self = self else { return }
                    self.viewInput?.readPasteboard()
                }
            ])
            showTip(delegate: self, identifier: "images_tip")
            
            var startPoint = pollURLBg.superview!.convert(pollURLBg.center, to: scrollContentView)
            startPoint.y += (pollURLBg.bounds.height + lineWidth + 30)/2
            var endPoint = pollImagesView.superview!.convert(pollImagesView.center, to: scrollContentView)
            endPoint.y -= (pollImagesStaticLabel.bounds.height + lineWidth)/2
//            animateTransition(lineStart: startPoint, lineEnd: endPoint, lineCompletionBlocks: [], animationBlocks: [], completionBlocks: [])
            animateLine(line: pollURLLine, lineCompletionBlocks: [], animationBlocks: [], completionBlocks: [])
        case .Choices:
            let scrollPoint = pollChoicesView.superview!.convert(pollChoicesView.frame.origin, to: scrollContentView)
            scrollVerticalToPoint(y: scrollPoint.y - 30, completionBlocks: [
//                {
//                    [weak self] in guard let self = self else { return }
//                    animate(button: self.pollChoicesButton, completionBlocks: [])
//                },
//                {
//                    [weak self] in guard let self = self else { return }
//                    reveal(view: self.pollChoicesBg, duration: 0.3, completionBlocks: [
//                        {
//                            [weak self] in
//                            guard let self = self else { return }
//                            let banner = Popup(callbackDelegate: self, bannerDelegate: self, heightScaleFactor: deviceType == .iPhoneSE ? 0.8 : 0.5)
//
//                            banner.present(subview: ChoiceEditingPopup(callbackDelegate: banner, item: self.choiceItems.first, index: self.choiceItems.firstIndex(of: self.choiceItems.first!)! + 1, forceEditing: true, mode:  .Create))
//                        }
//                    ])
//                }
            ])
            
            animate(button: self.pollChoicesButton, completionBlocks: [])
            reveal(view: self.pollChoicesBg, duration: 0.3, completionBlocks: [
                {
                    [weak self] in
                    guard let self = self else { return }
                    
                    fatalError()
//                    let banner = Popup(callbackDelegate: self, bannerDelegate: self, heightScaleFactor: deviceType == .iPhoneSE ? 0.8 : 0.5)
//                    banner.accessibilityIdentifier = "choices_tip"
//                    delayAsync(delay: 0.25) {
//                        banner.present(content: ChoiceEditingPopup(callbackDelegate: banner, item: self.choiceItems.first, index: self.choiceItems.firstIndex(of: self.choiceItems.first!)! + 1, forceEditing: true, mode:  .Create))
//                    }
                }
            ])
            
            var startPoint = pollImagesBg.superview!.convert(pollImagesBg.center, to: scrollContentView)
            startPoint.y += (pollImagesBg.bounds.height + lineWidth + 30)/2
            var endPoint = pollChoicesView.superview!.convert(pollChoicesView.center, to: scrollContentView)
            endPoint.y -= (pollChoicesStaticLabel.bounds.height + lineWidth)/2
//            animateTransition(lineStart: startPoint, lineEnd: endPoint, lineCompletionBlocks: [], animationBlocks: [], completionBlocks: [])
            animateLine(line: pollImagesLine, lineCompletionBlocks: [], animationBlocks: [], completionBlocks: [])
        case .Comments:
            let scrollPoint = commentsView.superview!.convert(commentsView.frame.origin, to: scrollContentView)
            scrollVerticalToPoint(y: min(scrollPoint.y - 30, CGPoint(x: .zero, y: scrollView.contentSize.height - (bounds.height - safeAreaInsets.bottom - safeAreaInsets.top)).y), completionBlocks: [
//                {
//                    [weak self] in guard let self = self else { return }
//                    animate(button: self.commentsButton, completionBlocks: [
//                        { [weak self] in guard let self = self else { return }; self.commentsButton.state = .On},
//                        { [weak self] in guard let self = self else { return }; let banner = Popup(callbackDelegate: self, bannerDelegate: self, heightScaleFactor: deviceType == .iPhoneSE ? 0.8 : 0.6)
//                            banner.present(subview: CommentsSelection(option: self.comments, callbackDelegate: banner))}
//                    ])
//                },
            ])
            
            animate(button: self.commentsButton, completionBlocks: [
                { [weak self] in guard let self = self else { return }; self.commentsButton.state = .On},
                { [weak self] in guard let self = self else { return };
                    
                    
                    fatalError()
//                    let banner = Popup(callbackDelegate: self, bannerDelegate: self, heightScaleFactor: deviceType == .iPhoneSE ? 0.8 : 0.6)
//                    banner.present(content: CommentsSelection(option: self.comments, callbackDelegate: banner))
                }
            ])
            
            var startPoint = pollChoicesBg.superview!.convert(pollChoicesBg.center, to: scrollContentView)
            startPoint.y += (pollChoicesBg.bounds.height + lineWidth + 30)/2
            var endPoint = commentsView.superview!.convert(commentsView.center, to: scrollContentView)
            endPoint.y -= (commentsStaticLabel.bounds.height + lineWidth)/2//delta
//            animateTransition(lineStart: startPoint, lineEnd: endPoint, lineCompletionBlocks: [], animationBlocks: [], completionBlocks: [])
            animateLine(line: pollChoicesLine, lineCompletionBlocks: [], animationBlocks: [], completionBlocks: [])
        case .Limits:
            let scrollPoint = limitsView.superview!.convert(limitsView.frame.origin, to: scrollContentView)
            scrollVerticalToPoint(y: min(scrollPoint.y - 30, CGPoint(x: .zero, y: scrollView.contentSize.height - (bounds.height - safeAreaInsets.bottom - safeAreaInsets.top)).y), completionBlocks: [
//                {
//                    [weak self] in guard let self = self else { return }
//                    animate(button: self.limitsButton, completionBlocks: [
//                        { [weak self] in guard let self = self else { return }; self.limitsButton.state = .On},
//                        { [weak self] in guard let self = self else { return }; let banner = Popup(callbackDelegate: self, bannerDelegate: self, heightScaleFactor: deviceType == .iPhoneSE ? 0.8 : 0.6)
//                            banner.present(subview: LimitsSelectionView(value: self.limits, callbackDelegate: banner))}
//                    ])
//                },
            ])
            
            animate(button: self.limitsButton, completionBlocks: [
                { [weak self] in guard let self = self else { return }; self.limitsButton.state = .On},
                { [weak self] in guard let self = self else { return };
                    
                    fatalError()
//                    let banner = Popup(callbackDelegate: self, bannerDelegate: self, heightScaleFactor: deviceType == .iPhoneSE ? 0.8 : 0.6)
//                    banner.accessibilityIdentifier = "limits_tip"
//                    banner.present(content: LimitsSelectionView(value: self.limits, callbackDelegate: banner))
                }
            ])
            
            var startPoint = commentsView.superview!.convert(commentsView.center, to: scrollContentView)
            startPoint.y += (commentsView.bounds.height + lineWidth)/2
            var endPoint = limitsView.superview!.convert(limitsView.center, to: scrollContentView)
            endPoint.y -= (limitsStaticLabel.bounds.height + lineWidth)/2//delta
//            animateTransition(lineStart: startPoint, lineEnd: endPoint, lineCompletionBlocks: [], animationBlocks: [], completionBlocks: [])
            animateLine(line: commentsLine, lineCompletionBlocks: [], animationBlocks: [], completionBlocks: [])
        case .Hot:
            let scrollPoint = hotOptionView.superview!.convert(hotOptionView.frame.origin, to: scrollContentView)
            scrollVerticalToPoint(y: min(scrollPoint.y - 30, CGPoint(x: .zero, y: scrollView.contentSize.height - (bounds.height - safeAreaInsets.bottom - safeAreaInsets.top)).y), completionBlocks: [
//                {
//                    [weak self] in guard let self = self else { return }
//                    animate(button: self.hotOptionButton, completionBlocks: [
//                        { [weak self] in guard let self = self else { return }; self.hotOptionButton.state = .On},
//                        { [weak self] in guard let self = self else { return }; let banner = Popup(callbackDelegate: self, bannerDelegate: self, heightScaleFactor: deviceType == .iPhoneSE ? 0.8 : 0.6)
//                            banner.present(subview: HotSelectionView(option: self.hot, callbackDelegate: banner))}
//                    ])
//                },
            ])
            
            animate(button: self.hotOptionButton, completionBlocks: [
                {
                    [weak self] in guard let self = self else { return }
                    self.hotOptionButton.state = .On
                },
                {
                    [weak self] in guard let self = self else { return }
                    guard self.option == .Private else {
                        
                        fatalError()
//                        let banner = Popup(callbackDelegate: self, bannerDelegate: self, heightScaleFactor: deviceType == .iPhoneSE ? 0.8 : 0.6)
//                        banner.accessibilityIdentifier = "hot_tip"
//                        banner.present(content: HotSelectionView(option: self.hot, callbackDelegate: banner))
                        return
                    }
                    self.hot = .Off
//                    self.hotOptionButton.isUserInteractionEnabled = false
                    self.hotOptionButton.color = .systemGray
                    self.hotOptionButton.icon.backgroundColor = .systemGray
                    self.viewInput?.onStageCompleted()
                }
            ])
            
            var startPoint = limitsView.superview!.convert(limitsView.center, to: scrollContentView)
            startPoint.y += (limitsView.bounds.height + lineWidth)/2
            var endPoint = hotOptionView.superview!.convert(hotOptionView.center, to: scrollContentView)
            endPoint.y -= (hotOptionStaticLabel.bounds.height + lineWidth)/2//delta
//            animateTransition(lineStart: startPoint, lineEnd: endPoint, lineCompletionBlocks: [], animationBlocks: [], completionBlocks: [])
            animateLine(line: limitsLine, lineCompletionBlocks: [], animationBlocks: [], completionBlocks: [])
        case .Ready:
            publicationButton.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            let scrollPoint = publicationButton.superview!.convert(publicationButton.frame.origin, to: scrollContentView)
            scrollVerticalToPoint(y: min(scrollPoint.y - 30, CGPoint(x: .zero, y: scrollView.contentSize.height - (bounds.height - safeAreaInsets.bottom - safeAreaInsets.top)).y), completionBlocks: [
                {
                    UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut) {
                        self.publicationButton.transform = .identity
                        self.publicationButton.alpha = 1
                    } completion: { _ in
                        self.scrollView.isScrollEnabled = true
                        self.scrollView.get(all: CircleButton.self).filter({ $0.accessibilityIdentifier == "button" }).forEach { $0.isUserInteractionEnabled = true }
                    }
//#if !DEBUG
                    UserDefaults.App.hasSeenAppIntroduction = true
//#endif
                }]
            )
        }
    }
}





// MARK: - UI Setup
extension PollCreationView {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
//        pollTitleTextView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
        scrollContentView.get(all: [UITextView.self]).forEach {
            guard let v =  $0 as? UITextView else { return }
            v.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
        }
        scrollContentView.get(all: [UIImageView.self]).filter({
            $0.accessibilityIdentifier == "skip"
        }).forEach {
            $0.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
        }
        scrollContentView.get(all: [UITextView.self]).forEach {
            guard let v = $0 as? UITextView else { return }
            v.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
        }
        scrollContentView.get(all: [CircleButton.self]).forEach {
            guard let v =  $0 as? CircleButton else { return }
            v.color = self.traitCollection.userInterfaceStyle == .dark ? .systemBlue : self.color
            v.icon.backgroundColor = self.traitCollection.userInterfaceStyle == .dark ? .systemBlue : self.color
        }
        pollURLSkip.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
        pollImagesSkip.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
        pollURLTextField.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
        scrollContentView.get(all: [UIView.self]).filter({ $0.accessibilityIdentifier == "front" }).forEach { [weak self] v in
            guard let self = self else { return }
            v.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .systemBackground
        }
        scrollContentView.get(all: [UIView.self]).filter({ $0.accessibilityIdentifier == "shadow" }).forEach { [weak self] v in
            guard let self = self else { return }
            v.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
        }
        scrollContentView.get(all: [UIView.self]).filter({ $0.accessibilityIdentifier == "line" }).forEach { [weak self] v in
            guard let self = self else { return }
            v.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
        }

        publicationButton.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
        pollImagesHeaderButton.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
        pollChoicesHeaderButton.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
    }
    
    private func setupUI() {
        setNeedsLayout()
        layoutIfNeeded()
        setText()
        setupInputViews()
        
        color = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
        
        scrollContentView.subviews.forEach {
            $0.alpha = 0
            if let circle = $0 as? CircleButton { circle.state = .Off }
        }
        
        lineWidth = topicButton.lineWidth
        pollTitleTextView.font = StringAttributes.font(name: StringAttributes.Fonts.Style.Bold,
                                                       size: pollTitleTextView.frame.width * 0.1)
        pollDescriptionTextView.font = StringAttributes.font(name: StringAttributes.Fonts.Style.Regular,
                                                             size: pollDescriptionTextView.frame.width * 0.05)
        pollQuestionTextView.font = StringAttributes.font(name: StringAttributes.Fonts.Style.Semibold,
                                                       size: pollQuestionTextView.frame.width * 0.05)
        pollURLTextField.font = StringAttributes.font(name: StringAttributes.Fonts.Style.Regular,
                                                       size: pollURLTextField.frame.height * 0.35)
        pollURLTextField.cornerRadius = pollURLTextField.frame.height / 2
        
        ///Disable till all stages are completed
        scrollView.isScrollEnabled = false
        scrollView.get(all: CircleButton.self).filter({ $0.accessibilityIdentifier == "button" }).forEach { $0.isUserInteractionEnabled = false }
        if #available(iOS 14, *) {
            imagesContainer = ImageSelectionCollectionView(dataProvider: self, callbackDelegate: self, color: color)
            imagesContainer!.addEquallyTo(to: pollImagesContainerView)
            choiceContainer = AddChoiceCollectionView(dataProvider: self, callbackDelegate: self, color: color)
            choiceContainer!.addEquallyTo(to: pollChoicesContainerView)
            pollChoicesContainerView.addSubview(choiceContainer!)
//            pollChoicesContainerView.translatesAutoresizingMaskIntoConstraints = false
//            NSLayoutConstraint.activate([
//                choiceContainer.topAnchor.constraint(equalTo: pollChoicesContainerView.topAnchor),
//                choiceContainer.leadingAnchor.constraint(equalTo: pollChoicesContainerView.leadingAnchor),
//                choiceContainer.trailingAnchor.constraint(equalTo: pollChoicesContainerView.trailingAnchor),
////                choiceContainer.bottomAnchor.constraint(equalTo: pollChoicesContainerView.bottomAnchor),
////                choiceContainer.widthAnchor.constraint(equalTo: pollChoicesContainerView.widthAnchor),
////                choiceContainer.bottomAnchor.constraint(equalTo: pollChoicesContainerView.bottomAnchor),
//
//            ])
//            choiceContainer.bottomAnchor.constraint(equalTo: pollChoicesTemp.topAnchor).isActive = true
//
//            // We need constraints that define the height of the cell when closed and when open
//            // to allow for animating between the two states.
//            let closedConstraint =
//            choiceContainer.bottomAnchor.constraint(equalTo: pollChoicesContainerView.bottomAnchor)
//            closedConstraint.priority = .defaultLow
//            closedConstraint.isActive = true
        } else {
            // Fallback on earlier versions
        }
    }
    
    private func setObservers() {
        observers.append(pollTitleTextView.observe(\UITextView.contentSize, options: [NSKeyValueObservingOptions.new]) { [weak self] (view: UIView, change: NSKeyValueObservedChange<CGSize>) in
            guard let self = self,
                  let constraint = self.pollTitleBg.getAllConstraints().filter({ $0.identifier == "height" }).first,
                  let supplementaryConstraint = self.pollTitleTemp.getAllConstraints().filter({ $0.identifier == "supp_height" }).first,
                  let value = change.newValue else { return }
            UIView.animate(withDuration: 0.2) {
                self.pollTitleTextView.cornerRadius = self.pollTitleTextView.frame.width * 0.05
                self.scrollContentView.setNeedsLayout()
                constraint.constant = value.height + supplementaryConstraint.constant + 20//(supplementaryConstraint.constant == 0 ? 20 : 10)
                self.scrollContentView.layoutIfNeeded()
            }
            
            let destinationPath = UIBezierPath(roundedRect: CGRect(origin: .zero,
                                                                   size: CGSize(width: self.pollTitleBg.bounds.width,
                                                                                height: value.height + supplementaryConstraint.constant + 20)),
                                               cornerRadius: self.pollTitleBg.frame.width * 0.05).cgPath
            let anim = Animations.get(property: .ShadowPath,
                                      fromValue: self.pollTitleBg.layer.shadowPath as Any,
                                      toValue: destinationPath,
                                      duration: 0.2,
                                      delay: 0,
                                      repeatCount: 0,
                                      autoreverses: false,
                                      timingFunction: .linear,
                                      delegate: nil,
                                      isRemovedOnCompletion: true,
                                      completionBlocks: nil)
            self.pollTitleBg.layer.add(anim, forKey: nil)
            self.pollTitleBg.layer.shadowPath = destinationPath
        })
        observers.append(pollDescriptionTextView.observe(\UITextView.contentSize, options: [NSKeyValueObservingOptions.new]) { [weak self] (view: UIView, change: NSKeyValueObservedChange<CGSize>) in
            guard let self = self,
                  let constraint = self.pollDescriptionBg.getAllConstraints().filter({ $0.identifier == "height" }).first,
                  let supplementaryConstraint = self.pollDescriptionTemp.getAllConstraints().filter({ $0.identifier == "supp_height" }).first,
                  let value = change.newValue else { return }
            UIView.animate(withDuration: 0.2) {
                self.pollDescriptionTextView.cornerRadius = self.pollDescriptionTextView.frame.width * 0.05
                self.scrollContentView.setNeedsLayout()
                constraint.constant = value.height + supplementaryConstraint.constant + 20//(supplementaryConstraint.constant == 0 ? 20 : 10)
                self.scrollContentView.layoutIfNeeded()
            }
            
            let destinationPath = UIBezierPath(roundedRect: CGRect(origin: .zero,
                                                                   size: CGSize(width: self.pollDescriptionBg.bounds.width,
                                                                                height: value.height + supplementaryConstraint.constant + 20)),
                                               cornerRadius: self.pollDescriptionBg.frame.width * 0.05).cgPath
            let anim = Animations.get(property: .ShadowPath,
                                      fromValue: self.pollDescriptionBg.layer.shadowPath as Any,
                                      toValue: destinationPath,
                                      duration: 0.2,
                                      delay: 0,
                                      repeatCount: 0,
                                      autoreverses: false,
                                      timingFunction: .linear,
                                      delegate: nil,
                                      isRemovedOnCompletion: true,
                                      completionBlocks: nil)
            self.pollDescriptionBg.layer.add(anim, forKey: nil)
            self.pollDescriptionBg.layer.shadowPath = destinationPath
        })
        observers.append(pollQuestionTextView.observe(\UITextView.contentSize, options: [NSKeyValueObservingOptions.new]) { [weak self] (view: UIView, change: NSKeyValueObservedChange<CGSize>) in
            guard let self = self,
                  let constraint = self.pollQuestionBg.getAllConstraints().filter({ $0.identifier == "height" }).first,
                  let supplementaryConstraint = self.pollQuestionTemp.getAllConstraints().filter({ $0.identifier == "supp_height" }).first,
                  let value = change.newValue else { return }
            self.pollQuestionTextView.cornerRadius = self.pollQuestionTextView.frame.width * 0.05
            UIView.animate(withDuration: 0.2) {
                self.scrollContentView.setNeedsLayout()
                constraint.constant = value.height + supplementaryConstraint.constant + 20//(supplementaryConstraint.constant == 0 ? 20 : 10)
                self.scrollContentView.layoutIfNeeded()
            }
            
            let destinationPath = UIBezierPath(roundedRect: CGRect(origin: .zero,
                                                                   size: CGSize(width: self.pollQuestionBg.bounds.width,
                                                                                height: value.height + supplementaryConstraint.constant + 20)),
                                               cornerRadius: self.pollQuestionBg.frame.width * 0.05).cgPath
            let anim = Animations.get(property: .ShadowPath,
                                      fromValue: self.pollQuestionBg.layer.shadowPath as Any,
                                      toValue: destinationPath,
                                      duration: 0.2,
                                      delay: 0,
                                      repeatCount: 0,
                                      autoreverses: false,
                                      timingFunction: .linear,
                                      delegate: nil,
                                      isRemovedOnCompletion: true,
                                      completionBlocks: nil)
            self.pollQuestionBg.layer.add(anim, forKey: nil)
            self.pollQuestionBg.layer.shadowPath = destinationPath
        })
        observers.append(pollURLBg.observe(\UIView.bounds, options: [NSKeyValueObservingOptions.new]) { (view: UIView, change: NSKeyValueObservedChange<CGRect>) in
            self.pollURLBg.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.6).cgColor
            self.pollURLBg.layer.shadowPath = UIBezierPath(roundedRect: self.pollURLBg.bounds,
                                                             cornerRadius: self.pollURLBg.frame.width * 0.05).cgPath
            self.pollURLBg.layer.shadowRadius = 7
            self.pollURLBg.layer.shadowOffset = .zero
        })
        observers.append(pollURLTextField.observe(\InsetTextField.bounds, options: [NSKeyValueObservingOptions.new]) { (view: UIView, change: NSKeyValueObservedChange<CGRect>) in
            self.pollURLTextField.cornerRadius = self.pollURLTextField.frame.height / 2
        })
        observers.append(pollImagesHeaderLabel.observe(\UILabel.bounds, options: [NSKeyValueObservingOptions.new]) { [weak self] (view: UIView, change: NSKeyValueObservedChange<CGRect>) in
            guard let self = self,
            let rect = change.newValue else { return }
            self.pollImagesHeaderLabel.font = StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: rect.height * 0.4)
        })
        observers.append(pollChoicesHeaderLabel.observe(\UILabel.bounds, options: [NSKeyValueObservingOptions.new]) { [weak self] (view: UIView, change: NSKeyValueObservedChange<CGRect>) in
            guard let self = self,
            let rect = change.newValue else { return }
            self.pollChoicesHeaderLabel.font = StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: rect.height * 0.4)
        })
        observers.append(publicationButton.observe(\UIButton.bounds, options: [NSKeyValueObservingOptions.new]) { [weak self] (view, change) in
            guard let self = self else { return }
            self.publicationButton.cornerRadius = self.publicationButton.frame.height / 2.25
//            print(self.publicationButton.frame.origin)
//            self.scrollView.contentSize.height = self.publicationButton.frame.origin.y + self.publicationButton.frame.height * 2
        })
        observers.append(publicationButton.observe(\UIButton.center, options: [NSKeyValueObservingOptions.new]) { [weak self] (view, change) in
            guard let self = self else { return }
            print(self.publicationButton.frame.origin)
            self.scrollView.contentSize.height = self.publicationButton.frame.origin.y + self.publicationButton.frame.height * 2.5
        })

        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidHide), name: UIResponder.keyboardDidHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
        
    }
    
    private func scrollVerticalToPoint(y: CGFloat, duration: TimeInterval = 0.4, delay: TimeInterval = 0, completionBlocks: [Closure]) {
        UIView.animate(withDuration: duration, delay: delay, options: [.curveEaseInOut], animations: {
            self.scrollView.contentOffset.y = y
//            self.lastContentOffsetY = y
        }) {
            _ in
            completionBlocks.forEach({ $0() })
        }
    }
    
    private func setupInputViews() {
        pollTitleFg.layer.masksToBounds = true
        pollTitleFg.layer.cornerRadius = pollTitleFg.frame.width * 0.05
        pollTitleBg.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
        
        pollDescriptionFg.layer.masksToBounds = true
        pollDescriptionFg.layer.cornerRadius = pollDescriptionFg.frame.width * 0.05
        pollDescriptionBg.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
        
        pollQuestionFg.layer.masksToBounds = true
        pollQuestionFg.layer.cornerRadius = pollQuestionFg.frame.width * 0.05
        pollQuestionBg.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
        
        pollURLContainerView.layer.masksToBounds = true
        pollURLContainerView.layer.cornerRadius = pollURLContainerView.frame.width * 0.05
        pollURLBg.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
        
        pollImagesFg.layer.masksToBounds = true
        pollImagesFg.layer.cornerRadius = pollImagesFg.frame.width * 0.05
        pollImagesBg.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
        
        pollChoicesFg.layer.masksToBounds = true
        pollChoicesFg.layer.cornerRadius = pollChoicesFg.frame.width * 0.05
        pollChoicesBg.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
        
    }
    
    @objc
    private func setText() {
        if fontSize == .zero { fontSize = topicStaticLabel.bounds.width * 0.09 }
        
        ///Topic
        let topicStaticString = NSMutableAttributedString()
        topicStaticString.append(NSAttributedString(string: "topic".localized.uppercased(), attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: fontSize), foregroundColor: .label/*color*/, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        topicStaticLabel.attributedText = topicStaticString
        
        let topicString = NSMutableAttributedString()
        topicString.append(NSAttributedString(string: topic.isNil ? "" : topic.title.uppercased(), attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: fontSize), foregroundColor: .label/*color*/, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        topicLabel.attributedText = topicString
        
        ///Options
        let optionsStaticString = NSMutableAttributedString()
        optionsStaticString.append(NSAttributedString(string: "accessibility".localized.uppercased(), attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: fontSize), foregroundColor: .label, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        optionsStaticLabel.attributedText = optionsStaticString
        
        let optionsString = NSMutableAttributedString()
        optionsString.append(NSAttributedString(string: option.rawValue.localized.uppercased(), attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: fontSize), foregroundColor: .label, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        optionsLabel.attributedText = optionsString
        
        ///Poll title
        let pollTitleStaticString = NSMutableAttributedString()
        pollTitleStaticString.append(NSAttributedString(string: "poll_title".localized.uppercased(), attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: fontSize), foregroundColor: .label, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        pollTitleStaticLabel.attributedText = pollTitleStaticString
        
        ///Poll description
        let pollDescriptionStaticString = NSMutableAttributedString()
        pollDescriptionStaticString.append(NSAttributedString(string: "poll_description".localized.uppercased(), attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: fontSize), foregroundColor: .label, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        pollDescriptionStaticLabel.attributedText = pollDescriptionStaticString
        
        let optionalString = NSMutableAttributedString()
        optionalString.append(NSAttributedString(string: "*" + "optional".localized.lowercased(), attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Regular, size: pollDescriptionTextView.frame.width * 0.035), foregroundColor: .secondaryLabel, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
//        pollDescriptionOptionalLabel.attributedText = optionalString
        pollURLOptionalLabel.attributedText = optionalString
        pollImagesOptionalLabel.attributedText = optionalString
        
        ///Poll Question
        let pollQuestionStaticString = NSMutableAttributedString()
        pollQuestionStaticString.append(NSAttributedString(string: "poll_question".localized.uppercased(), attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: fontSize), foregroundColor: .label, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        pollQuestionStaticLabel.attributedText = pollQuestionStaticString
        
        
        ///Poll URL
        let pollURLStaticString = NSMutableAttributedString()
        pollURLStaticString.append(NSAttributedString(string: "url".localized.uppercased(), attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: fontSize), foregroundColor: .label, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        pollURLStaticLabel.attributedText = pollURLStaticString
        
        ///Poll images
        let pollImagesStaticString = NSMutableAttributedString()
        pollImagesStaticString.append(NSAttributedString(string: "images".localized.uppercased(), attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: fontSize), foregroundColor: .label, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        pollImagesStaticLabel.attributedText = pollImagesStaticString
        
        ///Poll choices
        let pollChoicesStaticString = NSMutableAttributedString()
        pollChoicesStaticString.append(NSAttributedString(string: "poll_choices".localized.uppercased(), attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: fontSize), foregroundColor: .label, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        pollChoicesStaticLabel.attributedText = pollChoicesStaticString
        
        ///Commenta
        let commentsStaticString = NSMutableAttributedString()
        commentsStaticString.append(NSAttributedString(string: "comments".localized.uppercased(), attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: fontSize), foregroundColor: .label, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        commentsStaticLabel.attributedText = commentsStaticString
        
        let commentsString = NSMutableAttributedString()
        commentsString.append(NSAttributedString(string:  comments == .On ? "are_on".localized.uppercased() : "are_off".localized.uppercased(), attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: fontSize), foregroundColor: .label, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        commentsLabel.attributedText = commentsString
        
        ///Limits
        let limitsStaticString = NSMutableAttributedString()
        limitsStaticString.append(NSAttributedString(string: "voters_limit".localized.uppercased(), attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: fontSize), foregroundColor: .label, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        limitsStaticLabel.attributedText = limitsStaticString
        
        let limitsString = NSMutableAttributedString()
        limitsString.append(NSAttributedString(string: String(describing: limits), attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: fontSize), foregroundColor: .label, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        limitsLabel.attributedText = limitsString
        
        ///Hot start
        let hotOptionStaticString = NSMutableAttributedString()
        hotOptionStaticString.append(NSAttributedString(string: "hot_option".localized.uppercased(), attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: fontSize), foregroundColor: .label, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        hotOptionStaticLabel.attributedText = hotOptionStaticString
        
        let hotOptionString = NSMutableAttributedString()
        hotOptionString.append(NSAttributedString(string: "", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: fontSize), foregroundColor: .label, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        hotOptionLabel.attributedText = hotOptionString
        
        let urlPlaceholder = NSMutableAttributedString()
        urlPlaceholder.append(NSAttributedString(string: "url_placeholder".localized, attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Regular, size: pollURLTextField.frame.height * 0.35), foregroundColor: .secondaryLabel, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        pollURLTextField.attributedPlaceholder = urlPlaceholder
    }
    
    @objc
    private func handleTap(_ recognizer: UITapGestureRecognizer) {
        guard let v = recognizer.view else { return }
        if v == pollURLSkip {
            guard viewInput?.stage == .Hyperlink else {
                showTip(delegate: self, identifier: "url_tip", force: true)
                return
            }
            pollURLTextField.resignFirstResponder()
            guard !pollURLTextField.isFirstResponder else { return }
            UIView.transition(with: pollURLSkip, duration: 0.2, options: .transitionCrossDissolve, animations: {
                self.pollURLSkip.image = UIImage(systemName: "info")
            }, completion: {_ in self.viewInput?.onStageCompleted()})
        } else if v == pollImagesSkip {
            guard viewInput?.stage == .Images else {
                showTip(delegate: self, identifier: "images_tip", force: true)
                return
            }
            UIView.transition(with: pollImagesSkip, duration: 0.2, options: .transitionCrossDissolve, animations: {
                self.pollImagesSkip.image = UIImage(systemName: "info")
            }, completion: {_ in
                self.viewInput?.onStageCompleted()
            })
        } else if v == pollChoicesHeaderButton {
            let item = ChoiceItem(text: "")
            choiceItems.append(item)
            
            fatalError()
//            let banner = Popup(callbackDelegate: self, bannerDelegate: self, heightScaleFactor: deviceType == .iPhoneSE ? 0.8 : 0.5)
//
//            banner.present(content: ChoiceEditingPopup(callbackDelegate: banner, item: item, index: self.choiceItems.firstIndex(of: self.choiceItems.last!)! + 1 , forceEditing: true, mode: .Create))
        } else if v == pollImagesHeaderButton {
            guard imageItems.count < 3 else {
                showBanner(bannerDelegate: self,
                           text: AppError.maximumImages.localizedDescription,
                           content: ImageSigns.exclamationMark,
                           dismissAfter: 1)
                return
            }
//            let item = ImageItem(title: "")
//            imageItems.append(item)
//            imagesContainer?.reload()
//            let banner = Popup(callbackDelegate: self, bannerDelegate: self, heightScaleFactor: deviceType == .iPhoneSE ? 0.8 : 0.65)
//            banner.present(subview: ImageSelectionPopup(controller: viewInput as? UIViewController, callbackDelegate: banner, item: item, index: self.choiceItems.firstIndex(of: self.choiceItems.last!)! + 1))
            onAddImageTap()
        } else if v == pollChoicesSkip {
            ///Check
            guard choiceItems.count >= 2 else {
                showBanner(bannerDelegate: self,
                           text: AppError.minimumChoices.localizedDescription,
                           content: ImageSigns.exclamationMark,
                           dismissAfter: 1)
                return
            }
            UIView.transition(with: pollChoicesSkip, duration: 0.2, options: .transitionCrossDissolve, animations: {
                self.pollChoicesSkip.image = UIImage(systemName: "checkmark")
            }, completion: {_ in
                self.viewInput?.onStageCompleted()
            })
        } else if v == pollTitleSkip {
            pollTitleTextView.resignFirstResponder()
        } else if v == pollDescriptionSkip {
            pollDescriptionTextView.resignFirstResponder()
            guard viewInput?.stage != .Description else { return }
            showTip(delegate: self, identifier: "description_tip", force: true)
        } else if v == pollQuestionSkip {
            pollQuestionTextView.resignFirstResponder()
        } else if v == topicButton {
            let scrollPoint = pollTitleView.superview!.convert(topicView.frame.origin, to: scrollContentView)
            scrollVerticalToPoint(y: scrollPoint.y, completionBlocks: [])
            
            fatalError()
//            let banner = Popup(callbackDelegate: self, bannerDelegate: self, heightScaleFactor: deviceType == .iPhoneSE ? 0.8 : 0.6)
//            banner.present(content: TopicSelectionModernContainer(isModal: true, callbackDelegate: banner))
        } else if v == optionsButton {
            let scrollPoint = pollTitleView.superview!.convert(optionsView.frame.origin, to: scrollContentView)
            scrollVerticalToPoint(y: scrollPoint.y, completionBlocks: [])
            
            fatalError()
//            let banner = Popup(callbackDelegate: self, bannerDelegate: self, heightScaleFactor: deviceType == .iPhoneSE ? 0.8 : 0.6)
//            banner.present(content: OptionSelection(isModal: true, option: option, callbackDelegate: banner))
        } else if v == commentsButton {
            let scrollPoint = commentsView.superview!.convert(commentsView.frame.origin, to: scrollContentView)
            scrollVerticalToPoint(y: min(scrollPoint.y - 30, CGPoint(x: .zero, y: scrollView.contentSize.height - (bounds.height - safeAreaInsets.bottom - safeAreaInsets.top)).y), completionBlocks: [])
            
            fatalError()
//            let banner = Popup(callbackDelegate: self, bannerDelegate: self, heightScaleFactor: deviceType == .iPhoneSE ? 0.8 : 0.6)
//            banner.present(content: CommentsSelection(option: self.comments, callbackDelegate: banner))
        } else if v == limitsButton {
            let scrollPoint = limitsView.superview!.convert(limitsView.frame.origin, to: scrollContentView)
            scrollVerticalToPoint(y: min(scrollPoint.y - 30, CGPoint(x: .zero, y: scrollView.contentSize.height - (bounds.height - safeAreaInsets.bottom - safeAreaInsets.top)).y), completionBlocks: [])
            
            fatalError()
//            let banner = Popup(callbackDelegate: self, bannerDelegate: self, heightScaleFactor: deviceType == .iPhoneSE ? 0.8 : 0.6)
//            banner.present(content: LimitsSelectionView(value: self.limits, callbackDelegate: banner))
        } else if v == hotOptionButton {
            let scrollPoint = hotOptionView.superview!.convert(hotOptionView.frame.origin, to: scrollContentView)
            scrollVerticalToPoint(y: min(scrollPoint.y - 30, CGPoint(x: .zero, y: scrollView.contentSize.height - (bounds.height - safeAreaInsets.bottom - safeAreaInsets.top)).y), completionBlocks: [])
            guard option == .Private else {
                
                fatalError()
//                let banner = Popup(callbackDelegate: self, bannerDelegate: self, heightScaleFactor: deviceType == .iPhoneSE ? 0.8 : 0.6)
//                banner.present(content: HotSelectionView(option: self.hot, callbackDelegate: banner))
                return
            }
            showBanner(bannerDelegate: self,
                       text: "hot_restricted".localized,
                       content: ImageSigns.exclamationMark,
                       dismissAfter: 2)
        } else if v == pollTitleButton {
            pollTitleTextView.becomeFirstResponder()
        } else if v == pollDescriptionButton {
            pollDescriptionTextView.becomeFirstResponder()
        } else if v == pollQuestionButton {
            pollQuestionTextView.becomeFirstResponder()
        } else if v == pollURLButton {
            pollURLTextField.becomeFirstResponder()
        }
    }
    
    func onChoicesHeightChange(_ height: CGFloat) {
        guard let constraint = self.pollChoicesContainerView.getAllConstraints().filter({ $0.identifier == "height" }).first else { return }
        UIView.animate(withDuration: 0.2) {
            self.scrollContentView.setNeedsLayout()
            constraint.constant = height
            self.scrollContentView.layoutIfNeeded()
        }
    }
    
    func onImagesHeightChange(_ height: CGFloat) {
        guard let constraint = self.pollImagesContainerView.getAllConstraints().filter({ $0.identifier == "height" }).first else { return }
        UIView.animate(withDuration: 0.2) {
            self.scrollContentView.setNeedsLayout()
            constraint.constant = self.imageItems.isEmpty ? 1 : height == 0 ? 1 : height
            self.scrollContentView.layoutIfNeeded()
        }
    }
    
    @objc
    private func keyboardDidHide() {
        if let recognizer = gestureRecognizers?.filter({ $0.accessibilityValue == "hideKeyboard" }).first {
            gestureRecognizers?.remove(object: recognizer)
        }
    }
    
    @objc
    private func keyboardDidShow() {
//        guard !pollURLTextField.isFirstResponder else { return }
        guard gestureRecognizers.isNil || gestureRecognizers!.filter({ $0.accessibilityValue == "hideKeyboard" }).isEmpty else { return }
        let touch = UITapGestureRecognizer(target:self, action: #selector(self.hideKeyboard))
        touch.accessibilityValue = "hideKeyboard"
        self.addGestureRecognizer(touch)
    }
    
    @objc
    private func hideKeyboard() {
        endEditing(true)
    }
}





// MARK: - BannerObservable
extension PollCreationView: BannerObservable {
    func onBannerWillAppear(_ sender: Any) {}
    
    func onBannerWillDisappear(_ sender: Any) {}
    
    func onBannerDidAppear(_ sender: Any) {
        guard let v = sender as? UIView,
        let identifier = v.accessibilityIdentifier else { return }
        if identifier == "insufficient_balance" {
            showBanner(bannerDelegate: self,
                       text: AppError.insufficientBalance.localizedDescription + ".\n" + "change_parameters".localized,
                       content: ImageSigns.exclamationMark,
                       dismissAfter: 3)
        } else {
            showTip(delegate: self, identifier: identifier)
        }
    }
    
    func onBannerDidDisappear(_ sender: Any) {
        if let banner = sender as? Banner {
            if banner.accessibilityIdentifier == "isTextFieldEditingEnabled" {
                isTextFieldEditingEnabled = true
            }
            banner.removeFromSuperview()
        } else if let popup = sender as? Popup {
            popup.removeFromSuperview()
            if popup.accessibilityIdentifier == "pop" {
                viewInput?.onContinue()
            }
        }
    }
}





// MARK: - CallbackObservable
extension PollCreationView: CallbackObservable {
    func callbackReceived(_ sender: Any) {
        if let _topic = sender as? Topic {
            topic = _topic
        } else if let _option = sender as? PollCreationController.Option {
            option = _option
        } else if let imageItem = sender as? ImageItem {
            if let _existing = imageItems.filter({ $0.id == imageItem.id }).first {
                var existing = _existing
                guard imageItem.shouldBeDeleted else {
                    guard let index = imageItems.firstIndex(where: {$0.id == imageItem.id}) else { return }
                    imageItems[index].image = imageItem.image
                    imageItems[index].title = imageItem.title
                    imagesContainer?.reload()
                    return
                }
                guard let index = imageItems.firstIndex(where: {$0.id == imageItem.id}) else { return }
                imageItems.remove(at: index)
                imagesContainer?.reload()
            } else {
                imageItems.append(imageItem)
                imagesContainer?.reload()
            }
        } else if let choiceItem = sender as? ChoiceItem {
            if let _ = choiceItems.filter({ $0.id == choiceItem.id }).first {
//                var existing = _existing
                guard choiceItem.shouldBeDeleted else {
                    guard let index = choiceItems.firstIndex(where: {$0.id == choiceItem.id}) else { return }
                    choiceItems[index].text = choiceItem.text
                    choiceItems[index].index = choiceItem.index
                    choiceContainer?.reload()
                    return
                }
                guard let index = imageItems.firstIndex(where: {$0.id == choiceItem.id}) else { return }
                choiceItems.remove(at: index)
                choiceContainer?.delete(choiceItem)
            } else {
                choiceItems.append(choiceItem)
//                choiceItem.index = choiceItems.count
                choiceContainer?.reload()
            }
        } else if let _comments = sender as? PollCreationController.Comments {
            comments = _comments
        } else if let value = sender as? Int {
            self.limits = value
        } else if let _hot = sender as? PollCreationController.Hot {
            hot = _hot
        } else if let url = sender as? URL {
            guard !pollURLTextField.isNil else { return }
            pollURLTextField.text = url.absoluteString
            let scrollPoint = pollURLView.superview!.convert(pollURLView.frame.origin, to: scrollContentView)
            scrollVerticalToPoint(y: scrollPoint.y - 30, completionBlocks: [])
        } else if let image = sender as? UIImage {
            let scrollPoint = pollImagesView.superview!.convert(pollImagesView.frame.origin, to: scrollContentView)
            scrollVerticalToPoint(y: scrollPoint.y - 30, completionBlocks: [])
            let item = ImageItem(title: "", image: image)
            imageItems.append(item)
            imagesContainer?.reload()
            delayAsync(delay: 0.1) { [weak self] in
                guard let self = self else { return }
                
                fatalError()
//                let banner = Popup(callbackDelegate: self, bannerDelegate: self, heightScaleFactor: deviceType == .iPhoneSE ? 0.8 : 0.6)
//                banner.present(content: ImageSelectionPopup(callbackDelegate: banner, item: item, index: self.choiceItems.firstIndex(of: self.choiceItems.last!)! + 1))
            }
        }
    }
}





// MARK: - CAAnimationDelegate
extension PollCreationView: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag, let completionBlocks = anim.value(forKey: "completionBlocks") as? [Closure] {
            completionBlocks.forEach { $0() }
        } else if let completionBlocks = anim.value(forKey: "maskCompletionBlocks") as? [Closure] {
            completionBlocks.forEach { $0() }
        } else if let initialLayer = anim.value(forKey: "layer") as? CAShapeLayer, let path = anim.value(forKey: "destinationPath") {
            initialLayer.path = path as! CGPath
            if let completionBlock = anim.value(forKey: "completionBlock") as? Closure {
                completionBlock()
            }
        }
    }
}





// MARK: - UITextViewDelegate
extension PollCreationView: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard isTextFieldEditingEnabled else { return false }
        
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        
        var maxCharacters: Int = .max
                
        // get the current text, or use an empty string if that failed
        let currentText = textView.text ?? ""
        
        // attempt to read the range they are trying to change, or exit if we can't
        guard let stringRange = Range(range, in: currentText) else { return false }
        
        // add their new text to the existing text
        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
        
        if textView === pollTitleTextView {
            maxCharacters = ModelProperties.shared.surveyTitleMaxLength
        } else if textView === pollDescriptionTextView {
            maxCharacters = ModelProperties.shared.surveyDescriptionMaxLength
        } else if textView === pollQuestionTextView {
            maxCharacters = ModelProperties.shared.surveyQuestionMaxLength
        }
        

        if updatedText.count > maxCharacters {
            if isTextFieldEditingEnabled {
                showBanner(bannerDelegate: self,
                           text: AppError.maximumCharactersExceeded(maxValue: maxCharacters).localizedDescription,
                           content: ImageSigns.exclamationMark,
                           dismissAfter: 0.5,
                           identifier: "isTextFieldEditingEnabled")
                isTextFieldEditingEnabled = false
            }
        }
        return updatedText.count <= maxCharacters
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView == pollTitleTextView {//|| textView == pollQuestionTextView {
            let scrollPoint = pollTitleView.convert(pollTitleTextView.frame.origin, to: scrollContentView)
            if scrollView.isScrollEnabled, lastContentOffsetY != scrollPoint.y {
                scrollVerticalToPoint(y: scrollPoint.y - 30, completionBlocks: [])
            }
            let space = textView.bounds.size.height - textView.contentSize.height
            let inset = max(0, space/2)
            textView.contentInset = UIEdgeInsets(top: inset, left: textView.contentInset.left, bottom: inset, right: textView.contentInset.right)
        } else if textView == pollDescriptionTextView {
            let scrollPoint = pollDescriptionView.convert(pollDescriptionTextView.frame.origin, to: scrollContentView)
            if scrollView.isScrollEnabled, lastContentOffsetY != scrollPoint.y {
                scrollVerticalToPoint(y: scrollPoint.y - 30, completionBlocks: [])
            }
        } else if textView == pollQuestionTextView {
            let scrollPoint = pollQuestionView.convert(pollQuestionTextView.frame.origin, to: scrollContentView)
            if scrollView.isScrollEnabled, lastContentOffsetY != scrollPoint.y {
                scrollVerticalToPoint(y: scrollPoint.y - 30, completionBlocks: [])
            }
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView == pollTitleTextView {
            let space = textView.bounds.size.height - textView.contentSize.height
            let inset = max(0, space/2)
            textView.contentInset = UIEdgeInsets(top: inset, left: textView.contentInset.left, bottom: inset, right: textView.contentInset.right)
        }
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        if viewInput?.willMoveToParent ?? false {
            return true
        }
        
        var minCharacters = 0
        if textView === pollTitleTextView {
            minCharacters = ModelProperties.shared.surveyTitleMinLength
        } else if textView === pollDescriptionTextView {
            minCharacters = ModelProperties.shared.surveyDescriptionMinLength
        } else if textView === pollQuestionTextView {
            minCharacters = ModelProperties.shared.surveyQuestionMinLength
        }
        
        if textView.text.count < minCharacters {
            showBanner(bannerDelegate: self,
                       text: AppError.minimumCharactersExceeded(minValue: minCharacters).localizedDescription,
                       content: ImageSigns.exclamationMark,
                       dismissAfter: 0.5,
                       identifier: "isTextFieldEditingEnabled")
            isTextFieldEditingEnabled = false
            return false
        }
        if textView == pollTitleTextView, viewInput?.stage == .Title {
            UIView.transition(with: pollTitleSkip, duration: 0.2, options: .transitionCrossDissolve, animations: {
                self.pollTitleSkip.image = UIImage(systemName: "checkmark")
            }, completion: {_ in self.viewInput?.onStageCompleted()})
        } else if textView == pollDescriptionTextView, viewInput?.stage == .Description {
            UIView.transition(with: pollDescriptionSkip, duration: 0.2, options: .transitionCrossDissolve, animations: {
                self.pollDescriptionSkip.image = UIImage(systemName: "checkmark")
            }, completion: {_ in self.viewInput?.onStageCompleted()})
        } else if textView == pollQuestionTextView, viewInput?.stage == .Question {
            UIView.transition(with: pollQuestionSkip, duration: 0.2, options: .transitionCrossDissolve, animations: {
                self.pollQuestionSkip.image = UIImage(systemName: "checkmark")
            }, completion: {_ in self.viewInput?.onStageCompleted()})
        } else {
            viewInput?.onStageCompleted()
        }
        return true
    }
}





// MARK: - UITextFieldDelegate
extension PollCreationView: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == pollURLTextField {
            let scrollPoint = pollURLView.convert(pollURLTextField.frame.origin, to: scrollContentView)
            if scrollView.isScrollEnabled, lastContentOffsetY != scrollPoint.y {
            scrollVerticalToPoint(y: scrollPoint.y - 30, completionBlocks: [])
            }
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard isTextFieldEditingEnabled else { return false }
        if textField == pollURLTextField {
            pollURLBrowserButton.setTitle(URL(string: string).isNil ? "open_safari".localized : "open_hyperlink".localized, for: .normal)
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === pollURLTextField, let text = textField.text {
            if !text.isEmpty {
                guard !text.isValidURL, isTextFieldEditingEnabled else {
                    pollURLTextField.resignFirstResponder()
//                    UIView.animate(withDuration: 0.15) {
//                        self.pollURLSkip.alpha = 0
//                        self.pollURLSkip.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
//                    }
//                    viewInput?.onStageCompleted()
//                    UIView.transition(with: pollURLSkip, duration: 0.2, options: .transitionCrossDissolve, animations: {
//                        self.pollURLSkip.image = UIImage(systemName: "info")
//                    }, completion: {_ in })
                    return true
                }
                showBanner(bannerDelegate: self,
                           text: AppError.invalidURL.localizedDescription,
                           content: ImageSigns.exclamationMark,
                           dismissAfter: 0.5,
                           identifier: "isTextFieldEditingEnabled")
                isTextFieldEditingEnabled = false
                return false
            } else {
//                pollURLTextField.resignFirstResponder()
////                UIView.animate(withDuration: 0.15) {
////                    self.pollURLSkip.alpha = 0
////                    self.pollURLSkip.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
////                }
////                viewInput?.onStageCompleted()
//                UIView.transition(with: pollURLSkip, duration: 0.2, options: .transitionCrossDissolve, animations: {
//                    self.pollURLSkip.image = UIImage(systemName: "info")
//                }, completion: {_ in self.viewInput?.onStageCompleted()})
                textField.resignFirstResponder()
                return true
            }
        }
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if viewInput?.willMoveToParent ?? false {
            return true
        }
        
        if textField === pollURLTextField, let text = textField.text {
            if !text.isEmpty {
                guard !text.isValidURL, isTextFieldEditingEnabled else {
                    pollURLTextField.resignFirstResponder()
//                    UIView.transition(with: pollURLSkip, duration: 0.2, options: .transitionCrossDissolve, animations: {
//                        self.pollURLSkip.image = UIImage(systemName: "info")
//                    }, completion: {_ in self.viewInput?.onStageCompleted()})
//                    UIView.animate(withDuration: 0.15) {
//                        self.pollURLSkip.alpha = 0
//                        self.pollURLSkip.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
//                    }
//                    viewInput?.onStageCompleted()
//                    pollURLBrowserButton.setTitle("open_hyperlink".localized, for: .normal)
                    return true
                }
                showBanner(bannerDelegate: self,
                           text: AppError.invalidURL.localizedDescription,
                           content: ImageSigns.exclamationMark,
                           dismissAfter: 0.5,
                           identifier: "isTextFieldEditingEnabled")
                isTextFieldEditingEnabled = false
                return false
            } else {
                pollURLTextField.resignFirstResponder()
//                UIView.transition(with: pollURLSkip, duration: 0.2, options: .transitionCrossDissolve, animations: {
//                    self.pollURLSkip.image = UIImage(systemName: "info")
//                }, completion: {_ in self.viewInput?.onStageCompleted()})
//                UIView.animate(withDuration: 0.15) {
//                    self.pollURLSkip.alpha = 0
//                    self.pollURLSkip.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
//                }
//                viewInput?.onStageCompleted()
//                pollURLBrowserButton.setTitle("open_safari".localized, for: .normal)
                return true
            }
        }
        return true
    }
}





// MARK: - ImageSelectionListener
extension PollCreationView: ImageSelectionListener {
    func addImage() {
//        guard imageItems.count < 3 else {
//            showBanner(bannerDelegate: self,
//                       text: AppError.maximumImages.localizedDescription,
//                       imageContent: ImageSigns.exclamationMark,
//                       shouldDismissAfter: 0.5)
//            return
//        }
//        let banner = Popup(callbackDelegate: self, bannerDelegate: self, heightScaleFactor: deviceType == .iPhoneSE ? 0.8 : 0.6)
//        banner.present(subview: ImageSelectionPopup(controller: viewInput as? UIViewController, callbackDelegate: banner))
    }
    
    func deleteImage(_ imageItem: ImageItem) {
        imageItems.remove(object: imageItem)
    }
    
    func editImage(_ item: ImageItem) {
        
        fatalError()
//        let banner = Popup(callbackDelegate: self, bannerDelegate: self, heightScaleFactor: deviceType == .iPhoneSE ? 0.8 : 0.6)
//        banner.present(content: ImageSelectionPopup(callbackDelegate: banner, item: item))
    }
}





// MARK: - ChoiceListener
extension PollCreationView: ChoiceListener {
    func deleteChoice(_ choiceItem: ChoiceItem) {
        choiceItems.remove(object: choiceItem)
    }
    
    func editChoice(_ choiceItem: ChoiceItem) {
        
        fatalError()
//        let banner = Popup(callbackDelegate: self, bannerDelegate: self, heightScaleFactor: deviceType == .iPhoneSE ? 0.8 : 0.5)
//        banner.present(content: ChoiceEditingPopup(callbackDelegate: banner, item: choiceItem, index: self.choiceItems.firstIndex(of: choiceItem)! + 1 ?? 0))
    }
}





// MARK: - UIScrollViewDelegate
extension PollCreationView: UIScrollViewDelegate {
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        print("df")
//    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        lastContentOffsetY = scrollView.contentOffset.y
    }

//    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
//        lastContentOffsetY = scrollView.contentOffset.y
//    }
//
//    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        lastContentOffsetY = scrollView.contentOffset.y
//    }
}





// MARK: - Logic
extension PollCreationView {
    private func prepareDict() -> [String: Any] {
        
        var dict: [String: Any] = [:]
        dict["category"] = topic.id
        dict["type"] = Survey.SurveyType.Poll.rawValue
        dict["is_private"] = option == .Private
        dict["is_anonymous"] = option == .Anon
        dict["is_commenting_allowed"] = comments == .On
        dict["post_hot"] = hot == .On
        dict["vote_capacity"] = limits
        dict["hlink"] = URL(string: pollURLTextField.text ?? "")?.absoluteString
        dict["title"] = pollTitleTextView.text ?? ""
        dict["question"] = pollQuestionTextView.text ?? ""
        dict["description"] = pollDescriptionTextView.text ?? ""
        dict["answers"] = choiceItems.map() { [
            "description": $0.text,
        ] }
        if !imageItems.isEmpty {
            dict["media"] = imageItems.map() {[
                "title": $0.title,
                "image": $0.image
            ]}
        }
        
        return dict
        
        
//        var images: [Int: [UIImage: String]] = [:]
//        imageItems.enumerated().forEach() { index, item in
//            images[index + 1] = [item.image: item.title]
//        }
//
//        poll = Survey(type: .Poll,
//                      title: pollTitleTextView.text ?? "",
//                      topic: topic,
//                      description: description,
//                      question: pollQuestionTextView.text ?? "",
//                      answers: choiceItems.map { return $0.text},
//                      media: images,
//                      url: URL(string: pollURLTextField.text ?? ""),
//                      voteCapacity: limits,
//                      isPrivate: option == .Private,
//                      isAnonymous: option == .Anon,
//                      isCommentingAllowed: comments == .On,
//                      isHot: hot == .On,
//                      isFavorite: false)
    }
}

extension PollCreationView: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //        if let origImage = info[.cropRect] as? UIImage {
        if let origImage = info[.originalImage] as? UIImage {
            let resizedImage = origImage.resized(to: CGSize(width: 400, height: 400))
            guard let imageData = resizedImage.jpegData(compressionQuality: 0.4),
                  let image = UIImage(data: imageData) else { fatalError("") }
            viewInput?.dismiss(animated: true)
            
            let item = ImageItem(title: "", image: image)
            imageItems.append(item)
            imagesContainer?.reload()
            delayAsync(delay: 0.1) { [weak self] in
                guard let self = self else { return }
                
                fatalError()
//                let banner = Popup(callbackDelegate: self, bannerDelegate: self, heightScaleFactor: deviceType == .iPhoneSE ? 0.8 : 0.6)
//                banner.present(content: ImageSelectionPopup(callbackDelegate: banner, item: item, index: self.choiceItems.firstIndex(of: self.choiceItems.last!)! + 1))
            }
            
        }
    }
    
    func onAddImageTap() {
            imagePicker.allowsEditing = true
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        let photo = UIAlertAction(title: "photo_album".localized, style: UIAlertAction.Style.default, handler: {
            (action: UIAlertAction) in
            self.imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
            self.viewInput?.present(self.imagePicker, animated: true, completion: nil)
        })
        photo.setValue(UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor.systemBlue
            default:
                return UIColor.label
            }
        }, forKey: "titleTextColor")
        alert.addAction(photo)
        let camera = UIAlertAction(title: "camera".localized, style: UIAlertAction.Style.default, handler: {
            (action: UIAlertAction) in
            self.imagePicker.sourceType = UIImagePickerController.SourceType.camera
            self.viewInput?.present(self.imagePicker, animated: true, completion: nil)
        })
        camera.setValue(UIColor { traitCollection in
                switch traitCollection.userInterfaceStyle {
                case .dark:
                    return UIColor.systemBlue
                default:
                    return UIColor.label
                }
            }, forKey: "titleTextColor")
            alert.addAction(camera)
        let cancel = UIAlertAction(title: "cancel".localized, style: UIAlertAction.Style.destructive, handler: nil)
            alert.addAction(cancel)
        self.viewInput?.present(alert, animated: true, completion: nil)
    }

}

