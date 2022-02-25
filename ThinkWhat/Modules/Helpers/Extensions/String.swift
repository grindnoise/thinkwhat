//
//  String.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 18.02.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

extension String {
    /**
     Returns a localized version of the string designated by the specified `bundle`.
     - parameter bundle: Bundle to operate.
     */
    func localized(_ bundle: Bundle = .main) -> String {
        bundle.localize(self)
    }
    
    /**
     Returns a localized version of the string designated by Bundle.main.
     */
    var localized: String {
        return localized()
    }
    
    func localized(languageCode: String) -> String {
        let path = Bundle.main.path(forResource: languageCode, ofType: "lproj")
        let bundle = Bundle(path: path!)
        
        return NSLocalizedString(self, tableName: nil, bundle: bundle!, value: "", comment: "")
    }
    
    func fullRange() -> NSRange {
        let str = NSString(string: self)
        return NSRange(location: 0, length: str.length)
    }
    
    var hexColor: UIColor? {
        guard !isEmpty else {
            return nil
        }
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
    
    var length: Int {
        return self.count //characters.count
    }

    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[(start ..< end)])
    }
    
    func toDateTime() -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
        return formatter.date(from: self)!
    }
    
    func toDate() -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.date(from: self)!
    }
    
    public func fileName() -> String {
        return URL(fileURLWithPath: self).deletingPathExtension().lastPathComponent
    }
    
    func fileExtension() -> String {
        return URL(fileURLWithPath: self).pathExtension
    }
    
    var trimmingTrailingSpaces: String {
        if let range = rangeOfCharacter(from: .whitespacesAndNewlines, options: [.anchored, .backwards]) {
            return String(self[..<range.lowerBound]).trimmingTrailingSpaces
        }
        return self
    }
    
    var youtubeID: String? {
        let pattern = "((?<=(v|V)/)|(?<=be/)|(?<=(\\?|\\&)v=)|(?<=embed/))([\\w-]++)"
        
        let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        let range = NSRange(location: 0, length: count)
        
        guard let result = regex?.firstMatch(in: self, range: range) else {
            return nil
        }
        
        return (self as NSString).substring(with: result.range)
    }
    
    var isYoutubeLink: Bool {
        let youtubeRegex = "(http(s)?:\\/\\/)?(www\\.|m\\.)?youtu(be\\.com|\\.be)(\\/watch\\?([&=a-z]{0,})(v=[\\d\\w]{1,}).+|\\/[\\d\\w]{1,})"
        
        let youtubeCheckResult = NSPredicate(format: "SELF MATCHES %@", youtubeRegex)
        return youtubeCheckResult.evaluate(with: self)
    }
    var isFacebookLink: Bool {
        let regex = "(http(s)?:\\/\\/)?(www\\.|m\\.)?facebook.com\\/.*"
        let result = NSPredicate(format: "SELF MATCHES %@", regex)
        return result.evaluate(with: self)
    }
    var isTikTokLink: Bool {
        let regex = "(http(s)?:\\/\\/)?(www\\.|m\\.)?tiktok.com\\/.*"
        let result = NSPredicate(format: "SELF MATCHES %@", regex)
        return result.evaluate(with: self)
    }
    var isVKLink: Bool {
        let regex = "(http(s)?:\\/\\/)?(www\\.|m\\.)?vk.com\\/.*"
        let result = NSPredicate(format: "SELF MATCHES %@", regex)
        return result.evaluate(with: self)
    }
    var isInstagramLink: Bool {
        let regex = "(http(s)?:\\/\\/)?(www\\.|m\\.)?(instagram.com|instagr.am)\\/([A-Za-z0-9-_.]+)/im"//.*"
        let result = NSPredicate(format: "SELF MATCHES %@", regex)
        return result.evaluate(with: self)
    }
//
//        return self.contains("https://www.tiktok.com/")
////        let youtubeRegex = "(http(s)?:\\/\\/)?(www\\.|m\\.)?youtu(be\\.com|\\.be)(\\/watch\\?([&=a-z]{0,})(v=[\\d\\w]{1,}).+|\\/[\\d\\w]{1,})"
////
////        let youtubeCheckResult = NSPredicate(format: "SELF MATCHES %@", youtubeRegex)
////        return youtubeCheckResult.evaluate(with: self)
//    }
//
    var isTikTokEmbedLink: Bool {
        return self.contains("tiktok-embed")
        //        let youtubeRegex = "(http(s)?:\\/\\/)?(www\\.|m\\.)?youtu(be\\.com|\\.be)(\\/watch\\?([&=a-z]{0,})(v=[\\d\\w]{1,}).+|\\/[\\d\\w]{1,})"
        //
        //        let youtubeCheckResult = NSPredicate(format: "SELF MATCHES %@", youtubeRegex)
        //        return youtubeCheckResult.evaluate(with: self)
    }
    
    var isValidEmail: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
    
    var encodedURL : String
    {
        return self.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
    }
    var decodedURL : String
    {
        return self.removingPercentEncoding!
    }
    
}
