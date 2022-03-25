//
//  APIUnavailableView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 24.03.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class APIUnavailableView: UIView {
    deinit {
        print("APIUnavailableView deinit")
    }
    
    // MARK: - Initialization
    init(frame: CGRect, delegate _delegate: CallbackDelegate) {
        super.init(frame: frame)
        delegate = _delegate
        commonInit()
    }
    
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
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(contentView)
        setupUI()
    }
    
    private func setupUI() {
        button.cornerRadius = button.frame.height/2.25
    }
    
    // MARK: - IB outlets
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var label: UILabel! {
        didSet {
            label.text = "api_unavailable".localized
        }
    }
    @IBOutlet weak var button: UIButton! {
        didSet {
            button.setTitle("retry".localized.uppercased(), for: .normal)
            button.backgroundColor = UIColor { traitCollection in
                switch traitCollection.userInterfaceStyle {
                case .dark:
                    return .systemBlue
                default:
                    return K_COLOR_RED
                }
            }
        }
    }
    @IBOutlet weak var labelCenterX: NSLayoutConstraint!
    @IBOutlet weak var buttonBottom: NSLayoutConstraint!
    @IBAction func buttonTapped(_ sender: Any) {
        delegate?.callbackReceived(self)
    }
    
    weak var delegate: CallbackDelegate?
}
