//
//  ImageSelection.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 01.06.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

struct ImageItem: Hashable {
    
    var title: String
    var image: UIImage!
    var shouldBeDeleted = false
    let id: UUID = UUID()
    
    init(title: String, image: UIImage) {
        self.title = title
        self.image = image
    }
    
    init(title: String) {
        self.title = title
    }
}

protocol ImageSelectionProvider: class {
    var dataItems: [ImageItem] { get }
    var callbackDelegate: CallbackObservable? { get set }
    var listener: ImageSelectionListener? { get }
    
    func reload()
    func append(_: ImageItem)
    func delete(_: ImageItem)
}

protocol ImageSelectionListener: class {
    var imageItems: [ImageItem] { get set }
    
    func addImage()
    func deleteImage(_: ImageItem)
    func editImage(_: ImageItem)
    func onImagesHeightChange(_: CGFloat)
}

