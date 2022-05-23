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
    @IBOutlet weak var whiteFrame: UIView!
    @IBOutlet weak var foregroundFrame: UIView!
    @IBOutlet weak var actionView: UIView! {
        didSet {
            actionView.layer.masksToBounds = false
        }
    }
    @IBOutlet weak var percentLabel: UILabel! {
        didSet {
            percentLabel.textColor = mode == .None ? .label : .black
        }
    }
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    @IBOutlet weak var actionViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var label: UILabel! {
        didSet {
            label.alpha = mode == .None ? 1 : 0
            label.text = "no_votes".localized
        }
    }
    @IBOutlet weak var choiceBadge: Icon! {
        didSet {
            choiceBadge.alpha = isSelected ? 1 : 0
            choiceBadge.backgroundColor = .clear
            choiceBadge.isRounded = false
            choiceBadge.iconColor = color
            choiceBadge.scaleMultiplicator = 1.2
            choiceBadge.category = .Choice
        }
    }
    @IBOutlet weak var choiceBadgeTrailingConstraint: NSLayoutConstraint!
    var indexPath: IndexPath!
    private var tapGesture: UITapGestureRecognizer!
    private var panGesture: UIPanGestureRecognizer!
//    private var apiManager: APIManagerProtocol!
    private var color: UIColor = K_COLOR_RED
    private weak var delegate: CallbackObservable!
