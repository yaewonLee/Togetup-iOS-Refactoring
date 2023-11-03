//
//  GroupBoardModel.swift
//  TogetUp
//
//  Created by 이예원 on 2023/10/20.
//

import Foundation

struct GroupBoardResponse: Codable {
    let httpStatusCode: Int
    let httpReasonPhrase: String
    let message: String
    let result: GroupBoardResult
}

struct GroupBoardResult: Codable {
    let name: String
    let theme: String
    let userLogList: [UserLog]
}

struct UserLog: Codable {
    let userId: Int
    let userName: String
    let isMyLog: Bool
    let userCompleteType: String
    let missionPicLink: String
}
