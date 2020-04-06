//
//  SurveyImageCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 19.03.2020.
//  Copyright © 2020 Pavel Bukharov. All rights reserved.
//

import UIKit

class SurveyImageCell: UITableViewCell, UIScrollViewDelegate {

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
            scrollView.isUserInteractionEnabled = isSetupCompleted ? true : false
            scrollView.delegate = self
        }
    }
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var icon: GalleryIcon! {
        didSet {
            let touch = UITapGestureRecognizer(target:self, action:#selector(self.callback))
            touch.cancelsTouchesInView = false
            icon.addGestureRecognizer(touch)
        }
    }
    
    @objc fileprivate func callback() {
        delegate?.cellSubviewTapped(self)
    }
    weak var delegate: CellButtonDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func createSlides(count: Int) {
        if !isSetupCompleted {
            //scrollView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
            scrollView.contentSize = CGSize(width: scrollView.frame.width * CGFloat(count), height: scrollView.frame.height)
            scrollView.isScrollEnabled = true
            scrollView.isPagingEnabled = true
            
            for i in 0..<count {
                let slide  = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
                //slide.backgroundColor = .white//i == 0 ? UIColor.black : UIColor.red//.withAlphaComponent(0.3 * CGFloat(i))
                slide.frame = CGRect(x: scrollView.frame.width * CGFloat(i), y: 0, width: scrollView.frame.width, height: scrollView.frame.height)
                slide.imageView.backgroundColor = .lightGray
                scrollView.addSubview(slide)
                slides.append(slide)
//                slide.imageView.image = UIImage(named: "ic_onboarding_1")
            }
            pageControl.numberOfPages = count
            isSetupCompleted = true
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x/contentView.frame.width)
        pageControl.currentPage = Int(pageIndex)
    }
}
