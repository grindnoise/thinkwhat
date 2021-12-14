//
//  ClaimViewController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 08.06.2020.
//  Copyright © 2020 Pavel Bukharov. All rights reserved.
//

import UIKit

class ClaimViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    deinit {
        print("---\(self) deinit()")
    }
    private var claimCategory: ClaimCategory? {
        didSet {
            for cell in claimCells {
                if cell.claimCategory != claimCategory {
                    cell.isChecked = false
                }
            }
            if claimCategory != nil {
                delegate?.callbackReceived(claimCategory!)
            }
        }
    }
    
    @IBOutlet weak var effectView: UIVisualEffectView! {
        didSet {
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0, delay: 0, options: [], animations: {
                self.effectView.effect = nil
            })
        }
    }
    @IBOutlet weak var feedbackLabel: UILabel! {
        didSet {
            let attributedText = NSMutableAttributedString()
            attributedText.append(NSAttributedString(string: "Жалоба отправлена", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: 25), foregroundColor: .black, backgroundColor: .clear)))
            attributedText.append(NSAttributedString(string: "\n\nСпасибо за обратную поддержку!", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Regular, size: 19), foregroundColor: .darkGray, backgroundColor: .clear)))
            feedbackLabel.attributedText = attributedText
            feedbackLabel.textAlignment = .center
            feedbackLabel.alpha = 0
            feedbackLabel.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }
    }
    @IBOutlet weak var feedbackView: UIView!
    @IBOutlet weak var tableView: UITableView!
    private var claimCells: [ClaimCell]    = []
    weak var delegate: CallbackDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self as UITableViewDelegate
        tableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ClaimCategories.shared.container.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < ClaimCategories.shared.container.count, let cell = tableView.dequeueReusableCell(withIdentifier: "claim", for: indexPath) as? ClaimCell {
            cell.setNeedsLayout()
            cell.layoutIfNeeded()
            cell.claimCategory = ClaimCategories.shared.container[indexPath.row]
            if !claimCells.contains(cell) {
                claimCells.append(cell)
            }
            return cell
        } else if let cell = tableView.dequeueReusableCell(withIdentifier: "cancel", for: indexPath) as? ClaimCancelCell {
            cell.cellDelegate = self
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? ClaimCell {
            cell.isChecked = true
            claimCategory = cell.claimCategory
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableView.automaticDimension
        if indexPath.row < ClaimCategories.shared.container.count {
            return UITableView.automaticDimension
        } else {
            return 3 * CGFloat(ClaimCategories.shared.container.count)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func showFeedback(completion: @escaping(Bool)->()) {
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0, options: [.curveLinear], animations: {
            self.feedbackView.alpha = 1
            self.effectView.effect = UIBlurEffect(style: .light)
        }) {
            _ in
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.2, delay: 0, options: [.curveEaseInOut], animations: {
            self.effectView.effect = nil
            self.feedbackLabel.alpha = 1
            self.feedbackLabel.transform = .identity
            }) {
                _ in
                completion(true)
            }
        }
    }
}

class ClaimCell: UITableViewCell {
    deinit {
        print("***ClaimCell deinit***")
    }
    
    @IBOutlet weak var checkBox: CheckBox!
    @IBOutlet weak var frameView: UIView!
    @IBOutlet weak var textView: UITextView! {
        didSet {
//            let recognizer = UITapGestureRecognizer(target: self, action: #selector(ClaimCell.handleTap(recognizer:)))
//            textView.addGestureRecognizer(recognizer)
            if claimCategory != nil {
                let textContent = claimCategory.description.contains("\t") ? claimCategory.description : "\t" + claimCategory.description
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.hyphenationFactor = 1.0
                paragraphStyle.lineSpacing = 5
                let attributedString = NSMutableAttributedString(string: textContent, attributes: [NSAttributedString.Key.paragraphStyle:paragraphStyle])
                attributedString.addAttributes(StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Regular, size: 14), foregroundColor: isChecked ? .black : .gray, backgroundColor: .clear), range: textContent.fullRange())
                textView.attributedText = attributedString
                textView.textContainerInset = UIEdgeInsets(top: 3, left: textView.textContainerInset.left, bottom: 3, right: textView.textContainerInset.right)
            }
        }
    }
    var claimCategory: ClaimCategory! {
        didSet {
            if textView != nil {
                let textContent = claimCategory.description.contains("\t") ? claimCategory.description : "\t" + claimCategory.description
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.hyphenationFactor = 1.0
                paragraphStyle.lineSpacing = 5
                let attributedString = NSMutableAttributedString(string: textContent, attributes: [NSAttributedString.Key.paragraphStyle:paragraphStyle])
                attributedString.addAttributes(StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Regular, size: 14), foregroundColor: isChecked ? .black : .gray, backgroundColor: .clear), range: textContent.fullRange())
                textView.attributedText = attributedString
                textView.textContainerInset = UIEdgeInsets(top: 3, left: textView.textContainerInset.left, bottom: 3, right: textView.textContainerInset.right)
            }
        }
    }
    weak var cellDelegate: CallbackDelegate?
    var isChecked = false {
        didSet {
            if oldValue != isChecked, checkBox != nil {
                checkBox.isOn = isChecked
                UIView.transition(with: textView, duration: 0.3, options: .transitionCrossDissolve, animations: {
                    self.textView.textColor = self.isChecked ? .black : .gray
                })
            }
        }
    }
//    @objc private func handleTap(recognizer: UITapGestureRecognizer) {
//        if recognizer.state == .ended {
//            cellDelegate?.callbackReceived(index as AnyObject)
//        }
//    }
}

extension ClaimViewController: CallbackDelegate {
    func callbackReceived(_ sender: AnyObject) {
        if sender is ClaimCancelCell {
            delegate?.callbackReceived("cancel_claim" as AnyObject)
//            dismiss(animated: true) { _ in }
        }
    }
}

class ClaimCancelCell: UITableViewCell {
    weak var cellDelegate: CallbackDelegate?
    deinit {
        print("***ClaimCancelCell deinit***")
    }
    @IBOutlet weak var button: UIButton!
    @IBAction func buttonTapped(_ sender: Any) {
        cellDelegate?.callbackReceived(self)
    }
}
