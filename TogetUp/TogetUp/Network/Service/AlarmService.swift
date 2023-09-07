//
//  AlarmService.swift
//  TogetUp
//
//  Created by 이예원 on 2023/09/04.
//

import Foundation
import Moya


enum AlarmService {
    case createAlarm(param: CreateAlarmRequest)
}

extension AlarmService: TargetType {
    var baseURL: URL {
        return URL(string: URLConstant.baseURL)!
    }
    
    var path: String {
        switch self {
        case .createAlarm:
            return URLConstant.createAlarm
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .createAlarm:
            return .post
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .createAlarm(let param):
            return .requestJSONEncodable(param)
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .createAlarm:
            let token = KeyChainManager.shared.getToken()
            print(token!)
            return [
                "Authorization": "Bearer \(token ?? "")",
                "Content-Type": "application/json"
            ]
        }
        
    }
}
