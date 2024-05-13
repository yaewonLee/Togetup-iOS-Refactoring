//
//  VersionCheckResponseModel.swift
//  TogetUp
//
//  Created by 이예원 on 5/13/24.
//

import Foundation

struct VersionCheckResponse: Decodable {
    let httpStatusCode: Int
    let httpReasonPhrase: String
    let message: String
    let result: VersionCheckResult?
}

struct VersionCheckResult: Decodable {
    let isLatest: Bool
    let url: String?
}
