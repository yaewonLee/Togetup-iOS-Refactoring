//
//  AlarmModel.swift
//  TogetUp
//
//  Created by 이예원 on 2023/09/10.
//

import Foundation

struct GetAlarmListResponse: Codable {
    let httpStatusCode: Int
    let httpReasonPhrase: String
    let message: String
    let result: [GetAlarmResult]?
}

struct GetSingleAlarmResponse: Codable {
    let httpStatusCode: Int
    let httpReasonPhrase: String
    let message: String
    let result: GetAlarmResult?
}

struct CreateEditDeleteAlarmResponse: Codable {
    let httpStatusCode: Int
    let httpReasonPhrase: String
    let message: String
    let result: Int?
}

struct CreateOrEditAlarmRequest: Codable {
    let missionId: Int
    let missionObjectId: Int?
    let isSnoozeActivated: Bool
    let name: String
    let icon: String
    let isVibrate: Bool
    let alarmTime: String
    let monday: Bool
    let tuesday: Bool
    let wednesday: Bool
    let thursday: Bool
    let friday: Bool
    let saturday: Bool
    let sunday: Bool
    let isActivated: Bool
    let roomId: Int?
    let snoozeInterval: Int
    let snoozeCnt: Int
}


struct GetAlarmResult: Codable {
    let id: Int
    let userId: Int
    let name: String
    let icon: String
    let snoozeInterval: Int
    let snoozeCnt: Int
    let alarmTime: String
    let monday, tuesday, wednesday, thursday, friday, saturday, sunday: Bool
    let isSnoozeActivated, isVibrate, isActivated: Bool
    let getMissionRes: MissionRes?
    let getMissionObjectRes: MissionObjectRes?
    let roomRes: RoomRes?
}

struct MissionRes: Codable {
    let id: Int
    let name: String
    let createdAt: String
    let isActive: Bool
}

struct MissionObjectRes: Codable {
    let id: Int
    let name, kr, icon: String
}

struct RoomRes: Codable {
    let id: Int
    let name, intro, groupProfileImgLink, password: String
    let state: Int
}
