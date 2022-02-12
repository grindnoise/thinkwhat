//
//  ContentLoader.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 10.02.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import Foundation

struct ContentLoader {
    enum Error: Swift.Error {
        case fileNotFound(name: String)
        case fileDecodingFailed(name: String, Swift.Error)
    }

    static func loadBundledData(fromFileNamed name: String, withExtension: String,
                         in bundle: Bundle = .main) throws -> Data {
        guard let url = bundle.url(
            forResource: name,
            withExtension: withExtension
        ) else {
            throw Error.fileNotFound(name: name)
        }

//        do {
            return try Data(contentsOf: url)
//        } catch {
//            throw Error.fileDecodingFailed(name: name, error)
//        }
    }
    
    static func urlForResource(fromFileNamed name: String, withExtension: String,
                         in bundle: Bundle = .main) throws -> URL {
        guard let url = bundle.url(
            forResource: name,
            withExtension: withExtension
        ) else {
            throw Error.fileNotFound(name: name)
        }
        return url
    }
}
