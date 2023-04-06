//
//  NewPollViewController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 16.03.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class NewPollController: UIViewController, TintColorable, UINavigationControllerDelegate {
  
  ///Sequence of stages to post new survey
  enum Stage: Int, CaseIterable {
    case Topic, Title, Description, Images, Hyperlink, Question, Choices, Comments, Anonymity, Limits, Hot, Ready
    
    func next() -> Stage? { Stage(rawValue: (self.rawValue + 1)) }
    
    var numImage: UIImage { UIImage(systemName: "\(self.rawValue + 1).circle.fill") ?? UIImage() }
    
    var title: String {
      switch self {
      case .Topic: return "new_poll_topic".localized
      case .Title: return "new_poll_title".localized
      case .Description: return "new_poll_description".localized
      case .Question: return "new_poll_question".localized
      case .Choices: return "new_poll_choices".localized
      case .Hyperlink: return "new_poll_hyperlink".localized
      case .Images: return "new_poll_images".localized
      case .Comments: return "new_poll_comments".localized
      case .Anonymity: return "new_poll_anonymity".localized
      case .Hot: return "new_poll_hot".localized
      case .Limits: return "new_poll_limit".localized
      case .Ready: return "new_poll_cost".localized
      }
    }
    
    var placeholder: String {
      switch self {
      case .Topic: return "new_poll_topic_placeholder".localized
      case .Title: return "new_poll_title_placeholder".localized
      case .Description: return "new_poll_description_placeholder".localized
      case .Question: return "new_poll_question_placeholder".localized
      case .Choices: return "new_poll_choices_placeholder".localized
      case .Hyperlink: return "new_poll_hyperlink_placeholder".localized
      case .Images: return "new_poll_images_placeholder".localized
      case .Comments: return "new_poll_comments_placeholder".localized
      case .Anonymity: return "new_poll_anonymity_placeholder".localized
      case .Hot: return "new_poll_hot_placeholder".localized
      case .Limits: return "new_poll_limit_placeholder".localized
      default: return ""
      }
    }
    
    var minLength: Int {
      switch self {
      case .Title: return ModelProperties.shared.surveyTitleMinLength
      case .Description: return ModelProperties.shared.surveyDescriptionMinLength
      case .Question: return ModelProperties.shared.surveyQuestionMinLength
      case .Choices: return ModelProperties.shared.surveyAnswerTitleMinLength
      case .Images: return ModelProperties.shared.surveyMediaTitleMinLength
      default: return 0
      }
    }
      
    var maxLength: Int {
      switch self {
      case .Title: return ModelProperties.shared.surveyTitleMaxLength
      case .Description: return ModelProperties.shared.surveyDescriptionMaxLength
      case .Question: return ModelProperties.shared.surveyQuestionMaxLength
      case .Choices: return ModelProperties.shared.surveyAnswerTitleMaxLength
      case .Images: return ModelProperties.shared.surveyMediaTitleMaxLength
      default: return 0
      }
    }
    
    func percent() -> Double {  Double((self.rawValue + 1) * 100 / Stage.allCases.count) / 100 }
  }
  
  
  
  // MARK: - Public properties
  var controllerOutput: NewPollControllerOutput?
  var controllerInput: NewPollControllerInput?
  var tintColor: UIColor
  
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  ///**Logic**
  private var isTitleOnScreen = true
  ///**UI**
  private let progressCapsule: ProgressCapsule = ProgressCapsule(placeholder: "new_poll_readiness".localized.uppercased(),
                                                                 padding: 4,
                                                                 font: UIFont(name: Fonts.Bold, size: 20)!,
                                                                 iconCategory: .MegaphoneFill)
  private lazy var imagePicker: UIImagePickerController = {
      let picker = UIImagePickerController()
      picker.delegate = self
      return picker
  }()
  
  

  // MARK: - Initialization
  init(color: UIColor) {
    self.tintColor = color
    
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  

  // MARK: - Destructor
  deinit {
    progressCapsule.removeFromSuperview()
    observers.forEach { $0.invalidate() }
    tasks.forEach { $0?.cancel() }
    subscriptions.forEach { $0.cancel() }
    NotificationCenter.default.removeObserver(self)
#if DEBUG
    print("\(String(describing: type(of: self))).\(#function)")
#endif
  }
  
  
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let view = NewPollView()
    let model = NewPollModel()
    
    self.controllerOutput = view
    self.controllerOutput?
      .viewInput = self
    self.controllerInput = model
    self.controllerInput?
      .modelOutput = self
    
    self.view = view as UIView
    
    setupUI()
  }
  
  override func willMove(toParent parent: UIViewController?) {
    controllerOutput?.willMoveToParent()
    
    super.willMove(toParent: parent)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    guard let constraint = progressCapsule.getConstraint(identifier: "centerYAnchor"),
    let navigationBar = self.navigationController?.navigationBar
    else { return }
    
    UIView.animate(withDuration: 0.1, animations: { [weak self] in
      guard let self = self else { return }
      
      navigationBar.setNeedsLayout()
      constraint.constant = -(navigationBar.bounds.height + self.view.statusBarFrame.height)
      navigationBar.layoutIfNeeded()
    }) { [weak self] _ in
      guard let self = self else { return }
      
      self.isTitleOnScreen = false
    }
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
//    Publishers.countdown(queue: .main,
//                         interval: .milliseconds(700),
//                         times: .max(Int(7)))
//    .sink { [weak self] element in
//      guard let self = self else { return }
//
//      self.progressCapsule.setProgress(value: Double(7 - element)/7)
//    }
//    .store(in: &subscriptions)

    
    guard !isTitleOnScreen,
          let constraint = progressCapsule.getConstraint(identifier: "centerYAnchor")
    else { return }
    
    UIView.animate(withDuration: 0.1, animations: { [weak self] in
      guard let self = self else { return }
      
      self.navigationController?.navigationBar.setNeedsLayout()
      constraint.constant = 0
      self.navigationController?.navigationBar.layoutIfNeeded()
    }) { [weak self] _ in
      guard let self = self else { return }
      
      self.isTitleOnScreen = true
    }
  }
}

