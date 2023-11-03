//
//  NetworkLogger.swift
//  TogetUp
//
//  Created by 이예원 on 2023/09/01.
//

import Foundation
import Moya

final class NetworkLogger: PluginType {
    func willSend(_ request: RequestType, target: TargetType) {
        #if DEBUG
        print("\n---------- [REQUEST] ----------\n")
        print("API Endpoint : \(target.baseURL.absoluteString + target.path)")
        print("Headers : \(target.headers ?? [:])")
        print("Task : \(target.task)")
        print("--------------------------------\n")
        #endif
    }

    func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        #if DEBUG
        switch result {
        case let .success(response):
            guard let httpURLResponse = response.response else {
                break
            }
            print("\n---------- [RESPONSE] ----------\n")
            print("API Endpoint : \(target.baseURL.absoluteString + target.path)")
            print("Headers : \(httpURLResponse.allHeaderFields)")
            print("Response JSON : \(try! response.mapJSON())")
            print("---------------------------------\n")
        case let .failure(error):
            print("\n---------- [ERROR RESPONSE] ----------\n")
            print("API Endpoint : \(target.baseURL.absoluteString + target.path)")
            print("Headers : \(target.headers ?? [:])")
            print("Task : \(target.task)")
            print("Error : \(error)")
            print("--------------------------------\n")
        }
        #endif
    }

}
