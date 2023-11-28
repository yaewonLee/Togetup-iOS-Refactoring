//
//  UserService.swift
//  TogetUp
//
//  Created by 이예원 on 2023/09/03.
//

import Foundation
import Moya

enum UserService {
    case deleteUser
    case deleteAppleUser(code: String)
    case sendFcmToken(fcmToken: String)
    case getAvatarList
}

extension UserService: TargetType {
    var baseURL: URL {
        return URL(string: URLConstant.baseURL)!
    }
    
    var path: String {
        switch self {
        case .deleteUser:
            return URLConstant.withdrawl
        case .deleteAppleUser:
            return URLConstant.appleWithdrawl
        case .sendFcmToken:
            return URLConstant.sendFcmToken
        case .getAvatarList:
            return URLConstant.getAvatarList
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .deleteUser, .deleteAppleUser:
            return .delete
        case .sendFcmToken:
            return .patch
        case .getAvatarList:
            return .get
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .deleteUser, .getAvatarList:
            return .requestPlain
        case .deleteAppleUser(let code):
            return .requestParameters(parameters: ["authorizationCode": code], encoding: JSONEncoding.default)
        case .sendFcmToken(let fcmToken):
            return .requestParameters(parameters: ["fcmToken": fcmToken], encoding: URLEncoding.queryString)
        }
    }
    
    var headers: [String : String]? {
       let token = KeyChainManager.shared.getToken()
       return ["Authorization": "Bearer \(token ?? "")"]
   } 
}
