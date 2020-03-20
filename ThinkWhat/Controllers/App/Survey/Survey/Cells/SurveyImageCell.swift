//
//  SurveyImageCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 19.03.2020.
//  Copyright © 2020 Pavel Bukharov. All rights reserved.
//

import UIKit

class SurveyImageCell: UITableViewCell {

    var slides: [Slide] = []
    var isSetupCompleted = false {
        didSet {
            if isSetupCompleted {
                scrollView.isUserInteractionEnabled = true
            }
        }
    }
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            //scrollView.isUserInteractionEnabled = isSetupCompleted ? true : false
        }
    }
    @IBOutlet weak var pageControl: UIPageControl!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setupSlides(count: Int) {
        if !isSetupCompleted {
            //scrollView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
            scrollView.contentSize = CGSize(width: scrollView.frame.width * CGFloat(count), height: scrollView.frame.height)
            scrollView.isScrollEnabled = true
            scrollView.isPagingEnabled = true
            
            for i in 0..<count {
                let slide  = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
                slide.backgroundColor = i == 0 ? UIColor.black : UIColor.red//.withAlphaComponent(0.3 * CGFloat(i))
                slide.frame = CGRect(x: scrollView.frame.width * CGFloat(i), y: 0, width: scrollView.frame.width, height: scrollView.frame.height)
                scrollView.addSubview(slide)
                slides.append(slide)
//                slide.imageView.image = UIImage(named: "ic_onboarding_1")
            }
            isSetupCompleted = true
        }
    }
}
