//
//  DevService.swift
//  TogetUp
//
//  Created by 이예원 on 5/12/24.
//

import Foundation
import Moya

enum DevService {
    case versionCheck(currentAppVersion: String)
}

extension DevService: TargetType {
    var baseURL: URL {
        return URL(string: URLConstant.baseURL)!
    }
    
    var path: String {
        switch self {
        case .versionCheck:
            return URLConstant.versionCheck
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var task: Moya.Task {
        switch self {
        case .versionCheck(let currentAppVersion):
            return .requestParameters(parameters: ["currentAppVersion" : currentAppVersion], encoding: URLEncoding.queryString)
        }
    }
    
    var headers: [String : String]? {
        let token = KeyChainManager.shared.getToken()
        return [
            "Authorization": "Bearer \(token ?? "")",
            "Content-Type": "application/json"
        ]
    }
}
