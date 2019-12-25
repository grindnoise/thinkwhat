//
//  NewSurveyViewController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 29.11.2019.
//  Copyright © 2019 Pavel Bukharov. All rights reserved.
//

import UIKit

class NewSurveyViewController: UIViewController, UINavigationControllerDelegate {
    
//    class var categorySelectionCell: UINib {
//        return UINib(nibName: "CategorySelectionCell", bundle: nil)
//    }
//    class var privacySelectionCell: UINib {
//        return UINib(nibName: "PrivacySelectionCell", bundle: nil)
//    }
//    class var anonymitySelectionCell: UINib {
//        return UINib(nibName: "AnonymitySelectionCell", bundle: nil)
//    }
//    class var votesSelectionCell: UINib {
//        return UINib(nibName: "VotesSelectionCell", bundle: nil)
//    }
    class var newSurveyHeaderCell: UINib {
        return UINib(nibName: "NewSurveyHeaderCell", bundle: nil)
    }
    
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var bottomHeight: NSLayoutConstraint!
    @IBAction func cancelTapped(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func createTapped(_ sender: Any) {
        print("create")
    }
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var privacySwitch: UISwitch!
    @IBOutlet weak var votesQuantity: UITextField!
    @IBOutlet weak var questionTextView: UITextView!
    
    fileprivate var isRearranging = false
    fileprivate var isViewSetupCompleted = false
    fileprivate var leftEdgeInset: CGFloat = 0
    fileprivate var currentTF: UITextField?
    fileprivate var imagePicker         = UIImagePickerController()
    fileprivate var currentTV: UITextView? {
        didSet {
            if oldValue != nil, let cell = oldValue?.superview?.superview as? QuestionCreationCell{//}.isKind(of: QuestionCreationCell.self) {
                checkQuestionText(beganEditing: false, textView: oldValue!, placeholder: cell.questionPlaceholder)
            }
        }
    }
//    fileprivate var isReplacingImage = false
    fileprivate var questionTextChanged = false
    fileprivate var images: [UIImage] = [] {//[Int] = [] {//
        didSet {
            if !isRearranging {
                if images.count > oldValue.count {
                    if #available(iOS 11.0, *) {
                        tableView.performBatchUpdates({
                            tableView.insertRows(at: [IndexPath(row: images.count-1, section: 3)], with: .top)
//                            if let c = tableView.cellForRow(at: IndexPath(row: 0, section: 10)) {
//                                c.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//                            }
                        }) {
                            _ in
                            if let header = self.tableView.headerView(forSection: 2) as? NewSurveyHeaderCell {
                                self.configureHeader(header: header, forSection: 2)
                                //                    tableView.reloadData()//Sections(IndexSet(arrayLiteral: indexPath.section), with: .bottom)
                            }
                        }
                    } else {
                        tableView.beginUpdates()
                        tableView.insertRows(at: [IndexPath(row: images.count-1, section: 3)], with: .top)
                        tableView.endUpdates()
                    }
                }
            }
        }
    }
    fileprivate var answers: [String] = [] {
        didSet {
            if !isRearranging {
                if answers.count > oldValue.count {
                    if #available(iOS 11.0, *) {
                        tableView.performBatchUpdates({
                            tableView.insertRows(at: [IndexPath(row: answers.count-1, section: 5)], with: .top)
//                            if let c = tableView.cellForRow(at: IndexPath(row: 0, section: 10)) {
//                                c.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//                            }
                        }) {
                            _ in
                            if let header = self.tableView.headerView(forSection: 4) as? NewSurveyHeaderCell {
                                self.configureHeader(header: header, forSection: 4)
                                //                    tableView.reloadData()//Sections(IndexSet(arrayLiteral: indexPath.section), with: .bottom)
                            }
                        }
                    } else {
                        tableView.beginUpdates()
                        tableView.insertRows(at: [IndexPath(row: images.count-1, section: 5)], with: .top)
                        tableView.endUpdates()
                    }
                }
            }
        }
    }
    fileprivate let sections = ["ПАРАМЕТРЫ", "ВОПРОС", "ИЗОБРАЖЕНИЯ", "", "ОТВЕТЫ", ""]
    fileprivate var questionRowHeight: CGFloat = 0
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("seg")
    }
    
    //@IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        navigationController?.isNavigationBarHidden = false
