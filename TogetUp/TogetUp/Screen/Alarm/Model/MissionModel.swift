//
//  MissionModel.swift
//  TogetUp
//
//  Created by 이예원 on 2023/09/11.
//

import Foundation

struct GetMissionListResponse: Codable {
    let httpStatusCode: Int
    let httpReasonPhrase, message: String
    let result: MissionListResult
}

struct MissionListResult: Codable {
    let id: Int
    let name, createdAt: String
    let isActive: Bool
    let missionObjectResList: [MissionObjectResList]
}

struct MissionObjectResList: Codable {
    let id: Int
    let name, kr, icon: String
}
