//
//  NewSurveyViewController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 29.11.2019.
//  Copyright © 2019 Pavel Bukharov. All rights reserved.
//

import UIKit

class NewSurveyViewController: UIViewController, UINavigationControllerDelegate {
    
    class var newSurveyHeaderCell: UINib {
        return UINib(nibName: "NewSurveyHeaderCell", bundle: nil)
    }
    
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var bottomHeight: NSLayoutConstraint!
    @IBAction func cancelTapped(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func createTapped(_ sender: Any) {
        if checkNecessaryFields() {
            
        }
    }
    fileprivate var textEditingView: TextEditingView!
    @IBOutlet weak var tableView: UITableView!
//    @IBOutlet weak var privacySwitch: UISwitch!
    @IBOutlet weak var votesQuantity: UITextField!
    @IBOutlet weak var questionTextView: UITextView!
    
    //Survey data
    //Necessary
//    fileprivate var survey:         Survey!
    fileprivate var category:       SurveyCategory?
    fileprivate var privacy:        Bool = false
    fileprivate var anonymity:      SurveyAnonymity?
    fileprivate var votesCapacity:  Int = 100
    fileprivate var question:       String = ""
    fileprivate var answers:        [String] = [] {
        didSet {
            if !isRearranging {
                if answers.count > oldValue.count {
                    if #available(iOS 11.0, *) {
                        tableView.performBatchUpdates({
                            tableView.insertRows(at: [IndexPath(row: answers.count-1, section: 5)], with: .top)
                            //                            if let c = tableView.cellForRow(at: IndexPath(row: 0, section: 10)) {
                            //                                c.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                            //                            }
                            if let header = self.tableView.headerView(forSection: 4) as? NewSurveyHeaderCell {
                                self.configureHeader(header: header, forSection: 4)
                                //                                if let headerCell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 4)) {
                                //                                    self.tableView.beginUpdates()
                                //                                    headerCell.separatorInset = UIEdgeInsets(top: 0, left: headerCell.frame.width/9, bottom: 0, right: headerCell.frame.width/9)
                                //                                    self.tableView.endUpdates()
                                //                                }
                                //                    tableView.reloadData()//Sections(IndexSet(arrayLiteral: indexPath.section), with: .bottom)
                            }
                        })
                    } else {
                        tableView.beginUpdates()
                        tableView.insertRows(at: [IndexPath(row: images.count-1, section: 5)], with: .top)
                        tableView.endUpdates()
                    }
                }
            }
        }
    }
    //Unnecessary
    fileprivate var url:            String = ""
    fileprivate var images:         [[UIImage: String]] = [] {//[Int] = [] {//
        didSet {
            if !isRearranging {
                if images.count > oldValue.count {
                    if #available(iOS 11.0, *) {
                        tableView.performBatchUpdates({
                            tableView.insertRows(at: [IndexPath(row: images.count-1, section: 3)], with: .top)
                            //                            if let c = tableView.cellForRow(at: IndexPath(row: 0, section: 10)) {
                            //                                c.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                            //                            }
                            if let header = self.tableView.headerView(forSection: 2) as? NewSurveyHeaderCell {
                                self.configureHeader(header: header, forSection: 2)
                                //                    tableView.reloadData()//Sections(IndexSet(arrayLiteral: indexPath.section), with: .bottom)
                            }
                        })
                    } else {
                        tableView.beginUpdates()
                        tableView.insertRows(at: [IndexPath(row: images.count-1, section: 3)], with: .top)
                        tableView.endUpdates()
                    }
                }
            }
        }
    }
    
    fileprivate var verticalContentOffset: CGFloat = 0
    fileprivate var isRearranging = false
    fileprivate var isViewSetupCompleted = false
    fileprivate var leftEdgeInset: CGFloat = 0
    fileprivate var currentTF: UITextField? {
        didSet {
            UIView.animate(withDuration: 0.2) {
                if self.currentTF != nil {
                    self.currentTF?.backgroundColor = .groupTableViewBackground
                    self.tableView.isScrollEnabled  = false
                } else if oldValue != nil {
                    oldValue!.backgroundColor = .clear
                    self.tableView.isScrollEnabled  = true
                    //Save description
                    if let imageCell = oldValue?.superview?.superview as? ImageSelectionCell, let indexPath = self.tableView.indexPath(for: imageCell) {
                        for subview in imageCell.contentView.subviews {
                            if subview is UIImageView {
                                if let imageView = subview as? UIImageView, let image = imageView.image {
                                    self.images[indexPath.row][image] = oldValue!.text
                                }
                                break
                            }
                        }
                    }
                }
            }
        }
    }
    fileprivate var scrollCompletion: Closure?
    fileprivate var imagePicker         = UIImagePickerController ()
