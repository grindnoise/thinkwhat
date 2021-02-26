//
//  ImagesSelectionViewController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 18.01.2021.
//  Copyright © 2021 Pavel Bukharov. All rights reserved.
//

import UIKit

class ImagesSelectionViewController: UIViewController, UINavigationControllerDelegate {
    
    private var isAnimating = false
    private var isAnimationStopped = false
    private var isRearranging = false
    private var textFields: [UITextField] = []
    var images:         [[UIImage: String]] = [] {//[Int] = [] {//
        didSet {
            setTitle()
            if actionButton != nil, tableView != nil, !isRearranging, addButton != nil {
                addButton.setTitleColor(images.count >= MAX_IMAGES_COUNT ? K_COLOR_GRAY : K_COLOR_RED, for: .normal)
//                if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ImageHeaderCell {
//                    delay(seconds: 0.5) {
////                        cell.cameraIcon.state = self.images.count < MAX_IMAGES_COUNT ? .enabled : .disabled
////                        cell.galleryIcon.state = self.images.count < MAX_IMAGES_COUNT ? .enabled : .disabled
//                    }
                //                }
                if images.count > oldValue.count {
//                    setTitle()
                    tableView.insertRows(at: [IndexPath(row: images.count-1, section: 0)], with: .top)
                    delay(seconds: 0.2) {
                        self.tableView.selectRow(at: IndexPath(row: self.images.count-1, section: 0), animated: true, scrollPosition: .bottom)
                    }
                    if let header = self.tableView.headerView(forSection: 2) as? NewSurveyHeaderCell {
                        actionButton.text = "\(images.count/MAX_IMAGES_COUNT)"
                    }
                    if images.count > 0, oldValue.isEmpty {
                        UIView.animate(withDuration: 0.2) {
                            self.label.alpha = 0
                        }
                    }
                } else if images.isEmpty, !oldValue.isEmpty {
                    UIView.animate(withDuration: 0.2, animations: {
                        self.label.alpha = 1
                    }) {
                        _ in
                        self.isAnimationStopped      = true
                        self.actionButton.tagColor   = K_COLOR_GRAY
                        self.actionButton.text       = "ПРОПУСТИТЬ"
                        self.actionButton.textSize   = 26
                    }
                }
            }
        }
    }
    private var titleString = "Изображения"
    private var imagePicker = UIImagePickerController ()
    private var currentTF: UITextField? {
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
    private var offsetY:    CGFloat = 0
    private var kbHeight:   CGFloat!
    private var isMovedUp:  Bool?
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    @IBOutlet weak var label: UILabel! {
        didSet {
            label.text = "ИЗОБРАЖЕНИЙ \n НЕТ"
            label.alpha = images.isEmpty ? 1 : 0
        }
    }
    @IBOutlet weak var actionButton: SurveyCategoryIcon! {
        didSet {
            actionButton.categoryID = .Text
            actionButton.tagColor   = images.isEmpty ? K_COLOR_GRAY : K_COLOR_RED
            actionButton.text       = images.isEmpty ? "ПРОПУСТИТЬ" : "OK"
            actionButton.textSize = images.isEmpty ? 26 : 43
            let tap = UITapGestureRecognizer(target: self, action: #selector(ImagesSelectionViewController.somethingTapped))
            actionButton.addGestureRecognizer(tap)
        }
    }
    @IBOutlet weak var addButton: UIButton! {
        didSet {
            addButton.setTitleColor(images.count >= MAX_IMAGES_COUNT ? K_COLOR_GRAY : K_COLOR_RED, for: .normal)
        }
    }
    @IBAction func addTapped(_ sender: Any) {
        if images.count >= MAX_IMAGES_COUNT {
            showAlert(type: .Warning, buttons: [["Хорошо": [.Cancel: nil]]], text: "Достигнуто максимальное количество изображений")
        } else {
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
    }
    //    @IBOutlet weak var addButton: UIBarButtonItem!
    //    @IBAction func addTapped(_ sender: UIBarButtonItem) {
    //        print("add")
    //    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        imagePicker.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        isAnimationStopped = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setTitle()
        actionButton.tagColor   = images.isEmpty ? K_COLOR_GRAY : K_COLOR_RED
        actionButton.text       = images.isEmpty ? "ПРОПУСТИТЬ" : "OK"
        actionButton.textSize = images.isEmpty ? 26 : 43
        if !images.isEmpty {
            isAnimationStopped = false
            let anim = animateTransformScale(fromValue: 1, toValue: 1.15, duration: 0.4, repeatCount: 0, autoreverses: true, timingFunction: CAMediaTimingFunctionName.easeOut.rawValue, delegate: self as CAAnimationDelegate)
            anim.setValue(self.actionButton, forKey: "btn")
            actionButton.layer.add(anim, forKey: nil)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
//        if !images.isEmpty {
//            isAnimationStopped = false
//            let anim = animateTransformScale(fromValue: 1, toValue: 1.15, duration: 0.4, repeatCount: 0, autoreverses: true, timingFunction: CAMediaTimingFunctionName.easeOut.rawValue, delegate: self as CAAnimationDelegate)
//            anim.setValue(self.actionButton, forKey: "btn")
//            actionButton.layer.add(anim, forKey: nil)
//        }
    }
    
    private func setupViews() {
        navigationItem.backBarButtonItem                    = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        navigationItem.setHidesBackButton(true, animated: false)
        
        if let nc = navigationController as? NavigationControllerPreloaded {
            nc.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
            nc.navigationBar.shadowImage     = UIImage()
            nc.isShadowed = false
            nc.duration = 0.2
            nc.transitionStyle = .Icon
            nc.navigationBar.isTranslucent   = false
            nc.isNavigationBarHidden         = false
            nc.navigationBar.barTintColor    = .white
        }
    }
    
    @objc fileprivate func somethingTapped(recognizer: UITapGestureRecognizer) {
        
        if let v = recognizer.view {
            switch v {
            case actionButton:
                if images.isEmpty {
                    navigationController?.popViewController(animated: true)
                } else {
                    UIView.animate(withDuration: 0.15, delay: 0, options: [.curveEaseInOut], animations: {
                        self.actionButton.transform = .identity
                    }) {
                        _ in
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            default:
                print("default")
            }
        }
    }
    
    private func setTitle() {
        let navTitle = UILabel()
        navTitle.numberOfLines = 2
        navTitle.textAlignment = .center
        let attrString = NSMutableAttributedString()
        attrString.append(NSAttributedString(string: titleString + " (", attributes: StringAttributes.getAttributes(font: StringAttributes.getFont(name: StringAttributes.Fonts.Style.Bold, size: 19), foregroundColor: .black, backgroundColor: .clear)))
        attrString.append(NSAttributedString(string: "\(images.count)/\(MAX_IMAGES_COUNT)", attributes: StringAttributes.getAttributes(font: StringAttributes.getFont(name: StringAttributes.Fonts.Style.Regular, size: 17), foregroundColor: .gray, backgroundColor: .clear)))
        attrString.append(NSAttributedString(string: ")", attributes: StringAttributes.getAttributes(font: StringAttributes.getFont(name: StringAttributes.Fonts.Style.Bold, size: 19), foregroundColor: .black, backgroundColor: .clear)))
        navTitle.attributedText = attrString
        navigationItem.titleView = navTitle
    }
}

extension ImagesSelectionViewController: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        isAnimating = false
        if !isAnimationStopped, let btn = anim.value(forKey: "btn") as? SurveyCategoryIcon {
            let _anim = animateTransformScale(fromValue: 1, toValue: 1.1, duration: 0.5, repeatCount: 0, autoreverses: true, timingFunction: CAMediaTimingFunctionName.easeInEaseOut.rawValue, delegate: self as CAAnimationDelegate)
            _anim.setValue(btn, forKey: "btn")
            btn.layer.add(_anim, forKey: nil)
            isAnimating = true
        }
    }
}

extension ImagesSelectionViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return images.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "image", for: indexPath) as? ImageSelectionCell {
            cell.setNeedsLayout()
            cell.layoutIfNeeded()
            cell.pictureView.image = images[indexPath.row].keys.first
            cell.pictureView.contentMode = UIView.ContentMode.scaleAspectFill
            cell.pictureView.layer.cornerRadius = cell.pictureView.frame.height / 2
            cell.textField.text = images[indexPath.row].values.first
            cell.textField.delegate = self
            cell.delegate = self
            cell.indexPath = indexPath
            addTextField(cell.textField)
            if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
                //cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                for i in 0...tableView.numberOfRows(inSection: indexPath.section) {
                    if let c = tableView.cellForRow(at: IndexPath(row: i-1, section: indexPath.section)) {
                        c.separatorInset = UIEdgeInsets(top: 0, left: c.frame.width/5, bottom: 0, right: c.frame.width/5)
                    }
                }
            }
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.height / CGFloat(MAX_IMAGES_COUNT)
    }
}

