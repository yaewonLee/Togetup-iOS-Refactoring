//
//  WithdrawlService.swift
//  TogetUp
//
//  Created by 이예원 on 2023/09/03.
//

import Foundation
import Moya

enum WithdrawlService {
    case deleteUser
    case deleteAppleUser(code: String)
    
}

extension WithdrawlService: TargetType {
    var baseURL: URL {
        return URL(string: URLConstant.baseURL)!
    }
    
    var path: String {
        switch self {
        case .deleteUser:
            return URLConstant.withdrawl
        case .deleteAppleUser:
            return URLConstant.appleWithdrawl
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .deleteUser, .deleteAppleUser:
            return .delete
        }
    }
    
    var task: Task {
        switch self {
        case .deleteUser:
            return .requestPlain
        case .deleteAppleUser(let code):
            return .requestParameters(parameters: ["authorizationCode": code], encoding: JSONEncoding.default)
        }
    }
    
    var headers: [String : String]? {
       let token = KeyChainManager.shared.getToken()
       return ["Authorization": "Bearer \(token ?? "")"]
   } 
}
