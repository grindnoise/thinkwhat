//////
//////  ProgressCirle.swift
//////  ThinkWhat
//////
//////  Created by Pavel Bukharov on 22.10.2019.
//////  Copyright © 2019 Pavel Bukharov. All rights reserved.
//////
////
//import UIKit
//import PlaygroundSupport
////
//////extension Float {
//////    var degreesToRadians : CGFloat {
//////        return CGFloat(self) * CGFloat(M_PI) / 180.0
//////    }
//////}
//////
////////
////////  ProgressCirle.swift
////////  ThinkWhat
////////
////////  Created by Pavel Bukharov on 22.10.2019.
////////  Copyright © 2019 Pavel Bukharov. All rights reserved.
////////
//////extension UIImage {
//////
//////    func circularImage(size: CGSize?, frameColor: UIColor) -> UIImage {
//////        let newSize = size ?? self.size
//////
//////        let minEdge = min(newSize.height, newSize.width)
//////        let size = CGSize(width: minEdge, height: minEdge)
//////
//////        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
//////        let context = UIGraphicsGetCurrentContext()
//////
//////        self.draw(in: CGRect(origin: CGPoint.zero, size: size), blendMode: .copy, alpha: 1.0)
//////
//////        let offset = size.height * 0.04
//////
//////        if frameColor != .clear {
//////            let outerPath = UIBezierPath(ovalIn: CGRect(origin: CGPoint.zero, size: size))
//////            outerPath.lineWidth = offset * 2.5
//////            frameColor.setStroke()
//////            outerPath.stroke()
//////
//////            let innerFrame = CGRect(origin: CGPoint(x: CGPoint.zero.x + offset , y: CGPoint.zero.y + offset), size: CGSize(width: size.width - offset * 2, height: size.height - offset * 2))
//////            let innerPath = UIBezierPath(ovalIn: innerFrame)
//////            innerPath.lineWidth = offset * 0.7
//////            UIColor.white.setStroke()
//////            innerPath.stroke()
//////        }
//////
//////        context!.setBlendMode(.copy)
//////        context!.setFillColor(UIColor.clear.cgColor)
//////
//////        let imageSize = size
//////
//////        let rectPath = UIBezierPath(rect: CGRect(origin: CGPoint.zero, size: imageSize))
//////        let circlePath = UIBezierPath(ovalIn: CGRect(origin: CGPoint.zero, size: imageSize))
//////        rectPath.append(circlePath)
//////        rectPath.usesEvenOddFillRule = true
//////        rectPath.fill()
//////
//////
//////        let result = UIGraphicsGetImageFromCurrentImageContext()
//////        UIGraphicsEndImageContext()
//////
//////        return result!
//////    }
//////
//////}
//////
//////
//////var image = UIImage(named: "user")!
//////let circularImage     = image.circularImage(size: CGSize(width: 200, height: 200), frameColor: .blue)
////internal class Line {
////    var path = UIBezierPath()
////    var layer = CAShapeLayer()
////}
////
////@IBDesignable
////class BorderedLabel: UILabel {
////    let line = Line()
////    var lineWidth: CGFloat = 10
////    var isAnimated = false
////
////    override init(frame: CGRect) {
////        super.init(frame: frame)
////        configureLine()
////    }
////
////    required init?(coder aDecoder: NSCoder) {
////        super.init(coder: aDecoder)
////        configureLine()
////    }
////
////    func configureLine() {
////        let path = UIBezierPath()
////        let point_1 = CGPoint(x: frame.midX - lineWidth / 2, y: frame.minY + lineWidth / 2)
////        path.move(to: point_1)
////
////        let point_2 = CGPoint(x: frame.maxX - lineWidth / 2, y: frame.minY + lineWidth / 2)
////        path.addLine(to: point_2)
////        let point_3 = CGPoint(x: frame.maxX - lineWidth / 2, y: frame.maxY - lineWidth / 2)
////        path.addLine(to: point_3)
////        let point_4 = CGPoint(x: frame.minX + lineWidth / 2, y: frame.maxY - lineWidth / 2)
////        path.addLine(to: point_4)
////        let point_5 = CGPoint(x: frame.minX + lineWidth / 2, y: frame.minY + lineWidth / 2)
////        path.addLine(to: point_5)
////        let point_6 = CGPoint(x: frame.midX + lineWidth / 2, y: frame.minY + lineWidth / 2)
////        path.addLine(to: point_6)
////        line.layer.lineWidth = lineWidth
////        line.layer.strokeColor = UIColor.red.withAlphaComponent(0.2).cgColor
////        line.layer.fillColor = UIColor.clear.cgColor
////        line.layer.lineCap = .square
////        line.layer.path = path.cgPath
////        line.layer.strokeEnd = isAnimated ? 1 : 0
////        layer.addSublayer(line.layer)
////    }
////
////    func animate() {
////        let strokeEndAnimation = CABasicAnimation(keyPath: #keyPath(CAShapeLayer.strokeEnd))
////        strokeEndAnimation.fromValue = line.layer.strokeEnd
////        strokeEndAnimation.toValue = 1
////        strokeEndAnimation.duration = 0.5
////        line.layer.add(strokeEndAnimation, forKey: "animEnd")
////        isAnimated = true
////    }
////}
////
////let l = BorderedLabel(frame: CGRect(origin: .zero, size: CGSize(width: 200, height: 150)))
//////l.backgroundColor = .white
////l.textAlignment = .center
////l.text = "Test"
////l.animate()
//////l.configureLine()
//
//let liveView = UIView(frame: CGRect(x: 0, y: 0, width: 400, height: 50))
//liveView.backgroundColor = .white
//
//PlaygroundPage.current.needsIndefiniteExecution = true
//PlaygroundPage.current.liveView = liveView
//
//let square = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
//square.backgroundColor = .red
//
//liveView.addSubview(square)
//
//let animator = UIViewPropertyAnimator.init(duration: 5, curve: .linear)
//
//animator.addAnimations {
//
//    square.frame.origin.x = 350
//}
//
//let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
//blurView.frame = liveView.bounds
//
//liveView.addSubview(blurView)
//
//animator.addAnimations {
//
//    blurView.effect = nil
//}
//
//// If you want to restore the blur after it was animated, you have to
//// safe a reference to the effect which is manipulated
//let effect = blurView.effect
//
//animator.addCompletion {
//    // In case you want to restore the blur effect
//    if $0 == .start { blurView.effect = effect }
//}
//
//animator.startAnimation()
//animator.pauseAnimation()
//
//DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//
//    animator.fractionComplete = 0.5
//}
//
//DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
//
//    // decide the direction you want your animation to go.
//    // animator.isReversed = true
//    animator.startAnimation()
//}

