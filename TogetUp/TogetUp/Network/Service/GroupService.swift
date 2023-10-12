//
//  GroupService.swift
//  TogetUp
//
//  Created by 이예원 on 2023/10/12.
//

import Foundation
import Moya

enum GroupService {
    case getGroupList
}

extension GroupService: TargetType {
    var baseURL: URL {
        return URL(string: URLConstant.baseURL)!
    }
    
    var path: String {
        switch self {
        case .getGroupList:
            return URLConstant.getGroupList
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getGroupList:
            return .get
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .getGroupList:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .getGroupList:
            let token = KeyChainManager.shared.getToken()
            return [
                "Authorization": "Bearer \(token ?? "")",
                "Content-Type": "application/json"
            ]
        }
    }
}
