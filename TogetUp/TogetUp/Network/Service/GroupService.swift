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
    case getMissionLog(roomId: Int, localDateTime: String)
    case getGroupDetail(roomId: Int)
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
        case .getGroupDetail(let roomId):
            return URLConstant.getGroupDetail + "\(roomId)"
        case .getMissionLog:
            return URLConstant.getMissionLog
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getGroupList, .getGroupDetail,.getMissionLog:
            return .get
        case .createGroup:
            return .post
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .getGroupList, .getGroupDetail:
            return .requestPlain
        case .createGroup(let param):
            return .requestJSONEncodable(param)
        case .getMissionLog(let roomId, let date):
            let fixedTime = "11:55:38"
            let fullDateTime = "\(date) \(fixedTime)"
            return .requestParameters(parameters: ["roomId": roomId, "localDateTime": fullDateTime], encoding: URLEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .getGroupList, .createGroup, .getGroupDetail, .getMissionLog:
            let token = KeyChainManager.shared.getToken()
            return [
                "Authorization": "Bearer \(token ?? "")",
                "Content-Type": "application/json"
            ]
        }
    }
}
