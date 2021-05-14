//
//  ImageViewController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 13.05.2021.
//  Copyright © 2021 Pavel Bukharov. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController {
    var image: UIImage!
    
    @IBOutlet weak var scrollView: PanZoomImageView! {
        didSet {
            scrollView.image = image
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if let nc = navigationController as? NavigationControllerPreloaded {
            nc.isShadowed = false
            nc.setNavigationBarHidden(true, animated: false)
            
            let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
            tapRecognizer.numberOfTapsRequired = 1
            scrollView.addGestureRecognizer(tapRecognizer)
        }
    }
        
        @objc private func handleTap(_ sender: UITapGestureRecognizer) {
            navigationController!.setNavigationBarHidden(!navigationController!.isNavigationBarHidden, animated: true)
        }
//            nc.navigationBar.setBackgroundImage(UIImage(), for: .default)
//            nc.navigationBar.shadowImage = UIImage()
//            nc.navigationBar.isTranslucent = true
//            nc.navigationBar.tintColor = .white
//            let backItem = UIBarButtonItem()
//            backItem.title = "Назад"
//            navigationItem.backBarButtonItem = backItem
    
//
//    override func viewWillLayoutSubviews() {
//        super.viewWillLayoutSubviews()
//        updateMinZoomScaleForSize(view.bounds.size)
//    }
//
//    func updateConstraintsForSize(_ size: CGSize) {
//        let yOffset = max(0, (size.height - imageView.frame.height) / 2)
//        imageViewTopConstraint.constant = yOffset
//        imageViewBottomConstraint.constant = yOffset
//
//        let xOffset = max(0, (size.width - imageView.frame.width) / 2)
//        imageViewLeadingConstraint.constant = xOffset
//        imageViewTrailingConstraint.constant = xOffset
//
//        view.layoutIfNeeded()
//    }
//
//    func updateMinZoomScaleForSize(_ size: CGSize) {
//        let widthScale = size.width / imageView.bounds.width
//        let heightScale = size.height / imageView.bounds.height
//        let minScale = min(widthScale, heightScale)
//
//        scrollView.minimumZoomScale = minScale
//        scrollView.zoomScale = minScale
//    }

}

//extension ImageViewController: UIScrollViewDelegate {
//    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
//        return imageView
//    }
//
//    func scrollViewDidZoom(_ scrollView: UIScrollView) {
//        updateConstraintsForSize(view.bounds.size)
//    }
//}




class PanZoomImageView: UIScrollView {
    
    var image: UIImage! {
        didSet {
            imageView.image = image
        }
    }
    private let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    convenience init(named: String) {
        self.init(frame: .zero)
//        self.imageName = named
    }
    
    private func commonInit() {
        // Setup image view
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalTo: widthAnchor),
            imageView.heightAnchor.constraint(equalTo: heightAnchor),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor)
            ])
        
        // Setup scroll view
        minimumZoomScale = 1
        maximumZoomScale = 3
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        delegate = self
    
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTapRecognizer.numberOfTapsRequired = 2
        addGestureRecognizer(doubleTapRecognizer)
    }
    
    @objc private func handleDoubleTap(_ sender: UITapGestureRecognizer) {
        if zoomScale == 1 {
            setZoomScale(2, animated: true)
        } else {
            setZoomScale(1, animated: true)
        }
    }
    
}

extension PanZoomImageView: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
}
