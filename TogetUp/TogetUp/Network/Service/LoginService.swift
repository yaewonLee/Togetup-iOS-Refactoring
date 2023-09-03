//
//  LoginService.swift
//  TogetUp
//
//  Created by 이예원 on 2023/09/01.
//

import Foundation
import Moya

enum LoginService {
    case kakao(param: KakaoLoginRequest)
}

extension LoginService: TargetType {
    var baseURL: URL {
        return URL(string: URLConstant.baseURL)!
    }
    
    var path: String {
        switch self {
        case .kakao:
            return URLConstant.login
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .kakao:
            return .post
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .kakao(let param):
            return .requestJSONEncodable(param)
        }
    }
    
    var headers: [String : String]? {
        return ["Content-type": "application/json"]
    }
}
