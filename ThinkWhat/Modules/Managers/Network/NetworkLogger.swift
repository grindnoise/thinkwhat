//
//  NetworkLogger.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 16.08.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import Alamofire

class NetworkLogger: EventMonitor {
    //1
    let queue = DispatchQueue(label: "PB.ThinkWhat.local.networklogger")
    //2
    func requestDidFinish(_ request: Request) {
#if LOCAL
//        print(request.description)
#endif
    }
    //3
    func request<Value>(
        _ request: DataRequest,
        didParseResponse response: DataResponse<Value, AFError>
    ) {
        guard let data = response.data else {
            return
        }
        if let json = try? JSONSerialization
            .jsonObject(with: data, options: .mutableContainers) {
#if LOCAL
//            print(json)
#endif
        }
    }
}
