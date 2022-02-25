//
//  Bundle.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 18.02.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

extension Bundle {
    
    static var UIKit: Bundle {
        Self(for: UIApplication.self)
    }
    
    func localize(_ key: String, table: String? = nil) -> String {
        self.localizedString(forKey: key, value: nil, table: nil)
    }
    
    var localizableStrings: [String: String]? {
        guard let fileURL = url(forResource: "Localizable", withExtension: "strings") else {
            return nil
        }
        do {
            let data = try Data(contentsOf: fileURL)
            let plist = try PropertyListSerialization.propertyList(from: data, format: .none)
            return plist as? [String: String]
        } catch {
            print(error)
        }
        return nil
    }
}

import ObjectiveC

private var associatedLanguageBundle:Character = "0"

class PrivateBundle: Bundle {
    override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        let bundle: Bundle? = objc_getAssociatedObject(self, &associatedLanguageBundle) as? Bundle
        return (bundle != nil) ? (bundle!.localizedString(forKey: key, value: value, table: tableName)) : (super.localizedString(forKey: key, value: value, table: tableName))

    }
}

#if canImport(L10n_swift)
import L10n_swift

extension Bundle {
    class func setLanguageAndPublish(_ language: String, in bundle: Bundle = .main) {
        var onceToken: Int = 0
        
        if (onceToken == 0) {
            /* TODO: move below code to a static variable initializer (dispatch_once is deprecated) */
            object_setClass(Bundle.main, PrivateBundle.self)
        }
        onceToken = 1
        objc_setAssociatedObject(Bundle.main, &associatedLanguageBundle, (language != nil) ? Bundle(path: bundle.path(forResource: language, ofType: "lproj") ?? "") : nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        L10n.shared.language = language
        NotificationCenter.default.post(name: Notification.Name("LANGUAGE_CHANGED"), object: nil)
    }
}
#else
extension Bundle {
    class func setLanguage(_ language: String, in bundle: Bundle = .main) {
        var onceToken: Int = 0
        
        if (onceToken == 0) {
            /* TODO: move below code to a static variable initializer (dispatch_once is deprecated) */
            object_setClass(Bundle.main, PrivateBundle.self)
        }
        onceToken = 1
        objc_setAssociatedObject(Bundle.main, &associatedLanguageBundle, (language != nil) ? Bundle(path: bundle.path(forResource: language, ofType: "lproj") ?? "") : nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}
#endif