//    private var highlightedImageView: Avatar? {
//        didSet {
//            if highlightedImageView != nil, highlightedImageView != oldValue {
//                highlightedImageView?.layer.zPosition += 10
//                let constraint = highlightedImageView?.getAllConstraints().filter({ $0.identifier == "centerY" }).first
//                UIView.animate(withDuration: 0.17, delay: 0, options: [.curveEaseInOut], animations: {
//                    self.actionView.setNeedsLayout()
//                    constraint?.constant -= self.actionView.frame.height * 0.9
//                    self.actionView.layoutIfNeeded()
//                    self.highlightedImageView?.transform = CGAffineTransform(scaleX: 1.6, y: 1.6)
//                })
//
//                if oldValue != nil {
//                    let oldConstraint = oldValue!.getAllConstraints().filter({ $0.identifier == "centerY" }).first
//                    oldValue?.layer.zPosition -= 10
//                    UIView.animate(withDuration: 0.1, delay: 0, options: [.curveEaseOut], animations: {
//                        self.actionView.setNeedsLayout()
//                        oldConstraint?.constant += self.actionView.frame.height * 0.9
//                        self.actionView.layoutIfNeeded()
//                        oldValue?.transform = .identity
//                    })
//                }
//            } else if oldValue != nil {
//                oldValue?.layer.zPosition -= 10
//                let oldConstraint = oldValue!.getAllConstraints().filter({ $0.identifier == "centerY" }).first
//                UIView.animate(withDuration: 0.1) {
//                    self.actionView.setNeedsLayout()
//                    oldConstraint?.constant += self.actionView.frame.height * 0.9
//                    self.actionView.layoutIfNeeded()
//                    oldValue?.transform = .identity
//                }
//            }
//        }
//    }
//    private var imageViews: [Avatar] = []
    private var highlightedAvatar: Avatar? {
        didSet {
            if highlightedAvatar != nil, highlightedAvatar != oldValue {
                highlightedAvatar?.layer.zPosition += 10
                let constraint = highlightedAvatar?.getAllConstraints().filter({ $0.identifier == "centerY" }).first
                UIView.animate(withDuration: 0.17, delay: 0, options: [.curveEaseInOut], animations: {
                    self.actionView.setNeedsLayout()
                    constraint?.constant -= self.actionView.frame.height * 0.9
                    self.actionView.layoutIfNeeded()
                    self.highlightedAvatar?.transform = CGAffineTransform(scaleX: 1.6, y: 1.6)
                    guard let label = self.highlightedAvatar?.subviews.filter({ $0 is ArcLabel }).first as? ArcLabel else { return }
                    label.alpha = 1
                })

                if oldValue != nil {
                    let oldConstraint = oldValue!.getAllConstraints().filter({ $0.identifier == "centerY" }).first
                    oldValue?.layer.zPosition -= 10
                    UIView.animate(withDuration: 0.1, delay: 0, options: [.curveEaseOut], animations: {
                        self.actionView.setNeedsLayout()
                        oldConstraint?.constant += self.actionView.frame.height * 0.9
                        self.actionView.layoutIfNeeded()
                        oldValue?.transform = .identity
                        guard let label = oldValue?.subviews.filter({ $0 is ArcLabel }).first as? ArcLabel else { return }
                        label.alpha = 0
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
                    guard let label = oldValue?.subviews.filter({ $0 is ArcLabel }).first as? ArcLabel else { return }
                    label.alpha = 0
                }
            }
        }
    }
    private var avatars: [Avatar] = []
    private var interactionViews: [[UIView: Avatar]] = []
    var answer: Answer!
    private func setupImages() {
        switch mode {
        case .Anon:
            label.alpha = 1
            label.text = answer.totalVotes == 0 ? "no_votes".localized : "\(answer.totalVotes)\n" + "votes".localized
        default:
            guard !answer.voters.isEmpty else { label.alpha = 1; return }
                if isSelected {
                    if !answer.voters.filter({ $0 == Userprofiles.shared.current! }).isEmpty {
                        if let index = answer.voters.firstIndex(where: { $0 == Userprofiles.shared.current!/*Userprofiles.shared.own?.id*/ }) {
                            if  index != 0  {
                                answer.voters.rearrange(from: index, to: 0)
                            }
                        }
                    } else {
                        answer.voters.insert(Userprofiles.shared.current!, at: 0)//(Userprofiles.shared.own!, at: 0)
                    }
                }
                
                for i in 0..<answer.voters.count {
                    if i == 5 {
                        break
                    }
                    let avatar = Avatar(frame: .zero)
                    avatar.layer.zPosition = 10 - CGFloat(i)
                    avatars.append(avatar)
                    actionView.addSubview(avatar)
                    avatar.layer.masksToBounds = false
                    avatar.translatesAutoresizingMaskIntoConstraints = false
                    let centerY = avatar.centerYAnchor.constraint(equalTo: actionView.centerYAnchor)
                    centerY.identifier = "centerY"
                    centerY.isActive = true
                    //                    .isActive = true
                    if i == 0 {
                        if answer.totalVotes > 5 {
                            avatar.leadingAnchor.constraint(equalTo: actionView.leadingAnchor, constant: 4).isActive = true
                        } else {
                            avatar.centerXAnchor.constraint(equalTo: actionView.centerXAnchor).isActive = true
                        }
                    } else {
                        avatar.leadingAnchor.constraint(equalTo: avatars[i-1].leadingAnchor, constant: 8).isActive = true
                    }
                    //                imageView.heightAnchor.constraint(equalTo: actionView.heightAnchor, multiplier: (0.8 - 0)/1.0).isActive = true
                    avatar.heightAnchor.constraint(equalTo: actionView.heightAnchor).isActive = true
                    avatar.widthAnchor.constraint(equalTo: avatar.heightAnchor).isActive = true
                    avatar.darkColor = color.withAlphaComponent(0.5)
                    avatar.lightColor = color.withAlphaComponent(0.5)
                    
                    ///Add arc label with first name
                    let label = ArcLabel()
                    label.angle = 1.65
                    label.text = answer.voters[i].firstName
                    label.font = StringAttributes.font(name: StringAttributes.FontStyle.Regular.rawValue, size: 8)
                    label.textColor = .label
                    avatar.addSubview(label)
                    label.translatesAutoresizingMaskIntoConstraints = false
                    label.alpha = 0
                    NSLayoutConstraint.activate([
                        label.widthAnchor.constraint(equalTo: avatar.widthAnchor, multiplier: 1.6),
                        label.heightAnchor.constraint(equalTo: avatar.heightAnchor, multiplier: 1.6),
                        label.centerXAnchor.constraint(equalTo: avatar.centerXAnchor),
                        label.centerYAnchor.constraint(equalTo: avatar.centerYAnchor)
                    ])
                    if answer.voters[i].image != nil {
                        avatar.imageView.image = answer.voters[i].image!
                    } else if let url = answer.voters[i].imageURL {
                        avatar.imageView.image = UIImage(named: "user")!
                        API.shared.downloadImage(url: url) { progress in
                            //                        print(progress)
                        } completion: { result in
                            switch result {
                            case .success(let image):
                                self.answer.voters[i].image = image
                                Animations.onImageLoaded(imageView: avatar.imageView, image: image)
                                //                            UIView.transition(with: avatar,
                                //                                              duration: 0.5,
                                //                                              options: .transitionCrossDissolve,
                                //                                              animations: { avatar.imageView.image = image },
                                //                                              completion: nil)
                            case .failure(let error):
#if DEBUG
                                print(error.localizedDescription)
#endif
                            }
                        }
                    } else {
                        avatar.imageView.image = UIImage(named: "user")!
                    }
                }
                if answer.totalVotes > 5 {
                    let label = UILabel(frame: .zero)
                    actionView.addSubview(label)
                    label.translatesAutoresizingMaskIntoConstraints = false
                    label.numberOfLines = 0
                    label.text = "\("more".localized)\n\(answer.totalVotes-5)"
                    label.font = StringAttributes.font(name: StringAttributes.Fonts.Style.Regular, size: 9)
                    label.textColor = .label
                    label.backgroundColor = .clear
                    label.textAlignment = .center
                    label.heightAnchor.constraint(equalTo: actionView.heightAnchor).isActive = true
                    label.leadingAnchor.constraint(equalTo: avatars.last!.trailingAnchor).isActive = true
                    label.trailingAnchor.constraint(equalTo: actionView.trailingAnchor).isActive = true
                    label.layer.zPosition = 100
                }
                panGesture = UIPanGestureRecognizer(target: self, action: #selector(ResultIndicator.handlePan(recognizer:)))
                panGesture.delegate = self
                actionView.addGestureRecognizer(panGesture)
                tapGesture = UITapGestureRecognizer(target: self, action: #selector(ResultIndicator.handleTap(recognizer:)))
                tapGesture.delegate = self
                actionView.addGestureRecognizer(tapGesture)
//            }
        }
    }
    var isSelected = false {
        didSet {
            //TODO: - Add selected mark
        }
    }
    var value: Int = 0
    var mode: ChoiceResultCell.Mode = .Stock {
        didSet {
            if mode == .Anon {
                //actionViewConstraint.setMultiplierWithFade(0, duration: 0)
            } else if mode == .None {
                label.alpha = 1
                label.leadingAnchor.constraint(equalTo: actionView.leadingAnchor).isActive = true
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
    
    init(delegate: CallbackObservable, answer: Answer, color: UIColor, isSelected: Bool, mode _mode: ChoiceResultCell.Mode) {
        super.init(frame: .zero)
        self.mode = _mode
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
        guard !backgroundFrame.isNil, !foregroundFrame.isNil, !widthConstraint.isNil else { return }
        backgroundFrame.backgroundColor = .lightGray.withAlphaComponent(0.1)
        foregroundFrame.backgroundColor = color.withAlphaComponent(0.5)//isSelected ? color.withAlphaComponent(0.5) : color.withAlphaComponent(0.35)
        backgroundFrame.cornerRadius = contentView.frame.height / 2
        whiteFrame.cornerRadius = contentView.frame.height / 2
        foregroundFrame.cornerRadius = contentView.frame.height / 2
        self.backgroundFrame.setNeedsLayout()
        self.backgroundFrame.layoutIfNeeded()
        setPercentage(value: nil)
        //            if !isAnimationEnabled {
        //                widthConstraint.constant = value > 0 ? max(CGFloat(value)*backgroundFrame.frame.width/100, contentView.frame.height) : 0
        //            }
        choiceBadgeTrailingConstraint.constant = -backgroundFrame.cornerRadius//backgroundFrame.frame.height / 3
        if isSelected {
            choiceBadge.category = .Choice
        }
        setText()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        percentLabel.textColor = mode == .None ? .label : .black
    }
    
    @objc private func handleTap(recognizer: UITapGestureRecognizer) {
        if recognizer.state == .ended {
            if !answer.voters.isEmpty {
//                let dict = ["users": userprofiles, "total": totalCount, "answerID": answerID] as [String : Any]
                let array = [answer as AnyObject, avatars as AnyObject, indexPath as AnyObject, color as AnyObject]
                delegate?.callbackReceived(array as AnyObject)
            }
        }
    }
    
    @objc private func handlePan(recognizer: UIPanGestureRecognizer) {
        guard avatars.count > 1 else {
            return
        }
        if interactionViews.isEmpty {
            interactionViews.removeAll()
            let v = UIView(frame: avatars[0].frame)
//            v.backgroundColor = .black
            v.layer.zPosition = 200
            actionView.addSubview(v)
            interactionViews.append([v: avatars[0]])

            for i in 1..<avatars.count {
                if let previousView = avatars[i - 1] as? UIView, let previousFrame = previousView.bounds as? CGRect, let currentView = avatars[i] as? UIView, let currentFrame = currentView.bounds as? CGRect{
                    let point = previousView.convert(CGPoint(x: previousFrame.maxX, y: 0), to: currentView)
                    let visibleFrame = CGRect(origin: CGPoint(x: currentView.frame.origin.x + point.x, y: currentView.frame.origin.y), size: CGSize(width: currentFrame.width - point.x, height: currentFrame.height))
                    let v = UIView(frame: visibleFrame)
//                    v.backgroundColor = .red
                    v.layer.zPosition = 200 + CGFloat(i)
                    actionView.addSubview(v)
                    interactionViews.append([v: avatars[i]])
                }
            }
        }
        
        let point = recognizer.location(in: actionView)
        interactionViews.forEach({
            (dict) in
            if let v = dict.keys.first as? UIView, let imageView = dict.values.first {
                if v.frame.contains(point) {
                    if self.highlightedAvatar != imageView {
                        self.highlightedAvatar = imageView
                    }
                }
            }
        })
        
        if recognizer.state == .ended || recognizer.state == .cancelled {
            highlightedAvatar = nil
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
    
    private func setText() {
        let attributedText = NSMutableAttributedString()
        attributedText.append(NSAttributedString(string: "\(value)%", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: isSelected ? StringAttributes.Fonts.Style.Bold : StringAttributes.Fonts.Style.Regular, size: frame.height * 0.27), foregroundColor: .label, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        percentLabel.attributedText = attributedText
//        percentLabel.text = "\(value)%"
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
