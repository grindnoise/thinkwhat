////
////  CreateNewSurveyViewController.swift
////  ThinkWhat
////
////  Created by Pavel Bukharov on 27.10.2020.
////  Copyright © 2020 Pavel Bukharov. All rights reserved.
////
//
//import UIKit
//import Vision
//import SafariServices
//import SwiftyJSON
//
//class NewPollController: UIViewController, UINavigationControllerDelegate {
//    
//    deinit {
//        print("DEINIT NewPollController")
//    }
//
//    //Sequence of stages to post new survey
//    enum Stage: Int, CaseIterable {
//        case Category, Anonymity, Privacy, Votes, Comments, Hot, Title, Description, Hyperlink, Images, Question, Answers, Post
//    }
//    
//    var stage: Stage = .Category {
//        didSet {
//            moveToNextStage()
//            maximumStage = stage
//        }
//    }
//    
//    //Current cost
//    var cost: [String: Int] = [:]
//    
//    private var maximumStage: Stage = .Category {
//        didSet {
//            if oldValue.rawValue >= maximumStage.rawValue {
//                maximumStage = oldValue
//            }
////            maximumStage = stage.rawValue <= oldValue.rawValue ? oldValue : maximumStage//Stage(rawValue: maximumStage.rawValue + 1) ?? .Post
////            if maximumStage == .Answers {
//////                scrollView.isScrollEnabled = true
////            }
//        }
//    }
//    
//    private var isViewSetupCompleted = false
//    
//    @IBOutlet weak var scrollView: UIScrollView!
//    
//    @IBOutlet weak var contentView: UIView!
//    
//    
//    //MARK: - Category
//    var topic: Topic? {
//        didSet {
////            setTitle()
//            if topic != nil {
//                topicTitle.alpha = 0
//                topicTitle.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
//                UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut], animations: {
//                    self.topicTitle.alpha = 1
//                    self.topicTitle.transform = .identity
//                })
//                stage = .Anonymity
//                topicIcon.color = topic!.tagColor
//                topicIcon.category = Icon.Category(rawValue: topic!.id) ?? .Null
//                topicTitle.text = topic!.title.uppercased()
//            }
//        }
//    }
//    
//    @IBOutlet weak var topicTitle: UILabel! {
//        didSet {
//            topicTitle.alpha = 0
//            if topic == nil {
//                topicTitle.text = "РАЗДЕЛ"
//            }
//        }
//    }
//    
//    @IBOutlet weak var topicIcon: CircleButton! {
//        didSet {
//            let tap = UITapGestureRecognizer(target: self, action: #selector(NewPollController.viewTapped(gesture:)))
//            topicIcon.addGestureRecognizer(tap)
//            //            categoryIcon.icon.isFramed = false
//            topicIcon.icon.alpha = 0
//            topicIcon.state = .Off
//            topicIcon.color = selectedColor
//            topicIcon.text = "РАЗДЕЛ"
//            topicIcon.category = .Category_RU
//        }
//    }
//    
//    @IBOutlet weak var categoryLabel: UILabel! {
//        didSet {
//            categoryLabel.alpha = 0
//        }
//    }
//    
//    
//    //MARK: - Anon
//    var isAnonymous = false {
//        didSet {
//            anonTitle.alpha = 0
//            anonTitle.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
//            UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut], animations: {
//                self.anonTitle.alpha = 1
//                self.anonTitle.transform = .identity
//            })
//
//            stage = .Privacy
//            anonIcon.color = selectedColor
//            anonIcon.category = isAnonymous ? Icon.Category.Anon : Icon.Category.AnonDisabled//SurveyCategoryIcon.Category(rawValue: category!.ID) ?? .Null
//        }
//    }
//    
//    @IBOutlet weak var anonTitle: UILabel! {
//        didSet {
//            anonTitle.alpha = 0
//        }
//    }
//    
//    @IBOutlet weak var anonIcon: CircleButton! {
//        didSet {
//            let tap = UITapGestureRecognizer(target: self, action: #selector(NewPollController.viewTapped(gesture:)))
//            anonIcon.addGestureRecognizer(tap)
//            anonIcon.icon.alpha = 0
//            //            anonIcon.backgroundColor = .clear
//            anonIcon.state      = .Off
//            anonIcon.category   = .Anon
//            anonIcon.color      = selectedColor
//        }
//    }
//    
//    @IBOutlet weak var anonLabel: UILabel! {
//        didSet {
//            anonLabel.alpha = 0
//        }
//    }
//    
//    //MARK: - Privacy
//    var isPrivate = false {
//        didSet {
//            privacyTitle.alpha = 0
//            privacyTitle.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
//            UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut], animations: {
//                self.privacyTitle.alpha = 1
//                self.privacyTitle.transform = .identity
//            })
//            
//            stage = .Votes
//        }
//    }
//    
//    @IBOutlet weak var privacyTitle: UILabel! {
//        didSet {
//            privacyTitle.alpha = 0
//        }
//    }
//    
//    @IBOutlet weak var privacyIcon: CircleButton! {
//        didSet {
//            let tap = UITapGestureRecognizer(target: self, action: #selector(NewPollController.viewTapped(gesture:)))
//            privacyIcon.addGestureRecognizer(tap)
//            privacyIcon.icon.alpha = 0
//            //            privacyIcon.backgroundColor = .clear
//            privacyIcon.state       = .Off
//            privacyIcon.category    = .Locked
//            privacyIcon.color       = selectedColor
//        }
//    }
//    
//    @IBOutlet weak var privacyLabel: UILabel! {
//        didSet {
//            privacyLabel.alpha = 0
//        }
//    }
//    
//    
//    //MARK: - Votes
//    var votesCapacity = 100 {
//        didSet {
//            votesTitle.alpha = 0
//            votesTitle.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
//            UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut], animations: {
//                self.votesTitle.alpha = 1
//                self.votesTitle.transform = .identity
//            })
//            stage = .Comments
//            votesTitle.text = "\(votesCapacity)"
//        }
//    }
//    
//    @IBOutlet weak var votesLabel: UILabel! {
//        didSet {
//            votesLabel.alpha = 0
//        }
//    }
//    
//    @IBOutlet weak var votesIcon: CircleButton! {
//        didSet {
//            let tap = UITapGestureRecognizer(target: self, action: #selector(NewPollController.viewTapped(gesture:)))
//            votesIcon.addGestureRecognizer(tap)
//            votesIcon.icon.alpha = 0
//            //            votesIcon.backgroundColor = .clear
//            votesIcon.state       = .Off
//            votesIcon.category    = .Crowd//.Text
//            votesIcon.color       = selectedColor
//            votesIcon.text        = "100"
//        }
//    }
//    
//    @IBOutlet weak var votesTitle: UILabel! {
//        didSet {
//            votesTitle.alpha = 0
//        }
//    }
//    
//    //MARK: - Comments
//    var isCommentingAllowed = true {
//        didSet {
//            commentsTitle.alpha = 0
//            commentsTitle.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
//            UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut], animations: {
//                self.commentsTitle.alpha = 1
//                self.commentsTitle.transform = .identity
//            })
//            commentsTitle.text = isCommentingAllowed ? "РАЗРЕШЕНЫ" : "ЗАПРЕЩЕНЫ"
//            stage = .Hot
//        }
//    }
//    
//    @IBOutlet weak var commentsLabel: UILabel! {
//        didSet {
//            commentsLabel.alpha = 0
//        }
//    }
//    @IBOutlet weak var commentsTitle: UILabel! {
//        didSet {
//            commentsTitle.alpha = 0
//        }
//    }
//    @IBOutlet weak var commentsIcon: CircleButton! {
//        didSet {
//            let tap = UITapGestureRecognizer(target: self, action: #selector(NewPollController.viewTapped(gesture:)))
//            commentsIcon.addGestureRecognizer(tap)
//            commentsIcon.icon.alpha = 0
//            commentsIcon.state       = .Off
//            commentsIcon.category    = .Comment
//            commentsIcon.color       = selectedColor
//        }
//    }
//    
//    
//    
//    //MARK: - Hot
//    var isHot = false {
//        didSet {
//            hotTitle.alpha = 0
//            hotTitle.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
//            UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut], animations: {
//                self.hotTitle.alpha = 1
//                self.hotTitle.transform = .identity
//            })
////            hotTitle.text = isCommentingAllowed ? "РАЗРЕШЕНЫ" : "ЗАПРЕЩЕНЫ"
//            stage = .Title
//        }
//    }
//    
//    @IBOutlet weak var hotLabel: UILabel! {
//        didSet {
//            hotLabel.alpha = 0
//        }
//    }
//    @IBOutlet weak var hotTitle: UILabel! {
//        didSet {
//            hotTitle.alpha = 0
//        }
//    }
//    @IBOutlet weak var hotIcon: CircleButton! {
//        didSet {
//            let tap = UITapGestureRecognizer(target: self, action: #selector(NewPollController.viewTapped(gesture:)))
//            hotIcon.addGestureRecognizer(tap)
//            hotIcon.icon.alpha = 0
//            hotIcon.state       = .Off
//            hotIcon.category    = .Rocket
//            hotIcon.color       = selectedColor
//        }
//    }
//    
//    
//    
//    //MARK: - Title
//    var pollTitle = ""
//    
//    @IBOutlet weak var titleIcon: CircleButton! {
//        didSet {
//            titleIcon.icon.alpha = 0
//            //            titleIcon.backgroundColor = .clear
//            titleIcon.accessibilityIdentifier   = "titleIcon"
//            titleIcon.state                     = .Off
//            titleIcon.color                     = selectedColor
//            titleIcon.category                  = .Abc
//            //            titleIcon.text                      = "ТИТУЛ"
//            let tap = UITapGestureRecognizer(target: self, action: #selector(NewPollController.viewTapped(gesture:)))
//            titleIcon.addGestureRecognizer(tap)
//        }
//    }
//    
//    @IBOutlet weak var titleArcLabel: ArcLabel!{
//        didSet {
//            titleArcLabel.alpha = 0
//            titleArcLabel.backgroundColor = .clear
//        }
//    }
//    @IBOutlet weak var pollTitleTextView: UITextView! {
//        didSet {
//            let boldAttrs = StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: 25), foregroundColor: .black, backgroundColor: .clear)
//            let attrString = NSAttributedString(string: "Введите титул", attributes: boldAttrs)
//            pollTitleTextView.attributedText = attrString
//            pollTitleTextView.textAlignment = .center
//            let tap = UITapGestureRecognizer(target: self, action: #selector(NewPollController.viewTapped(gesture:)))
//            pollTitleTextView.addGestureRecognizer(tap)
//        }
//    }
//    @IBOutlet weak var pollTitleContainer: UIView! {
//        didSet {
//            //            titleLabel.backgroundColor = .clear
//            //            titleLabel.textColor = .white
//            pollTitleContainer.alpha = 0
////            titleLabel.text = ""
////            pollTitleContainer.accessibilityIdentifier = "Title"
////            pollTitleContainer.isUserInteractionEnabled = true
////            let tap = UITapGestureRecognizer(target: self, action: #selector(NewPollController.viewTapped(gesture:)))
////            pollTitleContainer.addGestureRecognizer(tap)
//        }
//    }
//    
//    
//    //MARK: - Description
//    var pollDescription = ""
////    {
////        didSet {
//////            stage = .Hyperlink
////            let paragraphStyle = NSMutableParagraphStyle()
////            paragraphStyle.hyphenationFactor = 1.0
////            let attributedString = NSMutableAttributedString(string: pollDescription, attributes: [NSAttributedString.Key.paragraphStyle:paragraphStyle])
////            attributedString.addAttributes(StringAttributes.getAttributes(font: StringAttributes.getFont(name: StringAttributes.Fonts.Style.Regular, size: 15), foregroundColor: .black, backgroundColor: .clear), range: pollDescription.fullRange())
////            descriptionContainer.attributedText = attributedString
////        }
////    }
//    
//    @IBOutlet weak var pollDescriptionIcon: CircleButton! {
//        didSet {
//            pollDescriptionIcon.icon.alpha = 0
//            pollDescriptionIcon.state                      = .Off
//            pollDescriptionIcon.color                      = selectedColor
//            pollDescriptionIcon.category                   = .Paragraph//.Details_RU
////                        questionIcon.text                       = "ВОПРОС"
//            let tap = UITapGestureRecognizer(target: self, action: #selector(NewPollController.viewTapped(gesture:)))
//            pollDescriptionIcon.addGestureRecognizer(tap)
//        }
//    }
//    @IBOutlet weak var pollDescriptionArcLabel: ArcLabel!{
//        didSet {
//            pollDescriptionArcLabel.alpha = 0
//            pollDescriptionArcLabel.backgroundColor = .clear
//        }
//    }
//    @IBOutlet weak var pollDescriptionContainer: UIView!
//    @IBOutlet weak var pollDescriptionTextView: UITextView! {
//        didSet {
//            let paragraph = NSMutableParagraphStyle()
//            paragraph.alignment = .center
//            
//            var boldAttrs = StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: 25), foregroundColor: .black, backgroundColor: .clear)
//            var lightAttrs = StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Light, size: 20), foregroundColor: .black, backgroundColor: .clear)
//            boldAttrs[NSAttributedString.Key.paragraphStyle] = paragraph
//            lightAttrs[NSAttributedString.Key.paragraphStyle] = paragraph
//            
//            let attrString = NSMutableAttributedString()
//            attrString.append(NSAttributedString(string: "Опишите\nподробности", attributes: boldAttrs))
//            attrString.append(NSAttributedString(string: "\n(опционально)", attributes: lightAttrs))
//            pollDescriptionTextView.attributedText = attrString
//            
//            let tap = UITapGestureRecognizer(target: self, action: #selector(NewPollController.viewTapped(gesture:)))
//            pollDescriptionTextView.addGestureRecognizer(tap)
//        }
//    }
//    
//    //MARK: - Hyperlink
//    var hyperlink: URL? {
//        didSet {
//            if hyperlink != nil {
//            stage = .Images
//            }
//        }
//    }
//    
//    @IBOutlet weak var hyperlinkIcon: CircleButton! {
//        didSet {
//            hyperlinkIcon.icon.alpha = 0
//            hyperlinkIcon.state     = .Off
//            hyperlinkIcon.color     = selectedColor
//            hyperlinkIcon.category  = .Hyperlink
//            let tap = UITapGestureRecognizer(target: self, action: #selector(NewPollController.viewTapped(gesture:)))
//            hyperlinkIcon.addGestureRecognizer(tap)
//        }
//    }
//    @IBOutlet weak var hyperlinkArcLabel: ArcLabel!{
//        didSet {
//            hyperlinkArcLabel.alpha = 0
//            hyperlinkArcLabel.backgroundColor = .clear
//        }
//    }
//    @IBOutlet weak var hyperlinkView: UIView! {
//        didSet {
//            hyperlinkView.alpha = 0
//        }
//    }
//    @IBOutlet weak var hyperlinkLabel: InsetLabel! {
//        didSet {
//            hyperlinkLabel.insets = UIEdgeInsets(top: hyperlinkLabel.insets.top, left: 15, bottom: hyperlinkLabel.insets.bottom, right: 20)
//            hyperlinkLabel.isUserInteractionEnabled = true
//            let tap = UITapGestureRecognizer(target: self, action: #selector(NewPollController.viewTapped(gesture:)))
//            hyperlinkLabel.addGestureRecognizer(tap)
//        }
//    }
//    @IBOutlet weak var hyperlinkInfoButton: Icon! {
//        didSet {
//            hyperlinkInfoButton.backgroundColor = .clear//K_COLOR_RED
//            hyperlinkInfoButton.iconColor = K_COLOR_RED
//            hyperlinkInfoButton.category = .Info
//            let tap = UITapGestureRecognizer(target: self, action: #selector(NewPollController.viewTapped(gesture:)))
//            hyperlinkInfoButton.addGestureRecognizer(tap)
//        }
//    }
//    @IBOutlet weak var circle_1: UIView!
//    @IBOutlet weak var circle_2: UIView!
//    @IBOutlet weak var circle_3: UIView!
//    @IBOutlet weak var circle_4: UIView!
//    
//    @IBOutlet weak var youtube: YoutubeLogo! {
//        didSet {
//            let tap = UITapGestureRecognizer(target: self, action: #selector(NewPollController.viewTapped(gesture:)))
//            youtube.addGestureRecognizer(tap)
//        }
//    }
//    @IBOutlet weak var wiki: WikiLogo! {
//        didSet {
//            let tap = UITapGestureRecognizer(target: self, action: #selector(NewPollController.viewTapped(gesture:)))
//            wiki.addGestureRecognizer(tap)
//        }
//    }
//    @IBOutlet weak var instagram: InstagramLogo! {
//        didSet {
//            let tap = UITapGestureRecognizer(target: self, action: #selector(NewPollController.viewTapped(gesture:)))
//            instagram.addGestureRecognizer(tap)
//        }
//    }
//    @IBOutlet weak var safari: SafariLogo! {
//        didSet {
//            let tap = UITapGestureRecognizer(target: self, action: #selector(NewPollController.viewTapped(gesture:)))
//            safari.addGestureRecognizer(tap)
//        }
//    }
//    @IBOutlet weak var hyperlinkSkipButton: UIButton!
//    @IBAction func hyperlinkButtonSkipButtonPressed(_ sender: Any) {
//        if hyperlinkSkipButton.titleLabel?.text == "ПРОПУСТИТЬ" {
//            stage = .Images
//            UIView.transition(with: self.hyperlinkSkipButton, duration: 0.3, options: .transitionCrossDissolve, animations: {
//                self.hyperlinkSkipButton.setTitle("", for: .normal)
////                self.hyperlinkAccessoryIcon.alpha = 0
//            })
//        } else {
//            //            hyperlinkAccessoryIcon.category = .Trash
//            hyperlink = nil
//            UIView.transition(with: self.hyperlinkSkipButton, duration: 0.3, options: .transitionCrossDissolve, animations: {
//                self.hyperlinkLabel.attributedText = self.hyperlinkPlaceholder
//                self.hyperlinkLabel.cornerRadius = self.hyperlinkLabel.frame.height/2
//                self.hyperlinkSkipButton.setTitle(self.hyperlink == nil ? "" : "ОЧИСТИТЬ", for: .normal)
//            })
//            
//        }
//    }
////    @IBOutlet weak var hyperlinkAccessoryIcon: SurveyCategoryIcon! {
////        didSet {
////            hyperlinkAccessoryIcon.backgroundColor = .clear
////            hyperlinkAccessoryIcon.iconColor = .darkGray
////            hyperlinkAccessoryIcon.category = .Skip
////        }
////    }
//
//    
//    //MARK: - Images
//    var images: [Int: [UIImage: String]] = [:] {
//        didSet {
//            if stage == .Images, oldValue.count != images.count, imagesIcon != nil {
//                UIView.transition(with: self.imagesSkipButton, duration: 0.3, options: .transitionCrossDissolve, animations: {
//                    self.imagesSkipButton.setTitle("ДАЛЕЕ", for: .normal)
//                })
//                imageEditingList = {
//                    let vc = Storyboards.controllers.instantiateViewController(withIdentifier: "ImageEditingListTableViewController") as! ImageEditingListTableViewController
//                    let tap = UITapGestureRecognizer(target: self, action: #selector(NewPollController.viewTapped(gesture:)))
//                    tap.cancelsTouchesInView = false
//                    vc.view.addGestureRecognizer(tap)
//                    vc.delegate = self
//                    return vc
//                } ()
//            }
//        }
//    }
//    
//    @IBOutlet weak var imagesArcLabel: ArcLabel!{
//        didSet {
//            imagesArcLabel.alpha = 0
//            imagesArcLabel.backgroundColor = .clear
//        }
//    }
//    @IBOutlet weak var imagesIcon: CircleButton! {
//        didSet {
//            imagesIcon.icon.alpha = 0
//            //            imagesHeaderIcon.backgroundColor = .clear
//            imagesIcon.state      = .Off
//            imagesIcon.color      = selectedColor
//            imagesIcon.category   = .Picture
//            let tap = UITapGestureRecognizer(target: self, action: #selector(NewPollController.viewTapped(gesture:)))
//            imagesIcon.addGestureRecognizer(tap)
//        }
//    }
//    @IBOutlet weak var imagesView: UIView! {
//        didSet {
//            imagesView.alpha = 0
////            imagesLabel.attributedText = imagesPlaceholder
//        }
//    }
//    @IBOutlet weak var imagesInfoButton: Icon! {
//        didSet {
//            imagesInfoButton.backgroundColor = .clear//K_COLOR_RED
//            imagesInfoButton.iconColor = K_COLOR_RED
//            imagesInfoButton.category = .Info
//            let tap = UITapGestureRecognizer(target: self, action: #selector(NewPollController.viewTapped(gesture:)))
//            imagesInfoButton.addGestureRecognizer(tap)
//        }
//    }
//
//    @IBOutlet weak var imagesStackView: UIStackView!
//    @IBOutlet weak var image_1: UIView!
//    @IBOutlet weak var image_2: UIView!
//    @IBOutlet weak var image_3: UIView!
////    @IBOutlet weak var imagesStackViewBottom: NSLayoutConstraint!
//    private var stackImages: [UIView] = []
//    private var highlitedImage: [UIView: UIImageView] = [:]
//    private var imageEditingList: ImageEditingListTableViewController?
//    //Use for iOS 11, 12
//    private var imageObservationRequest: VNCoreMLRequest?
//    lazy private var imagesModel: MobileNet = {
//        return MobileNet()
//    } ()
//    @IBOutlet weak var imagesSkipButton: UIButton!
//    @IBAction func imagesButtonSkipButtonPressed(_ sender: Any) {
//        stage = .Question
//        UIView.transition(with: self.imagesSkipButton, duration: 0.3, options: .transitionCrossDissolve, animations: {
//            self.imagesSkipButton.setTitle("", for: .normal)
//        })
//    }
////    @IBOutlet weak var imagesAccessoryIcon: SurveyCategoryIcon! {
////        didSet {
////            imagesAccessoryIcon.backgroundColor = .clear
////            imagesAccessoryIcon.iconColor = .darkGray
////            imagesAccessoryIcon.category = .Skip
////        }
////    }
//    
//    //MARK: - Title
//    var question = "" {
//        didSet {
////            stage = .Answers
//            let paragraphStyle = NSMutableParagraphStyle()
//            paragraphStyle.hyphenationFactor = 1.0
//            let attributedString = NSMutableAttributedString(string: question, attributes: [NSAttributedString.Key.paragraphStyle:paragraphStyle])
//            attributedString.addAttributes(StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Regular, size: 17), foregroundColor: .black, backgroundColor: .clear), range: question.fullRange())
//            questionTextView.attributedText = attributedString
//        }
//    }
//    
//    @IBOutlet weak var questionIcon: CircleButton! {
//        didSet {
//            questionIcon.icon.alpha = 0
//            questionIcon.state                     = .Off
//            questionIcon.color                     = selectedColor
//            questionIcon.category                  = .QuestionMark
//            let tap = UITapGestureRecognizer(target: self, action: #selector(NewPollController.viewTapped(gesture:)))
//            questionIcon.addGestureRecognizer(tap)
//        }
//    }
//    
//    @IBOutlet weak var questionArcLabel: ArcLabel!{
//        didSet {
//            questionArcLabel.alpha = 0
//            questionArcLabel.backgroundColor = .clear
//        }
//    }
//    @IBOutlet weak var questionContainer: UIView! {
//        didSet {
//            questionContainer.alpha = 0
//        }
//    }
//    @IBOutlet weak var questionTextView: UITextView! {
//        didSet {
//            let boldAttrs = StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: 25), foregroundColor: .black, backgroundColor: .clear)
//            
//            let attrString = NSAttributedString(string: "Сформулируйте вопрос", attributes: boldAttrs)
//            questionTextView.attributedText = attrString
//            questionTextView.textAlignment = .center
//            
//            let tap = UITapGestureRecognizer(target: self, action: #selector(NewPollController.viewTapped(gesture:)))
//            questionTextView.addGestureRecognizer(tap)
//        }
//    }
//    
//    
//    
//    //MARK: - Answers
//    var answers: [String] = [""] {
//        didSet {
////            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0.3, options: [.curveEaseInOut], animations: {
//            UIView.animate(
//                withDuration: 0.4,
//                delay: 0.4,
//                usingSpringWithDamping: 0.7,
//                initialSpringVelocity: 0.2,
//                options: [.curveEaseInOut],
//                animations: {
//                if self.bottomViewConstraint.constant != 0, self.answers.filter({ !$0.isEmpty }).count >= 2 {
//                    self.stage = .Post
//                    self.view.setNeedsLayout()
//                    self.bottomViewConstraint.constant += self.bottomView.frame.height*1.5
//                    self.view.layoutIfNeeded()
////                    self.postButtonBlur.effect = UIBlurEffect.init(style: .light)
//                }
//                self.postButton.backgroundColor = self.answers.count >= 2 ? K_COLOR_RED : K_COLOR_GRAY
//            })
//            CATransaction.begin()
//            let anim = CABasicAnimation(keyPath: "shadowOpacity")
//            anim.fromValue = 0
//            anim.toValue = 1
//            anim.duration = 0.25
//            anim.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
//            anim.isRemovedOnCompletion = false
//            postButtonShadow.layer.add(anim, forKey: "shadowOpacity")
//            CATransaction.commit()
//            if answers.count == MAX_ANSWERS_COUNT, let cell = tableView.cellForRow(at: IndexPath(row: answers.count, section: 0)) as? AddAnswerCell {
//                UIView.animate(withDuration: 0.2) {
//                    cell.addButton.alpha = 0
//                }
//            }
//        }
//    }
//    @IBOutlet weak var tableView: UITableView!
//    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
//    @IBOutlet weak var answerIcon: CircleButton! {
//        didSet {
//            answerIcon.icon.alpha = 0
//            answerIcon.state      = .Off
//            answerIcon.color      = selectedColor
//            answerIcon.category   = .Opinion
//            let tap = UITapGestureRecognizer(target: self, action: #selector(NewPollController.viewTapped(gesture:)))
//            answerIcon.addGestureRecognizer(tap)
//        }
//    }
//    @IBOutlet weak var answerContainer: UIView! {
//        didSet {
//            answerContainer.alpha = 0
//        }
//    }
//    @IBOutlet weak var answerArcLabel: ArcLabel!{
//        didSet {
//            answerArcLabel.alpha = 0
//            answerArcLabel.backgroundColor = .clear
//        }
//    }
//    var selectedCellIndex: IndexPath?
//    
//    //MARK: - Interface properties
//    @IBInspectable var lineWidth: CGFloat = 5 {
//        didSet {
//            NotificationCenter.default.post(name: Notifications.UI.LineWidth, object: lineWidth)
//        }
//    }
//    @IBInspectable private var lastContentOffset: CGFloat = 0
//    @IBInspectable private var lineAnimationDuration = 0.3
//    @IBAction func postButtonTapped(_ sender: Any) {
//        if postButton.backgroundColor == K_COLOR_RED {
//            postSurvey()
//        } else {
//            delBanner.shared.contentType = .Warning
//            if let content = delBanner.shared.content as? Warning {
//                content.level = .Warning
//                content.text = "Минимальное количество вариантов ответов - 2"
//            }
//            delBanner.shared.present(shouldDismissAfter: 3, delegate: nil)
//        }
//    }
//    @IBOutlet weak var postButton: UIButton! {
//        didSet {
//            postButton.backgroundColor = K_COLOR_RED
//        }
//    }
//    @IBOutlet weak var postButtonShadow: UIView! {
//        didSet {
//            postButtonShadow.backgroundColor = .clear
//            postButtonShadow.layer.masksToBounds = false
//        }
//    }
//    @IBOutlet weak var bottomViewConstraint: NSLayoutConstraint!
////    @IBOutlet weak var postButtonBlur: UIVisualEffectView!
//    @IBOutlet weak var bottomView: UIView! {
//        didSet {
//            bottomView.layer.masksToBounds = false
//        }
//    }
//    //    var isNavigationBarHidden = false
//    
//    //Color based on selected category
//    var selectedColor = K_COLOR_RED {
//        didSet {
//            topicIcon.color              = selectedColor
//            anonIcon.color                  = selectedColor
//            privacyIcon.color               = selectedColor
//            votesIcon.color                 = selectedColor
//            titleIcon.color                 = selectedColor
//            pollTitleContainer.backgroundColor      = selectedColor.withAlphaComponent(0.3)
//            pollDescriptionIcon.color           = selectedColor
//            pollDescriptionContainer.backgroundColor = selectedColor.withAlphaComponent(0.3)
//            hyperlinkIcon.color             = selectedColor
//            hyperlinkView.backgroundColor   = selectedColor.withAlphaComponent(0.3)
//            imagesIcon.color                = selectedColor
//            imagesView.backgroundColor      = selectedColor.withAlphaComponent(0.3)
//            answerIcon.color                = selectedColor
//            commentsIcon.color              = selectedColor
//            hotIcon.color                   = selectedColor
//            hyperlinkInfoButton.setIconColor(selectedColor)
//            imagesInfoButton.setIconColor(selectedColor)
//            hotIcon.color                   = selectedColor
//            questionIcon.color              = selectedColor
//            questionContainer.backgroundColor   = selectedColor.withAlphaComponent(0.3)
//            answerContainer.backgroundColor = selectedColor.withAlphaComponent(0.3)
//            tableView.separatorColor        = selectedColor.withAlphaComponent(0.3)
////            tableView.reloadData()
//            lines.forEach { $0.layer.strokeColor = selectedColor.withAlphaComponent(0.3).cgColor }
////            badges.forEach {
////                $0.backgroundColor = selectedColor.withAlphaComponent(0.3)
//////                $0.textColor = selectedColor
////            }
//        }
//    }
//    
//    lazy var hyperlinkPlaceholder: NSMutableAttributedString = {
//        let attrString = NSMutableAttributedString()
//        attrString.append(NSAttributedString(string: "ВСТАВИТЬ ССЫЛКУ", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Regular, size: 15), foregroundColor: .darkGray, backgroundColor: .clear)))
//        return attrString
//    }()
//    
////    lazy var imagesPlaceholder: NSMutableAttributedString = {
////        let attrString = NSMutableAttributedString()
////        attrString.append(NSAttributedString(string: "Добавьте картинки", attributes: StringAttributes.getAttributes(font: StringAttributes.getFont(name: StringAttributes.Fonts.Style.Semibold, size: 25), foregroundColor: .darkGray, backgroundColor: .clear)))
////        attrString.append(NSAttributedString(string: "\n(не обязательное поле)", attributes: StringAttributes.getAttributes(font: StringAttributes.getFont(name: StringAttributes.Fonts.Style.Regular, size: 14), foregroundColor: .gray, backgroundColor: .clear)))
////        return attrString
////    }()
//    
//    //Array of colored lines between stages
//    private var lines: [Line] = []
////    var badges: [UILabel] = []
//    var tagColors = Colors.tags()
//    //Corner for labels
//    private var cornerRadius: CGFloat! {
//        didSet {
//            pollTitleContainer.layer.cornerRadius = cornerRadius
//            pollDescriptionContainer.layer.cornerRadius = cornerRadius
//            hyperlinkView.layer.cornerRadius = cornerRadius
//            imagesView.layer.cornerRadius = cornerRadius
//            questionContainer.layer.cornerRadius = cornerRadius
//            answerContainer.layer.cornerRadius = cornerRadius
//        }
//    }
//    //Get-only color
//    var color: UIColor {
//        get {
//            return selectedColor
//        }
//    }
//    private var answerRowHeight: CGFloat = 50
////    private var labelTopInset: CGFloat = 0 {
////        didSet {
//////            pollTitleContainer.topInset = labelTopInset
//////            descriptionContainer.topInset = labelTopInset
//////            imagesLabel.topInset = labelTopInset
////        }
////    }
//    
//    private var imagePicker = UIImagePickerController ()
//    
//    //Where to place selected image
//    var imagePosition = 0 {
//        didSet {
//            print(imagePosition)
//        }
//    }
//    
//    //Indicates if effectView is on screen
//    private var effectView: UIVisualEffectView?
//    private var survey: Survey?
//    //MARK: - VC Functions
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        API.shared.getBalanceAndPrice()
////        DispatchQueue.main.async {
//        let customTitle = CircleButton(frame: CGRect(origin: .zero, size: CGSize(width: 40, height: 40)), useAutoLayout: false)
//        customTitle.color = .white
//        customTitle.icon.iconColor = K_COLOR_RED
//        customTitle.icon.backgroundColor = .clear
//        customTitle.category = .Poll
//        customTitle.state = .Off
//        customTitle.contentView.backgroundColor = .clear
//        customTitle.oval.strokeColor = K_COLOR_RED.cgColor
//        customTitle.oval.lineCap = .round
////        customTitle.layer.masksToBounds = false
////        customTitle.oval.masksToBounds = false
////        customTitle.contentView.clipsToBounds = false
//        customTitle.lineWidth = customTitle.frame.width * 0.06
////        customTitle.clipsToBounds = false
//        self.navigationItem.titleView = customTitle
////        navigationItem.titleView?.clipsToBounds = false
////        //        }
////        let customTitle = SurveyCategoryIcon(frame: CGRect(origin: .zero, size: CGSize(width: 45, height: 45)))
////        customTitle.backgroundColor = .clear
////        customTitle.iconColor = K_COLOR_RED
////        customTitle.scaleMultiplicator = 0.25
////        customTitle.category = .Poll
////                //NewSurveyTitle(size: CGSize(width: self.navigationController!.navigationBar.frame.width * 0.7, height: self.navigationController!.navigationBar.frame.height), text: "Новый опрос", category: .Poll)
////            self.navigationItem.titleView = customTitle
//////        }
//        contentView.backgroundColor = .clear//UIColor.lightGray.withAlphaComponent(0.1)
////        view.backgroundColor        = UIColor.lightGray.withAlphaComponent(0.05)
//        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
//        tableView.delegate = self as UITableViewDelegate
//        tableView.dataSource = self
//        tableView.rowHeight = UITableView.automaticDimension
//        tableView.estimatedRowHeight = 600
//        tableView.tableFooterView = UIView()
//        UIImageView.appearance(whenContainedInInstancesOf: [UITableView.self]).tintColor = K_COLOR_RED
////        tableView.register(AddAnswerCell.self, forCellReuseIdentifier: "addAnswer")
////        tableView.register(AnswerCell.self, forCellReuseIdentifier: "answer")
//        imagePicker.delegate = self
//        imagePicker.allowsEditing = true
//        imagePicker.navigationBar.topItem?.rightBarButtonItem?.tintColor = K_COLOR_RED
//        
//        scrollView.isScrollEnabled = false
//        
//        if #available(iOS 13, *) {
//            
//        } else {
//            DispatchQueue.main.async {
//                guard let visionModel = try? VNCoreMLModel(for: self.imagesModel.model) else {
//                    fatalError("Error")
//                }
//                self.imageObservationRequest = VNCoreMLRequest(model: visionModel, completionHandler: {
//                    request, error in
//                    if let observations = request.results as? [VNClassificationObservation] {
//                        let top = observations.filter { $0.confidence >= 0.6 }.map {print("identifier: \($0.identifier), confidence: \($0.confidence)") }
//                        //                    top3.map { print("identifier: \($0.identifier), confidence: \($0.confidence)") }
//                    }
//                })
//            }
//        }
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        if let nc = navigationController as? NavigationControllerPreloaded {
//            nc.isShadowed = true
//            nc.navigationBar.isTranslucent = false
////            nc.transitionStyle = .Default
////            nc.navigationBar.tintColor = .black
//            //            if isNavigationBarHidden {
//            //                nc.setNavigationBarHidden(true, animated: true)
//            //            }
//        }
//        
//        if !isViewSetupCompleted {
//            view.setNeedsLayout()
//            view.layoutIfNeeded()
//            self.view.isUserInteractionEnabled = false
//            self.view.subviews.map { $0.isUserInteractionEnabled = false }
//            lineWidth = topicIcon.bounds.height / 18//0.75
//            isViewSetupCompleted = true
//
//            DispatchQueue.main.async {
////                self.imagesStackViewBottom.constant -= self.lineWidth
//                self.imagesStackView.setNeedsLayout()
//                self.imagesStackView.layoutIfNeeded()
//                self.image_1.cornerRadius = self.image_1.frame.width / 2
//                self.image_2.cornerRadius = self.image_1.frame.width / 2
//                self.image_3.cornerRadius = self.image_1.frame.width / 2
//                
//                self.stackImages = [self.image_1, self.image_2, self.image_3]
//                self.stackImages.map {
//                    v in
//                    let addButton = Icon.getIcon(frame: v.frame, category: .Plus, backgroundColor: .clear, pathColor: .darkGray)
//                    addButton.accessibilityIdentifier = "addImage"
//                    addButton.addEquallyTo(to: v, multiplier: 0.5)
//                    let tap = UITapGestureRecognizer(target: self, action: #selector(NewPollController.viewTapped(gesture:)))
//                    addButton.addGestureRecognizer(tap)
//                    v.transform = CGAffineTransform.init(scaleX: 0.7, y: 0.7)
//                    v.alpha = 0
//                }
//                self.tableView.reloadData()
//            }
//
//            postButton.cornerRadius = postButton.frame.height/2
//            bottomViewConstraint.constant  -= bottomView.frame.height*1.5
//            postButtonShadow.layer.shadowOpacity = 1
//            postButtonShadow.layer.shadowColor = UIColor.white.cgColor
//            postButtonShadow.layer.shadowPath = UIBezierPath(roundedRect: postButton.bounds, cornerRadius: postButton.cornerRadius).cgPath
//            postButtonShadow.layer.shadowRadius = 12
//            postButtonShadow.layer.shadowOffset = .zero
//            delay(seconds: 0.25) {
////                self.addBadge()
//                self.topicIcon.present(completionBlocks: [{
//                    self.topicIcon.state = .On
//                     self.performSegue(withIdentifier: Segues.App.NewSurveyToCategorySelection, sender: nil)
//                    }])
//                UIView.animate(withDuration: 0.4) {
//                    self.categoryLabel.alpha = 1
//                }
//            }
//            
//            circle_1.cornerRadius = circle_1.frame.width / 2
//            circle_2.cornerRadius = circle_1.frame.width / 2
//            circle_3.cornerRadius = circle_1.frame.width / 2
//            circle_4.cornerRadius = circle_1.frame.width / 2
//            isViewSetupCompleted = true
//
//            hyperlinkLabel.attributedText = hyperlinkPlaceholder
//            hyperlinkLabel.cornerRadius = hyperlinkLabel.frame.height/2
////            if let btn = self.navigationItem.rightBarButtonItem as? UIBarButtonItem {
////                let v = SurveyCategoryIcon(frame: CGRect(origin: .zero, size: CGSize(width: 27, height: 27)))
////                v.accessibilityIdentifier = "balance"
////                v.backgroundColor = .clear
////                v.iconColor = .black//Colors.UpperButtons.VioletBlueCrayola
////                v.category = .Balance
////                let tap = UITapGestureRecognizer(target: self, action: #selector(NewPollController.viewTapped(gesture:)))
////                v.addGestureRecognizer(tap)
////                btn.customView = v
////                v.scaleMultiplicator = 0.15
////                btn.customView?.alpha = 0
////                btn.customView?.clipsToBounds = false
////                btn.customView?.layer.masksToBounds = false
////                btn.customView?.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
////                UIView.animate(
////                    withDuration: 0.4,
////                    delay: 0,
////                    usingSpringWithDamping: 0.6,
////                    initialSpringVelocity: 2.5,
////                    options: [.curveEaseInOut],
////                    animations: {
////                        btn.customView?.transform = .identity
////                        btn.customView?.alpha = 1
////                })
////                self.navigationController?.navigationBar.setNeedsLayout()
////            }
//        }
//        
//        DispatchQueue.main.async {
//            self.images.compactMap {
//                dict in
//                var container: UIView!
//                if dict.key == 0 {
//                    container = self.image_1
//                } else if dict.key == 1 {
//                    container = self.image_2
//                } else if dict.key == 2 {
//                    container = self.image_3
//                }
//                
//                if container != nil, let image = dict.value.keys.first {
//                    let imageViews  = container.subviews.filter { $0 is UIImageView } as! [UIImageView]
//                    let imagesFound     = !imageViews.isEmpty
//                    
//                    //Disable tap for +
//                    //                container.subviews.filter { $0 is SurveyCategoryIcon }.first?.isUserInteractionEnabled = false
//                    
//                    if imagesFound {
//                        imageViews.map {
//                            imageView in
//                            
//                            if imageView.image != image {
//                                imageView.image = image
//                            }
//                        }
//                    } else {
//                        let imageView = UIImageView(frame: container.frame)
//                        imageView.isUserInteractionEnabled = true
//                        imageView.image = image
//                        imageView.contentMode = UIView.ContentMode.scaleAspectFill
//                        imageView.layer.masksToBounds = true
//                        imageView.addEquallyTo(to: container, multiplier: 0.85)
//                        container.layoutSubviews()
//                        imageView.layer.cornerRadius = imageView.frame.height / 2
//                        
//                        let tap = UITapGestureRecognizer(target: self, action: #selector(NewPollController.viewTapped(gesture:)))
//                        imageView.addGestureRecognizer(tap)
//                        
//                        let press = UILongPressGestureRecognizer(target: self, action: #selector(NewPollController.viewPressed(gesture:)))
//                        press.minimumPressDuration = 0.25
//                        imageView.addGestureRecognizer(press)
//                    }
//                }
//            }
//        }
//    }
//    
//    override func viewDidAppear(_ animated: Bool) {
//        if cornerRadius == nil {
//            cornerRadius = view.frame.width / 20
//        }
//        scrollView.contentSize.height = 4000
////        scrollView.isScrollEnabled = false
//        setAnswerContainerHeight()
//    }
//    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        
//        if isMovingFromParent {
//            imageEditingList?.view.removeFromSuperview()
//            imageEditingList?.removeFromParent()
//            imageEditingList = nil
//            if let nc = navigationController as? NavigationControllerPreloaded {
//                nc.duration = 0.2
//            }
//        }
//    }
//    
//    override func viewDidDisappear(_ animated: Bool) {
//        if let selectedRow = tableView.indexPathForSelectedRow {
//            tableView.deselectRow(at: selectedRow, animated: false)
//        }
//        highlitedImage.removeAll()
//    }
//    
////    private func addBadge() {
////        let badgeSize = CGSize(width: lineWidth*2.6, height: lineWidth*2.8)
////        var badge = UIView()
////        func getCenter(_ targetView: UIView) -> CGPoint {
////            let x = (targetView.frame.size.height/2) * CGFloat(cos(225 * Double.pi / 180)) + targetView.center.x
////            let y = (targetView.frame.size.height/2) * CGFloat(sin(225 * Double.pi / 180)) + targetView.center.y
////            return contentView.convert(CGPoint(x: x - lineWidth/2.6, y: y + lineWidth/2.6), to: scrollView)
////        }
////
////        func getBadge(forIcon icon: UIView, text: String) -> UIView {
////            let roundView = UIView(frame: CGRect(origin: .zero, size: badgeSize))
////            roundView.center = getCenter(icon)
////            roundView.backgroundColor = .white
////            roundView.layer.masksToBounds = true
////            roundView.cornerRadius = badgeSize.width/2
////            roundView.alpha = 0
////            let label = UILabel()
////            label.text = text
////            label.textAlignment = .center
////            label.backgroundColor = selectedColor.withAlphaComponent(0.3)
////            label.numberOfLines = 1
////            //label.sizeThatFits(CGSize(width: badgeSize.width*0.3, height: badgeSize.height*0.3))
////            label.font = StringAttributes.getFont(name: StringAttributes.Fonts.Style.Bold, size: 10)
////            label.textColor = .darkGray//.white//selectedColor
////            label.addEquallyTo(to: roundView)
////            badges.append(label)
////            return roundView
////        }
////
////        switch stage {
////        case .Category:
////            badge = getBadge(forIcon: categoryIcon, text: "1")
////        case .Anonymity:
////            badge = getBadge(forIcon: anonIcon, text: "2")
////        case .Privacy:
////            badge = getBadge(forIcon: privacyIcon, text: "3")
////        case .Votes:
////            badge = getBadge(forIcon: votesIcon, text: "4")
////        case .Comments:
////            badge = getBadge(forIcon: commentsIcon, text: "5")
////        case .Hot:
////            badge = getBadge(forIcon: hotIcon, text: "6")
////        case .Title:
////            badge = getBadge(forIcon: titleIcon, text: "7")
////        case .Description:
////            badge = getBadge(forIcon: descriptionIcon, text: "8")
////        case .Hyperlink:
////            badge = getBadge(forIcon: hyperlinkIcon, text: "9")
////        case .Images:
////            badge = getBadge(forIcon: imagesIcon, text: "10")
////        case .Question:
////            badge = getBadge(forIcon: imagesIcon, text: "11")
////        case .Answers:
////            badge = getBadge(forIcon: answerIcon, text: "12")
////        default:
////            print("")
////        }
////        contentView.addSubview(badge)
////        badge.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
////        UIView.animate(
////            withDuration: lineAnimationDuration,
////            delay: lineAnimationDuration/2,
////            usingSpringWithDamping: 0.6,
////            initialSpringVelocity: 0.7,
////            options: [.curveEaseInOut],
////            animations: {
////                badge.alpha = 1
////                badge.transform = .identity
////        })
////    }
//    
//    //MARK: - UI Functions
//    private func moveToNextStage() {
////        view.subviews.map {$0.isUserInteractionEnabled = false}
//        var initialView:            UIView!
//        var destinationView:        UIView!
//        //lineCompletionBlocks - used in animationDidStop()
//        var lineCompletionBlocks:   [Closure] = []
//        var animationBlocks:        [Closure] = []
//        var completionBlocks:       [Closure] = []
//        
//        func animateTransition(lineStart: CGPoint, lineEnd: CGPoint, lineCompletionBlocks: [Closure], animationBlocks animations: [Closure], completionBlocks completion: [Closure], animationDuration: TimeInterval = 0) {
//            let line     = drawLine(fromPoint: lineStart, endPoint: lineEnd, lineCap: .round)
//            let lineAnim = getLineAnimation(line: line, duration: animationDuration)
//            let duration = animationDuration
//            
//            contentView.layer.insertSublayer(line.layer, at: 0)
//            lineAnim.delegate = self
//            lineAnim.setValue(lineCompletionBlocks, forKey: "completionBlocks")
//            line.layer.add(lineAnim, forKey: "animEnd")
//            
//            UIView.animate(withDuration: duration, delay: lineAnimationDuration , options: [.curveEaseInOut], animations:
//                {
//                    DispatchQueue.main.async {
//                        animations.map { $0() }
//                    }
//            }) {
//                _ in
//                DispatchQueue.main.async {
//                    completion.map({ $0() })
//                }
//            }
//            line.layer.strokeEnd = 1
//        }
//        
//        func drawLine(fromView: UIView, toView: UIView, lineCap: CAShapeLayerLineCap) -> Line {
//            let line = Line()
//            line.path = UIBezierPath()
//            
//            let startPoint = contentView.convert(fromView.center, to: view)//fromView.convert(fromView.center, to: contentView)
//            line.path.move(to: startPoint)
//            
//            let endPoint = contentView.convert(toView.center, to: view)//toView.convert(toView.center, to: contentView)
//            line.path.addLine(to: endPoint)
//            
//            
//            let interfaceDirection = UIView.userInterfaceLayoutDirection(for: UISemanticContentAttribute.unspecified)
//            let path = interfaceDirection == .rightToLeft ? line.path.reversing() : line.path
//            
//            line.layer.strokeStart = 0
//            line.layer.strokeEnd = 0
//            line.layer.lineWidth = lineWidth
//            line.layer.strokeColor = selectedColor.withAlphaComponent(0.3).cgColor//K_COLOR_RED.withAlphaComponent(0.1).cgColor
//            line.layer.lineCap = lineCap
//            
//            line.layer.path = path.cgPath
//            lines.append(line)
//            return line
//        }
//        
//        func drawLine(fromPoint: CGPoint, endPoint: CGPoint, lineCap: CAShapeLayerLineCap) -> Line {
//            let line = Line()
//            line.path = UIBezierPath()
//            
//            line.path.move(to: fromPoint)
//            line.path.addLine(to: endPoint)
//            
//            let interfaceDirection = UIView.userInterfaceLayoutDirection(for: UISemanticContentAttribute.unspecified)
//            let path = interfaceDirection == .rightToLeft ? line.path.reversing() : line.path
//            
//            line.layer.strokeStart = 0
//            line.layer.strokeEnd = 0
//            line.layer.lineWidth = lineWidth
//            line.layer.strokeColor = selectedColor.withAlphaComponent(0.3).cgColor//K_COLOR_RED.withAlphaComponent(0.1).cgColor
//            line.layer.lineCap = lineCap
//            
//            line.layer.path = path.cgPath
//            lines.append(line)
//            return line
//        }
//        
//        func getLineAnimation(line: Line, duration: TimeInterval = 0) -> CAAnimationGroup {
//            let strokeEndAnimation      = CABasicAnimation(path: #keyPath(CAShapeLayer.strokeEnd), fromValue: line.layer.strokeEnd, toValue: 1, duration: duration == 0 ? lineAnimationDuration : duration)
//            //            let strokeWidthAnimation    = CAKeyframeAnimation(keyPath:"lineWidth")
//            //            strokeWidthAnimation.values   = [lineWidth * 2, lineWidth]
//            //            strokeWidthAnimation.keyTimes = [0, 1]
//            //            strokeWidthAnimation.duration = lineAnimationDuration
//            //            let pathFillColorAnim      = CAKeyframeAnimation(keyPath:"strokeColor")
//            //            pathFillColorAnim.values   = [selectedColor.withAlphaComponent(0.8).cgColor, selectedColor.withAlphaComponent(0.3).cgColor]
//            //            pathFillColorAnim.keyTimes = [0, 1]
//            //            pathFillColorAnim.duration = lineAnimationDuration
//            
//            let groupAnimation = CAAnimationGroup()
//            groupAnimation.animations = [strokeEndAnimation]//, strokeWidthAnimation, pathFillColorAnim]
//            groupAnimation.duration = duration == 0 ? lineAnimationDuration : duration
//            
//            return groupAnimation
//        }
//        
//        func reveal(view animatedView: UIView, duration: TimeInterval, completionBlocks: [Closure]) {
//            
//            let circlePathLayer = CAShapeLayer()
//            
//            func circleFrameTopCenter() -> CGRect {
//                var circleFrame = CGRect(x: 0, y: 0, width: 0, height: 0)
//                let circlePathBounds = circlePathLayer.bounds
//                circleFrame.origin.x = circlePathBounds.midX - circleFrame.midX
//                circleFrame.origin.y = circlePathBounds.minY - circleFrame.minY
//                return circleFrame
//            }
//            
//            func circleFrameTop() -> CGRect {
//                var circleFrame = CGRect(x: 0, y: 0, width: 0, height: 0)
//                let circlePathBounds = circlePathLayer.bounds
//                circleFrame.origin.x = circlePathBounds.midX - circleFrame.midX
//                circleFrame.origin.y = circlePathBounds.midY - circleFrame.midY
//                return circleFrame
//            }
//            
//            func circlePath() -> UIBezierPath {
//                return UIBezierPath(ovalIn: circleFrameTopCenter())
//            }
//            
//            circlePathLayer.frame = animatedView.bounds
//            circlePathLayer.path = circlePath().cgPath
//            animatedView.layer.mask = circlePathLayer
//            animatedView.alpha = 1
//            
//            let center = CGPoint(x: animatedView.bounds.midX, y: animatedView.bounds.midY)
//            
//            let finalRadius = sqrt((center.x*center.x) + (center.y*center.y))
//            
//            let radiusInset = finalRadius
//            
//            let outerRect = circleFrameTop().insetBy(dx: -radiusInset, dy: -radiusInset)
//            
//            let toPath = UIBezierPath(ovalIn: outerRect).cgPath
//            
//            let fromPath = circlePathLayer.path
//            
//            let maskLayerAnimation = CABasicAnimation(keyPath: "path")
//            
//            maskLayerAnimation.fromValue = fromPath
//            maskLayerAnimation.toValue = toPath
//            maskLayerAnimation.duration = duration
//            maskLayerAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
//            maskLayerAnimation.isRemovedOnCompletion = false
//            if !completionBlocks.isEmpty {
//                maskLayerAnimation.delegate = self
//                maskLayerAnimation.setValue(completionBlocks, forKey: "maskCompletionBlocks")
//            }
//            circlePathLayer.add(maskLayerAnimation, forKey: "path")
//            circlePathLayer.path = toPath
//        }
//        
//        guard stage.rawValue > maximumStage.rawValue else { return }
//        
//        animateProgress()
//        
//        switch stage {
//        case .Category:
//            print("Do nothing")
//        case .Anonymity:
//            initialView     = topicTitle
//            destinationView = anonLabel
////            destinationView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
//            animationBlocks.append {
//                destinationView.alpha = 1
////                destinationView.transform = .identity
//            }
//            let scrollPoint = contentView.convert(destinationView.frame.origin, to: scrollView).y - initialView.bounds.height / 4.25
//            lineCompletionBlocks.append {
//                self.scrollToPoint(y: scrollPoint, duration: 0.4, delay: 0, completionBlocks: [])
//            }
//            self.anonIcon.present(completionBlocks: [{
//                self.anonIcon.state = .On
//                self.performSegue(withIdentifier: Segues.App.NewSurveyToAnonimitySelection, sender: nil)
//                }])
//
//            var startPoint = contentView.convert(initialView.center, to: scrollView)
//            startPoint.y += initialView.frame.height/2//delta
//            var endPoint = contentView.convert(destinationView.center, to: scrollView)
//            endPoint.y -= destinationView.frame.height/2//delta
//            animateTransition(lineStart: startPoint, lineEnd: endPoint, lineCompletionBlocks: lineCompletionBlocks, animationBlocks: animationBlocks, completionBlocks: completionBlocks)
//        case .Privacy:
//            initialView     = anonTitle
//            destinationView = privacyLabel
//            animationBlocks.append {
//                self.privacyLabel.alpha = 1
//            }
//            let scrollPoint = contentView.convert(destinationView.frame.origin, to: scrollView).y - initialView.bounds.height / 4.25
//            lineCompletionBlocks.append {
//                self.scrollToPoint(y: scrollPoint, duration: 0.4, delay: 0, completionBlocks: [])
//            }
//                self.privacyIcon.present(completionBlocks: [{
//                    self.privacyIcon.state = .On
//                    self.performSegue(withIdentifier: Segues.App.NewSurveyToPrivacySelection, sender: nil)
//                    }])
//
//            var startPoint = contentView.convert(initialView.center, to: scrollView)
//            startPoint.y += initialView.frame.height/2//delta
//            var endPoint = contentView.convert(destinationView.center, to: scrollView)
//            endPoint.y -= destinationView.frame.height/2//delta
//            animateTransition(lineStart: startPoint, lineEnd: endPoint, lineCompletionBlocks: lineCompletionBlocks, animationBlocks: animationBlocks, completionBlocks: completionBlocks)
//        case .Votes:
//            initialView     = privacyTitle
//            destinationView = votesLabel
//            animationBlocks.append {
////                self.votesTitle.alpha = 1
//                self.votesLabel.alpha = 1
//            }
//            let scrollPoint = contentView.convert(destinationView.frame.origin, to: scrollView).y - initialView.bounds.height / 4.25
//            lineCompletionBlocks.append {
//                self.scrollToPoint(y: scrollPoint, duration: 0.4, delay: 0, completionBlocks: [])
//            }
//                self.votesIcon.present(completionBlocks: [{
//                    self.votesIcon.state = .On
//                    self.performSegue(withIdentifier: Segues.App.NewSurveyToVotesCountViewController, sender: nil)
//                    }])
//            
//            var startPoint = contentView.convert(initialView.center, to: scrollView)
//            startPoint.y += initialView.frame.height/2//delta
//            var endPoint = contentView.convert(destinationView.center, to: scrollView)
//            endPoint.y -= destinationView.frame.height/2//delta
//            animateTransition(lineStart: startPoint, lineEnd: endPoint, lineCompletionBlocks: lineCompletionBlocks, animationBlocks: animationBlocks, completionBlocks: completionBlocks)
//        case .Comments:
//            initialView     = votesLabel//votesIcon//imagesHeaderIcon
//            destinationView = commentsIcon
//            animationBlocks.append {
////                self.commentsTitle.alpha = 1
//                self.commentsLabel.alpha = 1
//            }
//            let scrollPoint = contentView.convert(destinationView.frame.origin, to: scrollView).y - initialView.bounds.height / 4.25
//            lineCompletionBlocks.append {
//                self.scrollToPoint(y: scrollPoint, duration: 0.4, delay: 0, completionBlocks: [])
//            }
//            var startPoint = contentView.convert(initialView.center, to: scrollView)
//            startPoint.y += initialView.frame.height/2//delta
//            var endPoint = contentView.convert(commentsLabel.center, to: scrollView)
//            endPoint.y -= commentsLabel.frame.height/2//delta
////            self.addBadge()
//            self.commentsIcon.present(completionBlocks: [{
//                self.commentsIcon.state = .On
//                self.performSegue(withIdentifier: Segues.App.NewSurveyToCommentingSelection, sender: nil)
//                }])
////            completionBlocks.append {
////                delay(seconds: 1) { self.performSegue(withIdentifier: Segues.App.NewSurveyToCommentingSelection, sender: nil) }
////            }
//            animateTransition(lineStart: startPoint, lineEnd: endPoint, lineCompletionBlocks: lineCompletionBlocks, animationBlocks: animationBlocks, completionBlocks: completionBlocks)
//        case .Hot:
//            initialView     = commentsLabel
//            destinationView = hotIcon
//            
//            let scrollPoint = contentView.convert(destinationView.frame.origin, to: scrollView).y - initialView.bounds.height / 4.25// - navigationBarHeight / 2.5
//            
//            lineCompletionBlocks.append {
//                self.scrollToPoint(y: scrollPoint, duration: 0.4, delay: 0, completionBlocks: [])
//            }
//            animationBlocks.append {
//                self.hotLabel.alpha = 1
//            }
////            self.addBadge()
//            self.hotIcon.present(completionBlocks: [{
//                    self.performSegue(withIdentifier: Segues.App.NewSurveyToHotSelection, sender: nil)
//                }])
//            var startPoint = contentView.convert(initialView.center, to: scrollView)
//            startPoint.y += initialView.frame.height/2
//            var endPoint = contentView.convert(hotLabel.center, to: scrollView)
//            endPoint.y -= hotLabel.frame.height/2
//            animateTransition(lineStart: startPoint,
//                              lineEnd: endPoint,
//                              lineCompletionBlocks: lineCompletionBlocks,
//                              animationBlocks: animationBlocks,
//                              completionBlocks: completionBlocks)
//        case .Title:
//            initialView     = hotLabel
//            destinationView = titleIcon
//            
//            let scrollPoint = contentView.convert(destinationView.frame.origin, to: scrollView).y - initialView.bounds.height / 4.25// - navigationBarHeight / 2.5
//            
//            lineCompletionBlocks.append {
//                self.scrollToPoint(y: scrollPoint, duration: 0.4, delay: 0, completionBlocks: [])
//            }
//            
//            self.titleIcon.present(completionBlocks: [{
//                reveal(view: self.pollTitleContainer, duration: 0.3, completionBlocks: [])
//                }])
//            
//            completionBlocks.append {
//                delay(seconds: 0.8) {
//                self.performSegue(withIdentifier: Segues.App.NewSurveyToTypingViewController, sender: self.titleIcon)
//                }
//            }
//            
//            UIView.animate(withDuration: 0.3) { self.titleArcLabel.alpha = 1 }
////            self.addBadge()
//
//            var startPoint = contentView.convert(initialView.center, to: scrollView)
//            startPoint.y += initialView.frame.height/2//delta
//            var endPoint = contentView.convert(titleArcLabel.center, to: scrollView)
//            endPoint.y -= titleArcLabel.frame.height/2//delta
//            
//            animateTransition(lineStart: startPoint, lineEnd: endPoint, lineCompletionBlocks: lineCompletionBlocks, animationBlocks: animationBlocks, completionBlocks: completionBlocks)
//        case .Description:
//            initialView     = titleIcon
//            destinationView = pollDescriptionIcon
//            
//            let scrollPoint = contentView.convert(destinationView.frame.origin, to: scrollView).y - initialView.bounds.height / 4.25// - navigationBarHeight / 2.5
//            
//            lineCompletionBlocks.append {
//                self.scrollToPoint(y: scrollPoint, duration: 0.4, delay: 0, completionBlocks: [])
//            }
//            pollDescriptionIcon.present(completionBlocks: [{
//                reveal(view: self.pollDescriptionContainer, duration: 0.3, completionBlocks: [])
//                }])
//            
//            completionBlocks.append {
//                delay(seconds: 0.8) {
//                    self.performSegue(withIdentifier: Segues.App.NewSurveyToTypingViewController, sender: self.pollDescriptionIcon)
//                }
//            }
//            
//            UIView.animate(withDuration: 0.3) { self.pollDescriptionArcLabel.alpha = 1 }
//            
//            self.pollDescriptionIcon.present(completionBlocks: [{
//                self.pollDescriptionIcon.state = .On
//                }])
//            
//            var startPoint = CGPoint(x: contentView.frame.width/2, y: contentView.convert(pollTitleContainer.frame.origin, to: scrollView).y + pollTitleContainer.frame.height + lineWidth/2)
//            startPoint.y += lineWidth/2
//            var endPoint = contentView.convert(pollDescriptionArcLabel.center, to: scrollView)
//            endPoint.y -= pollDescriptionArcLabel.frame.height/2//delta
//            animateTransition(lineStart: startPoint, lineEnd: endPoint, lineCompletionBlocks: lineCompletionBlocks, animationBlocks: animationBlocks, completionBlocks: completionBlocks, animationDuration: lineAnimationDuration/2)
//            
//        case .Hyperlink:
//            initialView     = pollDescriptionIcon
//            destinationView = hyperlinkIcon
//            
//            let scrollPoint = contentView.convert(destinationView.frame.origin, to: scrollView).y - initialView.bounds.height / 4.25// - navigationBarHeight / 2.5
//            lineCompletionBlocks.append {
//                self.scrollToPoint(y: scrollPoint, duration: 0.4, delay: 0, completionBlocks: [{ reveal(view: self.hyperlinkView, duration: 0.3, completionBlocks: []) }])
//            }
//            UIView.animate(withDuration: 0.3) { self.hyperlinkArcLabel.alpha = 1 }
////            self.addBadge()
//                self.hyperlinkIcon.present(completionBlocks: [{
//                    self.pollDescriptionIcon.state = .On
//                    }])
//            
//            completionBlocks.append {
//                self.view.isUserInteractionEnabled = true
//                self.view.subviews.map { $0.isUserInteractionEnabled = true }
//            }
//            if UserDefaults.App.hasSeenPollCreationIntroduction {
//                delay(seconds: 1) {
//                    delBanner.shared.contentType = .Warning
//                    if let content = delBanner.shared.content as? Warning {
//                        content.level = .Info
//                        content.text = "Прикрепите веб-ссылку (опционально)"
//                    }
//                    delBanner.shared.present(shouldDismissAfter: 3, delegate: nil)
//                }
//            }
//            
//            var startPoint = CGPoint(x: contentView.frame.width/2, y: contentView.convert(pollDescriptionContainer.frame.origin, to: scrollView).y + pollDescriptionContainer.frame.height + lineWidth/2)
//            startPoint.y += lineWidth/2
//            var endPoint = contentView.convert(hyperlinkArcLabel.center, to: scrollView)
//            endPoint.y -= hyperlinkArcLabel.frame.height/2
//            animateTransition(lineStart: startPoint, lineEnd: endPoint, lineCompletionBlocks: lineCompletionBlocks, animationBlocks: animationBlocks, completionBlocks: completionBlocks, animationDuration: lineAnimationDuration/2)
//        case .Images:
//            print("")
//            initialView     = hyperlinkIcon
//            destinationView = imagesIcon
//            
//            let scrollPoint = contentView.convert(destinationView.frame.origin, to: scrollView).y - initialView.bounds.height / 4.25// - navigationBarHeight / 2.5
//            
//            lineCompletionBlocks.append {
//                self.scrollToPoint(y: scrollPoint, duration: 0.4, delay: 0, completionBlocks: [{ reveal(view: self.imagesView, duration: 0.3, completionBlocks: []) }])//completionBlocks: [{
//            }
////            lineCompletionBlocks.append {
//                UIView.animate(withDuration: 0.3) { self.imagesArcLabel.alpha = 1 }
////            }
//            lineCompletionBlocks.append {
//                delay(seconds: 0.25) {
//                    self.stackImages.map {
//                        v in
//                        if let i = self.stackImages.firstIndex(of: v), let delay = Double(exactly: i) {
//                            UIView.animate(withDuration: 0.2, delay: delay * 0.1, animations: {
//                                v.transform = .identity
//                                v.alpha = 1 })
//                        }
//                    }
//                }
//                
//            }
//            if UserDefaults.App.hasSeenPollCreationIntroduction {
//                delay(seconds: 1) {
//                    delBanner.shared.contentType = .Warning
//                    if let content = delBanner.shared.content as? Warning {
//                        content.level = .Info
//                        content.text = "Дополните опрос изображениями (опционально)"
//                    }
//                    delBanner.shared.present(shouldDismissAfter: 2, delegate: nil)
//                }
//            }
////            delay(seconds: lineAnimationDuration * 0.2) {
////            self.addBadge()
//                self.imagesIcon.present(completionBlocks: [{
//                    self.imagesIcon.state = .On
//                    }])
////            }
//            
//            var startPoint = CGPoint(x: contentView.frame.width/2,
//                                     y: contentView.convert(hyperlinkView.frame.origin, to: scrollView).y + hyperlinkView.frame.height + lineWidth/2)
//            startPoint.y += lineWidth/2
//            var endPoint = contentView.convert(imagesArcLabel.center, to: scrollView)
//            endPoint.y -= imagesArcLabel.frame.height/2
//            animateTransition(lineStart: startPoint,
//                              lineEnd: endPoint,
//                              lineCompletionBlocks: lineCompletionBlocks,
//                              animationBlocks: animationBlocks,
//                              completionBlocks: completionBlocks)
//        case .Question:
//            initialView     = imagesIcon
//            destinationView = questionIcon
//            
//            let scrollPoint = contentView.convert(destinationView.frame.origin, to: scrollView).y - initialView.bounds.height / 4.25// - navigationBarHeight / 2.5
//            
//            lineCompletionBlocks.append {
//                self.scrollToPoint(y: scrollPoint, duration: 0.4, delay: 0, completionBlocks: [])
//            }
//
//            completionBlocks.append {
//                delay(seconds: 0.6) {
//                    self.performSegue(withIdentifier: Segues.App.NewSurveyToTypingViewController, sender: self.questionIcon)
//                }
//            }
//            UIView.animate(withDuration: 0.3) { self.questionArcLabel.alpha = 1 }
//            self.questionIcon.present(completionBlocks: [{
//                reveal(view: self.questionContainer, duration: 0.3, completionBlocks: [])
//                }])
//            
//            var startPoint = CGPoint(x: contentView.frame.width/2, y: contentView.convert(imagesView.frame.origin, to: scrollView).y + imagesView.frame.height + lineWidth/2)
//            startPoint.y += lineWidth/2
//            var endPoint = contentView.convert(questionArcLabel.center, to: scrollView)
//            endPoint.y -= questionArcLabel.frame.height/2//delta
//            animateTransition(lineStart: startPoint, lineEnd: endPoint, lineCompletionBlocks: lineCompletionBlocks, animationBlocks: animationBlocks, completionBlocks: completionBlocks)
//        case .Answers:
//            initialView     = questionIcon
//            destinationView = answerIcon
//            
//            let scrollPoint = contentView.convert(destinationView.frame.origin, to: scrollView).y - initialView.bounds.height / 4.25// - navigationBarHeight / 2.5
//            
//            lineCompletionBlocks.append {
//                self.scrollToPoint(y: scrollPoint, duration: 0.4, delay: 0, completionBlocks: [])
//            }
//            UIView.animate(withDuration: 0.3) { self.answerArcLabel.alpha = 1 }
//            
//            self.answerIcon.present(completionBlocks: [{
//                self.answerContainer.animateMaskLayer(duration: 0.3, completionBlocks: [], completionDelegate: self)
//                }])
//            
//            completionBlocks.append {
//                delay(seconds: 1) {
//                    self.selectedCellIndex = IndexPath(row: self.answers.count-1, section: 0)
//                    self.performSegue(withIdentifier: Segues.App.NewSurveyToTypingViewController, sender: self.selectedCellIndex)
//                }
//            }
//            var startPoint = CGPoint(x: contentView.frame.width/2, y: contentView.convert(questionContainer.frame.origin, to: scrollView).y + questionContainer.frame.height + lineWidth/2)
//            startPoint.y += lineWidth/2
//            var endPoint = contentView.convert(answerArcLabel.center, to: scrollView)
//            endPoint.y -= answerArcLabel.frame.height/2
//            animateTransition(lineStart: startPoint,
//                              lineEnd: endPoint,
//                              lineCompletionBlocks: lineCompletionBlocks,
//                              animationBlocks: animationBlocks,
//                              completionBlocks: completionBlocks)
//            //TODO: uncomment
//        //            AppData.shared.system.newPollTutorialRequired = false
//        case .Post:
//            scrollView.isScrollEnabled = true
//            let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.height + scrollView.contentInset.bottom)
//            scrollView.setContentOffset(bottomOffset, animated: true)
//            if let v = self.navigationItem.titleView as? CircleButton, let indicator = v.oval as? CAShapeLayer {
//                let anim = Animations.get(property: .LineWidth, fromValue: indicator.lineWidth, toValue: 0, duration: 0.3, timingFunction: CAMediaTimingFunctionName.easeInEaseOut, delegate: self, isRemovedOnCompletion: false, completionBlocks: [{
//                    indicator.lineWidth = 0
//                    delay(seconds: 0.3) {
//                        indicator.removeAllAnimations()
//                    }
//                    }])
//                indicator.add(anim, forKey: nil)
//            }
//        }
//    }
//    
//    private func animateProgress() {
//        let total = Stage.allCases.count - 1
//        let current = stage.rawValue
//        
//        let percentage = current * 100 / total
//        let strokeStart = CGFloat(1.0 - Double(percentage) / 100.0)
//        
//        if let v = self.navigationItem.titleView as? CircleButton, let indicator = v.oval as? CAShapeLayer {
//            //1 -> 0
//            let anim = Animations.get(property: .StrokeStart, fromValue: indicator.strokeStart, toValue: strokeStart, duration: 0.5, timingFunction: CAMediaTimingFunctionName.easeInEaseOut, delegate: self, isRemovedOnCompletion: false, completionBlocks: [{
//                indicator.strokeStart = strokeStart
//                delay(seconds: 0.3) {
//                    indicator.removeAllAnimations()
//                }
//                }])
//            indicator.add(anim, forKey: nil)
////            indicator.strokeStart = strokeStart
//        }
//    }
//    
//    private func setAnswerContainerHeight(animated: Bool = true) {
//        let rectOfCell = self.tableView.rectForRow(at: IndexPath(row: answers.count, section: 0))
//        answerContainer.setNeedsLayout()
//        tableViewHeight.constant = tableView.convert(rectOfCell, to: tableView.superview).maxY + 16
//        answerContainer.layoutIfNeeded()
//        scrollView.contentSize.height = tableView.convert(rectOfCell.origin, to: scrollView).y + rectOfCell.height + 100
//    }
//    
//    @objc fileprivate func viewTapped(gesture: UITapGestureRecognizer) {
//        if gesture.state == .ended, let v = gesture.view {
//            if let icon = v as? CircleButton {
//                if icon === topicIcon {
//                    //                    currentStage = .Category
//                    performSegue(withIdentifier: Segues.App.NewSurveyToCategorySelection, sender: nil)
//                } else if icon === anonIcon {
//                    //                    currentStage = .Anonymity
//                    performSegue(withIdentifier: Segues.App.NewSurveyToAnonimitySelection, sender: nil)
//                } else if icon === privacyIcon {
//                    //                    currentStage = .Privacy
//                    performSegue(withIdentifier: Segues.App.NewSurveyToPrivacySelection, sender: nil)
//                } else if icon === commentsIcon {
//                        //                    currentStage = .Privacy
//                        performSegue(withIdentifier: Segues.App.NewSurveyToCommentingSelection, sender: nil)
//                } else if icon === votesIcon {
//                    //                    currentStage = .Votes
//                    performSegue(withIdentifier: Segues.App.NewSurveyToVotesCountViewController, sender: nil)
//                } else if icon === titleIcon {
//                    //                    currentStage = .Title
//                    performSegue(withIdentifier: Segues.App.NewSurveyToTypingViewController, sender: icon)
//                } else if icon === questionIcon {
//                    //                    currentStage = .Title
//                    performSegue(withIdentifier: Segues.App.NewSurveyToTypingViewController, sender: icon)
//                } else if icon === pollDescriptionIcon {
//                    //                    currentStage = .Question
//                    performSegue(withIdentifier: Segues.App.NewSurveyToTypingViewController, sender: icon)
//                } else if icon === hotIcon {
//                    performSegue(withIdentifier: Segues.App.NewSurveyToHotSelection, sender: nil)
//                }
//            } else if let label = v as? UILabel {
//                if label === pollTitleContainer {
//                    performSegue(withIdentifier: Segues.App.NewSurveyToTypingViewController, sender: titleIcon)
//                } else if label === pollDescriptionContainer {
//                    performSegue(withIdentifier: Segues.App.NewSurveyToTypingViewController, sender: pollDescriptionIcon)
//                } else if label === questionContainer {
//                    performSegue(withIdentifier: Segues.App.NewSurveyToTypingViewController, sender: questionIcon)
//                } else if label === hyperlinkLabel {
//                    if hyperlink == nil {
//                        if let text = UIPasteboard.general.string, !text.isEmpty {
//                            if let url = URL(string: text) {
//                                UIView.transition(with: hyperlinkLabel, duration: 0.3, options: .transitionCrossDissolve, animations: {
//                                    self.hyperlinkLabel.cornerRadius = 15
//                                    self.hyperlinkLabel.text = url.absoluteString
//                                    self.hyperlinkSkipButton.setTitle("ОЧИСТИТЬ", for: .normal)
//                                })
//                                hyperlink = url
//                            }
//                        }
//                    } else {
//                        let config = SFSafariViewController.Configuration()
//                        let vc = SFSafariViewController(url: hyperlink!, configuration: config)
//                        present(vc, animated: true)
//                    }
//                }
//            } else if v.accessibilityIdentifier == "addImage", let parentView = v.superview {
//                if parentView === image_1 {
//                    imagePosition = 0
//                } else if parentView === image_2 {
//                    imagePosition = 1
//                } else {
//                    imagePosition = 2
//                }
//                
//                chooseImage()
//            } else if let v = gesture.view as? UIImageView, let image = v.image {
//                if v.superview == image_1 {
//                    imagePosition = 0
//                } else if v.superview == image_2 {
//                    imagePosition = 1
//                } else {
//                    imagePosition = 2
//                }
//                performSegue(withIdentifier: Segues.App.Image, sender: image)
//            } else if let v = gesture.view, v.accessibilityIdentifier == "imageEditingList" {
//                print("ImageEditingListTableViewController")
//            } else if effectView != nil, let frameView = highlitedImage.keys.first as? UIView, let imageView = highlitedImage.values.first as? UIImageView, let keyWindow = navigationController?.view.window {
//                dismissImageEffectView(_effectView: effectView!, frameView: frameView, imageView: imageView, keyWindow: keyWindow)
//            } else if v.accessibilityIdentifier == "balance" {
//                delBanner.shared.contentType = .TotaLCost
//                if let content = delBanner.shared.content as? TotalCost {
//                    content.balance = Userprofiles.shared.current!.balance
//                }
//                delBanner.shared.present(shouldDismissAfter: 5, delegate: nil)
//            } else if v == hyperlinkInfoButton {
//                delBanner.shared.contentType = .Warning
//                if let content = delBanner.shared.content as? Warning {
//                    content.level = .Info
//                    content.text = "Прикрепите веб-ссылку (опционально)"
//                }
//                delBanner.shared.present(shouldDismissAfter: 2, delegate: nil)
//            } else if v == imagesInfoButton {
//                delBanner.shared.contentType = .Warning
//                if let content = delBanner.shared.content as? Warning {
//                    content.level = .Info
//                    content.text = "Прикрепите изображение (опционально)"
//                }
//                delBanner.shared.present(shouldDismissAfter: 2, delegate: nil)
//            } else if v === pollTitleTextView {
//                performSegue(withIdentifier: Segues.App.NewSurveyToTypingViewController, sender: titleIcon)
//            } else if v === pollDescriptionTextView {
//                performSegue(withIdentifier: Segues.App.NewSurveyToTypingViewController, sender: pollDescriptionIcon)
//            } else if v === questionTextView {
//                performSegue(withIdentifier: Segues.App.NewSurveyToTypingViewController, sender: questionIcon)
////            } else if v === AnswerCell {
////                performSegue(withIdentifier: Segues.App.NewSurveyToTypingViewController, sender: questionIcon)
//            }
//        }
//    }
//
//    
//    @objc private func viewPressed(gesture: UILongPressGestureRecognizer) {
//        
//        if let imageView = gesture.view as? UIImageView, let keyWindow = navigationController?.view.window, effectView == nil, let parentView = imageView.superview {
//            
//            if parentView === image_1 {
//                imagePosition = 0
//            } else if parentView === image_2 {
//                imagePosition = 1
//            } else {
//                imagePosition = 2
//            }
//            
//            //            isEffectViewActive = true
//            
//            let darkEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
//            darkEffectView.effect = nil
//            darkEffectView.frame = keyWindow.frame
//            darkEffectView.addEquallyTo(to: keyWindow)
//            darkEffectView.contentView.isUserInteractionEnabled = true
//            effectView = darkEffectView
//            
//            let tap = UITapGestureRecognizer(target: self, action: #selector(NewPollController.viewTapped(gesture:)))
//            darkEffectView.contentView.addGestureRecognizer(tap)
//            
//            let copy = UIView(frame: parentView.frame)
//            copy.backgroundColor = .white
//            copy.center = parentView.superview!.convert(parentView.center, to: darkEffectView.contentView)
//            copy.layer.masksToBounds = true
//            copy.layer.cornerRadius = copy.frame.height / 2
//            darkEffectView.contentView.addSubview(copy)
//            
//            let imageCopy = UIImageView(frame: imageView.frame)
//            imageCopy.image = imageView.image
//            //            imageCopy.image?.cgImage. = imageView.image
//            imageCopy.contentMode = UIView.ContentMode.scaleAspectFill
//            imageCopy.layer.masksToBounds = true
//            imageCopy.layer.cornerRadius = imageCopy.frame.height / 2
//            imageCopy.center = CGPoint(x: copy.frame.width / 2, y: copy.frame.height / 2)
//            imageCopy.isUserInteractionEnabled = true
//            copy.addSubview(imageCopy)
//            
//            var listPos = CGPoint.zero
//            let listSize = CGSize(width: self.view.frame.width * 0.25 * 2, height: self.view.frame.width * 0.25 * 1.3)
//            let multiplier: CGFloat = copy.center.x == view.center.x ? 1.2 : 0.9
//            if copy.center.x == view.center.x {
//                listPos.x = view.center.x - listSize.width/2
//            } else if (copy.frame.origin.x + listSize.width) > view.frame.width  {
//                listPos.x = copy.frame.origin.x - listSize.width
//            } else if (copy.frame.origin.x + listSize.width) < view.frame.width {
//                listPos.x = copy.frame.origin.x + copy.frame.width * multiplier
//            }
//            if copy.center.x == view.center.x {
//                if (copy.frame.origin.y + listSize.height) > view.frame.height  {
//                    listPos.y = copy.frame.origin.y - listSize.height * multiplier
//                } else if (copy.frame.origin.y + listSize.height) <= view.frame.height {
//                    listPos.y = copy.frame.origin.y + copy.frame.height * multiplier
//                }
//            } else if (copy.frame.origin.y + listSize.height) > view.frame.height  {
//                listPos.y = copy.frame.origin.y - listSize.height
//            } else if (copy.frame.origin.y + listSize.height) <= view.frame.height {
//                listPos.y = copy.frame.origin.y + copy.frame.height
//            }
////            let tap_1 = UITapGestureRecognizer(target: self, action: #selector(CreateNewSurveyViewController.iconTapped(gesture:)))
////            imageCopy.addGestureRecognizer(tap_1)
//            
//            let destinationSize = CGSize(width: copy.frame.size.width * 1.2,
//                                         height: copy.frame.size.height * 1.2)
//            let destinationImageSize = CGSize(width: imageCopy.frame.size.width * 1.2,
//                                              height: imageCopy.frame.size.height * 1.2)
//            let destinationCenter = CGPoint(x: copy.center.x - (destinationSize.width - copy.frame.size.width) / 4,
//                                            y: copy.center.y - (destinationSize.height - copy.frame.size.height) / 4)
//            let destinationImageCenter = CGPoint(x: destinationSize.width / 2,
//                                                 y: destinationSize.height / 2)
//            
//            UIView.animate(
//                withDuration: 0.4,
//                delay: 0,
//                usingSpringWithDamping: 0.6,
//                initialSpringVelocity: 1.1,
//                options: [.curveEaseOut],
//                animations: {
//                    copy.frame.size = destinationSize
//                    copy.center = destinationCenter
//                    copy.layer.cornerRadius = copy.frame.height / 2
//                    imageCopy.frame.size = destinationImageSize
//                    imageCopy.center = destinationImageCenter
//                    imageCopy.layer.cornerRadius = imageCopy.frame.height / 2
//            })
//            
//            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.2, delay: 0, options: [.curveEaseIn], animations: {
//                darkEffectView.effect = UIBlurEffect(style: .dark)
//            }) {
//                _ in
//                self.highlitedImage.removeAll()
//                self.highlitedImage[copy] = imageCopy
////                if self.imageEditingList != nil {
//                    self.navigationController!.addChild(self.imageEditingList!)
//                    self.imageEditingList!.view.alpha = 1
//                    self.imageEditingList!.view.frame.size = listSize
//                    self.imageEditingList!.view.frame.origin = listPos
//                    darkEffectView.contentView.addSubview(self.imageEditingList!.view)
//                    self.imageEditingList!.tableView.reloadData()
//                    self.imageEditingList!.didMove(toParent: self.navigationController!)
////                }
//            }
//        }
//        
//    }
// 
//    private func setTitle() {
//        let navTitle = UILabel()
//        navTitle.numberOfLines = 2
//        navTitle.textAlignment = .center
//        let attrString = NSMutableAttributedString()
//        attrString.append(NSAttributedString(string: title!, attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: 19), foregroundColor: .black, backgroundColor: .clear)))
//        if topic != nil {
//            //MARK: TODO - Fatal error when parent is nil
//            attrString.append(NSAttributedString(string: "\n\(topic!.parent!.title)", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Regular, size: 13), foregroundColor: .darkGray, backgroundColor: .clear)))
//        }
//        navTitle.attributedText = attrString
//        navigationItem.titleView = navTitle
//    }
//    
//    func scrollToPoint(y: CGFloat, duration: TimeInterval = 0.5, delay: TimeInterval = 0, completionBlocks: [Closure]) {
//        UIView.animate(withDuration: duration, delay: delay, options: [.curveEaseInOut], animations: {
//            self.scrollView.contentOffset.y = y
//        }) {
//            _ in
//            completionBlocks.map({ $0() })
//        }
//    }
//    
//    private func chooseImage() {
//        imagePicker.allowsEditing = true
//        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)//UIAlertController(title: "Выберите источник", message: "", preferredStyle: UIAlertControllerStyle.actionSheet)
//        
//        //let titleAttrString = NSMutableAttributedString(string: "Выберите источник", attributes: semiboldAttrs)
//        //alert.setValue(titleAttrString, forKey: "attributedTitle")
//        let photo = UIAlertAction(title: "Фотоальбом", style: UIAlertAction.Style.default, handler: {
//            (action: UIAlertAction) in
//            self.imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
//            self.present(self.imagePicker, animated: true, completion: nil)
//        })
//        photo.setValue(UIColor.black, forKey: "titleTextColor")
//        alert.addAction(photo)
//        let camera = UIAlertAction(title: "Камера", style: UIAlertAction.Style.default, handler: {
//            (action: UIAlertAction) in
//            self.imagePicker.sourceType = UIImagePickerController.SourceType.camera
//            self.present(self.imagePicker, animated: true, completion: nil)
//        })
//        camera.setValue(UIColor.black, forKey: "titleTextColor")
//        camera.setValue(UIColor.black, forKey: "titleTextColor")
//        alert.addAction(camera)
//        let cancel = UIAlertAction(title: "Отмена", style: UIAlertAction.Style.destructive, handler: nil)
//        alert.addAction(cancel)
//        present(alert, animated: true, completion: nil)
//    }
//    
//    private func dismissImageEffectView(_effectView: UIVisualEffectView, frameView: UIView, imageView: UIImageView, keyWindow: UIWindow) {
//        //        isEffectViewActive = false
//        
//        var destinationView: UIView!
//        
//        switch imagePosition {
//        case 0:
//            destinationView = image_1
//        case 1:
//            destinationView = image_2
//        default:
//            destinationView = image_3
//        }
//        
//        let destinationFrame        = CGRect(origin: destinationView.superview!.convert(destinationView.frame.origin, to: keyWindow),
//                                             size: destinationView.frame.size)
//        let destinationImageView    = destinationView.subviews.filter { $0 is UIImageView}.first!
//        let destinationImageFrame   = CGRect(origin: destinationImageView.convert(destinationImageView.frame.origin, to: destinationImageView),
//                                             size: destinationImageView.frame.size)
//        
//        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.2, delay: 0, options: [.curveEaseInOut], animations: {
//            frameView.frame = destinationFrame
//            imageView.frame = destinationImageFrame
//            frameView.layer.cornerRadius = frameView.frame.height / 2
//            imageView.layer.cornerRadius = imageView.frame.height / 2
//            self.imageEditingList?.view.alpha = 0
//        })
//        
//        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations: {
//            _effectView.effect = nil
//        }) {
//            _ in
//            self.highlitedImage.removeAll()
//            self.imageEditingList?.view.removeFromSuperview()
//            self.imageEditingList?.removeFromParent()
//            self.effectView = nil
//            _effectView.removeFromSuperview()
//        }
//    }
//    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        navigationController?.setNavigationBarHidden(false, animated: true)
//        if let nc = navigationController as? NavigationControllerPreloaded {
//            nc.duration = 0.4
//            nc.transitionStyle = .Icon
//            if segue.identifier == Segues.App.NewSurveyToCategorySelection, let destinationVC = segue.destination as? CategorySelectionViewController {
//                nc.duration = 0.45
//                destinationVC.actionButtonHeight = topicIcon.frame.height
//            } else if segue.identifier == Segues.App.NewSurveyToTypingViewController, let destinationVC = segue.destination as? TextInputViewController {
//                nc.duration = 0.35
//                destinationVC.delegate = self
////                destinationVC.font = StringAttributes.font(name: StringAttributes.Fonts.Style.Regular, size: 17)
////                destinationVC.textColor = .black
//                if let icon = sender as? CircleButton {
//                    if icon === titleIcon {
//                        destinationVC.needsScaleAnim = pollTitle.isEmpty ? true : false
//                        destinationVC.type = .Title
//                        destinationVC.maxCharacters = ModelProperties.shared.surveyTitleMaxLength
//                        destinationVC.minCharacters = ModelProperties.shared.surveyTitleMinLength
//                        destinationVC.textContent = pollTitle//.isEmpty ? "" : pollTitle
//                    } else if icon === pollDescriptionIcon {
//                        destinationVC.needsScaleAnim = pollDescription.isEmpty ? true : false
//                        destinationVC.type = .Description
//                        destinationVC.maxCharacters = ModelProperties.shared.surveyDescriptionMaxLength
//                        destinationVC.minCharacters = ModelProperties.shared.surveyDescriptionMinLength
//                        destinationVC.textContent = pollDescription
//                    } else if icon === questionIcon {
//                        destinationVC.font = StringAttributes.font(name: StringAttributes.FontStyle.Regular.rawValue, size: 17)
//                        destinationVC.textContent = question
//                        if question.isEmpty {
//                            destinationVC.needsScaleAnim = true
//                            destinationVC.textContent = "\tВыберите наиболее подходящий вариант"
//                        }
//                        destinationVC.maxCharacters = ModelProperties.shared.surveyQuestionMaxLength
//                        destinationVC.minCharacters = ModelProperties.shared.surveyQuestionMinLength
//                        destinationVC.type = .Question
//                    }
//                } else if let indexPath = sender as? IndexPath, let cell = tableView.cellForRow(at: indexPath) as? AnswerSelectionCell {
//                    destinationVC.font = StringAttributes.font(name: StringAttributes.FontStyle.Regular.rawValue, size: 16)
//                    destinationVC.needsScaleAnim = cell.textView.text!.contains("Вариант") ? true : false
//                    destinationVC.type = .Answer
//                    destinationVC.maxCharacters = ModelProperties.shared.surveyAnswerTextMaxLength
//                    destinationVC.minCharacters = ModelProperties.shared.surveyAnswerTextMinLength
////                    destinationVC.titleString = "Вариант №\(indexPath.row + 1)"
//                    destinationVC.textContent = cell.textView.text!.contains("Вариант") ? "\t" : "\t\(cell.textView.text!.trimmingCharacters(in: .whitespaces))"
//                }
//                destinationVC.cornerRadius = pollTitleContainer.cornerRadius
//                destinationVC.color = selectedColor
//            } else if segue.identifier == Segues.App.NewSurveyToAnonimitySelection, let destinationVC = segue.destination as? BinarySelectionViewController {
//                destinationVC.color = selectedColor
//                destinationVC.selectionType = .Anonimity
//            } else if segue.identifier == Segues.App.NewSurveyToPrivacySelection, let destinationVC = segue.destination as? BinarySelectionViewController {
//                destinationVC.color = selectedColor
//                destinationVC.selectionType = .Privacy
//            } else if segue.identifier == Segues.App.NewSurveyToCommentingSelection, let destinationVC = segue.destination as? BinarySelectionViewController {
//                destinationVC.color = selectedColor
//                destinationVC.selectionType = .Comments
//            } else if segue.identifier == Segues.App.NewSurveyToHotSelection, let destinationVC = segue.destination as? BinarySelectionViewController {
//                destinationVC.color = selectedColor
//                destinationVC.selectionType = .Hot
//                destinationVC.cost = cost
//            } else if segue.identifier == Segues.App.NewSurveyToVotesCountViewController, let destinationVC = segue.destination as? VotesCountViewController {
//                destinationVC.votesCapacity = votesCapacity
//                destinationVC.cost = cost
//                //                destinationVC.actionButton.lineWidth = lineWidth
//                destinationVC.actionButtonWidthConstant = votesIcon.frame.width
//                destinationVC.color = selectedColor
////            } else if segue.identifier == Segues.App.Image, let destinationVC = segue.destination as? delImageViewController, let image = sender as? UIImage {
////                nc.duration = 0.25
////                nc.transitionStyle = .Icon
////                destinationVC.image = image
////                images.forEach { (_, dict) in
////                    if !dict.isEmpty, dict.first?.key == image {
////                        destinationVC.titleString = dict.first!.value
////                    }
////                }
////            } else if segue.identifier == Segues.NewSurvey.Results, let destinationVC = segue.destination as? NewSurveyResultViewController, survey != nil {
////                destinationVC.survey = survey!
//            }
//        }
//    }
//    
//    func setTitleForImage(_ image: UIImage, text: String) {
//        var key: Int?
//        images.forEach { (k, dict) in
//            if !dict.isEmpty, dict.first?.key == image {
//                key = k
//            }
//        }
//        if key != nil {
//            images[key!] = [image: text]
//        }
//    }
//    
//    func appendAnswer(_ _delay: Double = 0) {
//        delay(seconds: _delay) {
//            self.answers.append("")
//            self.tableView.insertRows(at: [IndexPath(row: self.answers.count-1, section: 0)], with: .top)
//            if self.answers.count == ModelProperties.shared.surveyAnswerMaxFreeCount + 1 {
//                delBanner.shared.contentType = .Warning
//                if let content = delBanner.shared.content as? Warning {
//                    content.level = .Warning
//                    content.text = "5 вариантов ответов бесплатно. За снятие ограничений будет дополнительно списано \(PriceList.shared.extraAnswers) баллов"
//                }
//                delBanner.shared.present(shouldDismissAfter: 5, delegate: nil)
//            }
//            //.selectRow(at: IndexPath(row: answers.count-1, section: 0), animated: true, scrollPosition: .bottom)
//            self.setAnswerContainerHeight()
//            //                    UIView.animate(withDuration: 0.15){
//            //                        self.scrollToPoint(y: self.scrollView.contentSize.height, completionBlocks: [])
//            //                    }
//            delay(seconds: 0.2) {
//                self.selectedCellIndex = IndexPath(row: self.answers.count-1, section: 0)
//                self.performSegue(withIdentifier: Segues.App.NewSurveyToTypingViewController, sender: self.selectedCellIndex)
//            }
//        }
//    }
//}
//
//extension NewPollController: CAAnimationDelegate {
//    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
//        if flag, let completionBlocks = anim.value(forKey: "completionBlocks") as? [Closure] {
//            completionBlocks.map{ $0() }
//        } else if let completionBlocks = anim.value(forKey: "maskCompletionBlocks") as? [Closure] {
//            completionBlocks.map{ $0() }
//        } else if let initialLayer = anim.value(forKey: "layer") as? CAShapeLayer, let path = anim.value(forKey: "destinationPath") {
//            initialLayer.path = path as! CGPath
//            if let completionBlock = anim.value(forKey: "completionBlock") as? Closure {
//                completionBlock()
//            }
//        }
//    }
//}
//
//extension NewPollController: CallbackObservable {
//    func callbackReceived(_ sender: Any) {
//        if let _category = sender as? Topic {
//            topic = _category
//        } else if let textView = sender as? UITextView, let accessibilityIdentifier = textView.accessibilityIdentifier {
//            if accessibilityIdentifier == "Title" {
//                pollTitle = textView.text
//            } else if accessibilityIdentifier == "Description" {
//                pollDescription = textView.text
//            }  else if accessibilityIdentifier == "Question" {
//                
//            }
//        } else if let string = sender as? String {
//            if string == "openImage" {
//                if let image = self.highlitedImage.first?.value.image {
//                    delay(seconds: 0.3) { self.performSegue(withIdentifier: Segues.App.Image, sender: image) }
//                }
//            } else if string == "replaceImage" {
//                delay(seconds: 0.3) { self.chooseImage() }
//            } else if string == "deleteImage" {
//                var imageView: UIImageView?
//                
//                switch imagePosition {
//                case 0:
//                    imageView = image_1.subviews.filter { $0 is UIImageView }.first as? UIImageView
//                case 1:
//                    imageView = image_2.subviews.filter { $0 is UIImageView }.first as? UIImageView
//                default:
//                    imageView = image_3.subviews.filter { $0 is UIImageView }.first as? UIImageView
//                }
//                
//                UIView.animate(withDuration: 0.4, delay: 0.3, options: [.curveEaseInOut], animations: {
//                    imageView?.alpha = 0
//                }) {
//                    _ in
//                    imageView?.removeFromSuperview()
//                    self.images[self.imagePosition] = [:]
//                }
//                //                showAlert(type: .Ok, buttons: [["Удалить": [CustomAlertView.ButtonType.Ok: nil]]], text: "Ошибка вызова сервера, пожалуйста, обновите список")
//            } else if string == "addAnswer" {
//                if answers.count < MAX_ANSWERS_COUNT {
//                    appendAnswer()
//                }
////                if answers.count == MAX_ANSWERS_COUNT, let cell = tableView.cellForRow(at: IndexPath(row: answers.count, section: 0)) as? AddAnswerCell {
////                    UIView.animate(withDuration: 0.2) {
////                        cell.addButton.alpha = 0
////                    }
////                }
//            }
//        } else if let index = sender as? IndexPath, let cell = tableView.cellForRow(at: index) as? AnswerSelectionCell {
//            
//        }
//    }
//}
//
//extension NewPollController: UIImagePickerControllerDelegate {
//    
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        if let origImage = info[.editedImage] as? UIImage {
//            let imageData = origImage.jpegData(compressionQuality: 0.6)
//            if let image = UIImage(data: imageData!) {
//                images[imagePosition] = [image: ""]
//                analyze(image: image)
//            }
//        }
//        dismiss(animated: true) {
//            if let nc = self.navigationController as? NavigationControllerPreloaded {
//                nc.isShadowed = true
//            }
//        }
//    }
//    
//    private func analyze(image: UIImage) {
//        
//        var handler: VNImageRequestHandler!
//        
//        if #available(iOS 13, *) {
//            //            var handler: VNImageRequestHandler?
//            //
//            //            #if os(iOS)
//            //            let request = VNClassifyImageRequest()
//            //            if let ciImage = image.ciImage {
//            //                handler = VNImageRequestHandler(ciImage: ciImage, options: [])
//            //            } else if let cgImage = image.cgImage {
//            //                handler = VNImageRequestHandler(cgImage: cgImage, options: [])
//            //            }
//            
//            //            try? handler?.perform(<#T##requests: [VNRequest]##[VNRequest]#>)
//            //            let observations = request.results as? [VNClassificationObservation]
//            //  let searchObservations = observations?.filter { $0.hasMinimumRecall(0.0, forPrecision: 0.7) }
//            
//            //            for index in contestantImageURLs.indices {
//            //                let contestantImageURL = contestantImageURLs[index]
//            //                if let contestantFPO = featureprintObservationForImage(atURL: contestantImageURL) {
//            //                    do {
//            //                        var distance = Float(0)
//            //                        try contestantFPO.computeDistance(&distance, to: originalFPO)
//            //                        ranking.append((contestantIndex: index, featureprintDistance: distance))
//            //                    } catch {
//            //                        print("Error computing distance between featureprints.")
//            //                    }
//            //                }
//            //            }
//            
//        } else {
//            guard let request = imageObservationRequest else {
//                return
//            }
//            if let ciImage = image.ciImage {
//                handler = VNImageRequestHandler(ciImage: ciImage)
//            } else if let cgImage = image.cgImage {
//                handler = VNImageRequestHandler(cgImage: cgImage)
//            }
//            try? handler.perform([request])
//        }
//    }
//}
//
//extension NewPollController: UITableViewDelegate, UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return answers.count + 1
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        if indexPath.row == answers.count, let cell = tableView.dequeueReusableCell(withIdentifier: "addAnswer", for: indexPath) as? AddAnswerCell {
////            cell.addButton.setTitleColor(selectedColor, for: .normal)
//            cell.delegate = self
//            cell.backgroundColor = .clear
//            cell.separatorInset = UIEdgeInsets(top: 0, left: cell.frame.width, bottom: 0, right: .greatestFiniteMagnitude)
//            return cell
//        } else if let cell = tableView.dequeueReusableCell(withIdentifier: "answer", for: indexPath) as? AnswerSelectionCell {
//            cell.setNeedsLayout()
//            cell.layoutIfNeeded()
////            cell.frameView.cornerRadius = 15
//            cell.tagView.cornerRadius = cell.tagView.frame.height/2
//            cell.tagView.text = "\(indexPath.row+1)"
//            cell.tagView.textColor = .white
//            cell.tagView.backgroundColor = tagColors[indexPath.row]
//            cell.tagView.textAlignment = .center
//            cell.index = indexPath
//            cell.delegate = self
//            cell.cornerRadius = 15
//            cell.separatorInset = UIEdgeInsets(top: 5, left: 0, bottom: 50, right: 0)
//            var textContent = "\tВариант №\(indexPath.row+1)"
//            if let text = answers[indexPath.row] as? String, !text.isEmpty {
//                textContent = text
//            }
//            let paragraphStyle = NSMutableParagraphStyle()
//            paragraphStyle.hyphenationFactor = 1.0
//            let attributedString = NSMutableAttributedString(string: textContent, attributes: [NSAttributedString.Key.paragraphStyle:paragraphStyle])
//            attributedString.addAttributes(StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Regular, size: 16), foregroundColor: .black, backgroundColor: .clear), range: textContent.fullRange())
//            cell.textView.attributedText = attributedString
////            cell.textView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//            if cell.textView.gestureRecognizers!.isEmpty {
//                let tap = UITapGestureRecognizer(target: self, action: #selector(NewPollController.viewTapped(gesture:)))
//                cell.textView.addGestureRecognizer(tap)
//            }
//            return cell
//        }
//        return UITableViewCell()
//    }
//    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        selectedCellIndex = indexPath
//        if let _ = tableView.cellForRow(at: selectedCellIndex!) as? AddAnswerCell, answers.count == MAX_ANSWERS_COUNT{
//            return
//        }
//        performSegue(withIdentifier: Segues.App.NewSurveyToTypingViewController, sender: indexPath)
//    }
//    
//    
//    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//        if (tableView.cellForRow(at: indexPath) as? AddAnswerCell) != nil || answers.count == 1 {
//            return UISwipeActionsConfiguration(actions: [])
//        }
//        let deleteAction = UIContextualAction(style: .destructive, title: "", handler: { (action, view, completion) in
//            self.answers.remove(at: indexPath.row)
//            self.tableView.selectRow(at: IndexPath(row: indexPath.row-1, section: 0), animated: true, scrollPosition: .bottom)
//            tableView.deleteRows(at: [indexPath], with: .top)
//            delay(seconds: 0.2) {
//                self.tableView.reloadData()
//                self.setAnswerContainerHeight()
//            }
//            completion(true)
//        })
//        deleteAction.backgroundColor = selectedColor.withAlphaComponent(0.001)//K_COLOR_RED
//        deleteAction.image = UIImage(named: "trash_icon")?.resized(to: CGSize(width: 32, height: 32))
//        return UISwipeActionsConfiguration(actions: [deleteAction])
//    }
//
//    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
//        if (tableView.cellForRow(at: indexPath) as? AddAnswerCell) != nil || answers.count == 1 {
//            return nil
//        }
//        let deleteButton = UITableViewRowAction(style: .default, title: "Удалить") { (action, indexPath) in
//            self.answers.remove(at: indexPath.row)
//            self.tableView.selectRow(at: IndexPath(row: indexPath.row-1, section: 0), animated: true, scrollPosition: .bottom)
//            tableView.deleteRows(at: [indexPath], with: .bottom)
//            delay(seconds: 0.3) {
//                self.setAnswerContainerHeight()
//            }
//        }
//        return [deleteButton]
//    }
//    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if let cell = tableView.cellForRow(at: indexPath) as? AnswerSelectionCell {
//            let sizeThatFitsTextView = cell.textView.sizeThatFits(CGSize(width: cell.textView.frame.size.width, height: CGFloat(MAXFLOAT)))
//            return sizeThatFitsTextView.height + 16
////            if let cell = tableView.cellForRow(at: indexPath) as? QuestionTitleCreationCell {
////                var yLength: CGFloat = 0
////                for v in cell.contentView.subviews {
////                    if v.isKind(of: UILabel.self) {
////                        yLength = v.frame.origin.y + v.frame.size.height
////                    }
////                }
////                let sizeThatFitsTextView = cell.textView.sizeThatFits(CGSize(width: cell.textView.frame.size.width, height: CGFloat(MAXFLOAT)))
////                var _questionTitleRowHeight: CGFloat = 0//Old
////                if questionTitleRowHeight != 0 {
////                    _questionTitleRowHeight = questionTitleRowHeight
////                }
////                questionTitleRowHeight = yLength + sizeThatFitsTextView.height + 10
////                if questionTitleRowHeight != _questionTitleRowHeight {
////                    currentOffsetY = questionTitleRowHeight - _questionTitleRowHeight
////                }
////                return questionTitleRowHeight
////            }
////            else {
////                return questionTitleRowHeight
////            }
//        }
//        return UITableView.automaticDimension
//    }
//    
//    private func postSurvey() {
////        survey = Survey(type: Survey.SurveyType.Poll,
////                        title: pollTitle,
////                        topic: topic!,
////                        description: pollDescription,
////                        question: question,
////                        answers: answers,
////                        media: images,
////                        url: hyperlink,
////                        voteCapacity: votesCapacity,
////                        isPrivate: isPrivate,
////                        isAnonymous: isAnonymous,
////                        isCommentingAllowed: isCommentingAllowed,
////                        isHot: isHot,
////                        isFavorite: false,
////                        isOwn: true)
//        
//        performSegue(withIdentifier: Segues.NewSurvey.Results, sender: nil)
//        
//        
//        
//        func getDict() -> [String: Any] {
//            var dict: [String: Any] = [:]
//
//            dict[DjangoVariables.Survey.type]                   = Survey.SurveyType.Poll.rawValue
//            dict[DjangoVariables.Survey.isAnonymous]            = isAnonymous
//            dict[DjangoVariables.Survey.category]               = topic!
//            dict[DjangoVariables.Survey.title]                  = pollTitle
//            dict[DjangoVariables.Survey.description]            = pollDescription
//            dict[DjangoVariables.Survey.isPrivate]              = isPrivate
//            dict[DjangoVariables.Survey.voteCapacity]           = votesCapacity
//            dict[DjangoVariables.Survey.isCommentingAllowed]    = isCommentingAllowed
//            dict[DjangoVariables.Survey.answers]                = answers//answersArray
//            dict[DjangoVariables.Survey.postHot]                = isHot
//            
//            //            var _answers: [[String: String]] = []
//            //            answers.forEach {
////                description in
////                _answers.append([DjangoVariables.SurveyAnswer.description: description.trimmingCharacters(in: .whitespaces)])
////            }
////            dict[DjangoVariables.Survey.answers] = _answers
//            
//            var _images: [[UIImage: String]] = []
//            images.forEach {
//                (index, dict) in
//                if let key = dict.keys.first,let value = dict.values.first {
//                    _images.append([key: value])
//                }
//            }
//            dict[DjangoVariables.Survey.images] = _images
//            if hyperlink != nil {
//                dict[DjangoVariables.Survey.hlink] = hyperlink!.absoluteString
//            }
//            return dict
//        }
//        
////        survey = Survey(type: .Poll, title: pollTitle, topic: topic!, description: pollDescription, question: question, answers: answers, media: images, url: hyperlink, voteCapacity: votesCapacity, isPrivate: isPrivate, isAnonymous: isAnonymous, isCommentingAllowed: isCommentingAllowed, isHot: isHot, isFavorite: false, isOwn: true)
//        performSegue(withIdentifier: Segues.NewSurvey.Results, sender: nil)
//        
//        
//        
////        API.shared.postSurvey(survey: survey!) {
////            json, error in
////            if error != nil {
////                NotificationCenter.default.post(name: Notifications.Surveys.NewSurveyPostError, object: ["error": error!.localizedDescription])
////            } else if json != nil {
////                //Attach ID to survey and append to existing array
////                if let id = json!["id"].intValue as? Int, let _answers = json!["answers"].arrayValue as? [JSON], let _media = json!["media"].arrayValue as? [JSON] {
////                    self.survey!.id = id
////                    Surveys.shared.all.append(self.survey!)
////                    Surveys.shared.newReferences.append(self.survey!.reference)
////                    Surveys.shared.ownReferences.append(self.survey!.reference)
////
////                    for _answer in _answers {
////                        if let answer = self.survey!.answers.filter({ $0.title == _answer[DjangoVariables.SurveyAnswer.title].stringValue }).first {
////                            answer.id = _answer[DjangoVariables.ID].intValue
////                        }
////                    }
////
////                    for _mediafile in _media {
////                        if let media = self.survey!.media.filter({ $0.order == _mediafile["order"].intValue }).first {
////                            media.id = _mediafile[DjangoVariables.ID].intValue
////                            media.imageURL = URL(string: _mediafile["image"].stringValue)
////                        }
////                    }
////
////                    NotificationCenter.default.post(name: Notifications.Surveys.UpdateNewSurveys, object: nil)
////                    NotificationCenter.default.post(name: Notifications.Surveys.SurveysByCategoryUpdated, object: nil)
////                    NotificationCenter.default.post(name: Notifications.Surveys.OwnSurveysUpdated, object: nil)
////                } else {
////                    NotificationCenter.default.post(name: Notifications.Surveys.NewSurveyPostError, object: ["error": "Не удалось прочитать данные"])
////                }
////            }
////        }
//
//        
//        
////        //Prepare new Survey w/o ID
////        if let _survey = Survey(newWithoutID: getDict()) {
////            survey = _survey
////            performSegue(withIdentifier: Segues.NewSurvey.Results, sender: nil)
////            apiManager.postSurvey(survey: survey!) {
////                json, error in
////                if error != nil {
////                    NotificationCenter.default.post(name: Notifications.Surveys.NewSurveyPostError, object: ["error": error!.localizedDescription])
////                } else if json != nil {
////                    //Attach ID to survey and append to existing array
////                    if let _ID = json!["id"].intValue as? Int, let _answers = json!["answers"].arrayValue as? [JSON] {
////                        self.survey!.ID = _ID
////                        for _answer in _answers {
////                            if let answer = SurveyAnswer(json: _answer) {
////                                self.survey!.answers.append(answer)
////                            }
////                        }
////                        Surveys.shared.append(object: self.survey!, type: .Downloaded)
////                        //Create SurveyLink & append to own & new arrays
////                        if let surveyLink = self.survey!.toShortSurvey() {
////                            Surveys.shared.categorizedLinks[self.category!]?.append(surveyLink)
////                            Surveys.shared.append(object: surveyLink, type: .OwnLinks)
////                            Surveys.shared.append(object: surveyLink, type: .NewLinks)
////                            //Send notification
////                            NotificationCenter.default.post(name: Notifications.Surveys.NewSurveysUpdated, object: nil)
////                            NotificationCenter.default.post(name: Notifications.Surveys.SurveysByCategoryUpdated, object: nil)
////                            NotificationCenter.default.post(name: Notifications.Surveys.OwnSurveysUpdated, object: nil)
////                        }
////                    } else {
////                        NotificationCenter.default.post(name: Notifications.Surveys.NewSurveyPostError, object: ["error": "Не удалось прочитать данные"])
////                    }
////                }
////            }
////
////        } else {
////            //Print error
////            showAlert(type: .Warning, buttons:
////                [["Закрыть": [CustomAlertView.ButtonType.Ok: { self.navigationController?.popViewController(animated: false) } ]],
////                 ["К опросу": [CustomAlertView.ButtonType.Ok: nil]]],
////                      title: "Ошибка",
////                      body: "Вернуться к созданию опроса?")
////        }
//    }
//}
//
//class AddAnswerCell: UITableViewCell {
//    deinit {
//        print("***AddAnswerCell deinit***")
//    }
//    weak var delegate:   CallbackObservable?
//    @IBOutlet weak var addButton: UIButton!
//    @IBAction func addButtonTapped(_ sender: Any) {
//        delegate?.callbackReceived("addAnswer" as AnyObject)
//    }
//}
//
//class AnswerSelectionCell: UITableViewCell {
//    deinit {
//        print("***AnswerSelectionCell deinit***")
//    }
//    weak var delegate:   CallbackObservable?
//    var index:      IndexPath!
////    @IBOutlet weak var frameView: UIView!
//    @IBOutlet weak var textView: UITextView! {
//        didSet {
//            let recognizer = UITapGestureRecognizer(target: self, action: #selector(AnswerSelectionCell.handleTap(recognizer:)))
//            textView.addGestureRecognizer(recognizer)
//        }
//    }
//    @IBOutlet weak var tagView: UILabel! //{
////        didSet {
////            tagView.backgroundColor = .red
////        }
////    }
//    
//    @objc private func handleTap(recognizer: UITapGestureRecognizer) {
//        if recognizer.state == .ended {
//            delegate?.callbackReceived(index as AnyObject)
//        }
//    }
//    
//    
//}
//
////extension NewPollController: ServerProtocol {
////
////}
