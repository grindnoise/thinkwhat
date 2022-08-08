//
//  VoteEducation.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 04.08.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class VoteEducation: UIView {

    // MARK: - Destructor
    deinit {
#if DEBUG
        print("\(String(describing: type(of: self))).\(#function)")
#endif
    }


    private weak var callbackDelegate: CallbackObservable?
    private let category: Icon.Category
    private let color: UIColor
    private var observers: [NSKeyValueObservation] = []
    private lazy var icon: CircleButton = {
        let icon = CircleButton(frame: CGRect(origin: .zero, size: CGSize(width: 40, height: 40)), useAutoLayout: true)
        icon.color = .clear
        icon.icon.isRounded = false
        icon.clipsToBounds = false
        icon.icon.iconColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
        icon.icon.backgroundColor = .clear
        icon.layer.masksToBounds = false
        icon.icon.layer.masksToBounds = false
        icon.oval.masksToBounds = false
        icon.icon.scaleMultiplicator = 1.2
        icon.category = category
        icon.state = .Off
        icon.contentView.backgroundColor = .clear
        icon.oval.strokeColor = traitCollection.userInterfaceStyle == .dark ? UIColor.systemBlue.cgColor : color.cgColor
        icon.oval.lineCap = .round
        icon.oval.strokeStart = 1
        
        observers.append(icon.observe(\CircleButton.bounds, options: .new) { view, change in
            guard let newValue = change.newValue else { return }
            view.oval.lineWidth = newValue.width * 0.075
        })
        
        return icon
    }()
    private lazy var button: UIButton = {
        let instance = UIButton()
        instance.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
//        instance.setTitle("ok".localized.uppercased(), for: .normal)
        let font = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .title3)
        instance.setAttributedTitle(NSAttributedString(string: "ok".localized.uppercased(), attributes: StringAttributes.getAttributes(font: font!, foregroundColor: .white, backgroundColor: .clear) as [NSAttributedString.Key : Any]), for: .normal)
        instance.addTarget(self, action: #selector(self.onTap), for: .touchUpInside)
        
        observers.append(instance.observe(\UIButton.bounds, options: .new) { view, change in
            guard let newValue = change.newValue else { return }
            view.cornerRadius = newValue.height/2.25
        })
        
        return instance
    }()
    private lazy var label: UILabel = {
        let instance = UILabel()
        instance.font = UIFont(name: Fonts.OpenSans.Regular.rawValue, size: 30)
        instance.adjustsFontSizeToFitWidth = true
        instance.minimumScaleFactor = 0.4
        instance.textColor = .label
        instance.numberOfLines = 0
        instance.textAlignment = .center
        instance.text = "poll_vote_edu_1".localized + "\n\n" + "poll_vote_edu_2".localized
        
        return instance
    }()
    private lazy var verticalStack: UIStackView = {
        let emptyView_1 = UIView()
        emptyView_1.backgroundColor = .clear
        emptyView_1.addSubview(icon)
        icon.translatesAutoresizingMaskIntoConstraints = false
        
        let emptyView_2 = UIView()
        emptyView_2.backgroundColor = .clear
        emptyView_2.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        let instance = UIStackView(arrangedSubviews: [emptyView_1, label, emptyView_2])
        instance.axis = .vertical
        instance.spacing = 8
        
        emptyView_1.translatesAutoresizingMaskIntoConstraints = false
        emptyView_2.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            emptyView_1.widthAnchor.constraint(equalTo: instance.widthAnchor),
            emptyView_1.heightAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 0.3),
            icon.widthAnchor.constraint(equalTo: icon.heightAnchor, multiplier: 1/1),
            icon.bottomAnchor.constraint(equalTo: emptyView_1.bottomAnchor),
            icon.centerXAnchor.constraint(equalTo: emptyView_1.centerXAnchor),
            icon.topAnchor.constraint(equalTo: emptyView_1.topAnchor),
            emptyView_2.widthAnchor.constraint(equalTo: instance.widthAnchor),
            emptyView_2.heightAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 0.2),
            button.centerYAnchor.constraint(equalTo: emptyView_2.centerYAnchor),
            button.centerXAnchor.constraint(equalTo: emptyView_2.centerXAnchor),
            button.heightAnchor.constraint(equalTo: emptyView_2.heightAnchor, multiplier: 0.7),
            button.widthAnchor.constraint(equalTo: button.heightAnchor, multiplier: 7/2),
        ])
        
        return instance
    }()
    
    // MARK: - Initialization
    init(topic: Icon.Category, color: UIColor, callbackDelegate: CallbackObservable) {
        self.callbackDelegate = callbackDelegate
        self.color = color
        self.category = topic
        
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        verticalStack.addEquallyTo(to: self)
        delayAsync(delay: 0.25) {
            self.icon.addEnableAnimation(duration: 1.75, completionBlock: { finished in
                self.icon.oval.opacity = 0
                
                let pathAnim = Animations.get(property: .Path, fromValue: (self.icon.icon.icon as! CAShapeLayer).path!, toValue: (self.icon.icon.getLayer(.Binoculars) as! CAShapeLayer).path!, duration: 0.5, delay: 0, repeatCount: 0, autoreverses: false, timingFunction: CAMediaTimingFunctionName.easeInEaseOut, delegate: nil, isRemovedOnCompletion: false)
                self.icon.icon.icon.add(pathAnim, forKey: nil)
                
                let fillAnim = Animations.get(property: .FillColor, fromValue: self.icon.icon.iconColor, toValue: self.traitCollection.userInterfaceStyle == .dark ? UIColor.systemBlue.cgColor : UIColor.black.cgColor, duration: 0.25, delay: 0.75, delegate: nil)
                self.icon.icon.icon.add(fillAnim, forKey: nil)
                (self.icon.icon.icon as! CAShapeLayer).fillColor = self.traitCollection.userInterfaceStyle == .dark ? UIColor.systemBlue.cgColor : UIColor.black.cgColor
            })
        }
    }
    
    @objc
    private func onTap() {
        callbackDelegate?.callbackReceived(self)
    }
}

extension VoteEducation: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        print("stop")
        self.icon.oval.strokeStart = 0
    }
}
