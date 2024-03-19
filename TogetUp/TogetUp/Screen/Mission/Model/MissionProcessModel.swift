//
//  MissionModel.swift
//  TogetUp
//
//  Created by 이예원 on 2023/09/25.
//

import Foundation

struct MissionDetectResponse: Codable {
    let httpStatusCode: Int
    let httpReasonPhrase: String
    let message: String
    let result: MissionResult?
}

struct MissionResult: Codable {
    let filePath: String
}

struct MissionCompleteRequest: Codable {
    let alarmId: Int
    let missionPicLink: String
}

struct MissionCompleteResponse: Codable {
    let httpStatusCode: Int
    let httpReasonPhrase: String
    let message: String
    let result: MissionCompleteResult?
}

struct MissionCompleteResult: Codable {
    let userStat: UserStats
    let userLevelUp: Bool
    let avatarUnlockAvailable: Bool
}

struct UserStats: Codable {
    let level: Int
    let expPercentage: Double
}
