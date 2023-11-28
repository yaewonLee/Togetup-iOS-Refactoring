//
//  HomeService.swift
//  TogetUp
//
//  Created by 이예원 on 11/26/23.
//

import Foundation
import Moya

enum HomeService {
    case getTimeLine
}

extension HomeService: TargetType {
    var baseURL: URL {
        return URL(string: URLConstant.baseURL)!
    }
    
    var path: String {
        switch self {
        case .getTimeLine:
            return URLConstant.getTimeline
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getTimeLine:
            return .get
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .getTimeLine:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .getTimeLine:
            let token = KeyChainManager.shared.getToken()
            return [
                "Authorization": "Bearer \(token ?? "")",
                "Content-Type": "application/json"
            ]
        }
    }
}
