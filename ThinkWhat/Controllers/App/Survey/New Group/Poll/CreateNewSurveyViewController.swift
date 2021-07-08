//
//  CreateNewSurveyViewController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 27.10.2020.
//  Copyright © 2020 Pavel Bukharov. All rights reserved.
//

import UIKit
import Vision

class NewPollController: UIViewController, UINavigationControllerDelegate {
    
    deinit {
        print("***CreateNewSurveyViewController deinit***")
    }
    
    //Sequence of stages to post new survey
    private enum Stage: Int {
        case Category, Anonymity, Privacy, Votes, Title, Question, Hyperlink, Images, Answers, Post
    }
    
    private var stage: Stage = .Category {
        didSet {
            maximumStage = stage
            moveToNextStage()
        }
    }
    
    private var maximumStage: Stage = .Category {
        didSet {
            maximumStage = stage.rawValue <= oldValue.rawValue ? oldValue : maximumStage//Stage(rawValue: maximumStage.rawValue + 1) ?? .Post
        }
    }
    
    private var isViewSetupCompleted = false
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var contentView: UIView!
    
    
    //MARK: - Category
    var category: SurveyCategory? {
        didSet {
            setTitle()
            if category != nil {
                categoryTitle.alpha = 1
                stage = .Anonymity
                categoryIcon.color = category!.tagColor ?? selectedColor
                categoryIcon.category = SurveyCategoryIcon.Category(rawValue: category!.ID) ?? .Null
                categoryTitle.text = category!.title.uppercased()
            }
        }
    }
    
    @IBOutlet weak var categoryTitle: UILabel! {
        didSet {
            categoryTitle.alpha = 0
            if category == nil {
                categoryTitle.text = "РАЗДЕЛ"
            }
        }
    }
    