//    fileprivate var currentTV: UITextView? {
//        didSet {
//            UIView.animate(withDuration: 0.2) {
//                if self.currentTV != nil {
//                    self.currentTV?.backgroundColor = .groupTableViewBackground
//                    self.tableView.isScrollEnabled  = false
//                } else if oldValue != nil {
//                    oldValue!.backgroundColor = .clear
//                    self.tableView.isScrollEnabled  = true
//                    if let selectedIndex = self.tableView.indexPathForSelectedRow {
//                        self.tableView.deselectRow(at: selectedIndex, animated: false)
//                    }
//                }
//            }
//            if oldValue != nil {
//                if let cell = oldValue?.superview?.superview as? QuestionCreationCell {//}.isKind(of: QuestionCreationCell.self) {
//                    checkTextViewEdited(beganEditing: false, textView: oldValue!, placeholder: cell.placeholder)
//                } else if let cell = oldValue?.superview?.superview as? AnswerCreationCell {//}.isKind(of: QuestionCreationCell.self) {
//                    checkTextViewEdited(beganEditing: false, textView: oldValue!, placeholder: cell.placeholder)
//                }
//            }
//        }
//    }
    fileprivate var currentOffsetY:     CGFloat                     = 0 {
        didSet {
            offsetY += currentOffsetY
            if isMovedUp ?? false {
                UIView.animate(withDuration: 0.2, animations: {
                    self.view.frame.origin.y += -self.currentOffsetY
                })
            }
        }
    }
    fileprivate var offsetY:            CGFloat                     = 0
    fileprivate var kbHeight:           CGFloat!
    fileprivate var isMovedUp:          Bool?
//    fileprivate var isReplacingImage = false
    fileprivate var questionTextChanged = false

    fileprivate let sections = ["ПАРАМЕТРЫ", "ВОПРОС", "ИЗОБРАЖЕНИЯ", "", "ОТВЕТЫ", "", ""]
    fileprivate var questionRowHeight: CGFloat = 0 {
        didSet {
//            if oldValue != 0, oldValue != questionRowHeight {
//                if isMovedUp == nil, currentTV != nil {
//                    let tfPoint = CGPoint(x: currentTV!.frame.minX, y: questionRowHeight)// * 1.5)
//                    let convertedPoint = view.superview!.convert(tfPoint, from: currentTV?.superview)
////                    tableView.convert(<#T##point: CGPoint##CGPoint#>, to: <#T##UICoordinateSpace#>)
////                    view.snapshotView(afterScreenUpdates: false)
////                    UIApplication.shared.windows[0].convert(tfPoint, to: UIApplication.shared.windows[0])
//                    //TODO point convert
//                    if convertedPoint.y - 60 <= (view.frame.height - kbHeight) {
//                        print("tv is not below keyboard")
//                    } else {
//                        offsetY = -(view.frame.height - kbHeight - (convertedPoint.y - 60))// + 15 //+ (activeTextField?.bounds.height)! / 2
//                        //                currentOffsetY = offsetY
//                    }
//                } else if !isMovedUp!, currentTV != nil {
//                    let a = textViewIsAboveKeyBoard(currentTV!)
//                    let tfPoint = CGPoint(x: currentTV!.frame.minX, y: questionRowHeight)// * 1.5)
//                    let convertedPoint = view.convert(tfPoint, from: currentTV?.superview)
//                    //print(view.convert(CGPoint(x: currentTV!.frame.minX, y: currentTF!.frame.maxY), from: currentTV?.superview))
//                    //                    view.snapshotView(afterScreenUpdates: false)
//                    //                    UIApplication.shared.windows[0].convert(tfPoint, to: UIApplication.shared.windows[0])
//                    //TODO point convert
//                    if convertedPoint.y - 60 <= (view.frame.height - kbHeight) {
//                        print("tv is not below keyboard")
//                    } else {
//                        offsetY = -(view.frame.height - kbHeight - convertedPoint.y)// + 15 //+ (activeTextField?.bounds.height)! / 2
//                        //                currentOffsetY = offsetY
//                    }
//                }
//            }
        }
    }
    fileprivate var answersRowHeight: [Int: CGFloat] = [:]
    fileprivate var textViews: [UITextView] = []
    fileprivate var textFields: [UITextField] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        navigationController?.isNavigationBarHidden = false
//        navigationController?.setNavigationBarHidden(true, animated: false)
        setupViews()
        imagePicker.delegate = self
        tableView.delegate = self as UITableViewDelegate
        tableView.dataSource = self
        tableView.register(NewSurveyViewController.newSurveyHeaderCell, forHeaderFooterViewReuseIdentifier: "header")
        NotificationCenter.default.addObserver(self, selector: #selector(NewSurveyViewController.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(NewSurveyViewController.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        if #available(iOS 11.0, *) {
            tableView.dragInteractionEnabled = true
            tableView.dragDelegate = self
            tableView.dropDelegate = self
        }
    }
    
    private func setupViews() {
        DispatchQueue.main.async {
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
            self.navigationController?.navigationBar.shadowImage     = UIImage()
            self.navigationController?.navigationBar.isTranslucent   = false
            self.navigationController?.isNavigationBarHidden         = false
            self.navigationController?.navigationBar.barTintColor    = .white
            self.navigationItem.backBarButtonItem                    = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
            self.navigationItem.setHidesBackButton(true, animated: false)
            self.navigationController?.setNavigationBarHidden(true, animated: false)
            self.createButton.backgroundColor = K_COLOR_GRAY
        }

    }
    
