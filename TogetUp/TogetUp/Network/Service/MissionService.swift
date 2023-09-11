//
//  MissionService.swift
//  TogetUp
//
//  Created by 이예원 on 2023/09/11.
//

import Foundation
import Moya

enum MissionService {
    case getMissionList(missionId: Int)
}

extension MissionService: TargetType {
    var baseURL: URL {
        return URL(string: URLConstant.baseURL)!
    }
    
    var path: String {
        switch self {
        case .getMissionList(let missionId):
            return URLConstant.getMissionList + "\(missionId)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getMissionList:
            return .get
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .getMissionList:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .getMissionList:
            let token = KeyChainManager.shared.getToken()
            return [
                "Authorization": "Bearer \(token ?? "")",
                "Content-Type": "application/json"
            ]
        }
    }
}

