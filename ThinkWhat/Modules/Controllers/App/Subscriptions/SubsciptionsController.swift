//
//  SubsciptionsController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 10.03.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class SubsciptionsController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let model = SubsciptionsModel()
               
        self.controllerOutput = view as? SubsciptionsView
        self.controllerOutput?
            .viewInput = self
        self.controllerInput = model
        self.controllerInput?
            .modelOutput = self
        
        title = "subscriptions".localized
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.setNeedsLayout()
        view.layoutIfNeeded()
        controllerOutput?.onDidLayout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        controllerOutput?.onDidLayout()
    }

    private func setupUI() {
        navigationController?.navigationBar.prefersLargeTitles = true
        guard let navigationBar = self.navigationController?.navigationBar else { return }
        navigationBar.addSubview(barButton)
        barButton.layer.cornerRadius = UINavigationController.Constants.ImageSizeForLargeState / 2
        barButton.clipsToBounds = true
        barButton.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
        barButton.translatesAutoresizingMaskIntoConstraints = false
        let gesture = UITapGestureRecognizer(target: self,
                                             action: #selector(SubsciptionsController.toggleBarButton))
        barButton.addGestureRecognizer(gesture)
        NSLayoutConstraint.activate([
            barButton.rightAnchor.constraint(equalTo: navigationBar.rightAnchor, constant: -UINavigationController.Constants.ImageRightMargin),
            barButton.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: -UINavigationController.Constants.ImageBottomMarginForLargeState),
            barButton.heightAnchor.constraint(equalToConstant: UINavigationController.Constants.ImageSizeForLargeState),
            barButton.widthAnchor.constraint(equalTo: barButton.heightAnchor)
            ])
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        barButton.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
    }
    
    @objc
    private func toggleBarButton() {
        controllerOutput?.onUpperContainerShown(isBarButtonOn)
        UIView.animate(withDuration: 0.2,
                       delay: 0,
                       options: .curveEaseOut) {
            self.barButton.transform = self.isBarButtonOn ? CGAffineTransform(rotationAngle: Double.pi) : .identity
        } completion: { _ in
            self.isBarButtonOn = !self.isBarButtonOn
        }
    }
    
    // MARK: - Properties
    var controllerOutput: SubsciptionsControllerOutput?
    var controllerInput: SubsciptionsControllerInput?
    private let barButton: UIImageView = {
        let v = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: 32, height: 32)))
        v.contentMode = .scaleAspectFit
        v.image = ImageSigns.chevronDownFilled.image
        v.isUserInteractionEnabled = true
        return v
    }()
    private var isBarButtonOn = true
}

// MARK: - View Input
extension SubsciptionsController: SubsciptionsViewInput {
    // Implement methods
}

// MARK: - Model Output
extension SubsciptionsController: SubsciptionsModelOutput {
    // Implement methods
}

extension SubsciptionsController: DataObservable {
    func onDataLoaded() {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
}
