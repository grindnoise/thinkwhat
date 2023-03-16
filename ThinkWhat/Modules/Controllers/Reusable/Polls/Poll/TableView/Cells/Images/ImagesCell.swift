//
//  ImagesCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 28.03.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class ImagesCell: UITableViewCell, UIScrollViewDelegate {
    deinit {
        print("ImagesCell deinit")
    }
    var slides: [Slide] = []
    private var isSetupComplete = false {
        didSet {
            if isSetupComplete {
                scrollView.isUserInteractionEnabled = true
            }
        }
    }
    private weak var delegate: CallbackObservable?
    private var survey: Survey!
    private var pageIndex: Int = 0
    private var color: UIColor = K_COLOR_RED
    
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.isUserInteractionEnabled = isSetupComplete ? true : false
            scrollView.delegate = self
        }
    }
    @IBOutlet weak var pageControl: UIView! {
        didSet {
            pageControl.alpha = 0
            pageControl.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        }
    }
    @IBOutlet weak var page: UILabel! {
        didSet {
            if page != nil, !slides.isEmpty {
                page.text = "\(pageIndex+1)/\(slides.count)"
            }
        }
    }
    //    @IBOutlet weak var pageControl: UIPageControl! {
//        didSet {
//            pageControl.alpha = 0
//        }
//    }
    
    @objc private func callback() {
        delegate?.callbackReceived(self)
    }
    
    
    func createSlides(count: Int) {
            scrollView.contentSize = CGSize(width: scrollView.frame.width * CGFloat(count), height: scrollView.frame.height)
            scrollView.isScrollEnabled = true
            scrollView.isPagingEnabled = true
            
            for i in 0..<count {
                let slide  = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
                slide.color = survey.topic.tagColor
                slide.frame = CGRect(x: scrollView.frame.width * CGFloat(i), y: 0, width: scrollView.frame.width, height: scrollView.frame.height)
                slide.imageView.backgroundColor = .secondarySystemBackground
                let recognizer = UITapGestureRecognizer(target: self, action: #selector(ImagesCell.imageTapped(recognizer:)))
                slide.imageView.addGestureRecognizer(recognizer)
                scrollView.insertSubview(slide, at: 0)
                slide.cornerRadius = slide.frame.width * 0.05
                slides.append(slide)
            }
    }
    
    func showPageControl(animated: Bool = true) {
        if slides.count > 1, pageControl != nil, page != nil {
            page.text = "\(pageIndex+1)/\(slides.count)"
            if animated {
                pageControl.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                UIView.animate(withDuration: 0.3, delay: 0.3, options: .curveEaseInOut, animations: {
                    self.pageControl.alpha = 1
                    self.pageControl.transform = .identity
                })
            } else {
                pageControl.alpha = 1
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        pageIndex = Int(round(scrollView.contentOffset.x/scrollView.frame.width))
        page.text = "\(pageIndex+1)/\(slides.count)"
    }
    
    @objc private func imageTapped(recognizer: UITapGestureRecognizer) {
        if let imageView = recognizer.view as? UIImageView, let image = imageView.image {
            delegate?.callbackReceived(image as AnyObject)
        }
    }
    
    public func setupUI(delegate callbackDelegate: CallbackObservable, survey _survey: Survey) {
        if !isSetupComplete {
            setNeedsLayout()
            layoutIfNeeded()
            survey = _survey
            pageControl.cornerRadius = pageControl.frame.height/4
            createSlides(count: survey.imagesCount)
            for (index, slide) in slides.enumerated() {
                if let media = survey.mediaWithImageURLs.filter({ $0.order == index}).first {
                    if let image = media.image {
                        slide.imageView.image = image//survey!.images![index]?.keys.first
                        slide.imageView.progressIndicatorView.alpha = 0
                    } else if let url = media.imageURL {
                        API.shared.system.downloadImage(url: url) { progress in
                            self.slides[index].imageView.progressIndicatorView.progress = progress
                        } completion: { result in
                            switch result {
                            case .success(let image):
                                media.image = image
                                self.slides[index].imageView.image = image
                                self.slides[index].imageView.progressIndicatorView.reveal()
                                if index == 0 {
                                    self.showPageControl()
                                }
                            case .failure(let error):
                                callbackDelegate.callbackReceived(AppError.imageDownload)
//                                delBanner.shared.contentType = .Warning
//                                if let content = delBanner.shared.content as? Warning {
//                                    content.level = .Error
//                                    content.text = "Произошла ошибка, изображение не было загружено"
//                                }
//                                delBanner.shared.present(shouldDismissAfter: 2, delegate: nil)
//                                print(error.localizedDescription)
                            }
                        }
                    }
                }
            }
            delegate = callbackDelegate
            pageControl.alpha = slides.count > 1 ? 1 : 0
            showPageControl(animated: false)
            isSetupComplete = true
        }
    }
}
