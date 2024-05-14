//
//  AvatarModel.swift
//  TogetUp
//
//  Created by 이예원 on 11/27/23.
//

import Foundation

struct AvatarResponse: Codable {
    let httpStatusCode: Int
    let httpReasonPhrase: String
    let message: String
    let result: [AvatarResult]?
}

struct AvatarResult: Codable {
    let theme: String
    let themeKr: String
    let defaultSpeech: String
    let avatarId: Int
    let isUnlocked: Bool
    let unlockLevel: Int
}

struct AvatarSpeechesResponse: Codable {
    let httpStatusCode: Int
    let httpReasonPhrase: String
    let message: String
    let result: AvatarSpeechesResult?
}

struct AvatarSpeechesResult: Codable {
    let speech: String
}
