//
//  SurveyClaimView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 02.06.2020.
//  Copyright © 2020 Pavel Bukharov. All rights reserved.
//

import UIKit

class SurveyClaimView: UIView, UITabBarDelegate, UITableViewDataSource {
    
    deinit {
        print("---\(self) deinit()")
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ClaimCategories.shared.container.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = ClaimCategories.shared.container[indexPath.row].description
        return cell
    }
    

    @IBOutlet var contentView: UIView!
    @IBAction func cancelTapped(_ sender: UIButton) {
        delegate?.callbackReceived(sender)
        dismiss()
    }
    @IBOutlet weak var tableView: UITableView!
    //    @IBOutlet weak var cancelButton: UIButton!
//    @IBAction func retryTapped(_ sender: Any) {
//        delegate?.signalReceived(self)
//    }
    weak var delegate: CallbackDelegate?
    
    init(frame: CGRect, delegate: CallbackDelegate?) {
        super.init(frame: frame)
        self.commonInit()
        self.delegate = delegate
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    private func commonInit() {
        
        Bundle.main.loadNibNamed("SurveyClaimView", owner: self, options: nil)
        guard let content = contentView else {
            return
        }
        
        content.frame = self.bounds
        content.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(content)
        contentView.alpha = 0
    }
    
    public func present() {
        
        let window = UIApplication.shared.keyWindow
        window?.addSubview(self)
        UIView.animate(withDuration: 0.15, delay: 0, options: .curveLinear, animations: {
            self.contentView.alpha = 1
        })
//        UIView.animate(withDuration: 0.3, animations: {
//            self.contentView.alpha = 1
//        })
    }
    
    fileprivate func dismiss() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveLinear, animations: {
            self.contentView.alpha = 0
        }) {
            _ in
            self.removeFromSuperview()
        }
    }
}
