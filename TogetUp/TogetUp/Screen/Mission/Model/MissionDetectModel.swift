//
//  MissionDetectModel.swift
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