//    fileprivate func setupGestures() {
//        let touch = UITapGestureRecognizer(target:self, action:#selector(NewSurveyViewController.hideKeyboard))
//        touch.cancelsTouchesInView = false
//        view.addGestureRecognizer(touch)
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        if !isViewSetupCompleted {
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
            isViewSetupCompleted = true
            self.createButton.layer.cornerRadius = self.createButton.frame.height / 2
        }
//        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
        if (navigationController as! NavigationControllerPreloaded).delegate == nil {
            (navigationController as! NavigationControllerPreloaded).delegate = appDelegate.transitionCoordinator
        }
        DispatchQueue.main.async {
            self.textEditingView = TextEditingView(frame: (UIApplication.shared.keyWindow?.frame)!, delegate: self)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if let selectedRow = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedRow, animated: false)
        }
    }
    
    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
}

extension NewSurveyViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { //PArams
            return 4
        } else if section == 1 {//Question
            return 2
        } else if section == 2 || section == 4 {//Image add, Answer add
            return 1
        } else if section == 3 {//Images
            return images.count
        } else if section == 5 {//Answer
            return answers.count
        } else if section == 6 {//Last
            return 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        if indexPath.section == 0 { //Params
            if indexPath.row == 0, let _cell = tableView.dequeueReusableCell(withIdentifier: "category", for: indexPath) as? CategorySelectionCell {
                if leftEdgeInset == 0 {
                    for v in _cell.contentView.subviews {
                        if v.isKind(of: UILabel.self) {
                            leftEdgeInset = v.frame.origin.x
                            break
                        }
                    }
                }
                _cell.separatorInset = UIEdgeInsets(top: 0, left: leftEdgeInset, bottom: 0, right: 0)//.greatestFiniteMagnitude)
                cell = _cell
            } else if indexPath.row == 1, let _cell = tableView.dequeueReusableCell(withIdentifier: "privacy", for: indexPath) as? PrivacySelectionCell {
                _cell.separatorInset = UIEdgeInsets(top: 0, left: leftEdgeInset, bottom: 0, right: 0)
                cell = _cell
            } else if indexPath.row == 2, let _cell = tableView.dequeueReusableCell(withIdentifier: "anonymity", for: indexPath) as? AnonymitySelectionCell {
                _cell.separatorInset = UIEdgeInsets(top: 0, left: leftEdgeInset, bottom: 0, right: 0)
                cell = _cell
            } else if indexPath.row == 3, let _cell = tableView.dequeueReusableCell(withIdentifier: "votes", for: indexPath) as? VotesSelectionCell {
                _cell.count.delegate = self
                addTextField(_cell.count)
                cell = _cell
                cell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.size.width, bottom: 0, right: .greatestFiniteMagnitude)
            }
        } else if indexPath.section == 1 { //Question, link
            if indexPath.row == 0, let _cell = tableView.dequeueReusableCell(withIdentifier: "question", for: indexPath) as? QuestionCreationCell {
//                _cell.textView.delegate = self
//                addTextView(_cell.textView)
                cell = _cell
                cell.separatorInset = UIEdgeInsets(top: 0, left: cell.frame.width/9, bottom: 0, right: cell.frame.width/9)
            } else if indexPath.row == 1, let _cell = tableView.dequeueReusableCell(withIdentifier: "link", for: indexPath) as? LinkAttachmentCell {
                _cell.link.delegate = self
                _cell.delegate = self
                addTextField(_cell.link)
                cell = _cell
                cell.separatorInset = UIEdgeInsets(top: 0, left: cell.frame.width/9, bottom: 0, right: cell.frame.width/9)
                //            cell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.size.width, bottom: 0, right: .greatestFiniteMagnitude)
            }
        } else if indexPath.section == 2, let _cell = tableView.dequeueReusableCell(withIdentifier: "imageHeader", for: indexPath) as? ImageHeaderCell {
            _cell.delegate = self
            cell = _cell
            cell.separatorInset = UIEdgeInsets(top: 0, left: cell.frame.width/9, bottom: 0, right: cell.frame.width/9)
        } else if indexPath.section == 3, let _cell = tableView.dequeueReusableCell(withIdentifier: "image", for: indexPath) as? ImageSelectionCell {
            _cell.setNeedsLayout()
            _cell.layoutIfNeeded()
            _cell.pictureView.image = images[indexPath.row].keys.first
            _cell.pictureView.contentMode = UIView.ContentMode.scaleAspectFill
            _cell.pictureView.layer.cornerRadius = _cell.pictureView.frame.height / 2
            _cell.textField.text = images[indexPath.row].values.first
            _cell.textField.delegate = self
            addTextField(_cell.textField)
            cell = _cell
//            if let c = tableView.cellForRow(at: IndexPath(row: 0, section: 10)) {
//                c.separatorInset = UIEdgeInsets(top: 0, left: c.frame.width/9, bottom: 0, right: c.frame.width/9)
//            }
            if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
                //cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                for i in 0...tableView.numberOfRows(inSection: indexPath.section) {
                    if let c = tableView.cellForRow(at: IndexPath(row: i-1, section: indexPath.section)) {
                        c.separatorInset = UIEdgeInsets(top: 0, left: c.frame.width/5, bottom: 0, right: c.frame.width/5)
                    }
                }
            }
        } else if indexPath.section == 4, let _cell = tableView.dequeueReusableCell(withIdentifier: "answerHeader", for: indexPath) as? AnswerCreationHeaderCell {
            _cell.delegate = self
            cell = _cell
            cell.separatorInset = UIEdgeInsets(top: 0, left: cell.frame.width/9, bottom: 0, right: cell.frame.width/9)
//            if !answers.isEmpty {//tableView.numberOfRows(inSection: 5) != 0 {
//                cell.separatorInset = UIEdgeInsets(top: 0, left: cell.frame.width/9, bottom: 0, right: cell.frame.width/9)
//            } else {
//                cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
//            }
        } else if indexPath.section == 5, let _cell = tableView.dequeueReusableCell(withIdentifier: "answer", for: indexPath) as? AnswerCreationCell {
            _cell.setNeedsLayout()
            _cell.layoutIfNeeded()
//            _cell.textView.delegate = self
            _cell.titleLabel!.text = "#\(indexPath.row + 1)"
//            addTextView(_cell.textView)
            if let text = answers[indexPath.row] as? String{
                if !text.isEmpty {
                    _cell.textView.text = text
                    _cell.textView.textAlignment = .natural
                } else {
                    _cell.textView.text = _cell.placeholder
                    _cell.textView.textAlignment = .center
                }
            }
            cell = _cell
//            if let headerCell = tableView.cellForRow(at: IndexPath(row: 0, section: 4)) {
//                headerCell.separatorInset = UIEdgeInsets(top: 0, left: headerCell.frame.width/9, bottom: 0, right: headerCell.frame.width/9)
//            }
            if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
                cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
                for i in 0...tableView.numberOfRows(inSection: indexPath.section) {
                    if let c = tableView.cellForRow(at: IndexPath(row: i-1, section: indexPath.section)) {
                        c.separatorInset = UIEdgeInsets(top: 0, left: c.frame.width/5, bottom: 0, right: c.frame.width/5)
                    }
                }
            } else {
                cell.separatorInset = UIEdgeInsets(top: 0, left: cell.frame.width/5, bottom: 0, right: cell.frame.width/5)
            }
        } else if indexPath.section == 6 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        }
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 || indexPath.section == 2 || indexPath.section == 4 {//Params, Image add, Answer add
                return 50
        } else if indexPath.section == 1 {//Question
            if indexPath.row == 0 {
                if let cell = tableView.cellForRow(at: indexPath) as? QuestionCreationCell {
                    var yLength: CGFloat = 0
                    for v in cell.contentView.subviews {
                        if v.isKind(of: UILabel.self) {
                            yLength = v.frame.origin.y + v.frame.size.height
                        }
                    }
                    let sizeThatFitsTextView = cell.textView.sizeThatFits(CGSize(width: cell.textView.frame.size.width, height: CGFloat(MAXFLOAT)))
                    var _questionRowHeight: CGFloat = 0//Old
                    if questionRowHeight != 0 {
                        _questionRowHeight = questionRowHeight
                    }
                    questionRowHeight = yLength + sizeThatFitsTextView.height + 10
                    if questionRowHeight != _questionRowHeight {
                        currentOffsetY = questionRowHeight - _questionRowHeight
                    }
                    return questionRowHeight
                }
                else {
                    return questionRowHeight
                }
            } else {
                return 115
            }
        } else if indexPath.section == 3 {//Image
            return 80
        } else if indexPath.section == 5 {//Answer
            if let cell = tableView.cellForRow(at: indexPath) as? AnswerCreationCell {
                var yLength: CGFloat = 0
                for v in cell.contentView.subviews {
                    if v.isKind(of: UILabel.self) {
                        yLength = v.frame.origin.y + v.frame.size.height
                    }
                }
//                let sizeThatFitsTextView = cell.textView.sizeThatFits(CGSize(width: cell.textView.frame.size.width, height: CGFloat(MAXFLOAT)))
//                var _answersRowHeight: CGFloat = 0//Old
//                if answersRowHeight[indexPath.row] != nil, answersRowHeight[indexPath.row] != 0 {
//                    _answersRowHeight = answersRowHeight[indexPath.row]!
//                }
//                answersRowHeight[indexPath.row] = yLength + sizeThatFitsTextView.height + 10
//                if answersRowHeight[indexPath.row] != _answersRowHeight {
//                    currentOffsetY = answersRowHeight[indexPath.row]! - _answersRowHeight
//                }
//                return answersRowHeight[indexPath.row] ?? 110
                let sizeThatFitsTextView = cell.textView.sizeThatFits(CGSize(width: cell.textView.frame.size.width, height: CGFloat(MAXFLOAT)))
                var oldValue: CGFloat = 0
                if answersRowHeight[indexPath.row] != nil {
                    oldValue = answersRowHeight[indexPath.row]!
                }
                answersRowHeight[indexPath.row] = yLength + sizeThatFitsTextView.height + 10
                if oldValue != 0, oldValue != answersRowHeight[indexPath.row] {
                    tableView.scrollToNearestSelectedRow(at: .bottom, animated: true)
                    if oldValue < answersRowHeight[indexPath.row]! {
//                        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
//                        currentOffsetY = (self.answersRowHeight[indexPath.row]! - oldValue) + tableView.contentOffset.y
                        delay(seconds: 0.01) {
                            tableView.setContentOffset(CGPoint(x: tableView.contentOffset.x, y: (self.answersRowHeight[indexPath.row]! - oldValue) + tableView.contentOffset.y), animated: true)
                        }
//                        tableView.scrollToBottom()
//                        tableView.contentOffset += (answersRowHeight[indexPath.row]! - oldValue)
                    } else {
//                        tableView.contentOffset -= (oldValue - answersRowHeight[indexPath.row]!)
                    }
                }
                return answersRowHeight[indexPath.row] ?? 110
            }
            else {
                return answersRowHeight[indexPath.row] ?? 110
            }
        } else if indexPath.section == 6 {//Image
            return 0
        }
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 3 || indexPath.section == 5 {
            return true
        }
        return false
    }
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "", handler: { (action, view, completion) in
            if indexPath.section == 3 {
                self.images.remove(at: indexPath.row)
            } else if indexPath.section == 5 {
                self.answers.remove(at: indexPath.row)
            }
            tableView.deleteRows(at: [indexPath], with: .automatic)
//            tableView.reloadSections(IndexSet(arrayLiteral: indexPath.section), with: .bottom)
            if indexPath.section == 3 {
                if let header = self.tableView.headerView(forSection: 2) as? NewSurveyHeaderCell {
                    self.configureHeader(header: header, forSection: 2)
                }
                if tableView.numberOfRows(inSection: 3) > 0, let header = tableView.cellForRow(at: IndexPath(row: 0, section: 2)) {
                    header.separatorInset = UIEdgeInsets(top: 0, left: header.frame.width/9, bottom: 0, right: header.frame.width/9)
                }
            } else if indexPath.section == 5 {
                if let header = self.tableView.headerView(forSection: 4) as? NewSurveyHeaderCell {
                    self.configureHeader(header: header, forSection: 4)
                }
                if tableView.numberOfRows(inSection: 5) > 0, let header = tableView.cellForRow(at: IndexPath(row: 0, section: 4)) {
                    header.separatorInset = UIEdgeInsets(top: 0, left: header.frame.width/9, bottom: 0, right: header.frame.width/9)
                }
            }
//            self.currentTV = nil
            completion(true)
        })
        deleteAction.backgroundColor = K_COLOR_RED
        deleteAction.image = UIImage(named: "trash_icon")?.resized(to: CGSize(width: 30, height: 30))
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteButton = UITableViewRowAction(style: .default, title: "Удалить") { (action, indexPath) in
            //                tableView.beginUpdates()
            if indexPath.section == 3 {
                self.images.remove(at: indexPath.row)
            } else {
                self.answers.remove(at: indexPath.row)
            }
            tableView.deleteRows(at: [indexPath], with: .bottom)
            //                tableView.endUpdates()
            //                tableView.reloadSections(IndexSet(arrayLiteral: indexPath.section), with: .bottom)
        }
        if indexPath.section == 3 {
            if let header = self.tableView.headerView(forSection: 2) as? NewSurveyHeaderCell {
                self.configureHeader(header: header, forSection: 2)
            }
            if tableView.numberOfRows(inSection: 3) > 0, let header = tableView.cellForRow(at: IndexPath(row: 0, section: 2)) {
                header.separatorInset = UIEdgeInsets(top: 0, left: header.frame.width/9, bottom: 0, right: header.frame.width/9)
            }
        } else if indexPath.section == 5 {
            if let header = self.tableView.headerView(forSection: 4) as? NewSurveyHeaderCell {
                self.configureHeader(header: header, forSection: 4)
            }
            if tableView.numberOfRows(inSection: 5) > 0, let header = tableView.cellForRow(at: IndexPath(row: 0, section: 4)) {
                header.separatorInset = UIEdgeInsets(top: 0, left: header.frame.width/9, bottom: 0, right: header.frame.width/9)
            }
        }
