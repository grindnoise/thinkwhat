//
//  ClaimView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 06.10.2021.
//  Copyright © 2021 Pavel Bukharov. All rights reserved.
//

import UIKit

class ClaimView: UIView {
    private var claimCells: [delClaimCell]    = []
    private var claimCategory: Claim? {
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
    weak var delegate: CallbackObservable?
    
    deinit {
        print("deinit")
    }
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self as UITableViewDelegate
            tableView.dataSource = self
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Not for XIB/NIB")
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("ClaimView", owner: self, options: nil)
        guard let content = contentView else {
            return
        }
        backgroundColor             = .clear
        content.frame               = bounds
        content.autoresizingMask    = [.flexibleHeight, .flexibleWidth]
        self.addSubview(content)
    }
}

extension ClaimView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Claims.shared.all.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = delClaimCell(frame: CGRect(origin: .zero, size: CGSize(width: tableView.frame.width, height: 50)))
            cell.claimCategory = Claims.shared.all[indexPath.row]
            if !claimCells.contains(cell) {
                claimCells.append(cell)
            }
            return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? delClaimCell {
            cell.isChecked = true
            claimCategory = cell.claimCategory
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.height / CGFloat(Claims.shared.all.count)// + 1//UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
}
