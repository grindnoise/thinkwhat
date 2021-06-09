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
            nc.transitionStyle = .Icon
            nc.duration = 0.2
        }
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tapRecognizer.numberOfTapsRequired = 1
        scrollView.addGestureRecognizer(tapRecognizer)
        
    }
    
    @objc private func handleTap(_ sender: UITapGestureRecognizer) {
//        if scrollView.zoomScale != 1 {
//            scrollView.setZoomScale(1, animated: true)
//        }
        navigationController!.setNavigationBarHidden(!navigationController!.isNavigationBarHidden, animated: true)
    }
}

class PanZoomImageView: UIScrollView {
    
    var image: UIImage! {
        didSet {
            imageView.image = image
        }
    }
    let imageView = UIImageView()
    
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