extension ImagesSelectionViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        currentTF = nil
        currentTF = textField
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
    
    private func addTextField(_ textField: UITextField) {
        if !textFields.contains(textField) {
            textFields.append(textField)
        }
    }
}

extension ImagesSelectionViewController: UIImagePickerControllerDelegate {
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        if let origImage = info[.editedImage] as? UIImage {
//            let imageData = origImage.jpegData(compressionQuality: 0.6)
//            let image = UIImage(data: imageData!)
//            images.append([image!: ""])
//        }
//        dismiss(animated: true)
//    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let origImage = info[.editedImage] as? UIImage {
            let imageData = origImage.jpegData(compressionQuality: 0.6)
            let image = UIImage(data: imageData!)
            images.append([image!: ""])
        }
        dismiss(animated: true)
    }
    
    fileprivate func selectImage(_ source: UIImagePickerController.SourceType) {
        if images.count < MAX_IMAGES_COUNT {
            imagePicker.allowsEditing = true
            imagePicker.sourceType = source
            imagePicker.navigationBar.topItem?.rightBarButtonItem?.tintColor = .black
            present(imagePicker, animated: true)
        } else {
            showAlert(type: .Warning, buttons: [["Закрыть": [.Ok: nil]]], text: "Достигнуто максимальное количество изображений")
        }
    }
}

extension ImagesSelectionViewController: CallbackDelegate {
    func callbackReceived(_ sender: AnyObject) {
        if let v = sender as? ImageSelectionCell, let indexPath = tableView.indexPath(for: v) {
            images.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .bottom)
        }
    }
}
