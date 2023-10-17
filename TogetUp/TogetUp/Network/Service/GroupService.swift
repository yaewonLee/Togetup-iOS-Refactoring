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
    case createGroup(param: CreateGroupRequest)
}

extension GroupService: TargetType {
    var baseURL: URL {
        return URL(string: URLConstant.baseURL)!
    }
    
    var path: String {
        switch self {
        case .getGroupList:
            return URLConstant.getGroupList
        case .createGroup:
            return URLConstant.createGroup
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getGroupList:
            return .get
        case .createGroup:
            return .post
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .getGroupList:
            return .requestPlain
        case .createGroup(let param):
            return .requestJSONEncodable(param)
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .getGroupList, .createGroup:
            let token = KeyChainManager.shared.getToken()
            return [
                "Authorization": "Bearer \(token ?? "")",
                "Content-Type": "application/json"
            ]
        }
    }
}