//        navigationController?.setNavigationBarHidden(true, animated: false)
        setupViews()
        imagePicker.delegate = self
        tableView.delegate = self as UITableViewDelegate
        tableView.dataSource = self
        tableView.register(NewSurveyViewController.newSurveyHeaderCell, forHeaderFooterViewReuseIdentifier: "header")
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
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    //    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    //        self.lastContentOffset = scrollView.contentOffset.y
    //    }
    

    
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
        }
        return 1
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
                cell = _cell
                cell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.size.width, bottom: 0, right: .greatestFiniteMagnitude)
            }
        } else if indexPath.section == 1 { //Question, link
            if indexPath.row == 0, let _cell = tableView.dequeueReusableCell(withIdentifier: "question", for: indexPath) as? QuestionCreationCell {
                _cell.question.delegate = self
                cell = _cell
                cell.separatorInset = UIEdgeInsets(top: 0, left: cell.frame.width/9, bottom: 0, right: cell.frame.width/9)
            } else if indexPath.row == 1, let _cell = tableView.dequeueReusableCell(withIdentifier: "link", for: indexPath) as? LinkAttachmentCell {
                _cell.link.delegate = self
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
            _cell.pictureView.image = images[indexPath.row]
            _cell.pictureView.contentMode = UIView.ContentMode.scaleAspectFill
            _cell.pictureView.layer.cornerRadius = _cell.pictureView.frame.height / 2
            cell = _cell
            if let c = tableView.cellForRow(at: IndexPath(row: 0, section: 10)) {
                c.separatorInset = UIEdgeInsets(top: 0, left: c.frame.width/9, bottom: 0, right: c.frame.width/9)
            }
            if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
                cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
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
                    let sizeThatFitsTextView = cell.question.sizeThatFits(CGSize(width: cell.question.frame.size.width, height: CGFloat(MAXFLOAT)))
                    questionRowHeight = yLength + sizeThatFitsTextView.height + 10
                    return questionRowHeight
                }
                else {
                    return questionRowHeight
                }
            }
        } else if indexPath.section == 3 {//Image
            return 80
        }
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 3 || indexPath.section == 5 {
            return true
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if #available(iOS 11.0, *) {
                tableView.performBatchUpdates({
                    images.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .none)
                }) {
                    _ in
                    tableView.reloadSections(IndexSet(arrayLiteral: indexPath.section), with: .none)
                    if indexPath.section == 2 {
                        if let header = self.tableView.headerView(forSection: 2) as? NewSurveyHeaderCell {
                            self.configureHeader(header: header, forSection: 2)
                        }
                        if tableView.numberOfRows(inSection: 3) > 0, let header = tableView.cellForRow(at: IndexPath(row: 0, section: 2)) {
                            header.separatorInset = UIEdgeInsets(top: 0, left: header.frame.width/9, bottom: 0, right: header.frame.width/9)
                        }
                    } else if indexPath.section == 4 {
                        if let header = self.tableView.headerView(forSection: 4) as? NewSurveyHeaderCell {
                            self.configureHeader(header: header, forSection: 4)
                        }
                    }
                }
            } else {
                tableView.beginUpdates()
                if indexPath.section == 3 {
                    images.remove(at: indexPath.row)
//                    if let header = tableView.cellForRow(at: IndexPath(row: 0, section: 10)) {
//                        if tableView.numberOfRows(inSection: 11) == 0 {
//                            header.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//                        } else {
//                            header.separatorInset = UIEdgeInsets(top: 0, left: header.frame.width/9, bottom: 0, right: header.frame.width/9)
//                        }
//                    }
                }
                tableView.deleteRows(at: [indexPath], with: .bottom)
                tableView.endUpdates()
                tableView.reloadSections(IndexSet(arrayLiteral: 3), with: .none)
            }
        }
    }
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "", handler: { (action, view, success) in
            tableView.performBatchUpdates({
                if indexPath.section == 3 {
                    self.images.remove(at: indexPath.row)
                } else if indexPath.section == 5 {
                    self.answers.remove(at: indexPath.row)
                }
                tableView.deleteRows(at: [indexPath], with: .bottom)
                tableView.reloadSections(IndexSet(arrayLiteral: indexPath.section), with: .bottom)
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
                }
            })
        })
        deleteAction.image = UIImage(named: "trash_icon")?.resized(to: CGSize(width: 25, height: 25))
        deleteAction.backgroundColor = .red
        
//        let replaceAction = UIContextualAction(style: .destructive, title: "", handler: { (action, view, success) in
//            tableView.performBatchUpdates({
//                self.images.remove(at: indexPath.row)
//                tableView.deleteRows(at: [indexPath], with: .bottom)
//            }) {
//                _ in
//                tableView.reloadSections(IndexSet(arrayLiteral: indexPath.section), with: .none)
//                if tableView.numberOfRows(inSection: 11) == 0, let header = tableView.cellForRow(at: IndexPath(row: 0, section: 10)) {
//                    header.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//                }
//            }
//            //self.tableView.dataSource?.tableView!(self.tableView, commit: .delete, forRowAt: indexPath)
//            //return
//        })
//        replaceAction.image = UIImage(named: "folder_icon")?.resized(to: CGSize(width: 23, height: 23))
//        replaceAction.backgroundColor = .orange
        
