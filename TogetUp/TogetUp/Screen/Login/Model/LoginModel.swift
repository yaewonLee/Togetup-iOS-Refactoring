//
//  LoginModel.swift
//  TogetUp
//
//  Created by 이예원 on 2023/08/30.
//

import Foundation
import Moya

struct LoginRequest: Codable {
    let oauthAccessToken: String
    let loginType: String
    var userName: String?
}

struct LoginResponse: Codable {
    let httpStatusCode: Int
    let httpReasonPhrase: String
    let message: String?
    let result: LoginResult?
}

struct LoginResult: Codable {
    let userId: Int?
    let userName: String?
    let email: String?
    let accessToken: String
    let avatarId: Int
    let userStat: UserStatus
}

struct UserStatus: Codable {
    let level: Int
    let experience: Int
    let point: Int
}

