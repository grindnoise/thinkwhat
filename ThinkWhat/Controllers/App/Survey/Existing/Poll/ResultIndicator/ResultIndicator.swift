//
//  ResultIndicator.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 02.11.2021.
//  Copyright © 2021 Pavel Bukharov. All rights reserved.
//

import UIKit

class ResultIndicator: UIView {
    enum Mode {
        case None, Anon, Stock
    }
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var backgroundFrame: UIView!
    @IBOutlet weak var foregroundFrame: UIView!
    @IBOutlet weak var actionView: UIView! {
        didSet {
            actionView.layer.masksToBounds = false
        }
    }
    @IBOutlet weak var percentLabel: UILabel!
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    @IBOutlet weak var actionViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var label: UILabel! {
        didSet {
            label.alpha = mode == .None ? 1 : 0
            label.text = "Голосов\nнет"
        }
    }
    @IBOutlet weak var choiceBadge: Icon! {
        didSet {
            choiceBadge.alpha = isSelected ? 1 : 0
            choiceBadge.backgroundColor = .clear
            choiceBadge.isRounded = false
            choiceBadge.iconColor = color
            choiceBadge.scaleMultiplicator = 1.3
            choiceBadge.category = .Choice
        }
    }
    @IBOutlet weak var choiceBadgeTrailingConstraint: NSLayoutConstraint!
    var indexPath: IndexPath!
    private var tapGesture: UITapGestureRecognizer!
    private var panGesture: UIPanGestureRecognizer!
//    private var apiManager: APIManagerProtocol!
    private var color: UIColor = K_COLOR_RED
    private weak var delegate: CallbackDelegate!
    private var highlightedImageView: UIImageView? {
        didSet {
            if highlightedImageView != nil, highlightedImageView != oldValue {
                highlightedImageView?.layer.zPosition += 10
                let constraint = highlightedImageView?.getAllConstraints().filter({ $0.identifier == "centerY" }).first
                UIView.animate(withDuration: 0.17, delay: 0, options: [.curveEaseInOut], animations: {
                    self.actionView.setNeedsLayout()
                    constraint?.constant -= self.actionView.frame.height * 0.9
                    self.actionView.layoutIfNeeded()
                    self.highlightedImageView?.transform = CGAffineTransform(scaleX: 1.6, y: 1.6)
                })

                if oldValue != nil {
                    let oldConstraint = oldValue!.getAllConstraints().filter({ $0.identifier == "centerY" }).first
                    oldValue?.layer.zPosition -= 10
                    UIView.animate(withDuration: 0.1, delay: 0, options: [.curveEaseOut], animations: {
                        self.actionView.setNeedsLayout()
                        oldConstraint?.constant += self.actionView.frame.height * 0.9
                        self.actionView.layoutIfNeeded()
                        oldValue?.transform = .identity
                    })
                }
            } else if oldValue != nil {
                oldValue?.layer.zPosition -= 10
                let oldConstraint = oldValue!.getAllConstraints().filter({ $0.identifier == "centerY" }).first
                UIView.animate(withDuration: 0.1) {
                    self.actionView.setNeedsLayout()
                    oldConstraint?.constant += self.actionView.frame.height * 0.9
                    self.actionView.layoutIfNeeded()
                    oldValue?.transform = .identity
                }
            }
        }
    }
    private var imageViews: [UIImageView] = []
    private var interactionViews: [[UIView: UIImageView]] = []
    var answer: Answer!
    private func setupImages() {
        if !answer.voters.isEmpty {
            if isSelected {
                if !answer.voters.filter({ $0 == AppData.shared.userprofile }).isEmpty {
                    if let index = answer.voters.firstIndex(where: { $0 == AppData.shared.userprofile/*Userprofiles.shared.own?.id*/ }) {
                        if  index != 0  {
                            answer.voters.rearrange(from: index, to: 0)
                        }
                    }
                } else {
                    answer.voters.insert(AppData.shared.userprofile, at: 0)//(Userprofiles.shared.own!, at: 0)
                }
            }
            
            for i in 0..<answer.voters.count {
                if i == 5 {
                    break
                }
                let imageView = UIImageView(frame: .zero)
                imageView.layer.zPosition = 10 - CGFloat(i)
                imageViews.append(imageView)
                actionView.addSubview(imageView)
                imageView.layer.masksToBounds = false
                imageView.translatesAutoresizingMaskIntoConstraints = false
                let centerY = imageView.centerYAnchor.constraint(equalTo: actionView.centerYAnchor)
                centerY.identifier = "centerY"
                centerY.isActive = true
                //                    .isActive = true
                if i == 0 {
                    if answer.totalVotes > 5 {
                        imageView.leadingAnchor.constraint(equalTo: actionView.leadingAnchor, constant: 4).isActive = true
                    } else {
                        imageView.centerXAnchor.constraint(equalTo: actionView.centerXAnchor).isActive = true
                    }
                } else {
                    imageView.leadingAnchor.constraint(equalTo: imageViews[i-1].leadingAnchor, constant: 8).isActive = true
                }
                imageView.heightAnchor.constraint(equalTo: actionView.heightAnchor, multiplier: (0.8 - 0)/1.0).isActive = true
                imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor).isActive = true
                if answer.voters[i].image != nil {
                    imageView.image = answer.voters[i].image!.circularImage(size: CGSize(width: actionView.frame.height, height: actionView.frame.height), frameColor: color)
                } else if let url = answer.voters[i].imageURL {
                    imageView.image = UIImage(named: "user")!.circularImage(size: CGSize(width: actionView.frame.height, height: actionView.frame.height), frameColor: color)
                    API.shared.downloadImage(url: url) { progress in
                        print(progress)
                    } completion: { result in
                        switch result {
                        case .success(let image):
                            self.answer.voters[i].image = image
                            UIView.transition(with: imageView,
                                              duration: 0.5,
                                              options: .transitionCrossDissolve,
                                              animations: { imageView.image = image.circularImage(size: imageView.frame.size, frameColor: self.color) },
                                              completion: nil)
                        case .failure(let error):
                            showAlert(type: .Warning, buttons: [["Закрыть": [CustomAlertView.ButtonType.Ok: nil]]], text: error.localizedDescription)
                        }
                    }
                } else {
                    imageView.image = UIImage(named: "user")!.circularImage(size: CGSize(width: actionView.frame.height, height: actionView.frame.height), frameColor: color)
                }
            }
            if answer.totalVotes > 5 {
                let label = UILabel(frame: .zero)
                actionView.addSubview(label)
                label.translatesAutoresizingMaskIntoConstraints = false
                label.numberOfLines = 0
                label.text = "еще\n\(answer.totalVotes-5)"
                label.font = StringAttributes.font(name: StringAttributes.Fonts.Style.Regular, size: 8)
                label.textColor = .darkGray
                label.backgroundColor = .clear
                label.textAlignment = .center
                label.heightAnchor.constraint(equalTo: actionView.heightAnchor).isActive = true
                label.leadingAnchor.constraint(equalTo: imageViews.last!.trailingAnchor).isActive = true
                label.trailingAnchor.constraint(equalTo: actionView.trailingAnchor).isActive = true
                label.layer.zPosition = 100
            }
            panGesture = UIPanGestureRecognizer(target: self, action: #selector(ResultIndicator.handlePan(recognizer:)))
            panGesture.delegate = self
            actionView.addGestureRecognizer(panGesture)
            tapGesture = UITapGestureRecognizer(target: self, action: #selector(ResultIndicator.handleTap(recognizer:)))
            tapGesture.delegate = self
            actionView.addGestureRecognizer(tapGesture)
        }
    }
    var isSelected = false {
        didSet {
            //TODO: - Add selected mark
        }
    }
    var value: Int = 0 {
        didSet {
            percentLabel.text = "\(value)%"
        }
    }
    var mode: ChoiceResultCell.Mode = .Stock {
        didSet {
            if mode == .Anon {
                actionViewConstraint.setMultiplierWithFade(0, duration: 0)
            } else if mode == .None {
                label.alpha = 1
            }
        }
    }
    var needsUIUpdate = true
    private var isAnimationEnabled = true
    
    override var frame: CGRect {
        didSet {
            if needsUIUpdate {
                updateUI()
            }
        }
    }
    
    override var bounds: CGRect {
        didSet {
            if needsUIUpdate {
                updateUI()
            }
        }
    }
    
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    init(delegate: CallbackDelegate, answer: Answer, color: UIColor, isSelected: Bool) {
        super.init(frame: .zero)
        self.delegate = delegate
        self.isSelected = isSelected
        self.answer = answer
//        self.apiManager = apiManager
        self.color = color
        self.commonInit()
        self.setupImages()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("ResultIndicator", owner: self, options: nil)
        guard let content = contentView else {
            return
        }
        content.layer.masksToBounds = false
        content.frame = self.bounds
        content.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(content)
        self.backgroundColor = .clear
    }
    
    func updateUI() {
        if backgroundFrame != nil, foregroundFrame != nil, widthConstraint != nil {
//            contentView.backgroundColor = .clear
            backgroundFrame.backgroundColor = color.withAlphaComponent(0.05)
            foregroundFrame.backgroundColor = isSelected ? color.withAlphaComponent(0.65) : color.withAlphaComponent(0.35)
            backgroundFrame.cornerRadius = contentView.frame.height / 2
            foregroundFrame.cornerRadius = contentView.frame.height / 2
            setPercentage(value: nil)
//            if !isAnimationEnabled {
//                widthConstraint.constant = value > 0 ? max(CGFloat(value)*backgroundFrame.frame.width/100, contentView.frame.height) : 0
//            }
            choiceBadgeTrailingConstraint.constant = -backgroundFrame.frame.height / 3
            if isSelected {
                choiceBadge.category = .Choice
            }
        }
    }
    
    @objc private func handleTap(recognizer: UITapGestureRecognizer) {
        if recognizer.state == .ended {
            if !answer.voters.isEmpty {
//                let dict = ["users": userprofiles, "total": totalCount, "answerID": answerID] as [String : Any]
                let array = [answer as AnyObject, imageViews as AnyObject, indexPath as AnyObject]
                delegate?.callbackReceived(array as AnyObject)
            }
        }
    }
    
    @objc private func handlePan(recognizer: UIPanGestureRecognizer) {
        guard imageViews.count > 1 else {
            return
        }
        if interactionViews.isEmpty {
            interactionViews.removeAll()
            let v = UIView(frame: imageViews[0].frame)
//            v.backgroundColor = .black
            v.layer.zPosition = 200
            actionView.addSubview(v)
            interactionViews.append([v: imageViews[0]])

            for i in 1..<imageViews.count {
                if let previousView = imageViews[i - 1] as? UIView, let previousFrame = previousView.bounds as? CGRect, let currentView = imageViews[i] as? UIView, let currentFrame = currentView.bounds as? CGRect{
                    let point = previousView.convert(CGPoint(x: previousFrame.maxX, y: 0), to: currentView)
                    let visibleFrame = CGRect(origin: CGPoint(x: currentView.frame.origin.x + point.x, y: currentView.frame.origin.y), size: CGSize(width: currentFrame.width - point.x, height: currentFrame.height))
                    let v = UIView(frame: visibleFrame)
//                    v.backgroundColor = .red
                    v.layer.zPosition = 200 + CGFloat(i)
                    actionView.addSubview(v)
                    interactionViews.append([v: imageViews[i]])
                }
            }
        }
        
        let point = recognizer.location(in: actionView)
        interactionViews.forEach({
            (dict) in
            if let v = dict.keys.first as? UIView, let imageView = dict.values.first {
                if v.frame.contains(point) {
                    if self.highlightedImageView != imageView {
                        print(imageView)
                        self.highlightedImageView = imageView
                    }
                }
            }
        })
        
        if recognizer.state == .ended || recognizer.state == .cancelled {
            highlightedImageView = nil
        }
    }
    
    func setPercentage(value _value: Int?, animated: Bool = false) {
        if _value != nil {
            value = _value!
        }
        if isAnimationEnabled || animated {
            self.widthConstraint.constant = 0
            self.foregroundFrame.setNeedsLayout()
            self.foregroundFrame.layoutIfNeeded()
            UIView.animate(withDuration: 0.2,
                           delay: 0,
                           options: [.curveEaseInOut],
                           animations: {
                            self.widthConstraint.constant = self.value > 0 ? max(CGFloat(self.value)*self.backgroundFrame.frame.width/100, self.contentView.frame.height) : 0
            },
                           completion: {
                            _ in
                            self.isAnimationEnabled = false
            })
        }
    }
}

extension ResultIndicator: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == self.tapGesture &&
            otherGestureRecognizer == self.panGesture {
            return true
        }
        return false
    }
}
