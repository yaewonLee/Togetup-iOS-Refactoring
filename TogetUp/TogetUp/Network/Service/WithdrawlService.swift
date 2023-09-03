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
}

extension WithdrawlService: TargetType {
    var baseURL: URL {
        return URL(string: URLConstant.baseURL)!
    }
    
    var path: String {
        switch self {
        case .deleteUser:
            return URLConstant.withdrawl
        }
    }
    var method: Moya.Method {
        switch self {
        case .deleteUser:
            return .delete
        }
    }
    var task: Task {
        switch self {
        case .deleteUser:
            return .requestPlain
        }
    }
    var headers: [String : String]? {
       let token = KeyChainManager.shared.getToken()
       return ["Authorization": "Bearer \(token ?? "")"]
   }

}