extension NewPollController: NewPollViewInput {
  func preview(_ instance: Survey) {
    let backItem = UIBarButtonItem()
    backItem.title = ""
    navigationItem.backBarButtonItem = backItem
    navigationController?.pushViewController(PollController(surveyReference: instance.reference,
                                                            mode: .Preview,
                                                            showNext: false),
                                             animated: true)
  }
  
  func setColor(_ color: UIColor) {
    setNavigationBarTintColor(color)
    progressCapsule.setColor(color)
  }
  
  func addImage() {
    imagePicker.allowsEditing = true
    let alert = UIAlertController(title: nil,
                                  message: nil,
                                  preferredStyle: UIAlertController.Style.actionSheet)

    let photo = UIAlertAction(title: "photo_album".localized, style: UIAlertAction.Style.default, handler: {
      (action: UIAlertAction) in
      self.imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
      self.present(self.imagePicker, animated: true, completion: nil)
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
      self.present(self.imagePicker, animated: true, completion: nil)
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
    present(alert, animated: true, completion: nil)
  }
  
  func setProgress(_ value: Double) {
    progressCapsule.setProgress(value: value)
  }
  
  
}

extension NewPollController: NewPollModelOutput {
  
}

// MARK: - Private
private extension NewPollController {
  func setupUI() {
    setNavigationBarTintColor(tintColor)
    
    guard let navigationBar = navigationController?.navigationBar else { return }
    
    progressCapsule.placeInCenter(of: navigationBar)
    navigationBar.setNeedsLayout()
    navigationBar.layoutIfNeeded()

    let appearance = UINavigationBarAppearance()
    appearance.configureWithDefaultBackground()
    appearance.backgroundColor = .systemBackground
    appearance.shadowColor = nil
    navigationBar.standardAppearance = appearance
    navigationBar.scrollEdgeAppearance = appearance
    navigationBar.prefersLargeTitles = false

    if #available(iOS 15.0, *) { navigationBar.compactScrollEdgeAppearance = appearance }
  }
}

extension NewPollController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let origImage = info[.editedImage] as? UIImage {
            let resizedImage = origImage.resized(to: CGSize(width: 200, height: 200))
            let imageData = resizedImage.jpegData(compressionQuality: 0.4)
            
            controllerOutput?.imageAdded(UIImage(data: imageData!)!)
            dismiss(animated: true)
        }
    }
}