import UIKit

// a view controller subclass that contains an image view, a visual effect view above it and a slider with an action which controls blur radius of effect view's blur
class BlurDemoViewController: UIViewController {
    let imageView = UIImageView()
    
    let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    
    var animator: UIViewPropertyAnimator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // make imageView same size as view and tell it to stretch together with view both horizontally and verticaly (autoresizing masks are cool again)
        imageView.frame = view.bounds
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        // I don't want my bunny stretched so:
        imageView.contentMode = .scaleAspectFill
        view.addSubview(imageView)
        
        // same thing as with imageView
        effectView.frame = view.bounds
        effectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(effectView)
        
        // animator does all the hard work and just lets us tell it what fraction of its animation we want to see. note that duration is not important here as we will just drive the animation manually
        animator = UIViewPropertyAnimator(duration: 1, curve: .linear) {
            // this is the main trick, animating between a blur effect and nil is how you can manipulate blur radius
            self.effectView.effect = nil
        }
        
        // make a slider always at the bottom of view
        let slider = UISlider()
        slider.frame.origin.x = 20
        slider.frame.origin.y = view.frame.size.height - slider.frame.size.height - 20
        slider.frame.size.width = view.frame.size.width - 40
        slider.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        slider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        view.addSubview(slider)
    }
    
    // this function will be called by UISlider when its value changes. It needs @objc so that it has a #selector (which UISlider uses to send target-action events)
    @objc private func sliderValueChanged(sender: UISlider) {
        animator?.fractionComplete = CGFloat(sender.value)
    }
}

// now just instantiate a blur demo vc and give it an image to show
let vc = BlurDemoViewController()
vc.view.backgroundColor = .white
//vc.imageView.image = #imageLiteral(resourceName: "user.png")

// you can also try out different blur styles if you like
//vc.effectView.effect = UIBlurEffect(style: .dark)
//vc.effectView.effect = UIBlurEffect(style: .extraLight)
// PlaygroundSupport allows us to show a live view (controller)
import PlaygroundSupport
PlaygroundPage.current.liveView = vc