//        self.currentTV = nil
        deleteButton.backgroundColor = K_COLOR_RED
        return [deleteButton]
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == 0, let cell = tableView.cellForRow(at: indexPath) as? CategorySelectionCell {
                performSegue(withIdentifier: kSegueAppNewSurveyToCategory, sender: nil)
            } else if indexPath.row == 2, let cell = tableView.cellForRow(at: indexPath) as? AnonymitySelectionCell {
                performSegue(withIdentifier: kSegueAppNewSurveyToAnonymity, sender: nil)
            }
//            if currentTV != nil {
//                currentTV?.isUserInteractionEnabled = false
//                view.endEditing(true)
//                currentTV = nil
//            }
//            cell.count.becomeFirstResponder()
//            if !cell.count.isFirstResponder {
//                delay(seconds: 0.01) {
//                    cell.count.becomeFirstResponder()
//                }
//            }
//            cell.count.isUserInteractionEnabled = true
//            currentTF = cell.count
        } else if indexPath.section == 1, let cell = tableView.cellForRow(at: indexPath) as? LinkAttachmentCell {
//            cell.link.becomeFirstResponder()
//            if !cell.link.isFirstResponder {
//                delay(seconds: 0.01) {
//                    cell.link.becomeFirstResponder()
//                }
//            }
//            cell.link.isUserInteractionEnabled = true
//            currentTF = cell.link
        } else if indexPath.section == 1 {
            if indexPath.row == 0, let cell = tableView.cellForRow(at: indexPath) as? QuestionCreationCell {
//                isStatusBarHidden = true
                textEditingView.present(title: "Вопрос", textView: cell.textView, placeholder: cell.placeholder, closure: {self.tableView.deselectRow(at: indexPath, animated: true); self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)})
//                currentTV = cell.textView
//                if tableView.contentOffset != .zero {
//                    tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
//                    scrollCompletion = { cell.textView.becomeFirstResponder(); cell.textView.isUserInteractionEnabled = true }
//                } else {
//                    cell.textView.becomeFirstResponder()
//                    cell.textView.isUserInteractionEnabled = true
//                }
            }
        } else if indexPath.section == 5 {
            if let cell = tableView.cellForRow(at: indexPath) as? AnswerCreationCell {
                textEditingView.present(title: "Ответ \(cell.titleLabel.text!)", textView: cell.textView, placeholder: cell.placeholder, closure: {self.tableView.deselectRow(at: indexPath, animated: true); self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)})
//                currentTV = cell.textView
//                if tableView.contentOffset.y != verticalContentOffset {
//                    tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
//                    scrollCompletion = { cell.textView.becomeFirstResponder(); cell.textView.isUserInteractionEnabled = true }
//                } else {
//                    cell.textView.becomeFirstResponder()
//                    cell.textView.isUserInteractionEnabled = true
//                }
////                cell.textView.becomeFirstResponder()
////                cell.textView.isUserInteractionEnabled = true
            }
        } else {
//            if currentTV != nil {
//                currentTV?.resignFirstResponder()
//                currentTV?.isUserInteractionEnabled = false
//                view.endEditing(true)
//                currentTV = nil
//            }
            if currentTF != nil {
                currentTF?.resignFirstResponder()
                currentTF?.isUserInteractionEnabled = false
                view.endEditing(true)
                currentTF = nil
            }
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        //Reorder datasource
        if destinationIndexPath.row != sourceIndexPath.row {
        isRearranging = true
        if sourceIndexPath.section == 3 {
            images.rearrange(from: sourceIndexPath.row, to: destinationIndexPath.row)
        } else if sourceIndexPath.section == 5 {
            answers.rearrange(from: sourceIndexPath.row, to: destinationIndexPath.row)
            delay(seconds: 0.01) {
                tableView.reloadSections(IndexSet(arrayLiteral: sourceIndexPath.section), with: .none)
            }
        }
        isRearranging = false
        }
    }

    
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 3 && tableView.numberOfRows(inSection: 3) > 1 {
            return true
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 || section == 1 || section == 2 || section == 4 || section == 4 {
            return 35
        } else if section == 6 {
            return 10
        }
        return 0
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as? NewSurveyHeaderCell {
            var count = ""
            if section == 2 { count = " (\(images.count)/3)"} else if section == 4 { count = " (\(answers.count))"}
            header.title.text = sections[section] + count
            return header
        }
        return nil
    }
    
    fileprivate func configureHeader(header: NewSurveyHeaderCell, forSection section: Int) {
        var title = sections[section]
        if section == 2 {
            title += " (\(images.count)/3)"
        } else if section == 4 {
            title += " (\(answers.count))"
        }
        header.title.text = title
    }
}

