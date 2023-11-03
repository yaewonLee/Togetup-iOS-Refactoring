//
//  GroupSettingModel.swift
//  TogetUp
//
//  Created by 이예원 on 2023/10/19.
//

import Foundation

struct GroupSettingResponse: Codable {
    let httpStatusCode: Int
    let httpReasonPhrase: String
    let message: String
    let result: ResultData?
}

struct ResultData: Codable {
    let roomData: RoomData
    let alarmData: AlarmData
    let userList: [User]
}

struct RoomData: Codable {
    let icon: String
    let name: String
    let intro: String
    let createdAt: String
    let personnel: Int
}

struct AlarmData: Codable {
    let id: Int
    let missionKr: String
    let alarmTime: String
    let alarmDay: String
}

struct User: Codable {
    let userId: Int
    let userName: String
    let isHost: Bool
    let theme: String
    let level: Int
}

struct DeleteMemberResponse: Codable {
    let httpStatusCode: Int
    let httpReasonPhrase: String
    let message: String
}
