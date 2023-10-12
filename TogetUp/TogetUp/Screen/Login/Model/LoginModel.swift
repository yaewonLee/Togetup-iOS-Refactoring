//
//  LoginModel.swift
//  TogetUp
//
//  Created by 이예원 on 2023/08/30.
//

import Foundation
import Moya

struct LoginRequest: Codable {
    var oauthAccessToken: String
    var loginType: String
    var userName: String?
}

struct LoginResponse: Codable {
    var httpStatusCode: Int
    var httpReasonPhrase: String
    var message: String?
    var result: LoginResult?
}

struct LoginResult: Codable {
    var userId: Int
    var userName: String
    var email: String?
    var accessToken: String
}

