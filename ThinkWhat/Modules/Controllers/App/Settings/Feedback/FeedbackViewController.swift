//
//  FeedbackViewController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 12.10.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class FeedbackViewController: UIViewController, TintColorable {
  
  // MARK: - Properties
  var controllerOutput: FeedbackControllerOutput?
  var controllerInput: FeedbackControllerInput?
  var tintColor: UIColor
  
  
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  private lazy var tagCapsule: TagCapsule = { TagCapsule(text: "feedback".localized.uppercased(),
                                                         padding: 4,
                                                         color: navigationController!.navigationBar.tintColor,
                                                         font: UIFont(name: Fonts.Bold, size: 20)!,
                                                         iconCategory: .Letter) }()
  private var padding: CGFloat = 8
  
  // MARK: - Destructor
  deinit {
#if DEBUG
    print("\(String(describing: type(of: self))).\(#function)")
#endif
  }
  
  
  init(tintColor: UIColor) {
    self.tintColor = tintColor
    
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  // MARK: - Lifecycle Methods
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let view = FeedbackView()
    let model = FeedbackModel()
    
    self.controllerOutput = view
    self.controllerOutput?
      .viewInput = self
    self.controllerInput = model
    self.controllerInput?
      .modelOutput = self
    
    self.view = view as UIView
    //        title = "feedback".localized
    
    setupUI()
    navigationController?.navigationBar.prefersLargeTitles = false
    //        navigationItem.largeTitleDisplayMode = .always
  }
}

private extension FeedbackViewController {
  func setupUI() {
    let button = UIBarButtonItem(image: UIImage(systemName: "questionmark", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold)), style: .plain, target: self, action: #selector(self.handleTap))
    
    navigationItem.setRightBarButton(button, animated: true)
    navigationItem.titleView = tagCapsule
  }
  
  @objc
  func handleTap() {
    view.endEditing(true)
    
    let banner = NewBanner(contentView: TextBannerContent(image: UIImage(systemName: "lightbulb.fill")!,
                                                          text: "feedback_hint",
                                                          tintColor: tintColor),
                           contentPadding: UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8),
                           isModal: false,
                           useContentViewHeight: true,
                           shouldDismissAfter: 1)
    banner.didDisappearPublisher
      .sink { _ in banner.removeFromSuperview() }
      .store(in: &self.subscriptions)
  }
}

extension FeedbackViewController: FeedbackViewInput {
  func sendFeedback(_ description: String) {
    controllerInput?.sendFeedback(description)
  }
}

extension FeedbackViewController: FeedbackModelOutput {}
