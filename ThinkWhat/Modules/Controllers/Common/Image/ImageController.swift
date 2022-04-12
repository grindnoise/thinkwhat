//
//  ImageController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 11.04.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class ImageController: UIViewController {

    deinit {
        debugPrint("ImageViewController deinit")
    }

    init(image _image: UIImage, title _title: String) {
        super.init(nibName: nil, bundle: nil)
        self.image = _image
        self.titleString = _title
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var tapRecognizer: UITapGestureRecognizer! {
        didSet {
            tapRecognizer.delegate = self
        }
    }
    private var doubleTapRecognizer: UITapGestureRecognizer! {
        didSet {
            doubleTapRecognizer.delegate = self
        }
    }
    
    private var image: UIImage!
    private var titleString: String = ""
    
    let theScrollView: UIScrollView = {
            let v = UIScrollView()
            v.backgroundColor = .clear
        v.minimumZoomScale = 1
        v.maximumZoomScale = 3
        v.showsHorizontalScrollIndicator = false
        v.showsVerticalScrollIndicator = false
            return v
        }()

        let contentView: UIView = {
            let v = UIView()
            v.backgroundColor = .clear
            return v
        }()
    
    let imageView: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFit
        v.backgroundColor = .clear
        return v
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        [theScrollView, contentView, imageView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        view.addSubview(theScrollView)
        theScrollView.addSubview(contentView)
        theScrollView.delegate = self
        contentView.addSubview(imageView)
        imageView.image = image
        
        let contentViewHeightConstraint = contentView.heightAnchor.constraint(equalTo: theScrollView.heightAnchor, constant: 0.0)
        contentViewHeightConstraint.priority = .defaultLow
        
        NSLayoutConstraint.activate([
            
            // constrain all 4 sides of the scroll view to the safe area
            theScrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0.0),
            theScrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0.0),
            theScrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0.0),
            theScrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0.0),
            
            // constrain all 4 sides of the content view to the scroll view
            contentView.topAnchor.constraint(equalTo: theScrollView.topAnchor, constant: 0.0),
            contentView.bottomAnchor.constraint(equalTo: theScrollView.bottomAnchor, constant: 0.0),
            contentView.leadingAnchor.constraint(equalTo: theScrollView.leadingAnchor, constant: 0.0),
            contentView.trailingAnchor.constraint(equalTo: theScrollView.trailingAnchor, constant: 0.0),
            
            // constrain width of content view to width of scroll view
            contentView.widthAnchor.constraint(equalTo: theScrollView.widthAnchor, constant: 0.0),
            
            // constrain the stack view >= 8-pts from the top
            // <= minus 8-pts from the bottom
            // 40-pts leading and trailing
            imageView.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            // constrain stack view centerY to contentView centerY
            imageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 0.0),
            
            // activate the contentView's height constraint
            contentViewHeightConstraint,
            
        ])
                tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
                tapRecognizer.numberOfTapsRequired = 1
                theScrollView.addGestureRecognizer(tapRecognizer)
                doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(ImageController.handleDoubleTap(_:)))
                doubleTapRecognizer.numberOfTapsRequired = 2
        theScrollView.addGestureRecognizer(doubleTapRecognizer)
    }
    
        @objc private func handleTap(_ sender: UITapGestureRecognizer) {
//            navigationController!.setNavigationBarHidden(!navigationController!.isNavigationBarHidden, animated: true)
            }
    
        @objc fileprivate func handleDoubleTap(_ sender: UITapGestureRecognizer) {
            if theScrollView.zoomScale == 1 {
                theScrollView.setZoomScale(2, animated: true)
            } else {
                theScrollView.setZoomScale(1, animated: true)
            }
        }
    
}

extension ImageController: UIScrollViewDelegate {

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

}

