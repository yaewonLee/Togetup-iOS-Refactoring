//
//  TimelineModel.swift
//  TogetUp
//
//  Created by 이예원 on 11/26/23.
//

import Foundation

struct TimelineResponse: Codable {
    let httpStatusCode: Int
    let httpReasonPhrase: String
    let message: String
    let result: TimeLineResult?
}

struct TimeLineResult: Codable {
    let today: String
    let dayOfWeek: String
    let nextAlarm: AlarmModel?
    let todayAlarmList: [AlarmModel]?
}

struct AlarmModel: Codable {
    let id: Int
    let icon: String
    let alarmTime: String
    let name: String
    let missionObject: String
}


