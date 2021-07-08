//
//  ImageViewController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 13.05.2021.
//  Copyright © 2021 Pavel Bukharov. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController {
    var image:              UIImage!
    var titleString:        String = ""
    private var kbHeight:   CGFloat!
    private var isMovedUp:  Bool?
    private var textFields: [UITextField] = []
    private var offsetY:    CGFloat = 0
    @IBOutlet weak var scrollView: PanZoomImageView! {
        didSet {
            scrollView.image = image
        }
    }
    @IBOutlet weak var titleTextField: UITextField! {
        didSet {
            titleTextField.text = titleString
        }
    }
    @IBAction func titleChanged(_ sender: UITextField) {
        titleString = sender.text!
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if let nc = navigationController as? NavigationControllerPreloaded {
            nc.isShadowed = false
            nc.setNavigationBarHidden(true, animated: false)
            nc.transitionStyle = .Icon
            nc.duration = 0.25
        }
        titleTextField.delegate = self
        textFields.append(titleTextField)
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tapRecognizer.numberOfTapsRequired = 1
        scrollView.addGestureRecognizer(tapRecognizer)
        NotificationCenter.default.addObserver(self, selector: #selector(ImageViewController.applicationWillResignActive(notification:)), name: UIApplication.willResignActiveNotification, object: UIApplication.shared)
        NotificationCenter.default.addObserver(self, selector: #selector(ImageViewController.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ImageViewController.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func handleTap(_ sender: UITapGestureRecognizer) {
//        if scrollView.zoomScale != 1 {
//            scrollView.setZoomScale(1, animated: true)
//        }
        view.endEditing(true)
        navigationController!.setNavigationBarHidden(!navigationController!.isNavigationBarHidden, animated: true)
    }
}

extension ImageViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    private func findFirstResponder() -> UITextField? {
        
        for textField in textFields {
            if textField.isFirstResponder {
                return textField
            }
        }
        return nil
    }
    
    func textFieldIsAboveKeyBoard(_ textField: UITextField?) -> Bool {
        
        var activeTextField: UITextField?
        if textField != nil {
            activeTextField = textField
        } else {
            activeTextField = findFirstResponder()
        }
        
        if (activeTextField != nil) {
            
            let tfPoint = CGPoint(x: activeTextField!.frame.minX, y: activeTextField!.frame.maxY * 1.5)
            let convertedPoint = view.convert(tfPoint, from: activeTextField?.superview)
            
            
            if convertedPoint.y <= (view.frame.height - kbHeight) {
                return true
            } else {
                offsetY = -(view.frame.height - kbHeight - convertedPoint.y) + 15 //+ (activeTextField?.bounds.height)! / 2
            }
        }
        
        return false
        
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            if let keyboardSize =  (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                if (isMovedUp == nil) || isMovedUp == false {
                    kbHeight = keyboardSize.height
                    if !textFieldIsAboveKeyBoard(nil) {
                        self.moveTextField(true)
                    }
                }
            }
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        if isMovedUp != nil {
            if isMovedUp! {
                self.moveTextField(false)
            }
        }
    }
    
    @objc private func applicationWillResignActive(notification: NSNotification) {
        view.endEditing(true)
        if isMovedUp != nil {
            if isMovedUp! {
                moveTextField(false)
            }
        }
    }
    
    private func moveTextField(_ up: Bool) {
        let movement = (up ? -kbHeight : kbHeight)
        UIView.animate(withDuration: 0.2, animations: {
            self.view.frame.origin.y += movement!
            if up {
                self.isMovedUp = true
            } else {
                self.isMovedUp = false
            }
        })
    }
}

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
    
    convenience init(named: String) {
        self.init(frame: .zero)
//        self.imageName = named
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
    
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTapRecognizer.numberOfTapsRequired = 2
        addGestureRecognizer(doubleTapRecognizer)
    }
    
    @objc private func handleDoubleTap(_ sender: UITapGestureRecognizer) {
        if zoomScale == 1 {
            setZoomScale(2, animated: true)
        } else {
            setZoomScale(1, animated: true)
        }
    }
    
}

extension PanZoomImageView: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
}
