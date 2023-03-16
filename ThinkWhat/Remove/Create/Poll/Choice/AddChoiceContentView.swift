////
////  AddChoiceContentView.swift
////  ThinkWhat
////
////  Created by Pavel Bukharov on 14.06.2022.
////  Copyright © 2022 Pavel Bukharov. All rights reserved.
////
//
//import UIKit
//
//@available(iOS 14.0, *)
//class AddChoiceContentView: UIView, UIContentView {
//    
//    let textView = UITextView()
//    private var observers: [NSKeyValueObservation] = []
//    private var currentConfiguration: AddChoiceCellConfiguration!
//    var configuration: UIContentConfiguration {
//        get {
//            currentConfiguration
//        }
//        set {
//            guard let newConfiguration = newValue as? AddChoiceCellConfiguration else {
//                return
//            }
//            apply(configuration: newConfiguration)
//        }
//    }
//    
//
//    init(configuration: AddChoiceCellConfiguration) {
//        super.init(frame: .zero)
//        commonInit()
//        apply(configuration: configuration)
//        setObservers()
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//}
//
//@available(iOS 14.0, *)
//private extension AddChoiceContentView {
//    
//    private func commonInit() {
//        textView.font = UIFont(name: Fonts.Regular, size: 14)
//        addSubview(textView)
//        textView.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            textView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
//            textView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
//            textView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
//            textView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
//        ])
//        let constraint = heightAnchor.constraint(equalToConstant: max(50, textView.contentSize.height))
//        constraint.identifier = "height"
//        constraint.isActive = true
//        setNeedsLayout()
//        layoutIfNeeded()
//    }
//    
//    private func apply(configuration: AddChoiceCellConfiguration) {
//        
//        // Only apply configuration if new configuration and current configuration are not the same
//        guard currentConfiguration != configuration else {
//            return
//        }
//        currentConfiguration = configuration
//        textView.text = configuration.text
//    }
//    
//        private func setObservers() {
//            observers.append(textView.observe(\UITextView.contentSize, options: [NSKeyValueObservingOptions.new]) { [weak self] (view: UIView, change: NSKeyValueObservedChange<CGSize>) in
//                guard let self = self,
//                      let constraint = self.getAllConstraints().filter({ $0.identifier == "height"}).first,
//                      let value = change.newValue else { return }
////                self.removeConstraint(constraint)
////                self.translatesAutoresizingMaskIntoConstraints = false
////                let newConstraint = self.heightAnchor.constraint(equalToConstant: max(50, value.height))
////                newConstraint.identifier = "height"
////                newConstraint.isActive = true
//                UIView.animate(withDuration: 0.2) {
//                    self.setNeedsLayout()
//                    constraint.constant += 10
//                    self.layoutIfNeeded()
//                }
//            })
//        }
//}
