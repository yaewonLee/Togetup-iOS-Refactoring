//
//  WithdrawlModel.swift
//  TogetUp
//
//  Created by 이예원 on 2023/09/03.
//

import Foundation

struct WithdrawlResponse: Codable {
    let httpStatusCode: Int
    let httpReasonPhrase: String
    let message: String
}
