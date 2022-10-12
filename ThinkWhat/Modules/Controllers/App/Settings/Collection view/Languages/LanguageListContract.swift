//
//  LanguageListContract.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 11.10.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

protocol LanguageListViewInput: AnyObject {
    
    var controllerOutput: LanguageListControllerOutput? { get set }
    var controllerInput: LanguageListControllerInput? { get set }
    
    func updateContentLanguage(language: LanguageItem, use: Bool)
}

protocol LanguageListControllerInput: AnyObject {
    
    var modelOutput: LanguageListModelOutput? { get set }
    
    func updateContentLanguage(language: LanguageItem, use: Bool)
}

protocol LanguageListModelOutput: AnyObject {
    
}

protocol LanguageListControllerOutput: AnyObject {
    var viewInput: LanguageListViewInput? { get set }

}