extension NewSurveyViewController: UIScrollViewDelegate {
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        verticalContentOffset = tableView.contentOffset.y
        if scrollCompletion != nil {
            scrollCompletion!()
            scrollCompletion = nil
        }
    }
}

//extension NewSurveyViewController: UITextViewDelegate {
//    func textViewDidChange(_ textView: UITextView) {
//        tableView.beginUpdates()
//        tableView.endUpdates()
//    }
//
//    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//        if text == "\n" {
//            textView.isUserInteractionEnabled = false
//            if let indexPath = tableView.indexPathForSelectedRow, indexPath.section == 5 {
//                isRearranging = true
//                answers.remove(at: indexPath.row)
//                answers.insert(textView.text, at: indexPath.row)
//                isRearranging = false
//            }
////            currentTV = nil
//            textView.resignFirstResponder()
//            return false
//        }
//        return true
//    }
//
////    func textViewDidEndEditing(_ textView: UITextView) {
////        if let cell = tableView.cellForRow(at: tableView.indexPathForSelectedRow!) as? QuestionCreationCell {
////            checkQuestionText(beganEditing: false, textView: textView, placeholder: cell.questionPlaceholder)
////        }
////    }
//
//    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
//        currentTF = nil
//        if let indexPath = tableView.indexPathForSelectedRow {
//            if let cell = tableView.cellForRow(at: indexPath) as? QuestionCreationCell {
//                checkTextViewEdited(beganEditing: true, textView: textView, placeholder: cell.placeholder)
//            } else if let cell = tableView.cellForRow(at: indexPath) as? AnswerCreationCell {
//                checkTextViewEdited(beganEditing: true, textView: textView, placeholder: cell.placeholder)
//            }
//        }
//        return true
//    }
//
//    fileprivate func checkTextViewEdited(beganEditing: Bool, textView: UITextView, placeholder: String) {
//        if beganEditing {
//            if textView.text == placeholder {
//                textView.text = ""
//                textView.textAlignment = .natural
//            }
//        } else {
//            if textView.text.isEmpty {
//                textView.text = placeholder
//                textView.textAlignment = .center
//            }
//        }
//    }
//
//    fileprivate func findFirstResponderTextView() -> UITextView? {
//        for textView in textViews {
//            if textView.isFirstResponder {
//                return textView
//            }
//        }
//        return nil
//    }
//
//
//
//    fileprivate func addTextView(_ textView: UITextView) {
//        if !textViews.contains(textView) {
//            textViews.append(textView)
//        }
//    }
//
//
//
//    func textViewIsAboveKeyBoard(_ textView: UITextView?) -> Bool {
//        var activeTextView: UITextView?
//        if textView != nil {
//            activeTextView = textView
//        } else {
//            activeTextView = findFirstResponderTextView()
//        }
//
//        if (activeTextView != nil) {
//            let tfPoint = CGPoint(x: activeTextView!.frame.minX, y: activeTextView!.frame.maxY)// * 1.5)
//            let convertedPoint = view.convert(tfPoint, from: activeTextView?.superview)
//            if convertedPoint.y <= (view.frame.height - kbHeight) {
//                return true
//            } else {
//                offsetY = -(view.frame.height - kbHeight - convertedPoint.y)// + 15 //+ (activeTextField?.bounds.height)! / 2
//            }
//        }
//        return false
//    }
//
//
//
//
//
//
//}

