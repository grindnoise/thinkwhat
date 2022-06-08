//
//  ImageSelectionPopup.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 02.06.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class ImageSelectionPopup: UIView, UINavigationControllerDelegate {
    
    enum Mode {
        case Create, Edit
    }
    
    // MARK: - Initialization
    init(controller: UIViewController?, callbackDelegate: CallbackObservable, item: ImageItem? = nil) {
        super.init(frame: .zero)
        self.controller = controller
        self.item = item
        self.mode = item.isNil ? .Create : .Edit
        self.callbackDelegate = callbackDelegate
        commonInit()
    }
    
//    init(controller: UIViewController?, callbackDelegate: CallbackObservable) {
//        super.init(frame: .zero)
//        self.controller = controller
//        self.callbackDelegate = callbackDelegate
//        commonInit()
//    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        guard let contentView = self.fromNib() else { fatalError("View could not load from nib") }
        addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        setObservers()
        setupUI()
    }
    
    private func setObservers() {
        observers.append(imageView.observe(\UIImageView.bounds, options: .new, changeHandler: { [weak self] (view: UIView, change: NSKeyValueObservedChange<CGRect>) in
            guard let self = self, let value = change.newValue else { return }
            self.imageView.cornerRadius = value.width * 0.05
        }))
        observers.append(textView.observe(\UITextView.bounds, options: .new, changeHandler: { [weak self] (view: UIView, change: NSKeyValueObservedChange<CGRect>) in
            guard let self = self, let value = change.newValue else { return }
            self.textView.cornerRadius = value.width * 0.05
        }))
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidHide), name: UIResponder.keyboardDidHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
    }
    
    private func setupUI() {
        setText()
        previewStackView.alpha = mode == .Edit ? 1 : 0
        sourceStackView.alpha = mode == .Edit ? 0 : 1
        if mode == .Create {
            buttonsStackView.removeArrangedSubview(delete)
            buttonsStackView.removeArrangedSubview(confirm)
            delete.alpha = 0
            confirm.alpha = 0
        }
    }
    
    private func setText() {
        let fontSize_1: CGFloat = title.bounds.height * 0.3
        let fontSize_2: CGFloat = camera.bounds.width * 0.15
        
        let topicTitleString = NSMutableAttributedString()
        topicTitleString.append(NSAttributedString(string: mode == .Create ? "choose_image".localized : "edit_image".localized, attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: fontSize_1), foregroundColor: .label, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        title.attributedText = topicTitleString
        
        let cameraAttrString = NSMutableAttributedString()
        cameraAttrString.append(NSAttributedString(string: "camera".localized.uppercased(), attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: fontSize_2), foregroundColor: .label/*color*/, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        cameraLabel.attributedText = cameraAttrString
        
        let galleryAttrString = NSMutableAttributedString()
        galleryAttrString.append(NSAttributedString(string: "photo_album".localized.uppercased(), attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: fontSize_2), foregroundColor: .label/*color*/, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        galleryLabel.attributedText = galleryAttrString
        
        let descrAttrString = NSMutableAttributedString()
        descrAttrString.append(NSAttributedString(string: "poll_description".localized.uppercased(), attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Regular, size: descriptionLabel.bounds.width * 0.04), foregroundColor: .secondaryLabel/*color*/, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        descriptionLabel.attributedText = descrAttrString

        textView.font = StringAttributes.font(name: StringAttributes.Fonts.Style.Regular, size: textView.bounds.width * 0.04)
        textView.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
    }
    
    @objc
    private func handleTap(_ recognizer: UITapGestureRecognizer) {
        if let v = recognizer.view {
            if v === confirm {
                callbackDelegate?.callbackReceived(item as Any)
            } else if v === camera {
                self.imagePicker.sourceType = UIImagePickerController.SourceType.camera
                controller?.present(self.imagePicker, animated: true, completion: nil)
            } else if v === gallery {
                self.imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
                controller?.present(self.imagePicker, animated: true, completion: nil)
            } else if v === cancel {
                callbackDelegate?.callbackReceived("exit" as Any)
            } else if v === delete {
                item?.shouldBeDeleted = true
                callbackDelegate?.callbackReceived(item as Any)
            }
        }
    }
    
    @objc private func keyboardDidHide() {
        if let recognizer = gestureRecognizers?.filter({ $0.accessibilityValue == "hideKeyboard" }).first {
            gestureRecognizers?.remove(object: recognizer)
        }
    }
    
    @objc private func keyboardDidShow() {
        guard gestureRecognizers.isNil || gestureRecognizers!.filter({ $0.accessibilityValue == "hideKeyboard" }).isEmpty else { return }
        let touch = UITapGestureRecognizer(target:self, action: #selector(self.hideKeyboard))
        touch.accessibilityValue = "hideKeyboard"
        self.addGestureRecognizer(touch)
    }
    
    @objc private func hideKeyboard() {
        endEditing(true)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        gallery.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
        camera.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
        confirm.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
        textView.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
        cancel.tintColor =  traitCollection.userInterfaceStyle == .dark ? .systemBlue : .label
        confirm.tintColor =  traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
        textView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
    }
    
    
    // MARK: - IB outlets
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var sourceStackView: UIStackView!
    @IBOutlet weak var camera: UIImageView! {
        didSet {
            camera.isUserInteractionEnabled = true
            camera.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
            camera.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:))))
        }
    }
    @IBOutlet weak var cameraLabel: ArcLabel!
    @IBOutlet weak var gallery: UIImageView! {
        didSet {
            gallery.isUserInteractionEnabled = true
            gallery.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
            gallery.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:))))
        }
    }
    @IBOutlet weak var galleryLabel: ArcLabel!
    @IBOutlet weak var imageView: UIImageView! {
        didSet {
            imageView.contentMode = .scaleAspectFill
            imageView.image = item?.image
        }
    }
    @IBOutlet weak var descriptionLabel: InsetLabel! {
        didSet {
            descriptionLabel.insets = UIEdgeInsets(top: 10,
                                                   left: 10,
                                                   bottom: 10,
                                                   right: 10)
        }
    }
    @IBOutlet weak var previewStackView: UIStackView!
    @IBOutlet weak var textView: UITextView! {
        didSet {
            textView.contentInset = UIEdgeInsets(top: 10,
                                                 left: 8,
                                                 bottom: 10,
                                                 right: 10)
            textView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
            textView.text = item?.title ?? ""
            textView.delegate = self
        }
    }
    @IBOutlet weak var buttonsStackView: UIStackView!
    @IBOutlet weak var cancel: UIImageView! {
        didSet {
            cancel.isUserInteractionEnabled = true
            cancel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:))))
            cancel.tintColor =  traitCollection.userInterfaceStyle == .dark ? .systemBlue : .label
        }
    }
    @IBOutlet weak var confirm: UIImageView! {
        didSet {
            confirm.isUserInteractionEnabled = true
            confirm.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:))))
            confirm.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
        }
    }
    @IBOutlet weak var delete: UIImageView! {
        didSet {
            delete.isUserInteractionEnabled = true
            delete.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:))))
            delete.tintColor = .systemRed
        }
    }
    
    private var mode: ImageSelectionPopup.Mode = .Create {
        didSet {
            guard !previewStackView.isNil, !sourceStackView.isNil else { return }
            previewStackView.alpha = mode == .Edit ? 1 : 0
            sourceStackView.alpha = mode == .Edit ? 0 : 1
        }
    }
    private weak var callbackDelegate: CallbackObservable?
    private var item: ImageItem? {
        didSet {
            guard oldValue != item else { return }
            if !item.isNil {
                imageView.image = item?.image
                buttonsStackView.addArrangedSubview(confirm)
                confirm.alpha = 1
                previewStackView.alpha = 1
                sourceStackView.alpha = 0
            }
        }
    }
    private weak var controller: UIViewController?
    private lazy var imagePicker: UIImagePickerController = {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        return picker
    }()
    private var observers: [NSKeyValueObservation] = []
}

extension ImageSelectionPopup: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let origImage = info[.editedImage] as? UIImage {
            let resizedImage = origImage.resized(to: CGSize(width: 800, height: 800))
            guard let imageData = resizedImage.jpegData(compressionQuality: 0.4),
                  let image = UIImage(data: imageData) else { fatalError("") }
            guard item.isNil else { item!.image = image; return }
            item = ImageItem(title: "", image: image)
            controller?.dismiss(animated: true)
        }
    }
}

extension ImageSelectionPopup: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
                
        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
        return updatedText.count <= ModelProperties.shared.surveyMediaTitleMaxLength
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        item?.title = textView.text
    }
}