//import UIKit
//
//class ImageController: UIViewController {
//
//    deinit {
//        debugPrint("ImageViewController deinit")
//    }
//
//    init(image _image: UIImage, title _title: String) {
//        super.init(nibName: nil, bundle: nil)
//        self.image = _image
//        self.titleString = _title
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    enum Mode {
//        case ReadOnly, Write
//    }
//    var image:              UIImage!
//    var titleString:        String = ""
//    var mode: Mode = .Write
//
//    private var tapRecognizer: UITapGestureRecognizer! {
//        didSet {
//            tapRecognizer.delegate = self
//        }
//    }
//    private var doubleTapRecognizer: UITapGestureRecognizer! {
//        didSet {
//            doubleTapRecognizer.delegate = self
//        }
//    }
//    private var kbHeight:   CGFloat!
//    private var isMovedUp:  Bool?
//    private var textFields: [UITextField] = []
//    private var offsetY:    CGFloat = 0
//    private let initialTextViewBottomConstant: CGFloat = 16
//
//    var statusBarHidden = false {
//        didSet {
//            UIView.animate(withDuration: 0.3) {
//                self.setNeedsStatusBarAppearanceUpdate()
//            }
//        }
//    }
//
//    override var prefersStatusBarHidden: Bool {
//        return statusBarHidden
//    }
//
//    @IBOutlet weak var scrollView: PanZoomImageView! {
//        didSet {
//            scrollView.image = image
//
//        }
//    }
//    @IBOutlet weak var titleTextField: UITextField! {
//        didSet {
//            titleTextField.alpha = 0
//            if mode == .Write {
//                titleTextField.alpha = 1
//            }
//            titleTextField.text = titleString
//        }
//    }
//    @IBOutlet weak var titleTextView: UITextView! {
//        didSet {
//            titleTextView.textContainerInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
//            titleTextView.alpha = 0
//            titleTextView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
//            if mode == .ReadOnly, !titleString.isEmpty {
//                titleTextView.alpha = 1
//                let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
//                tapRecognizer.numberOfTapsRequired = 1
//                titleTextView.addGestureRecognizer(tapRecognizer)
//            }
//            titleTextView.text = titleString
//        }
//    }
//
//    @IBOutlet weak var textViewBottomConstraint: NSLayoutConstraint!
//    @IBAction func titleChanged(_ sender: UITextField) {
//        titleString = sender.text!
//    }
//    override func viewDidLoad() {
//        super.viewDidLoad()
////        if let nc = navigationController as? NavigationControllerPreloaded {
////            nc.isShadowed = false
////            nc.transitionStyle = .Icon
////            nc.duration = 0.2
////            self.navigationController?.navigationBar.barTintColor = .black
////        }
//        titleTextField.delegate = self
//        textFields.append(titleTextField)
//        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
//        tapRecognizer.numberOfTapsRequired = 1
//        scrollView.addGestureRecognizer(tapRecognizer)
//        NotificationCenter.default.addObserver(self, selector: #selector(ImageController.applicationWillResignActive(notification:)), name: UIApplication.willResignActiveNotification, object: UIApplication.shared)
//        NotificationCenter.default.addObserver(self, selector: #selector(ImageController.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(ImageController.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
//        doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(ImageController.handleDoubleTap(_:)))
//        doubleTapRecognizer.numberOfTapsRequired = 2
//        scrollView.addGestureRecognizer(doubleTapRecognizer)
//    }
//
//    @objc private func handleTap(_ sender: UITapGestureRecognizer) {
//        view.endEditing(true)
//        navigationController!.setNavigationBarHidden(!navigationController!.isNavigationBarHidden, animated: true)
//        navigationController?.setNeedsStatusBarAppearanceUpdate()
//        tabBarController?.setNeedsStatusBarAppearanceUpdate()
//        setNeedsStatusBarAppearanceUpdate()
//        statusBarHidden = !statusBarHidden
//
//        if mode == .ReadOnly, !titleString.isEmpty {
//            UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut], animations: {
//                self.view.setNeedsLayout()
//                self.textViewBottomConstraint.constant = self.textViewBottomConstraint.constant > 0 ? -(self.titleTextView.frame.height + 16) : 16
//                self.view.layoutIfNeeded()
//            })
//        }
//    }
//
//    @objc fileprivate func handleDoubleTap(_ sender: UITapGestureRecognizer) {
//        if scrollView.zoomScale == 1 {
//            scrollView.setZoomScale(2, animated: true)
//        } else {
//            scrollView.setZoomScale(1, animated: true)
//        }
//    }
//}
//
//extension ImageController: UITextFieldDelegate {
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        textField.resignFirstResponder()
//        return true
//    }
//
//    private func findFirstResponder() -> UITextField? {
//
//        for textField in textFields {
//            if textField.isFirstResponder {
//                return textField
//            }
//        }
//        return nil
//    }
//
//    func textFieldIsAboveKeyBoard(_ textField: UITextField?) -> Bool {
//
//        var activeTextField: UITextField?
//        if textField != nil {
//            activeTextField = textField
//        } else {
//            activeTextField = findFirstResponder()
//        }
//
//        if (activeTextField != nil) {
//
//            let tfPoint = CGPoint(x: activeTextField!.frame.minX, y: activeTextField!.frame.maxY * 1.5)
//            let convertedPoint = view.convert(tfPoint, from: activeTextField?.superview)
//
//
//            if convertedPoint.y <= (view.frame.height - kbHeight) {
//                return true
//            } else {
//                offsetY = -(view.frame.height - kbHeight - convertedPoint.y) + 15 //+ (activeTextField?.bounds.height)! / 2
//            }
//        }
//
//        return false
//
//    }
//
//    @objc func keyboardWillShow(_ notification: Notification) {
//        if let userInfo = notification.userInfo {
//            if let keyboardSize =  (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
//                if (isMovedUp == nil) || isMovedUp == false {
//                    kbHeight = keyboardSize.height
//                    if !textFieldIsAboveKeyBoard(nil) {
//                        self.moveTextField(true)
//                    }
//                }
//            }
//        }
//    }
//
//    @objc func keyboardWillHide(_ notification: Notification) {
//        if isMovedUp != nil {
//            if isMovedUp! {
//                self.moveTextField(false)
//            }
//        }
//    }
//
//    @objc private func applicationWillResignActive(notification: NSNotification) {
//        view.endEditing(true)
//        if isMovedUp != nil {
//            if isMovedUp! {
//                moveTextField(false)
//            }
//        }
//    }
//
//    private func moveTextField(_ up: Bool) {
//        let movement = (up ? -kbHeight : kbHeight)
//        UIView.animate(withDuration: 0.2, animations: {
//            self.view.frame.origin.y += movement!
//            if up {
//                self.isMovedUp = true
//            } else {
//                self.isMovedUp = false
//            }
//        })
//    }
//}
//
class PanZoomImageView: UIScrollView {

    var image: UIImage! {
        didSet {
            imageView.image = image
        }
    }
    let imageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        // Setup image view
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalTo: widthAnchor),
            imageView.heightAnchor.constraint(equalTo: heightAnchor),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor)
            ])

        // Setup scroll view
        minimumZoomScale = 1
        maximumZoomScale = 3
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        delegate = self
    }
}

extension PanZoomImageView: UIScrollViewDelegate {

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

}

extension ImageController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == self.tapRecognizer &&
            otherGestureRecognizer == self.doubleTapRecognizer {
            return true
        }
        return false
    }
}

