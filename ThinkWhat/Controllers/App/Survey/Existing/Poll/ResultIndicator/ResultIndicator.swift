//
//  ResultIndicator.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 02.11.2021.
//  Copyright © 2021 Pavel Bukharov. All rights reserved.
//

import UIKit

class ResultIndicator: UIView {
    
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
//    var answerID: Int!
    var indexPath: IndexPath!
    var tapGesture: UITapGestureRecognizer!
    var panGesture: UIPanGestureRecognizer!
    var apiManager: APIManagerProtocol!
    var frameColor: UIColor = K_COLOR_RED {
        didSet {
            if backgroundFrame != nil, foregroundFrame != nil {
                backgroundFrame.backgroundColor = frameColor.withAlphaComponent(0.05)
                foregroundFrame.backgroundColor = frameColor.withAlphaComponent(0.4)
            }
        }
    }
    weak var delegate: CallbackDelegate?
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
    var imageViews: [UIImageView] = []
    private var interactionViews: [[UIView: UIImageView]] = []
//    var totalCount = 0
//    var userprofiles: [UserProfile] = [] {
//        didSet {
//            if !userprofiles.isEmpty {
//                if isSelected {
//                    if !userprofiles.filter({ $0.ID == UserProfiles.shared.own?.ID }).isEmpty {
//                        if let index = userprofiles.firstIndex(where: { $0.ID == UserProfiles.shared.own?.ID }) {
//                            if  index != 0  {
//                                userprofiles.rearrange(from: index, to: 0)
//                            }
//                        }
//                    } else {
//                        userprofiles.insert(UserProfiles.shared.own!, at: 0)
//                    }
//                }
//
//                for i in 0..<userprofiles.count {
//                    if i == 5 {
//                        break
//                    }
//                    let imageView = UIImageView(frame: .zero)
//                    imageView.layer.zPosition = 10 - CGFloat(i)
//                    imageViews.append(imageView)
//                    actionView.addSubview(imageView)
//                    imageView.layer.masksToBounds = false
//                    imageView.translatesAutoresizingMaskIntoConstraints = false
//                    let centerY = imageView.centerYAnchor.constraint(equalTo: actionView.centerYAnchor)
//                    centerY.identifier = "centerY"
//                    centerY.isActive = true
////                    .isActive = true
//                    if i == 0 {
//                        if totalCount > 5 {
//                            imageView.leadingAnchor.constraint(equalTo: actionView.leadingAnchor, constant: 4).isActive = true
//                        } else {
//                            imageView.centerXAnchor.constraint(equalTo: actionView.centerXAnchor).isActive = true
//                        }
//                    } else {
//                        imageView.leadingAnchor.constraint(equalTo: imageViews[i-1].leadingAnchor, constant: 8).isActive = true
//                    }
//                    imageView.heightAnchor.constraint(equalTo: actionView.heightAnchor, multiplier: (0.8 - 0)/1.0).isActive = true
//                    imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor).isActive = true
//                    if userprofiles[i].image != nil {
//                        imageView.image = userprofiles[i].image!.circularImage(size: CGSize(width: actionView.frame.height, height: actionView.frame.height), frameColor: frameColor)
//                    } else if let url = userprofiles[i].imageURL as? String, !url.isEmpty {
//                        imageView.image = UIImage(named: "user")!.circularImage(size: CGSize(width: actionView.frame.height, height: actionView.frame.height), frameColor: frameColor)
//                        apiManager.downloadImage(url: url) {
//                            image, error in
//                            if error != nil {
//                                print(error!.localizedDescription)
//                            }
//                            if image != nil {
//                                self.userprofiles[i].image = image
//                                UIView.transition(with: imageView,
//                                                  duration: 0.5,
//                                                  options: .transitionCrossDissolve,
//                                                  animations: { imageView.image = image!.circularImage(size: imageView.frame.size, frameColor: self.frameColor) },
//                                                  completion: nil)
//                            }
//                        }
//                    } else {
//                        imageView.image = UIImage(named: "user")!.circularImage(size: CGSize(width: actionView.frame.height, height: actionView.frame.height), frameColor: frameColor)
//                    }
//                }
//                if totalCount > 5 {
//                    let label = UILabel(frame: .zero)
//                    actionView.addSubview(label)
//                    label.translatesAutoresizingMaskIntoConstraints = false
//                    label.numberOfLines = 0
//                    label.text = "еще\n\(totalCount-5)"
//                    label.font = StringAttributes.font(name: StringAttributes.Fonts.Style.Regular, size: 8)
//                    label.textColor = .darkGray
//                    label.backgroundColor = .clear
//                    label.textAlignment = .center
//                    label.heightAnchor.constraint(equalTo: actionView.heightAnchor).isActive = true
//                    label.leadingAnchor.constraint(equalTo: imageViews.last!.trailingAnchor).isActive = true
//                    label.trailingAnchor.constraint(equalTo: actionView.trailingAnchor).isActive = true
//                    label.layer.zPosition = 100
//                }
//                panGesture = UIPanGestureRecognizer(target: self, action: #selector(ResultIndicator.handlePan(recognizer:)))
//                panGesture.delegate = self
//                actionView.addGestureRecognizer(panGesture)
//                tapGesture = UITapGestureRecognizer(target: self, action: #selector(ResultIndicator.handleTap(recognizer:)))
//                tapGesture.delegate = self
//                actionView.addGestureRecognizer(tapGesture)
//            }
//        }
//    }
    var answer: Answer! {
        didSet {
            if !answer.userprofiles.isEmpty {
                if isSelected {
                    if !answer.userprofiles.filter({ $0.ID == UserProfiles.shared.own?.ID }).isEmpty {
                        if let index = answer.userprofiles.firstIndex(where: { $0.ID == UserProfiles.shared.own?.ID }) {
                            if  index != 0  {
                                answer.userprofiles.rearrange(from: index, to: 0)
                            }
                        }
                    } else {
                        answer.userprofiles.insert(UserProfiles.shared.own!, at: 0)
                    }
                }
                
                for i in 0..<answer.userprofiles.count {
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
                    if answer.userprofiles[i].image != nil {
                        imageView.image = answer.userprofiles[i].image!.circularImage(size: CGSize(width: actionView.frame.height, height: actionView.frame.height), frameColor: frameColor)
                    } else if let url = answer.userprofiles[i].imageURL as? String, !url.isEmpty {
                        imageView.image = UIImage(named: "user")!.circularImage(size: CGSize(width: actionView.frame.height, height: actionView.frame.height), frameColor: frameColor)
                        apiManager.downloadImage(url: url) {
                            image, error in
                            if error != nil {
                                print(error!.localizedDescription)
                            }
                            if image != nil {
                                self.answer.userprofiles[i].image = image
                                UIView.transition(with: imageView,
                                                  duration: 0.5,
                                                  options: .transitionCrossDissolve,
                                                  animations: { imageView.image = image!.circularImage(size: imageView.frame.size, frameColor: self.frameColor) },
                                                  completion: nil)
                            }
                        }
                    } else {
                        imageView.image = UIImage(named: "user")!.circularImage(size: CGSize(width: actionView.frame.height, height: actionView.frame.height), frameColor: frameColor)
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
    }
    var isSelected = false {
        didSet {
            //TODO: - Add selected mark
        }
    }
    var value: Int = 0 {
        didSet {
            percentLabel.text = "\(value)%"
            if value > 0, widthConstraint != nil {
//                setNeedsLayout()
                widthConstraint.constant = max(CGFloat(value)*backgroundFrame.frame.width/100, contentView.frame.height)
//                layoutIfNeeded()
            }
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
//    var color: UIColor = K_COLOR_TABBAR {
//        didSet {
//            if backgroundFrame != nil, foregroundFrame != nil {
//                backgroundFrame.backgroundColor = frameColor.withAlphaComponent(0.05)
//                foregroundFrame.backgroundColor = frameColor.withAlphaComponent(0.4)
//            }
//        }
//    }
    
    
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
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
    
    @objc private func handleTap(recognizer: UITapGestureRecognizer) {
        if recognizer.state == .ended {
            if !answer.userprofiles.isEmpty {
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
//                } else {
//                    highlightedImageView = nil
                }
            }
        })
        
        if recognizer.state == .ended || recognizer.state == .cancelled {
            highlightedImageView = nil
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
