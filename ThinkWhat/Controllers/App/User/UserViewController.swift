//
//  UserViewController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 30.11.2021.
//  Copyright © 2021 Pavel Bukharov. All rights reserved.
//

import UIKit
import SafariServices

class UserViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView! {
        didSet {
            imageView.backgroundColor = .clear
        }
    }
    @IBOutlet weak var usernameLabel: UILabel! {
        didSet {
            usernameLabel.numberOfLines = 2
        }
    }
    @IBOutlet weak var genderAgeLabel: UILabel! {
        didSet {
            genderAgeLabel.textColor = .gray
        }
    }
    @IBOutlet weak var publicationsLabel: UILabel!
    @IBOutlet weak var completeLabel: UILabel!
    @IBOutlet weak var subscribersLabel: UILabel!
    @IBOutlet weak var subscriptionBackground: UIView! {
        didSet {
            subscriptionBackground.layer.zPosition = 9
        }
    }
    @IBOutlet weak var subscriptionButton: UIButton! {
        didSet {
            subscriptionButton.layer.zPosition = 10
            subscriptionButton.backgroundColor = .white
            subscriptionButton.setTitleColor(.darkGray, for: .normal)
        }
    }
    @IBAction func subscriptionTapped(_ sender: UIButton) {
        
    }
    @IBOutlet weak var contentView: UIView! {
        didSet {
//            contentView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.05)
        }
    }
    @IBOutlet weak var tableView: UITableView! {
        didSet {
//            tableView.translatesAutoresizingMaskIntoConstraints = false
            tableView.rowHeight = UITableView.automaticDimension
            tableView.estimatedRowHeight = 2.0
        }
    }
    @IBOutlet weak var stackView: UIStackView! {
        didSet {
            stackView.distribution = .fillEqually
            stackView.spacing = 4
        }
    }
    @IBOutlet weak var stackViewWidthConstraint: NSLayoutConstraint!
    
    var color: UIColor = K_COLOR_RED
    var userprofile: Userprofile!
    private var isUISetupComplete = false
    private var barButton: Icon!
    private var socialButtons: [UIView] = [] {
        didSet {
            stackViewWidthConstraint.constant = stackView.frame.height * CGFloat(stackView.arrangedSubviews.count)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        assert(userprofile != nil, "\(self) userprofile is nil")
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupUI()
        API.shared.getUserTopPublications(user: userprofile) { result in
            switch result {
            case .success(let json):
                print(json)
            case .failure(let error):
                showAlert(type: .Warning, buttons: [["Закрыть": [CustomAlertView.ButtonType.Ok: nil]]], text: error.localizedDescription)
            }
        }

    }
    
    private func setupUI() {
        guard !isUISetupComplete else { return }
        isUISetupComplete = true
        if let nc = navigationController as? NavigationControllerPreloaded {
            nc.isShadowed = false
        }
        
        view.setNeedsLayout()
        view.layoutIfNeeded()
        usernameLabel.text = userprofile.name.replacingOccurrences(of: " ", with: "\n")
        genderAgeLabel.text = "\(userprofile.gender == .Male ? "мужчина" : "женщина"), \(userprofile.age)"
        subscriptionButton.cornerRadius = subscriptionButton.frame.height / 2
        subscriptionBackground.addShadow(shadowPath: UIBezierPath(roundedRect: subscriptionBackground.bounds,
                                                                cornerRadius: subscriptionButton.cornerRadius).cgPath,
                                         shadowColor: UIColor.lightGray.withAlphaComponent(0.4),
                                         shadowOffset: CGSize(width: 0, height: subscriptionBackground.bounds.height / 5),
                                         shadowOpacity: 1,
                                         shadowRadius: subscriptionBackground.bounds.height / 2)
        if let image = userprofile.image {
            imageView.image = image.circularImage(size: imageView.frame.size, frameColor: color)
//            imageView.cornerRadius = imageView.frame.height/2
        } else {
            //Download
        }
        barButton = Icon(frame: CGRect(origin: .zero, size: CGSize(width: 20, height: 20)))
        barButton.scaleMultiplicator = 1
        barButton.backgroundColor = .clear
        barButton.iconColor = .black
        barButton.isRounded = false
        barButton.category = .Follow
        if userprofile.facebookURL != nil {
            let icon = FacebookLogo(frame: .zero)
            icon.accessibilityIdentifier = "facebook"
            icon.isOpaque = false
            stackView.addArrangedSubview(icon)
            icon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(UserViewController.handleTap(recognizer:))))
            socialButtons.append(icon)
        }
        if userprofile.instagramURL != nil {
            let icon = InstagramLogo(frame: .zero)
            icon.accessibilityIdentifier = "instagram"
            icon.isOpaque = false
            icon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(UserViewController.handleTap(recognizer:))))
            stackView.addArrangedSubview(icon)
        }
        if userprofile.tiktokURL != nil {
            let icon = TikTokLogo(frame: .zero)
            icon.accessibilityIdentifier = "tiktok"
            icon.isOpaque = false
            icon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(UserViewController.handleTap(recognizer:))))
            stackView.addArrangedSubview(icon)
        }
        if userprofile.vkURL != nil {
            let icon = VKLogo(frame: .zero)
            icon.accessibilityIdentifier = "vk"
            icon.isOpaque = false
            icon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(UserViewController.handleTap(recognizer:))))
            stackView.addArrangedSubview(icon)
        }
    }
    
    @objc private func handleTap(recognizer: UITapGestureRecognizer) {
        if recognizer.state == .ended, let sender = recognizer.view {
            if sender.accessibilityIdentifier == "facebook", let url = userprofile.facebookURL {
                    var vc: SFSafariViewController!
                    let config = SFSafariViewController.Configuration()
                    config.entersReaderIfAvailable = true
                    vc = SFSafariViewController(url: url, configuration: config)
                    present(vc, animated: true)
            } else if sender.accessibilityIdentifier == "vk" {
                
            } else if sender.accessibilityIdentifier == "tiktok" {
                
            } else if sender.accessibilityIdentifier == "instagram" {
                
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension UserViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "interest", for: indexPath) as? InterestCell {
                if !cell.isViewSetupComplete {
                    cell.userprofile = userprofile
                    cell.collectionView.delegate = cell
                    cell.isViewSetupComplete = true
                }
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Топ интересов"
        } else if section == 1 {
            return "Активные публикации"
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if indexPath.section == 0 {
//            if let cell = tableView.cellForRow(at: indexPath) as? InterestCell {
//                return cell.collectionView.contentSize.height
//            }
//        }
        return UITableView.automaticDimension//200
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
}

