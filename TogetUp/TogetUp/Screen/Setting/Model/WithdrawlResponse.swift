//
//  WithdrawlResponse.swift
//  TogetUp
//
//  Created by 이예원 on 2023/09/03.
//

import Foundation

struct WithdrawlResponse: Codable {
    var httpStatusCode: Int
    var httpReasonPhrase: String
    var message: String
}
