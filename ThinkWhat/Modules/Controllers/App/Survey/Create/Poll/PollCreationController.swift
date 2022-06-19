//
//  PollCreationController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 26.05.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class PollCreationController: UIViewController {

    deinit {
        print("PollCreationController deinit")
    }

    //Sequence of stages to post new survey
    enum Stage: Int, CaseIterable {
        case Topic, Options, Title, Description, Question, Hyperlink, Images, Choices, Comments, Limits, Hot, Ready
        
        func next() -> Stage? {
            return Stage(rawValue: (self.rawValue + 1))
        }
    }
    
    enum Option: String {
        case Null = "", Ordinary = "default_option", Anon = "anon_option", Private = "private_option"
    }
    
    enum Comments {
        case On, Off
    }
    
    enum Hot {
        case On, Off
    }
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
       
        let model = PollCreationModel()
               
        self.controllerOutput = view as? PollCreationView
        self.controllerOutput?
            .viewInput = self
        self.controllerInput = model
        self.controllerInput?
            .modelOutput = self
        
        self.view = view as UIView
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = deviceType == .iPhoneSE ? false : true
        title = "new_poll".localized
        navigationItem.largeTitleDisplayMode = .always
//        DispatchQueue.main.async { [weak self] in
//            self?.navigationController?.navigationBar.sizeToFit()
//        }
        let navigationBar = navigationController?.navigationBar
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.shadowColor = .systemGray
        navigationBar?.scrollEdgeAppearance = navigationBarAppearance

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard stage == .Topic else { return }
        controllerOutput?.onNextStage(.Topic)
    }

    // MARK: - Properties
    var controllerOutput: PollCreationControllerOutput?
    var controllerInput: PollCreationControllerInput?
    var stage: Stage = .Topic
    private var maximumStage: Stage = .Topic {
        didSet {
            if oldValue.rawValue >= maximumStage.rawValue {
                maximumStage = oldValue
            }
        }
    }
}

// MARK: - View Input
extension PollCreationController: PollCreationViewInput {
    func onStageCompleted() {
        guard let next = stage.next() else { return }
        stage = next
        Task {
            await MainActor.run {
                controllerOutput?.onNextStage(stage)
            }
        }
    }
}

// MARK: - Model Output
extension PollCreationController: PollCreationModelOutput {
    // Implement methods
}

extension UIColor {

    /// Converts this `UIColor` instance to a 1x1 `UIImage` instance and returns it.
    ///
    /// - Returns: `self` as a 1x1 `UIImage`.
    func as1ptImage() -> UIImage {
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        setFill()
        UIGraphicsGetCurrentContext()?.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let image = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        return image
    }
}