    @IBOutlet weak var categoryIcon: CircleButton! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(NewPollController.iconTapped(gesture:)))
            categoryIcon.addGestureRecognizer(tap)
            //            categoryIcon.icon.isFramed = false
            categoryIcon.icon.alpha = 0
            categoryIcon.state = .Off
            categoryIcon.color = selectedColor
            categoryIcon.text = "РАЗДЕЛ"
            categoryIcon.category = .Category_RU
        }
    }
    
    @IBOutlet weak var categoryLabel: UILabel!
    
    
    //MARK: - Anon
    var isAnonymous = false {
        didSet {
            anonTitle.alpha = 1
            stage = .Privacy
            anonIcon.color = selectedColor
            anonIcon.category = isAnonymous ? SurveyCategoryIcon.Category.Anon : SurveyCategoryIcon.Category.AnonDisabled//SurveyCategoryIcon.Category(rawValue: category!.ID) ?? .Null
        }
    }
    
    @IBOutlet weak var anonTitle: UILabel! {
        didSet {
            anonTitle.alpha = 0
        }
    }
    
    @IBOutlet weak var anonIcon: CircleButton! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(NewPollController.iconTapped(gesture:)))
            anonIcon.addGestureRecognizer(tap)
            anonIcon.icon.alpha = 0
            //            anonIcon.backgroundColor = .clear
            anonIcon.state      = .Off
            anonIcon.category   = .Anon
            anonIcon.color      = selectedColor
        }
    }
    
    @IBOutlet weak var anonLabel: UILabel! {
        didSet {
            anonLabel.alpha = 0
        }
    }
    
    
    
    
    //MARK: - Privacy
    var isPrivate = false {
        didSet {
            privacyTitle.alpha = 1
            stage = .Votes
        }
    }
    
    @IBOutlet weak var privacyTitle: UILabel! {
        didSet {
            privacyTitle.alpha = 0
        }
    }
    
    @IBOutlet weak var privacyIcon: CircleButton! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(NewPollController.iconTapped(gesture:)))
            privacyIcon.addGestureRecognizer(tap)
            privacyIcon.icon.alpha = 0
            //            privacyIcon.backgroundColor = .clear
            privacyIcon.state       = .Off
            privacyIcon.category    = .Locked
            privacyIcon.color       = selectedColor
        }
    }
    
    @IBOutlet weak var privacyLabel: UILabel! {
        didSet {
            privacyLabel.alpha = 0
        }
    }
    
    
    //MARK: - Votes
    var votesCount = 100 {
        didSet {
            stage = .Title
        }
    }
    
    @IBOutlet weak var votesLabel: UILabel! {
        didSet {
            votesLabel.alpha = 0
        }
    }
    
    @IBOutlet weak var votesIcon: CircleButton! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(NewPollController.iconTapped(gesture:)))
            votesIcon.addGestureRecognizer(tap)
            votesIcon.icon.alpha = 0
            //            votesIcon.backgroundColor = .clear
            votesIcon.state       = .Off
            votesIcon.category    = .Text
            votesIcon.color       = selectedColor
            votesIcon.text        = "100"
        }
    }
    
    @IBOutlet weak var votesTitle: UILabel! {
        didSet {
            votesTitle.alpha = 0
        }
    }
    
    
    //MARK: - Title
    var questionTitle = "" {
        didSet {
            stage = .Question
        }
    }
    
    @IBOutlet weak var titleIcon: CircleButton! {
        didSet {
            titleIcon.icon.alpha = 0
            //            titleIcon.backgroundColor = .clear
            titleIcon.accessibilityIdentifier   = "titleIcon"
            titleIcon.state                     = .Off
            titleIcon.color                     = selectedColor
            titleIcon.category                  = .Title_RU
            //            titleIcon.text                      = "ТИТУЛ"
            let tap = UITapGestureRecognizer(target: self, action: #selector(NewPollController.iconTapped(gesture:)))
            titleIcon.addGestureRecognizer(tap)
        }
    }
    
    @IBOutlet weak var titleLabel: PaddingLabel! {
        didSet {
            //            titleLabel.backgroundColor = .clear
            //            titleLabel.textColor = .white
            titleLabel.alpha = 0
            titleLabel.accessibilityIdentifier = "Title"
            titleLabel.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(NewPollController.iconTapped(gesture:)))
            titleLabel.addGestureRecognizer(tap)
        }
    }
    
    
    //MARK: - Question
    var question = "" {
        didSet {
            stage = .Hyperlink
        }
    }
    
    @IBOutlet weak var questionIcon: CircleButton! {
        didSet {
            questionIcon.icon.alpha = 0
            //            questionIcon.backgroundColor = .clear
            questionIcon.accessibilityIdentifier    = "questionIcon"
            questionIcon.state                      = .Off
            questionIcon.color                      = selectedColor
            questionIcon.category                   = .Details_RU
            //            questionIcon.text                       = "ВОПРОС"
            let tap = UITapGestureRecognizer(target: self, action: #selector(NewPollController.iconTapped(gesture:)))
            questionIcon.addGestureRecognizer(tap)
        }
    }
    
    @IBOutlet weak var questionLabel: PaddingLabel! {
        didSet {
            questionLabel.alpha = 0
            //            questionLabel.textColor = .white
            questionLabel.accessibilityIdentifier = "Question"
            let tap = UITapGestureRecognizer(target: self, action: #selector(NewPollController.iconTapped(gesture:)))
            questionLabel.isUserInteractionEnabled = true
            questionLabel.addGestureRecognizer(tap)
        }
    }
    
    
    //MARK: - Hyperlink
    var hyperlink: URL? {
        didSet {
            stage = .Images
        }
    }
    
    @IBOutlet weak var hyperlinkIcon: CircleButton! {
        didSet {
            hyperlinkIcon.icon.alpha = 0
            //            hyperlinkIcon.backgroundColor = .clear
            hyperlinkIcon.state     = .Off
            hyperlinkIcon.color     = selectedColor
            hyperlinkIcon.category  = .Hyperlink_RU
            //            hyperlinkIcon.text      = "ССЫЛКА"
            let tap = UITapGestureRecognizer(target: self, action: #selector(NewPollController.iconTapped(gesture:)))
            hyperlinkIcon.addGestureRecognizer(tap)
        }
    }
    
    @IBOutlet weak var hyperlinkLabel: PaddingLabel! {
        didSet {
            hyperlinkLabel.alpha = 0
            //            hyperlinkLabel.textColor = .white
            hyperlinkLabel.accessibilityIdentifier = "Hyperlink"
            let tap = UITapGestureRecognizer(target: self, action: #selector(NewPollController.iconTapped(gesture:)))
            hyperlinkLabel.isUserInteractionEnabled = true
            hyperlinkLabel.addGestureRecognizer(tap)
            hyperlinkLabel.attributedText = hyperlinkPlaceholder
        }
    }
    
    
    //MARK: - Images
    var images: [Int: [UIImage: String]] = [:] {
        didSet {
            if stage == .Images, oldValue.count != images.count, imagesHeaderIcon != nil {
                let destinationPath = (imagesHeaderIcon.icon.getLayer(images.isEmpty ? .Skip_RU : .Next_RU) as! CAShapeLayer).path
                let pathAnim = Animations.get(property: .Path, fromValue: (imagesHeaderIcon.icon.icon as! CAShapeLayer).path, toValue: destinationPath, duration: 0.5, delay: 0.75, delegate: self, isRemovedOnCompletion: false)
                pathAnim.setValue(imagesHeaderIcon.icon.icon as! CAShapeLayer, forKey: "layer")
                pathAnim.setValue(destinationPath, forKey: "destinationPath")
//                pathAnim.setValue({ self.stage = .Answers }, forKey: "completionBlock")
                imagesHeaderIcon.icon.icon.add(pathAnim, forKey: nil)
            }
            //            stage = .Answers
        }
    }
    
    @IBOutlet weak var imagesHeaderIcon: CircleButton! {
        didSet {
            imagesHeaderIcon.icon.alpha = 0
            //            imagesHeaderIcon.backgroundColor = .clear
            imagesHeaderIcon.state      = .Off
            imagesHeaderIcon.color      = selectedColor
            imagesHeaderIcon.category   = .Picture
            let tap = UITapGestureRecognizer(target: self, action: #selector(NewPollController.iconTapped(gesture:)))
            imagesHeaderIcon.addGestureRecognizer(tap)
        }
    }
    @IBOutlet weak var imagesLabel: PaddingLabel! {
        didSet {
            imagesLabel.alpha = 0
            imagesLabel.attributedText = imagesPlaceholder
        }
    }
    @IBOutlet weak var imagesStackView: UIStackView!
    @IBOutlet weak var image_1: UIView!
    @IBOutlet weak var image_2: UIView!
    @IBOutlet weak var image_3: UIView!
    @IBOutlet weak var imagesStackViewBottom: NSLayoutConstraint!
    private var stackImages: [UIView] = []
    private var highlitedImage: [UIView: UIImageView] = [:]
    private lazy var imageEditingList: ImageEditingListTableViewController = {
        let vc = Storyboards.controllers.instantiateViewController(withIdentifier: "ImageEditingListTableViewController") as! ImageEditingListTableViewController
        let tap = UITapGestureRecognizer(target: self, action: #selector(NewPollController.iconTapped(gesture:)))
        tap.cancelsTouchesInView = false
        vc.view.addGestureRecognizer(tap)
        vc.delegate = self
        return vc
    } ()
    //Use for iOS 11, 12
    private var imageObservationRequest: VNCoreMLRequest?
    lazy private var imagesModel: MobileNet = {
        return MobileNet()
    } ()
    
    //MARK: - Answers
    private var answers: [String] = [""] {
        didSet {
            if oldValue.count != answers.count {
                UIView.animate(withDuration: 0.2) {
                    self.tableView.setNeedsLayout()
                    self.tableViewHeight.constant = CGFloat(self.answers.count) * self.answerRowHeight + self.answerRowHeight/2
                    self.tableView.layoutIfNeeded()
                }
            }
        }
    }
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var answerIcon: CircleButton! {
        didSet {
            answerIcon.icon.alpha = 0
            //            imagesHeaderIcon.backgroundColor = .clear
            answerIcon.state      = .Off
            answerIcon.color      = selectedColor
            answerIcon.category   = .Answer
            let tap = UITapGestureRecognizer(target: self, action: #selector(NewPollController.iconTapped(gesture:)))
            answerIcon.addGestureRecognizer(tap)
        }
    }
    @IBOutlet weak var answerContainer: UIView! {
        didSet {
            answerContainer.alpha = 0
        }
    }
    
    //MARK: - Interface properties
    @IBInspectable var lineWidth: CGFloat = 5 {
        didSet {
            NotificationCenter.default.post(name: Notifications.UI.LineWidth, object: lineWidth)
        }
    }
    
    @IBInspectable private var lastContentOffset: CGFloat = 0
    
    @IBInspectable private var lineAnimationDuration = 0.5
    
    //    var isNavigationBarHidden = false
    
    //Color based on selected category
    var selectedColor = K_COLOR_RED {
        didSet {
            anonIcon.color                  = selectedColor
            privacyIcon.color               = selectedColor
            votesIcon.color                 = selectedColor
            titleIcon.color                 = selectedColor
            titleLabel.backgroundColor      = selectedColor.withAlphaComponent(0.2)
            questionIcon.color              = selectedColor
            questionLabel.backgroundColor   = selectedColor.withAlphaComponent(0.2)
            hyperlinkIcon.color             = selectedColor
            hyperlinkLabel.backgroundColor  = selectedColor.withAlphaComponent(0.2)
            imagesHeaderIcon.color          = selectedColor
            imagesLabel.backgroundColor     = selectedColor.withAlphaComponent(0.2)
            answerIcon.color          = selectedColor
            answerContainer.backgroundColor     = selectedColor.withAlphaComponent(0.2)
            tableView.reloadData()
            lines.map({$0.layer.strokeColor = selectedColor.withAlphaComponent(0.2).cgColor})
        }
    }
    
    lazy var hyperlinkPlaceholder: NSMutableAttributedString = {
        let attrString = NSMutableAttributedString()
        attrString.append(NSAttributedString(string: "Добавьте ссылку", attributes: StringAttributes.getAttributes(font: StringAttributes.getFont(name: StringAttributes.Fonts.Style.Semibold, size: 25), foregroundColor: .darkGray, backgroundColor: .clear)))
        attrString.append(NSAttributedString(string: "\n(не обязательное поле)", attributes: StringAttributes.getAttributes(font: StringAttributes.getFont(name: StringAttributes.Fonts.Style.Regular, size: 14), foregroundColor: .gray, backgroundColor: .clear)))
        return attrString
    }()
    
    lazy var imagesPlaceholder: NSMutableAttributedString = {
        let attrString = NSMutableAttributedString()
        attrString.append(NSAttributedString(string: "Добавьте картинки", attributes: StringAttributes.getAttributes(font: StringAttributes.getFont(name: StringAttributes.Fonts.Style.Semibold, size: 25), foregroundColor: .darkGray, backgroundColor: .clear)))
        attrString.append(NSAttributedString(string: "\n(не обязательное поле)", attributes: StringAttributes.getAttributes(font: StringAttributes.getFont(name: StringAttributes.Fonts.Style.Regular, size: 14), foregroundColor: .gray, backgroundColor: .clear)))
        return attrString
    }()
    
    //Array of colored lines between stages
    private var lines: [Line] = []
    
    //Corner for labels
    private var cornerRadius: CGFloat! {
        didSet {
            titleLabel.layer.cornerRadius = cornerRadius
            questionLabel.layer.cornerRadius = cornerRadius
            hyperlinkLabel.layer.cornerRadius = cornerRadius
            imagesLabel.layer.cornerRadius = cornerRadius
            answerContainer.layer.cornerRadius = cornerRadius
        }
    }
    //Get-only color
    var color: UIColor {
        get {
            return selectedColor
        }
    }
    private var answerRowHeight: CGFloat = 50
    private var labelTopInset: CGFloat = 0 {
        didSet {
            titleLabel.topInset = labelTopInset
            questionLabel.topInset = labelTopInset
            hyperlinkLabel.topInset = labelTopInset
            imagesLabel.topInset = labelTopInset
        }
    }
    
    private var imagePicker = UIImagePickerController ()
    
    //Where to place selected image
    var imagePosition = 0 {
        didSet {
            print(imagePosition)
        }
    }
    
    //Indicates if effectView is on screen
    private var effectView: UIVisualEffectView?
    //    private var isEffectViewActive = false
    
    //MARK: - VC Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self as UITableViewDelegate
        tableView.dataSource = self
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.navigationBar.topItem?.rightBarButtonItem?.tintColor = K_COLOR_RED
        
        if #available(iOS 13, *) {
            
        } else {
            
            guard let visionModel = try? VNCoreMLModel(for: imagesModel.model) else {
                fatalError("Error")
            }
            
            imageObservationRequest = VNCoreMLRequest(model: visionModel, completionHandler: {
                request, error in
                if let observations = request.results as? [VNClassificationObservation] {
                    let top = observations.filter { $0.confidence >= 0.6 }.map {print("identifier: \($0.identifier), confidence: \($0.confidence)") }
                    //                    top3.map { print("identifier: \($0.identifier), confidence: \($0.confidence)") }
                }
            })
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let nc = navigationController as? NavigationControllerPreloaded {
            nc.isShadowed = true
            nc.navigationBar.isTranslucent = false
//            nc.navigationBar.tintColor = .black
            //            if isNavigationBarHidden {
            //                nc.setNavigationBarHidden(true, animated: true)
            //            }
        }
        
        if !isViewSetupCompleted {
            
            view.setNeedsLayout()
            view.layoutIfNeeded()
            
            lineWidth = categoryIcon.bounds.height / 11.75//0.75
            
            isViewSetupCompleted = true
            
            labelTopInset = categoryIcon.frame.height*0.35
            
            imagesStackViewBottom.constant -= lineWidth
            imagesStackView.setNeedsLayout()
            imagesStackView.layoutIfNeeded()
            image_1.cornerRadius = image_1.frame.width / 2
            image_2.cornerRadius = image_1.frame.width / 2
            image_3.cornerRadius = image_1.frame.width / 2
            
            stackImages = [image_1, image_2, image_3]
            stackImages.map {
                v in
                let addButton = SurveyCategoryIcon.getIcon(frame: v.frame, category: .Plus, backgroundColor: .clear, pathColor: .darkGray)
                addButton.accessibilityIdentifier = "addImage"
                addButton.addEquallyTo(to: v, multiplier: 0.5)
                let tap = UITapGestureRecognizer(target: self, action: #selector(NewPollController.iconTapped(gesture:)))
                addButton.addGestureRecognizer(tap)
                v.transform = CGAffineTransform.init(scaleX: 0.7, y: 0.7)
                v.alpha = 0
            }
            answerRowHeight = categoryIcon.frame.height
            tableView.reloadData()
            tableViewHeight.constant = CGFloat(answers.count) * answerRowHeight + answerRowHeight/2
        }
        
        images.compactMap {
            dict in
            var container: UIView!
            if dict.key == 0 {
                container = image_1
            } else if dict.key == 1 {
                container = image_2
            } else if dict.key == 2 {
                container = image_3
            }
            
            if container != nil, let image = dict.value.keys.first {
                let imageViews  = container.subviews.filter { $0 is UIImageView } as! [UIImageView]
                var imagesFound     = !imageViews.isEmpty
                
                //Disable tap for +
                //                container.subviews.filter { $0 is SurveyCategoryIcon }.first?.isUserInteractionEnabled = false
                
                if imagesFound {
                    imageViews.map {
                        imageView in
                        
                        if imageView.image != image {
                            imageView.image = image
                        }
                    }
                    
                } else {
                    
                    let imageView = UIImageView(frame: container.frame)
                    imageView.isUserInteractionEnabled = true
                    imageView.image = image
                    imageView.contentMode = UIView.ContentMode.scaleAspectFill
                    imageView.layer.masksToBounds = true
                    imageView.addEquallyTo(to: container, multiplier: 0.85)
                    container.layoutSubviews()
                    imageView.layer.cornerRadius = imageView.frame.height / 2
                    
                    let tap = UITapGestureRecognizer(target: self, action: #selector(NewPollController.iconTapped(gesture:)))
                    imageView.addGestureRecognizer(tap)
                    
                    let press = UILongPressGestureRecognizer(target: self, action: #selector(NewPollController.viewPressed(gesture:)))
                    press.minimumPressDuration = 0.25
                    imageView.addGestureRecognizer(press)
                    
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if cornerRadius == nil {
            cornerRadius = view.frame.width / 20
        }
        scrollView.contentSize.height = 2400
        
        if category == nil {
            categoryIcon.present(completionBlocks: [{
                self.categoryIcon.state = .On
                }])
        }
        
        ////        delay(seconds: 3){
        //            let icon = self.categoryIcon.icon.copyView() as! SurveyCategoryIcon
        //            self.contentView.addSubview(icon)
        ////
        ////        }
        ////
        //
        //        let toValue = (icon.getLayer(SurveyCategoryIcon.Category.Computers)  ! CAShapeLayer).path
        //        delay(seconds: 0.5){
        //
        //
        //            let pathAnim        = CABasicAnimation(keyPath: "path")
        //            pathAnim.fromValue  = (icon.icon as! CAShapeLayer).path
        //            pathAnim.toValue    = toValue
        //            pathAnim.duration = 0.3
        //            pathAnim.timingFunction = CAMediaTimingFunction.init(name: CAMediaTimingFunctionName.easeInEaseOut)
        //
        //            icon.icon.add(pathAnim, forKey: nil)
        //            (icon.icon as! CAShapeLayer).path = toValue
        //        }
        
    }
    
    //MARK: - UI Functions
    private func moveToNextStage() {
        
        var initialIcon:            CircleButton!
        var destinationIcon:        CircleButton!
        //lineCompletionBlocks - used in animationDidStop()
        var lineCompletionBlocks:   [Closure] = []
        var animationBlocks:        [Closure] = []
        var completionBlocks:       [Closure] = []
        
        func animateTransition(initialIcon: CircleButton, destinationIcon: CircleButton, lineCompletionBlocks: [Closure], animationBlocks animations: [Closure], completionBlocks completion: [Closure], animationDuration: TimeInterval?) {
            
            let line     = drawLine(fromView: initialIcon, toView: destinationIcon, lineCap: .round)
            let lineAnim = getLineAnimation(line: line)
            let duration = animationDuration ?? lineAnimationDuration
            
            contentView.layer.insertSublayer(line.layer, at: 0)
            lineAnim.delegate = self
            lineAnim.setValue(lineCompletionBlocks, forKey: "completionBlocks")
            line.layer.add(lineAnim, forKey: "animEnd")
            destinationIcon.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            
            UIView.animate(withDuration: duration, delay: lineAnimationDuration * 0.55, options: [.curveEaseInOut], animations:
                {
                    animations.map { $0() }
                    destinationIcon.alpha = 1
                    destinationIcon.transform = .identity
            }) {
                _ in
                completion.map({ $0() })
            }
            
            line.layer.strokeEnd = 1
            
        }
        
        func animateTransition(lineStart: CGPoint, lineEnd: CGPoint, initialIcon: CircleButton, destinationIcon: CircleButton, lineCompletionBlocks: [Closure], animationBlocks animations: [Closure], completionBlocks completion: [Closure], animationDuration: TimeInterval?) {
            
            let line     = drawLine(fromPoint: lineStart, endPoint: lineEnd, lineCap: .square)
            let lineAnim = getLineAnimation(line: line)
            let duration = animationDuration ?? lineAnimationDuration
            
            contentView.layer.insertSublayer(line.layer, at: 0)
            lineAnim.delegate = self
            lineAnim.setValue(lineCompletionBlocks, forKey: "completionBlocks")
            line.layer.add(lineAnim, forKey: "animEnd")
            //            destinationIcon.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            
            UIView.animate(withDuration: duration, delay: lineAnimationDuration * 0.55, options: [.curveEaseInOut], animations:
                { animations.map { $0() }}) {
                _ in
                completion.map({ $0() })
            }
            
            line.layer.strokeEnd = 1
        }
        
        func drawLine(fromView: UIView, toView: UIView, lineCap: CAShapeLayerLineCap) -> Line {
            let line = Line()
            line.path = UIBezierPath()
            
            let startPoint = contentView.convert(fromView.center, to: view)//fromView.convert(fromView.center, to: contentView)
            line.path.move(to: startPoint)
            
            let endPoint = contentView.convert(toView.center, to: view)//toView.convert(toView.center, to: contentView)
            line.path.addLine(to: endPoint)
            
            
            let interfaceDirection = UIView.userInterfaceLayoutDirection(for: UISemanticContentAttribute.unspecified)
            let path = interfaceDirection == .rightToLeft ? line.path.reversing() : line.path
            
            line.layer.strokeStart = 0
            line.layer.strokeEnd = 0
            line.layer.lineWidth = lineWidth
            line.layer.strokeColor = selectedColor.withAlphaComponent(0.2).cgColor//K_COLOR_RED.withAlphaComponent(0.1).cgColor
            line.layer.lineCap = lineCap
            
            line.layer.path = path.cgPath
            lines.append(line)
            return line
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
            line.layer.strokeColor = selectedColor.withAlphaComponent(0.2).cgColor//K_COLOR_RED.withAlphaComponent(0.1).cgColor
            line.layer.lineCap = lineCap
            
            line.layer.path = path.cgPath
            lines.append(line)
            return line
        }
        
        func getLineAnimation(line: Line) -> CAAnimationGroup {
            let strokeEndAnimation      = CABasicAnimation(path: #keyPath(CAShapeLayer.strokeEnd), fromValue: line.layer.strokeEnd, toValue: 1, duration: lineAnimationDuration)
            //            let strokeWidthAnimation    = CAKeyframeAnimation(keyPath:"lineWidth")
            //            strokeWidthAnimation.values   = [lineWidth * 2, lineWidth]
            //            strokeWidthAnimation.keyTimes = [0, 1]
            //            strokeWidthAnimation.duration = lineAnimationDuration
            //            let pathFillColorAnim      = CAKeyframeAnimation(keyPath:"strokeColor")
            //            pathFillColorAnim.values   = [selectedColor.withAlphaComponent(0.8).cgColor, selectedColor.withAlphaComponent(0.2).cgColor]
            //            pathFillColorAnim.keyTimes = [0, 1]
            //            pathFillColorAnim.duration = lineAnimationDuration
            
            let groupAnimation = CAAnimationGroup()
            groupAnimation.animations = [strokeEndAnimation]//, strokeWidthAnimation, pathFillColorAnim]
            groupAnimation.duration = lineAnimationDuration
            
            return groupAnimation
        }
        
        func reveal(view animatedView: UIView, duration: TimeInterval, completionBlocks: [Closure]) {
            
            let circlePathLayer = CAShapeLayer()
            
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
            maskLayerAnimation.isRemovedOnCompletion = false
            if !completionBlocks.isEmpty {
                maskLayerAnimation.delegate = self
                maskLayerAnimation.setValue(completionBlocks, forKey: "maskCompletionBlocks")
            }
            
            circlePathLayer.add(maskLayerAnimation, forKey: "path")
            circlePathLayer.path = toPath
            
        }
        
        guard stage.rawValue >= maximumStage.rawValue else { return }
        
        switch stage {
        case .Category:
            
            print("Do nothing")
            
        case .Anonymity:
            
            initialIcon     = categoryIcon
            destinationIcon = anonIcon
            animationBlocks.append {
                self.anonLabel.alpha = 1
            }
            var startPoint = contentView.convert(initialIcon.center, to: view)
            let delta = (initialIcon.frame.size.height / 4)
            startPoint.x -= delta
            startPoint.y += delta//initialIcon.frame.size.height / 2
            var endPoint = contentView.convert(destinationIcon.center, to: view)
            endPoint.x += delta
            endPoint.y -= delta
            delay(seconds: lineAnimationDuration * 0.4) {
                self.anonIcon.present(completionBlocks: [{
                    self.anonIcon.state = .On
                    //                    self.performSegue(withIdentifier: Segues.App.NewSurveyToAnonimitySelection, sender: nil)
                    }])
            }
            completionBlocks.append {
                delay(seconds: 0.2) { self.performSegue(withIdentifier: Segues.App.NewSurveyToAnonimitySelection, sender: nil) }
            }
            animateTransition(lineStart: startPoint, lineEnd: endPoint, initialIcon: initialIcon, destinationIcon: destinationIcon, lineCompletionBlocks: lineCompletionBlocks, animationBlocks: animationBlocks, completionBlocks: completionBlocks, animationDuration: nil)
            
            //            animateTransition(initialIcon: initialIcon, destinationIcon: destinationIcon, lineCompletionBlocks: lineCompletionBlocks, animationBlocks: animationBlocks, completionBlocks: completionBlocks, animationDuration: nil)
            
        case .Privacy:
            
            initialIcon     = anonIcon
            destinationIcon = privacyIcon
            animationBlocks.append {
                self.privacyLabel.alpha = 1
            }
            
            var startPoint = contentView.convert(initialIcon.center, to: view)
            let delta = (initialIcon.frame.size.height / 2)
            startPoint.x += delta
            var endPoint = contentView.convert(destinationIcon.center, to: view)
//            delay(seconds: lineAnimationDuration * 0.1) {
                self.privacyIcon.present(completionBlocks: [{
                    self.privacyIcon.state = .On
                    //                    self.performSegue(withIdentifier: Segues.App.NewSurveyToPrivacySelection, sender: nil)
                    }])
//            }
            completionBlocks.append {
                //                delay(seconds: 0.2) { self.performSegue(withIdentifier: Segues.App.NewSurveyToPrivacySelection, sender: nil) }
                self.performSegue(withIdentifier: Segues.App.NewSurveyToPrivacySelection, sender: nil)
            }
            animateTransition(lineStart: startPoint, lineEnd: endPoint, initialIcon: initialIcon, destinationIcon: destinationIcon, lineCompletionBlocks: lineCompletionBlocks, animationBlocks: animationBlocks, completionBlocks: completionBlocks, animationDuration: lineAnimationDuration * 1.3)
            
        case .Votes:
            
            initialIcon     = privacyIcon
            destinationIcon = votesIcon
            animationBlocks.append {
                self.votesTitle.alpha = 1
                self.votesLabel.alpha = 1
            }
            
            var startPoint = contentView.convert(initialIcon.center, to: view)
            let delta = (initialIcon.frame.size.height / 4)
            startPoint.x -= delta
            startPoint.y += delta//initialIcon.frame.size.height / 2
            var endPoint = contentView.convert(destinationIcon.center, to: view)
            endPoint.x += delta
            endPoint.y -= delta
            delay(seconds: lineAnimationDuration * 0.45) {
                self.votesIcon.present(completionBlocks: [{
                    self.votesIcon.state = .On
                    //                    self.performSegue(withIdentifier: Segues.App.NewSurveyToVotesCountViewController, sender: nil)
                    }])
            }
            completionBlocks.append {
                delay(seconds: 0.2) { self.performSegue(withIdentifier: Segues.App.NewSurveyToVotesCountViewController, sender: nil) }
            }
            animateTransition(lineStart: startPoint, lineEnd: endPoint, initialIcon: initialIcon, destinationIcon: destinationIcon, lineCompletionBlocks: lineCompletionBlocks, animationBlocks: animationBlocks, completionBlocks: completionBlocks, animationDuration: nil)
            
        case .Title:
            
            initialIcon     = votesIcon
            destinationIcon = titleIcon
            
            let scrollPoint = contentView.convert(destinationIcon.frame.origin, to: scrollView).y - initialIcon.bounds.height / 4.25// - navigationBarHeight / 2.5
            
            lineCompletionBlocks.append {
                self.scrollToPoint(y: scrollPoint, duration: 0.3, delay: 0, completionBlocks: [{ reveal(view: self.titleLabel, duration: 0.3, completionBlocks: []) }])
            }
            delay(seconds: lineAnimationDuration * 0.4) {
                self.titleIcon.present(completionBlocks: [{ self.titleIcon.state = .On }])
            }
            
            completionBlocks.append {
                delay(seconds: 0.75) { self.performSegue(withIdentifier: Segues.App.NewSurveyToTypingViewController, sender: self.titleIcon) }
            }
            
            var startPoint = contentView.convert(initialIcon.center, to: view)
            let delta = (initialIcon.frame.size.height / 2)
            startPoint.y += delta
            var endPoint = contentView.convert(destinationIcon.center, to: view)
            endPoint.y -= delta
            animateTransition(lineStart: startPoint, lineEnd: endPoint, initialIcon: initialIcon, destinationIcon: destinationIcon, lineCompletionBlocks: lineCompletionBlocks, animationBlocks: animationBlocks, completionBlocks: completionBlocks, animationDuration: nil)
            
        case .Question:
            
            initialIcon     = titleIcon
            destinationIcon = questionIcon
            
            let scrollPoint = contentView.convert(destinationIcon.frame.origin, to: scrollView).y - initialIcon.bounds.height / 4.25// - navigationBarHeight / 2.5
            
            lineCompletionBlocks.append {
                self.scrollToPoint(y: scrollPoint, duration: 0.3, delay: 0, completionBlocks: [{ reveal(view: self.questionLabel, duration: 0.3, completionBlocks: []) }])
            }
            delay(seconds: lineAnimationDuration * 0.1) {
                self.questionIcon.present(completionBlocks: [{ self.questionIcon.state = .On }])
            }
            
            completionBlocks.append {
                delay(seconds: 1) { self.performSegue(withIdentifier: Segues.App.NewSurveyToTypingViewController, sender: self.questionIcon) }
            }
            
            let startPoint = CGPoint(x: contentView.frame.width/2, y: contentView.convert(titleLabel.frame.origin, to: scrollView).y + titleLabel.frame.height + lineWidth/2)
            let delta = (initialIcon.frame.size.height / 2)
            var endPoint = contentView.convert(destinationIcon.center, to: scrollView)
            endPoint.y -= delta
            animateTransition(lineStart: startPoint, lineEnd: endPoint, initialIcon: initialIcon, destinationIcon: destinationIcon, lineCompletionBlocks: lineCompletionBlocks, animationBlocks: animationBlocks, completionBlocks: completionBlocks, animationDuration: nil)
            
        case .Hyperlink:
            initialIcon     = questionIcon
            destinationIcon = hyperlinkIcon
            
            let scrollPoint = contentView.convert(destinationIcon.frame.origin, to: scrollView).y - initialIcon.bounds.height / 4.25// - navigationBarHeight / 2.5
            
            lineCompletionBlocks.append {
                self.scrollToPoint(y: scrollPoint, duration: 0.3, delay: 0, completionBlocks: [{ reveal(view: self.hyperlinkLabel, duration: 0.3, completionBlocks: []) }])
            }
//            delay(seconds: lineAnimationDuration * 0.1) {
                self.hyperlinkIcon.present(completionBlocks: [{ self.questionIcon.state = .On }])
//            }
            
            completionBlocks.append {
                delay(seconds: 1.25) { self.performSegue(withIdentifier: Segues.App.NewSurveyToHyperlinkViewController, sender: nil) }
            }
            
            let startPoint = CGPoint(x: contentView.frame.width/2, y: contentView.convert(questionLabel.frame.origin, to: scrollView).y + questionLabel.frame.height + lineWidth/2)
            let delta = (initialIcon.frame.size.height / 2)
            var endPoint = contentView.convert(destinationIcon.center, to: scrollView)
            endPoint.y -= delta
            animateTransition(lineStart: startPoint, lineEnd: endPoint, initialIcon: initialIcon, destinationIcon: destinationIcon, lineCompletionBlocks: lineCompletionBlocks, animationBlocks: animationBlocks, completionBlocks: completionBlocks, animationDuration: nil)
        case .Images:
            initialIcon     = hyperlinkIcon
            destinationIcon = imagesHeaderIcon
            
            let scrollPoint = contentView.convert(destinationIcon.frame.origin, to: scrollView).y - initialIcon.bounds.height / 4.25// - navigationBarHeight / 2.5
            
            lineCompletionBlocks.append {
                self.scrollToPoint(y: scrollPoint, duration: 0.3, delay: 0, completionBlocks: [{ reveal(view: self.imagesLabel, duration: 0.3, completionBlocks: [{
                    delay(seconds: 0.25) {
                        UIView.transition(with: self.imagesLabel, duration: 0.2, options: .transitionCrossDissolve, animations: {
                            self.imagesLabel.text = ""
                        }) {
                            _ in
                            self.stackImages.map {
                                v in
                                if let i = self.stackImages.firstIndex(of: v), let delay = Double(exactly: i) {
                                    UIView.animate(withDuration: 0.2, delay: delay * 0.1, animations: {
                                        v.transform = .identity
                                        v.alpha = 1 })
                                }
                            }
                            let destinationPath = (self.imagesHeaderIcon.icon.getLayer(.Skip_RU) as! CAShapeLayer).path
                            let pathAnim = Animations.get(property: .Path, fromValue: (self.imagesHeaderIcon.icon.icon as! CAShapeLayer).path, toValue: destinationPath, duration: 0.5, delay: 0.75, delegate: self, isRemovedOnCompletion: false)
                            pathAnim.setValue(self.imagesHeaderIcon.icon.icon as! CAShapeLayer, forKey: "layer")
                            pathAnim.setValue(destinationPath, forKey: "destinationPath")
                            self.imagesHeaderIcon.icon.icon.add(pathAnim, forKey: nil)
                            UIView.animate(withDuration: 0.5, delay: 0.75, options: [], animations: {
                                self.imagesHeaderIcon.icon.backgroundColor = K_COLOR_RED
                            })
                        }
                    }
                    }])
                    }])
            }
            delay(seconds: lineAnimationDuration * 0.2) {
                self.imagesHeaderIcon.present(completionBlocks: [{ self.imagesHeaderIcon.state = .On }])
            }
            
            let startPoint = CGPoint(x: contentView.frame.width/2,
                                     y: contentView.convert(hyperlinkLabel.frame.origin, to: scrollView).y + hyperlinkLabel.frame.height + lineWidth/2)
            let delta = (initialIcon.frame.size.height / 2)
            var endPoint = contentView.convert(destinationIcon.center, to: scrollView)
            endPoint.y -= delta
            animateTransition(lineStart: startPoint,
                              lineEnd: endPoint,
                              initialIcon: initialIcon,
                              destinationIcon: destinationIcon,
                              lineCompletionBlocks: lineCompletionBlocks,
                              animationBlocks: animationBlocks,
                              completionBlocks: completionBlocks,
                              animationDuration: nil)
            
        case .Answers:
            initialIcon     = imagesHeaderIcon
            destinationIcon = answerIcon
            
            let scrollPoint = contentView.convert(destinationIcon.frame.origin, to: scrollView).y - initialIcon.bounds.height / 4.25// - navigationBarHeight / 2.5
            
            lineCompletionBlocks.append {
                self.scrollToPoint(y: scrollPoint, duration: 0.3, delay: 0, completionBlocks: [{
                    self.answerContainer.animateMaskLayer(duration: 0.3, completionBlocks: [], completionDelegate: self)
                    }])
            }
            self.answerIcon.present(completionBlocks: [{ self.answerIcon.state = .On }])
            completionBlocks.append {
//                delay(seconds: 1.25) { self.performSegue(withIdentifier: Segues.App.NewSurveyToHyperlinkViewController, sender: nil) }
            }
            
            let startPoint = CGPoint(x: contentView.frame.width/2, y: contentView.convert(imagesLabel.frame.origin, to: scrollView).y + imagesLabel.frame.height + lineWidth/2)
            let delta = (initialIcon.frame.size.height / 2)
            var endPoint = contentView.convert(destinationIcon.center, to: scrollView)
            endPoint.y -= delta
            animateTransition(lineStart: startPoint,
                              lineEnd: endPoint,
                              initialIcon: initialIcon,
                              destinationIcon: destinationIcon,
                              lineCompletionBlocks: lineCompletionBlocks,
                              animationBlocks: animationBlocks,
                              completionBlocks: completionBlocks,
                              animationDuration: nil)
            
        case .Post:
            print("Do nothing")
        }
    }
    
    @objc fileprivate func iconTapped(gesture: UITapGestureRecognizer) {
        if gesture.state == .ended, let v = gesture.view {
            if let icon = v as? CircleButton {
                if icon === categoryIcon {
                    //                    currentStage = .Category
                    performSegue(withIdentifier: Segues.App.NewSurveyToCategorySelection, sender: nil)
                } else if icon === anonIcon {
                    //                    currentStage = .Anonymity
                    performSegue(withIdentifier: Segues.App.NewSurveyToAnonimitySelection, sender: nil)
                } else if icon === privacyIcon {
                    //                    currentStage = .Privacy
                    performSegue(withIdentifier: Segues.App.NewSurveyToPrivacySelection, sender: nil)
                } else if icon === votesIcon {
                    //                    currentStage = .Votes
                    performSegue(withIdentifier: Segues.App.NewSurveyToVotesCountViewController, sender: nil)
                } else if icon === titleIcon {
                    //                    currentStage = .Title
                    performSegue(withIdentifier: Segues.App.NewSurveyToTypingViewController, sender: icon)
                } else if icon === questionIcon {
                    //                    currentStage = .Question
                    performSegue(withIdentifier: Segues.App.NewSurveyToTypingViewController, sender: icon)
                } else if icon === hyperlinkIcon {
                    //                    currentStage = .Hyperlink
                    performSegue(withIdentifier: Segues.App.NewSurveyToHyperlinkViewController, sender: nil)
                }  else if icon === imagesHeaderIcon {
                    let destinationPath = (self.imagesHeaderIcon.icon.getLayer(.Picture) as! CAShapeLayer).path
                    let pathAnim = Animations.get(property: .Path, fromValue: (self.imagesHeaderIcon.icon.icon as! CAShapeLayer).path, toValue: destinationPath, duration: 0.5, delegate: self, isRemovedOnCompletion: false)
                    pathAnim.setValue(self.imagesHeaderIcon.icon.icon as! CAShapeLayer, forKey: "layer")
                    pathAnim.setValue(destinationPath, forKey: "destinationPath")
                    self.imagesHeaderIcon.icon.icon.add(pathAnim, forKey: nil)
                    UIView.animate(withDuration: 0.5) {
                        self.imagesHeaderIcon.icon.backgroundColor = self.color
                    }
                    stage = .Answers
                }
            } else if let label = v as? UILabel {
                if label === titleLabel {
                    //                    currentStage = .Title
                    performSegue(withIdentifier: Segues.App.NewSurveyToTypingViewController, sender: titleIcon)
                } else if label === questionLabel {
                    //                    currentStage = .Question
                    performSegue(withIdentifier: Segues.App.NewSurveyToTypingViewController, sender: questionIcon)
                } else if label === hyperlinkLabel {
                    //                    currentStage = .Hyperlink
                    performSegue(withIdentifier: Segues.App.NewSurveyToHyperlinkViewController, sender: nil)
                }
            } else if v.accessibilityIdentifier == "addImage", let parentView = v.superview {
                if parentView === image_1 {
                    imagePosition = 0
                } else if parentView === image_2 {
                    imagePosition = 1
                } else {
                    imagePosition = 2
                }
                
                chooseImage()
            } else if let v = gesture.view as? UIImageView, let image = v.image {
                if v.superview == image_1 {
                    imagePosition = 0
                } else if v.superview == image_2 {
                    imagePosition = 1
                } else {
                    imagePosition = 2
                }
                performSegue(withIdentifier: Segues.App.NewSurveyToImagePreviewViewController, sender: image)
            } else if let v = gesture.view, v.accessibilityIdentifier == "imageEditingList" {
                print("ImageEditingListTableViewController")
            } else if effectView != nil, let frameView = highlitedImage.keys.first as? UIView, let imageView = highlitedImage.values.first as? UIImageView, let keyWindow = navigationController?.view.window {
                dismissImageEffectView(_effectView: effectView!, frameView: frameView, imageView: imageView, keyWindow: keyWindow)
            }
        }
    }
    
    @objc fileprivate func viewPressed(gesture: UILongPressGestureRecognizer) {
        
        if let imageView = gesture.view as? UIImageView, let keyWindow = navigationController?.view.window, effectView == nil, let parentView = imageView.superview {
            
            if parentView === image_1 {
                imagePosition = 0
            } else if parentView === image_2 {
                imagePosition = 1
            } else {
                imagePosition = 2
            }
            
            //            isEffectViewActive = true
            
            let darkEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
            darkEffectView.effect = nil
            darkEffectView.frame = keyWindow.frame
            darkEffectView.addEquallyTo(to: keyWindow)
            darkEffectView.contentView.isUserInteractionEnabled = true
            effectView = darkEffectView
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(NewPollController.iconTapped(gesture:)))
            darkEffectView.contentView.addGestureRecognizer(tap)
            
            let copy = UIView(frame: parentView.frame)
            copy.backgroundColor = .white
            copy.center = parentView.superview!.convert(parentView.center, to: darkEffectView.contentView)
            copy.layer.masksToBounds = true
            copy.layer.cornerRadius = copy.frame.height / 2
            darkEffectView.contentView.addSubview(copy)
            
            let imageCopy = UIImageView(frame: imageView.frame)
            imageCopy.image = imageView.image
            //            imageCopy.image?.cgImage. = imageView.image
            imageCopy.contentMode = UIView.ContentMode.scaleAspectFill
            imageCopy.layer.masksToBounds = true
            imageCopy.layer.cornerRadius = imageCopy.frame.height / 2
            imageCopy.center = CGPoint(x: copy.frame.width / 2, y: copy.frame.height / 2)
            imageCopy.isUserInteractionEnabled = true
            copy.addSubview(imageCopy)
            
            var listPos = CGPoint.zero
            let listSize = CGSize(width: self.view.frame.width * 0.25 * 2, height: self.view.frame.width * 0.25 * 1.3)
            let multiplier: CGFloat = copy.center.x == view.center.x ? 1.2 : 0.9
            if copy.center.x == view.center.x {
                listPos.x = view.center.x - listSize.width/2
            } else if (copy.frame.origin.x + listSize.width) > view.frame.width  {
                listPos.x = copy.frame.origin.x - listSize.width
            } else if (copy.frame.origin.x + listSize.width) < view.frame.width {
                listPos.x = copy.frame.origin.x + copy.frame.width * multiplier
            }
            if copy.center.x == view.center.x {
                if (copy.frame.origin.y + listSize.height) > view.frame.height  {
                    listPos.y = copy.frame.origin.y - listSize.height * multiplier
                } else if (copy.frame.origin.y + listSize.height) <= view.frame.height {
                    listPos.y = copy.frame.origin.y + copy.frame.height * multiplier
                }
            } else if (copy.frame.origin.y + listSize.height) > view.frame.height  {
                listPos.y = copy.frame.origin.y - listSize.height
            } else if (copy.frame.origin.y + listSize.height) <= view.frame.height {
                listPos.y = copy.frame.origin.y + copy.frame.height
            }
//            let tap_1 = UITapGestureRecognizer(target: self, action: #selector(CreateNewSurveyViewController.iconTapped(gesture:)))
//            imageCopy.addGestureRecognizer(tap_1)
            
            let destinationSize = CGSize(width: copy.frame.size.width * 1.2,
                                         height: copy.frame.size.height * 1.2)
            let destinationImageSize = CGSize(width: imageCopy.frame.size.width * 1.2,
                                              height: imageCopy.frame.size.height * 1.2)
            let destinationCenter = CGPoint(x: copy.center.x - (destinationSize.width - copy.frame.size.width) / 4,
                                            y: copy.center.y - (destinationSize.height - copy.frame.size.height) / 4)
            let destinationImageCenter = CGPoint(x: destinationSize.width / 2,
                                                 y: destinationSize.height / 2)
            
            UIView.animate(
                withDuration: 0.4,
                delay: 0,
                usingSpringWithDamping: 0.6,
                initialSpringVelocity: 1.1,
                options: [.curveEaseOut],
                animations: {
                    copy.frame.size = destinationSize
                    copy.center = destinationCenter
                    copy.layer.cornerRadius = copy.frame.height / 2
                    imageCopy.frame.size = destinationImageSize
                    imageCopy.center = destinationImageCenter
                    imageCopy.layer.cornerRadius = imageCopy.frame.height / 2
            })
            
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.2, delay: 0, options: [.curveEaseIn], animations: {
                darkEffectView.effect = UIBlurEffect(style: .dark)
            }) {
                _ in
                self.highlitedImage.removeAll()
                self.highlitedImage[copy] = imageCopy
                self.navigationController!.addChild(self.imageEditingList)
                self.imageEditingList.view.alpha = 1
                self.imageEditingList.view.frame.size = listSize
                self.imageEditingList.view.frame.origin = listPos
                darkEffectView.contentView.addSubview(self.imageEditingList.view)
                self.imageEditingList.tableView.reloadData()
                self.imageEditingList.didMove(toParent: self.navigationController!)
                //                self.imageEditingList.view.layer.zPosition = 10
                //                self.imageEditingList.view.bri
                
            }
            
        }
        
    }
    
    private func setTitle() {
        let navTitle = UILabel()
        navTitle.numberOfLines = 2
        navTitle.textAlignment = .center
        let attrString = NSMutableAttributedString()
        attrString.append(NSAttributedString(string: title!, attributes: StringAttributes.getAttributes(font: StringAttributes.getFont(name: StringAttributes.Fonts.Style.Bold, size: 19), foregroundColor: .black, backgroundColor: .clear)))
        if category != nil {
            //MARK: TODO - Fatal error when parent is nil
            attrString.append(NSAttributedString(string: "\n\(category!.parent!.title)", attributes: StringAttributes.getAttributes(font: StringAttributes.getFont(name: StringAttributes.Fonts.Style.Regular, size: 13), foregroundColor: .darkGray, backgroundColor: .clear)))
        }
        navTitle.attributedText = attrString
        navigationItem.titleView = navTitle
    }
    
    func scrollToPoint(y: CGFloat, duration: TimeInterval = 0.5, delay: TimeInterval = 0, completionBlocks: [Closure]) {
        UIView.animate(withDuration: duration, delay: delay, options: [.curveEaseInOut], animations: {
            self.scrollView.contentOffset.y = y
        }) {
            _ in
            completionBlocks.map({ $0() })
        }
    }
    
    private func chooseImage() {
        imagePicker.allowsEditing = true
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)//UIAlertController(title: "Выберите источник", message: "", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        //let titleAttrString = NSMutableAttributedString(string: "Выберите источник", attributes: semiboldAttrs)
        //alert.setValue(titleAttrString, forKey: "attributedTitle")
        let photo = UIAlertAction(title: "Фотоальбом", style: UIAlertAction.Style.default, handler: {
            (action: UIAlertAction) in
            self.imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
        })
        photo.setValue(UIColor.black, forKey: "titleTextColor")
        alert.addAction(photo)
        let camera = UIAlertAction(title: "Камера", style: UIAlertAction.Style.default, handler: {
            (action: UIAlertAction) in
            self.imagePicker.sourceType = UIImagePickerController.SourceType.camera
            self.present(self.imagePicker, animated: true, completion: nil)
        })
        camera.setValue(UIColor.black, forKey: "titleTextColor")
        camera.setValue(UIColor.black, forKey: "titleTextColor")
        alert.addAction(camera)
        let cancel = UIAlertAction(title: "Отмена", style: UIAlertAction.Style.destructive, handler: nil)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    private func dismissImageEffectView(_effectView: UIVisualEffectView, frameView: UIView, imageView: UIImageView, keyWindow: UIWindow) {
        //        isEffectViewActive = false
        
        var destinationView: UIView!
        
        switch imagePosition {
        case 0:
            destinationView = image_1
        case 1:
            destinationView = image_2
        default:
            destinationView = image_3
        }
        
        let destinationFrame        = CGRect(origin: destinationView.superview!.convert(destinationView.frame.origin, to: keyWindow),
                                             size: destinationView.frame.size)
        let destinationImageView    = destinationView.subviews.filter { $0 is UIImageView}.first!
        let destinationImageFrame   = CGRect(origin: destinationImageView.convert(destinationImageView.frame.origin, to: destinationImageView),
                                             size: destinationImageView.frame.size)
        
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.2, delay: 0, options: [.curveEaseInOut], animations: {
            frameView.frame = destinationFrame
            imageView.frame = destinationImageFrame
            frameView.layer.cornerRadius = frameView.frame.height / 2
            imageView.layer.cornerRadius = imageView.frame.height / 2
            self.imageEditingList.view.alpha = 0
        })
        
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations: {
            _effectView.effect = nil
        }) {
            _ in
            self.highlitedImage.removeAll()
            self.imageEditingList.view.removeFromSuperview()
            self.imageEditingList.removeFromParent()
            self.effectView = nil
            _effectView.removeFromSuperview()
            print(self.effectView)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        navigationController?.setNavigationBarHidden(false, animated: true)
        if let nc = navigationController as? NavigationControllerPreloaded {
            nc.duration = 0.55
            nc.transitionStyle = .Icon
            if segue.identifier == Segues.App.NewSurveyToCategorySelection, let destinationVC = segue.destination as? CategorySelectionViewController {
                nc.duration = 0.6
                //                destinationVC.category = category
                //                destinationVC.lineWidth = lineWidth
                destinationVC.actionButtonHeight = categoryIcon.frame.height
            } else if segue.identifier == Segues.App.NewSurveyToTypingViewController, let destinationVC = segue.destination as? TextInputViewController {
                nc.duration = 0.47
                if let icon = sender as? CircleButton {
                    if icon === titleIcon {
                        destinationVC.titleString = "Титул"
                        destinationVC.charactersLimit = DjangoVariables.FieldRestrictions.surveyTitleLength
                        destinationVC.textContent = questionTitle.isEmpty ? "" : questionTitle
                        //                    destinationVC.placeholder = "Введите титул.."
                        destinationVC.delegate = self
                        destinationVC.font = StringAttributes.getFont(name: StringAttributes.Fonts.Style.Regular, size: 17)
                        destinationVC.textColor = .black
                        destinationVC.accessibilityIdentifier = "Title"
                    } else if icon === questionIcon {
                        destinationVC.titleString = "Вопрос"
                        destinationVC.charactersLimit = DjangoVariables.FieldRestrictions.surveyQuestionLength
                        destinationVC.textContent = question.isEmpty ? "" : question
                        destinationVC.delegate = self
                        destinationVC.font = StringAttributes.getFont(name: StringAttributes.Fonts.Style.Regular, size: 17)
                        destinationVC.textColor = .black
                        destinationVC.accessibilityIdentifier = "Question"
                    }
                }
                destinationVC.cornerRadius = titleLabel.cornerRadius
                destinationVC.color = selectedColor
                //                nc.transitionStyle = .Blur
            } else if segue.identifier == Segues.App.NewSurveyToAnonimitySelection, let destinationVC = segue.destination as? BinarySelectionViewController {
                destinationVC.color = selectedColor
                destinationVC.selectionType = .Anonimity
                //                destinationVC.lineWidth = lineWidth
            } else if segue.identifier == Segues.App.NewSurveyToPrivacySelection, let destinationVC = segue.destination as? BinarySelectionViewController {
                destinationVC.color = selectedColor
                destinationVC.selectionType = .Privacy
                //                destinationVC.lineWidth = lineWidth
            } else if segue.identifier == Segues.App.NewSurveyToVotesCountViewController, let destinationVC = segue.destination as? VotesCountViewController {
                destinationVC.votesCount = votesCount
                //                destinationVC.actionButton.lineWidth = lineWidth
                destinationVC.actionButtonWidthConstant = votesIcon.frame.width
                destinationVC.color = selectedColor
            } else if segue.identifier == Segues.App.NewSurveyToHyperlinkViewController, let destinationVC = segue.destination as? HyperlinkSelectionViewController {
                destinationVC.color = selectedColor
                //                destinationVC.lineWidth = lineWidth
                nc.transitionStyle = .Icon
                if hyperlink != nil {
                    destinationVC.hyperlink = hyperlink
                }
                destinationVC.color = selectedColor
                destinationVC._labelHeight = hyperlinkLabel.frame.height
            } else if segue.identifier == Segues.App.NewSurveyToImagePreviewViewController, let destinationVC = segue.destination as? ImageViewController, let image = sender as? UIImage {
                nc.duration = 0.2
                nc.transitionStyle = .Icon
                destinationVC.image = image
            }
        }
    }
}

extension NewPollController: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag, let completionBlocks = anim.value(forKey: "completionBlocks") as? [Closure] {
            completionBlocks.map{ $0() }
        } else if let completionBlocks = anim.value(forKey: "maskCompletionBlocks") as? [Closure] {
            completionBlocks.map{ $0() }
        } else if let initialLayer = anim.value(forKey: "layer") as? CAShapeLayer, let path = anim.value(forKey: "destinationPath") {
            initialLayer.path = path as! CGPath
            
            if let completionBlock = anim.value(forKey: "completionBlock") as? Closure {
                completionBlock()
            }
        }
    }
}

extension NewPollController: CallbackDelegate {
    func callbackReceived(_ sender: AnyObject) {
        if let _category = sender as? SurveyCategory {
            category = _category
        } else if let textView = sender as? UITextView, let accessibilityIdentifier = textView.accessibilityIdentifier {
            if accessibilityIdentifier == "Title" {
                questionTitle = textView.text
            } else if accessibilityIdentifier == "Question"{
                question = textView.text
            }
        } else if let string = sender as? String {
            if string == "openImage" {
                delay(seconds: 0.3) { self.performSegue(withIdentifier: Segues.App.NewSurveyToImagePreviewViewController, sender: nil) }
            } else if string == "replaceImage" {
                delay(seconds: 0.3) { self.chooseImage() }
            } else if string == "deleteImage" {
                var imageView: UIImageView?
                
                switch imagePosition {
                case 0:
                    imageView = image_1.subviews.filter { $0 is UIImageView }.first as? UIImageView
                case 1:
                    imageView = image_2.subviews.filter { $0 is UIImageView }.first as? UIImageView
                default:
                    imageView = image_3.subviews.filter { $0 is UIImageView }.first as? UIImageView
                }
                
                UIView.animate(withDuration: 0.4, delay: 0.3, options: [.curveEaseInOut], animations: {
                    imageView?.alpha = 0
                }) {
                    _ in
                    imageView?.removeFromSuperview()
                    self.images[self.imagePosition] = [:]
                }
                //                showAlert(type: .Ok, buttons: [["Удалить": [CustomAlertView.ButtonType.Ok: nil]]], text: "Ошибка вызова сервера, пожалуйста, обновите список")
            } else if string == "addAnswer" {
                if answers.count < MAX_ANSWERS_COUNT {
                    answers.append("")
                    tableView.insertRows(at: [IndexPath(row: self.answers.count-1, section: 0)], with: .top)
                }
            }
        } else if let index = sender as? IndexPath, let cell = tableView.cellForRow(at: index) {
            
        }
    }
}

extension NewPollController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let origImage = info[.editedImage] as? UIImage {
            let imageData = origImage.jpegData(compressionQuality: 0.6)
            if let image = UIImage(data: imageData!) {
                images[imagePosition] = [image: ""]
                analyze(image: image)
            }
        }
        dismiss(animated: true)
    }
    
    private func analyze(image: UIImage) {
        
        var handler: VNImageRequestHandler!
        
        if #available(iOS 13, *) {
            //            var handler: VNImageRequestHandler?
            //
            //            #if os(iOS)
            //            let request = VNClassifyImageRequest()
            //            if let ciImage = image.ciImage {
            //                handler = VNImageRequestHandler(ciImage: ciImage, options: [])
            //            } else if let cgImage = image.cgImage {
            //                handler = VNImageRequestHandler(cgImage: cgImage, options: [])
            //            }
            
            //            try? handler?.perform(<#T##requests: [VNRequest]##[VNRequest]#>)
            //            let observations = request.results as? [VNClassificationObservation]
            //  let searchObservations = observations?.filter { $0.hasMinimumRecall(0.0, forPrecision: 0.7) }
            
            //            for index in contestantImageURLs.indices {
            //                let contestantImageURL = contestantImageURLs[index]
            //                if let contestantFPO = featureprintObservationForImage(atURL: contestantImageURL) {
            //                    do {
            //                        var distance = Float(0)
            //                        try contestantFPO.computeDistance(&distance, to: originalFPO)
            //                        ranking.append((contestantIndex: index, featureprintDistance: distance))
            //                    } catch {
            //                        print("Error computing distance between featureprints.")
            //                    }
            //                }
            //            }
            
        } else {
            guard let request = imageObservationRequest else {
                return
            }
            if let ciImage = image.ciImage {
                handler = VNImageRequestHandler(ciImage: ciImage)
            } else if let cgImage = image.cgImage {
                handler = VNImageRequestHandler(cgImage: cgImage)
            }
            try? handler.perform([request])
        }
    }
}

extension NewPollController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return answers.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == answers.count, let cell = tableView.dequeueReusableCell(withIdentifier: "addAnswer", for: indexPath) as? AddAnswerCell {
            cell.addButton.setTitleColor(selectedColor, for: .normal)
            cell.delegate = self
            return cell
        } else if let cell = tableView.dequeueReusableCell(withIdentifier: "answer", for: indexPath) as? AnswerCell {
            cell.setNeedsLayout()
            cell.layoutIfNeeded()
            cell.tagView.cornerRadius = cell.tagView.frame.height/2
            cell.index = indexPath
            cell.delegate = self
            if let text = answers[indexPath.row] as? String, !text.isEmpty {
                cell.label.text = text
            }
            return cell
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == answers.count {
            return answerRowHeight/2
        }
        return answerRowHeight
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "", handler: { (action, view, completion) in
            self.answers.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .top)
            completion(true)
        })
        deleteAction.backgroundColor = K_COLOR_RED
        deleteAction.image = UIImage(named: "trash_icon")?.resized(to: CGSize(width: 30, height: 30))
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteButton = UITableViewRowAction(style: .default, title: "Удалить") { (action, indexPath) in
            self.answers.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .bottom)
        }
        return [deleteButton]
    }
}

class AddAnswerCell: UITableViewCell {
    var delegate:   CallbackDelegate?
    @IBOutlet weak var addButton: UIButton!
    @IBAction func addButtonTapped(_ sender: Any) {
        delegate?.callbackReceived("addAnswer" as AnyObject)
    }
}

class AnswerCell: UITableViewCell {
    var delegate:   CallbackDelegate?
    var index:      IndexPath!
    @IBOutlet weak var label: UILabel! {
        didSet {
            let recognizer = UITapGestureRecognizer(target: self, action: #selector(AnswerCell.handleTap(recognizer:)))
            label.addGestureRecognizer(recognizer)
        }
    }
    @IBOutlet weak var tagView: UIView! {
        didSet {
            tagView.backgroundColor = .red
        }
    }
    
    @objc private func handleTap(recognizer: UITapGestureRecognizer) {
        if recognizer.state == .ended {
            delegate?.callbackReceived(index as AnyObject)
        }
    }
}
