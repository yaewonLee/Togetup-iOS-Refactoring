//
//  InviteDetailModel.swift
//  TogetUp
//
//  Created by 이예원 on 11/30/23.
//

import Foundation

struct InviteDetailResponse: Codable {
    let httpStatusCode: Int
    let httpReasonPhrase: String
    let message: String
    let result: InviteDetailResult
}

struct InviteDetailResult: Codable {
    let roomData: RoomResult
    let alarmData: AlarmResult
}

struct RoomResult: Codable {
    var id: Int
    var icon: String
    var name: String
    var intro: String
    var createdAt: String
    var personnel: Int
}

struct AlarmResult: Codable {
    var missionKr: String
    var alarmTime: String
    var alarmDay: String
}

