//
//  GroupListModel.swift
//  TogetUp
//
//  Created by 이예원 on 2023/10/12.
//

import Foundation

struct GroupListResponse: Codable {
    let httpStatusCode: Int
    let httpReasonPhrase: String
    let message: String
    let result: [GroupListResult?]
}

struct GroupListResult: Codable {
    let roomId: Int
    let icon: String
    let name: String
    let mission: String?
    let kr: String?
}