extension NewSurveyViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        currentTF = nil
        currentTF = textField
//        if currentTV != nil {
//            currentTV?.isUserInteractionEnabled = false
//            view.endEditing(true)
//            currentTV = nil
//        }
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        currentTF = nil
        return true
    }
    
    fileprivate func findFirstResponderTextField() -> UITextField? {
        for textField in textFields {
            if textField.isFirstResponder {
                return textField
            }
        }
        return nil
    }
    
    private func setOffset(_ up: Bool) {
        var distance: CGFloat = 0
        distance = (up ? -offsetY : offsetY)
        UIView.animate(withDuration: 0.2, animations: {
            self.view.frame.origin.y += distance
            if up {
                self.isMovedUp = true
            } else {
                self.isMovedUp = false
            }
        })
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            if let keyboardSize =  (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                if (isMovedUp == nil) || isMovedUp == false {
                    kbHeight = keyboardSize.height
                    if currentTF != nil, !textFieldIsAboveKeyBoard(nil) {
                        self.setOffset(true)
                    }
                    //                    } else if currentTV != nil , !textViewIsAboveKeyBoard(nil) {
                    //                        self.setOffset(true)
                    //                    }
                }
            }
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        if isMovedUp != nil {
            if isMovedUp! {
                self.setOffset(false)
                currentTF = nil
            }
        }
    }
    
    fileprivate func textFieldIsAboveKeyBoard(_ textField: UITextField?) -> Bool {
        var activeTextField: UITextField?
        if textField != nil {
            activeTextField = textField
        } else {
            activeTextField = findFirstResponderTextField()
        }
        
        if (activeTextField != nil) {
            let tfPoint = CGPoint(x: activeTextField!.frame.minX, y: activeTextField!.frame.maxY)// * 1.5)
            let convertedPoint = view.convert(tfPoint, from: activeTextField?.superview)
            if convertedPoint.y <= (view.frame.height - kbHeight) {
                return true
            } else {
                offsetY = -(view.frame.height - kbHeight - convertedPoint.y)// + 15 //+ (activeTextField?.bounds.height)! / 2
            }
        }
        return false
    }
    
    fileprivate func addTextField(_ textField: UITextField) {
        if !textFields.contains(textField) {
            textFields.append(textField)
        }
    }
}

