//
//  ThemeManager.swift
//  TogetUp
//
//  Created by 이예원 on 2/27/24.
//

import Foundation

struct Avatar {
    let avatarId: Int
    let koreanName: String
    let mainAvatarName: String
    let collectionViewAvatarName: String
    let colorName: String
}

class ThemeManager {
    static let shared = ThemeManager()

    let themes: [Avatar] = [
        Avatar(avatarId: 1, koreanName: "신입 병아리", mainAvatarName: "main_chick", collectionViewAvatarName: "c_chick", colorName: "chick"),
        Avatar(avatarId: 2, koreanName: "눈을 반짝이는 곰돌이", mainAvatarName: "main_bear", collectionViewAvatarName: "c_bear", colorName: "bear"),
        Avatar(avatarId: 3, koreanName: "깜찍한 토끼", mainAvatarName: "main_rabbit", collectionViewAvatarName: "c_rabbit", colorName: "rabbit"),
        Avatar(avatarId: 4, koreanName: "먹보 판다", mainAvatarName: "main_panda", collectionViewAvatarName: "c_panda", colorName: "panda"),
        Avatar(avatarId: 5, koreanName: "비오는 날 강아지", mainAvatarName: "main_puppy", collectionViewAvatarName: "c_puppy", colorName: "puppy"),
        Avatar(avatarId: 6, koreanName: "철학자 너구리", mainAvatarName: "main_racoon", collectionViewAvatarName: "c_racoon", colorName: "racoon")
    ]
}