//        deleteAction.backgroundColor = K_COLOR_RED
        let swipeConfig = UISwipeActionsConfiguration(actions: [deleteAction])//, replaceAction])
        swipeConfig.performsFirstActionWithFullSwipe = false
        return swipeConfig
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteButton = UITableViewRowAction(style: .default, title: "Удалить") { (action, indexPath) in
            self.tableView.dataSource?.tableView!(self.tableView, commit: .delete, forRowAt: indexPath)
            return
        }
        deleteButton.backgroundColor = K_COLOR_RED
        return [deleteButton]
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0, let cell = tableView.cellForRow(at: indexPath) as? VotesSelectionCell {
            if currentTV != nil {
                currentTV?.isUserInteractionEnabled = false
                view.endEditing(true)
                currentTV = nil
            }
            cell.count.becomeFirstResponder()
            if !cell.count.isFirstResponder {
                delay(seconds: 0.01) {
                    cell.count.becomeFirstResponder()
                }
            }
            cell.count.isUserInteractionEnabled = true
            currentTF = cell.count
        } else if indexPath.section == 1, let cell = tableView.cellForRow(at: indexPath) as? LinkAttachmentCell {
            cell.link.becomeFirstResponder()
            if !cell.link.isFirstResponder {
                delay(seconds: 0.01) {
                    cell.link.becomeFirstResponder()
                }
            }
            cell.link.isUserInteractionEnabled = true
            currentTF = cell.link
        } else if indexPath.section == 1 {
            if indexPath.row == 0, let cell = tableView.cellForRow(at: indexPath) as? QuestionCreationCell {
                cell.question.becomeFirstResponder()
                cell.question.isUserInteractionEnabled = true
                currentTV = cell.question
            }
        } else {
            if currentTV != nil {
                currentTV?.resignFirstResponder()
                currentTV?.isUserInteractionEnabled = false
                view.endEditing(true)
                currentTV = nil
            }
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
        isRearranging = true
        if sourceIndexPath.section == 3 {
            images.rearrange(from: sourceIndexPath.row, to: destinationIndexPath.row)
        } else if sourceIndexPath.section == 5 {
            answers.rearrange(from: sourceIndexPath.row, to: destinationIndexPath.row)
        }
        isRearranging = false
    }

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 3 && tableView.numberOfRows(inSection: 3) > 1 {
            return true
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 || section == 1 || section == 2 || section == 4 {
            return 30
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
        tableView.headerView(forSection: 2)
        var title = sections[section]
        if section == 2 {
            title += " (\(images.count)/3)"
        } else if section == 4 {
            title += " (\(answers.count))"
        }
        tableView.beginUpdates()
        header.title.text = title
        tableView.endUpdates()
    }
}

extension NewSurveyViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.isUserInteractionEnabled = false
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
//    func textViewDidEndEditing(_ textView: UITextView) {
//        if let cell = tableView.cellForRow(at: tableView.indexPathForSelectedRow!) as? QuestionCreationCell {
//            checkQuestionText(beganEditing: false, textView: textView, placeholder: cell.questionPlaceholder)
//        }
//    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if let cell = tableView.cellForRow(at: tableView.indexPathForSelectedRow!) as? QuestionCreationCell {
            checkQuestionText(beganEditing: true, textView: textView, placeholder: cell.questionPlaceholder)
        }
        return true
    }

    fileprivate func checkQuestionText(beganEditing: Bool, textView: UITextView, placeholder: String) {
        if beganEditing {
            if textView.text == placeholder {
                textView.text = ""
                textView.textAlignment = .natural
            }
        } else {
            if textView.text.isEmpty {
                textView.text = placeholder
                textView.textAlignment = .center
            }
        }
    }
}

extension NewSurveyViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        textField.isUserInteractionEnabled = false
        return true
    }
}

extension NewSurveyViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let origImage = info[.editedImage] as? UIImage {
            let imageData = origImage.jpegData(compressionQuality: 0.6)
            let image = UIImage(data: imageData!)
            images.append(image!)
        }
        dismiss(animated: true)
    }
    
    fileprivate func selectImage(_ source: UIImagePickerController.SourceType) {
        imagePicker.allowsEditing = true
        imagePicker.sourceType = source
        imagePicker.navigationBar.topItem?.rightBarButtonItem?.tintColor = .black
        present(imagePicker, animated: true)
    }
}

@available(iOS 11.0, *)
extension NewSurveyViewController: UITableViewDragDelegate {
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        if indexPath.section == 11 && tableView.numberOfRows(inSection: 11) > 1 {
            let dragItem = UIDragItem(itemProvider: NSItemProvider())
//            dragItem.itemProvider.setValue(indexPath, forUndefinedKey: "indexPath")
            dragItem.localObject = indexPath
            return [dragItem]
        }
        return []
    }
    
    func tableView(_ tableView: UITableView, dragSessionIsRestrictedToDraggingApplication session: UIDragSession) -> Bool {
        return true
    }

//    func dragItems(for indexPath: IndexPath) -> [UIDragItem] {
//        let image = images[indexPath.row]
//
//        let data = image
//        let itemProvider = NSItemProvider()
//
//        itemProvider.registerDataRepresentation(forTypeIdentifier: kUTTypePlainText as String, visibility: .all) { completion in
//            completion(data, nil)
//            return nil
//        }
//
//        return [
//            UIDragItem(itemProvider: itemProvider)
//        ]
//    }

//    func tableView(_ tableView: UITableView, dragSessionAllowsMoveOperation session: UIDragSession) -> Bool {
////        print(session.items[0].itemProvider.)
//        return true
//    }
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
        }
    }
}