extension NewSurveyViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let origImage = info[.editedImage] as? UIImage {
            let imageData = origImage.jpegData(compressionQuality: 0.6)
            let image = UIImage(data: imageData!)
            images.append([image!: ""])
        }
        dismiss(animated: true)
    }
    
    fileprivate func selectImage(_ source: UIImagePickerController.SourceType) {
        if images.count < 3 {
        imagePicker.allowsEditing = true
        imagePicker.sourceType = source
        imagePicker.navigationBar.topItem?.rightBarButtonItem?.tintColor = .black
        present(imagePicker, animated: true)
        } else {
            showAlert(type: .Warning, buttons: [["Закрыть": [.Ok: nil]]], text: "Достигнуто максимальное количество изображений")
        }
    }
}

@available(iOS 11.0, *)
extension NewSurveyViewController: UITableViewDragDelegate {
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        if (indexPath.section == 3 && tableView.numberOfRows(inSection: 3) > 1) || (indexPath.section == 5 && tableView.numberOfRows(inSection: 5) > 1) {
            let dragItem = UIDragItem(itemProvider: NSItemProvider())
            dragItem.localObject = indexPath
            return [dragItem]
        }
        return []
    }
    
    func tableView(_ tableView: UITableView, dragSessionIsRestrictedToDraggingApplication session: UIDragSession) -> Bool {
        return true
    }
}

