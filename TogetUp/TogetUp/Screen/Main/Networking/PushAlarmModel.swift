//
//  PushAlarmModel.swift
//  TogetUp
//
//  Created by 이예원 on 11/20/23.
//

import Foundation

struct PushAlarmResponse: Codable {
    let httpStatusCode: Int
    let httpReasonPhrase: String
    let message: String
    let result: Int?
}
