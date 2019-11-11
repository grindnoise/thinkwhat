//
//  ProgressCirle.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 22.10.2019.
//  Copyright © 2019 Pavel Bukharov. All rights reserved.
//

import UIKit

extension Float {
    var degreesToRadians : CGFloat {
        return CGFloat(self) * CGFloat(M_PI) / 180.0
    }
}

//
//  ProgressCirle.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 22.10.2019.
//  Copyright © 2019 Pavel Bukharov. All rights reserved.
//



class ProgressCirle: UIView {
    
    let circlePathLayer = CAShapeLayer()
    let innerCirclePathLayer = CAShapeLayer()
    let label: UILabel
    var circleRadius: CGFloat!
    var innerCircleRadius: CGFloat!
    var progress: CGFloat {
        didSet {
            if progress != oldValue {
                self.layoutSubviews()
            }
        }
    }
    override init(frame: CGRect) {
        progress = 1
        label = UILabel(frame: frame)
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        progress = 1
        label = UILabel()
        super.init(coder: aDecoder)
        configure()
    }
    
    func configure() {
        innerCirclePathLayer.frame = bounds
        innerCircleRadius = frame.size.height / 4.5
        innerCirclePathLayer.fillColor = UIColor.white.cgColor
        circlePathLayer.frame = bounds
        circleRadius = frame.size.height / 2
        circlePathLayer.fillColor = UIColor(red:1.00, green: 0.72, blue:0.22, alpha:1.0).cgColor//K_COLOR_RED.withAlphaComponent(0.5).cgColor
        label.textAlignment = .center
        label.frame.size = CGSize(width: innerCircleRadius * 1.5, height: innerCircleRadius * 1.5)
        label.center = center
//        label.font = UIFont(name: "OpenSans-Light", size: 15)
        label.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        label.textColor = .darkGray
        label.adjustsFontSizeToFitWidth = true
        label.layer.zPosition = 5
        layer.addSublayer(circlePathLayer)
        layer.addSublayer(innerCirclePathLayer)
        addSubview(label)
        label.minimumScaleFactor = 0.3
    }
    
    
    func circlePath() -> UIBezierPath {
        let angle = ((progress) / 100) * 360 - 90
        let radius = frame.size.height / 2
        let path = UIBezierPath(arcCenter: CGPoint(x: radius, y: radius), radius: radius, startAngle: CGFloat(-Double.pi/2), endAngle: Float(angle).degreesToRadians, clockwise: true)
        path.addLine(to: CGPoint(x: radius, y: radius))
        path.close()
        return path
    }
    
    func innerCirclePath() -> UIBezierPath {
        let angle = ((progress) / 100) * 360 - 90
        let radius = frame.size.height / 2
        let path = UIBezierPath(arcCenter: CGPoint(x: radius, y: radius), radius: innerCircleRadius, startAngle: CGFloat(-Double.pi/2), endAngle: CGFloat(3*Double.pi/2), clockwise: true)
        return path
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        circlePathLayer.frame = bounds
        circlePathLayer.path = circlePath().cgPath
        innerCirclePathLayer.frame = bounds
        innerCirclePathLayer.path = innerCirclePath().cgPath
        label.text = "\(Int(progress))"
    }
}

let circle = ProgressCirle(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 100, height: 100)))
circle.progress = 23

extension String {
    var hexColor: UIColor {
        let hex = trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.count {//characters.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return .clear
        }
        return UIColor(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}
 let color = "#954895".hexColor
circle.backgroundColor = color


//После получения токена
self.apiManager.profileNeedsUpdate() {
    if $1 != nil {
        showAlert(type: .Warning, buttons: ["Ок": [CustomAlertView.ButtonType.Ok: { for btn in self.buttons { btn.state = .disabled; hideAlert() }; AppData.shared.eraseData() }]], text: $1!.localizedDescription)
    } else if $0 == true {
        VKManager.getUserData() {
            response, error in
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            
            if response != nil {
                if let array = response!.dictionaryObject!["response"] {
                    if array is Array<[String: Any]> {
                        let dict = array as! Array<[String: Any]>
                        var vkData = [String: Any]()
                        if dict.count != 0 { vkData = dict.first! }
                        if let pictureKey = dict.first?.keys.filter( { $0.lowercased().contains("photo")} ).first, let value = vkData[pictureKey] as? String {
                            if let pictureURL = URL(string: value) {
                                Alamofire.request(pictureURL).responseData {
                                    response in
                                    if response.result.isFailure {
                                        print(response.result.debugDescription)
                                    }
                                    if let error = response.result.error as? AFError {
                                        print(error.localizedDescription)
                                    }
                                    if let imgData = response.result.value {
                                        if let image = UIImage(data: imgData) {
                                            imagePath = self.storeManager.storeImage(type: .Profile, image: image, fileName: nil, fileFormat: NSData(data: imgData).fileFormat, surveyID: nil)
                                            vkData["image"] = image
                                            vkData.removeValue(forKey: pictureKey)
                                            let data = VKManager.prepareUserData(vkData)
                                            self.apiManager.updateUserProfile(data: data) {
                                                response, error in
                                                if error != nil {
                                                    showAlert(type: .Warning, buttons: ["Ок": [CustomAlertView.ButtonType.Ok: { for btn in self.buttons { btn.state = .disabled; hideAlert() }; AppData.shared.eraseData() }]], text: error!.localizedDescription)
                                                }
                                                if response != nil {
                                                    AppData.shared.importUserData(response!, imagePath)
                                                    self.performSegue(withIdentifier: kSegueTermsFromStartScreen, sender: nil)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        } else {
                            self.apiManager.updateUserProfile(data: VKManager.prepareUserData(vkData)) {
                                response, error in
                                if error != nil {
                                    showAlert(type: .Warning, buttons: ["Ок": [CustomAlertView.ButtonType.Ok: { for btn in self.buttons { btn.state = .disabled; hideAlert() }; AppData.shared.eraseData() }]], text: error!.localizedDescription)
                                }
                                if response != nil {
                                    AppData.shared.importUserData(response!)
                                    self.performSegue(withIdentifier: kSegueTermsFromStartScreen, sender: nil)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