@available(iOS 11.0, *)
extension NewSurveyViewController: UITableViewDropDelegate {
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        if tableView.hasActiveDrag {
            if session.items.count > 1 { return UITableViewDropProposal(operation: .cancel, intent: .unspecified) }
            if session.localDragSession != nil { // Drag originated from the same app.
                if let indexPath = session.items.first!.localObject as? IndexPath {
                    if indexPath.section == destinationIndexPath?.section {
                        return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
                    } else {
                        return UITableViewDropProposal(operation: .cancel, intent: .unspecified)
                    }
                }
                return UITableViewDropProposal(operation: .cancel, intent: .unspecified)
            }
        }
        return UITableViewDropProposal(operation: .cancel, intent: .unspecified)
    }

    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
//        if let destinationPath = coordinator.destinationIndexPath, let sourcePath = coordinator.items.first?.dragItem.localObject as? IndexPath {
//            if (destinationPath.section == sourcePath.section) {
//                print("")
//            }
//        }
    }
}

extension NewSurveyViewController: CellButtonDelegate {
    func cellSubviewTapped(_ sender: AnyObject) {
        if sender is CameraIcon {
            selectImage(.camera)
        } else if sender is GalleryIcon {
            selectImage(.photoLibrary)
        } else if sender is PlusIcon {
            answers.append("")
            tableView.scrollToBottom()
            delay(seconds: 0.3) {
                let indexPath = IndexPath(row: self.answers.count - 1, section: 5)
                self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                self.tableView(self.tableView, didSelectRowAt: indexPath)
            }
        } else if sender is YoutubeLogo {
            if let url = URL(string: "https://www.youtube.com"),
                UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:])
            }
        } else if sender is WikiLogo {
            if let url = URL(string: "https://ru.m.wikipedia.org"),
                UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:])
            }
        } else if sender is InstagramLogo {
            if let url = URL(string: "https://instagram.com"),
                UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:])
            }
        } else if sender is UISwitch {
            privacy = (sender as! UISwitch).isOn
        } else if sender is AnonymitySettingsTableViewController {
            anonymity = (sender as! AnonymitySettingsTableViewController).anonymity
        }
    }
}

//Logic
extension NewSurveyViewController {
//    public func initNewSurvey() {
//
//    }
    //True if all fields are filled
    fileprivate func checkNecessaryFields() -> Bool {
        var errors: [String] = []
        //1. Category
        if category == nil {
            errors.append("категория")
        }
        //2. Anonymity
        if anonymity == nil {
            errors.append("анонимность")
        }
        //3. Votes capacity
        if votesCapacity == 0 {
            errors.append("количество мнений")
        }
        //4. Question
        if question.isEmpty {
            errors.append("текст опроса")
        }
        //5. Answers
        if answers.isEmpty {
            errors.append("варианты ответов")
        } else if answers.count < 2 {
            errors.append("недостаточно вариантов ответов")
        } else {
            for answer in answers{
                if answer.isEmpty {
                    errors.append("текст ответов")
                    break
                }
            }
        }
        
        if !errors.isEmpty {
            var errorText = "Не заполнены поля:\n"
            for error in errors {
                errorText += "-\(error)\n"
            }
            showAlert(type: .Warning, buttons: [["Закрыть": [.Ok: nil]]], text: errorText)
        }
        
        return errors.isEmpty
    }
}

extension NewSurveyViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == kSegueAppNewSurveyToAnonymity, let destinationVC = segue.destination as? AnonymitySettingsTableViewController {
            (navigationController as! NavigationControllerPreloaded).delegate = nil
            destinationVC.delegate = self
            destinationVC.anonymity = anonymity
        }
    }
}
