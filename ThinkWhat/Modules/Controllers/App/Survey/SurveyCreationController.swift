//
//  SurveyCreationController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 24.05.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class SurveyCreationController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.setNeedsLayout()
        view.layoutIfNeeded()
        setText()
    }
    
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        tabBarController?.setTabBarVisible(visible: true, animated: true)
    }

    
    private func setText() {
        let ratingString = NSMutableAttributedString()
        ratingString.append(NSAttributedString(string: "rating".localized.uppercased(), attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: ratingLabel.bounds.width * 0.1), foregroundColor: .secondaryLabel, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        ratingLabel.attributedText = ratingString
        
        let pollString = NSMutableAttributedString()
        pollString.append(NSAttributedString(string: "poll".localized.uppercased(), attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: ratingLabel.bounds.width * 0.1), foregroundColor: .secondaryLabel, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        pollLabel.attributedText = pollString
    }

    @IBOutlet weak var stack: UIStackView!
    @IBOutlet weak var ratingLabel: ArcLabel!
    @IBOutlet weak var ratingIcon: Icon! {
        didSet {
            ratingIcon.backgroundColor = UIColor.clear
            ratingIcon.iconColor       = UIColor.lightGray.withAlphaComponent(0.75)
            ratingIcon.category        = .Rating
//            ratingIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(NewSurveySelectionTypeController.handleTap(recognizer:))))
        }
    }
    @IBOutlet weak var pollLabel: ArcLabel!
    @IBOutlet weak var pollIcon: Icon! {
        didSet {
            pollIcon.backgroundColor = UIColor.clear
            pollIcon.iconColor       = UIColor.lightGray.withAlphaComponent(0.75)
            pollIcon.scaleMultiplicator     = 2.65
            pollIcon.category        = .Poll
//            pollIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(NewSurveySelectionTypeController.handleTap(recognizer:))))
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
