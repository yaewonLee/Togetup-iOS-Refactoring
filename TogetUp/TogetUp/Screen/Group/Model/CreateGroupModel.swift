//
//  CreateGroupModel.swift
//  TogetUp
//
//  Created by 이예원 on 2023/10/16.
//

import Foundation

struct CreateGroupRequest: Codable {
    let name: String
    let intro: String
    let postAlarmReq: GroupAlarmRequest
}

struct GroupAlarmRequest: Codable {
    let name: String
    let icon: String
    let snoozeInterval: Int
    let snoozeCnt: Int
    let alarmTime: String
    let monday: Bool
    let tuesday: Bool
    let wednesday: Bool
    let thursday: Bool
    let friday: Bool
    let saturday: Bool
    let sunday: Bool
    let isSnoozeActivated: Bool
    let isVibrate: Bool
    let missionId: Int
    let missionObjectId: Int?
    let roomId: Int?
}

struct CreateGroupResponse: Codable {
    let httpStatusCode: Int
    let httpReasonPhrase: String
    let message: String
}
