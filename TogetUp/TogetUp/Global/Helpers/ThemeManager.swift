//
//  ThemeManager.swift
//  TogetUp
//
//  Created by 이예원 on 2/27/24.
//

import Foundation

struct Theme {
    let koreanName: String
    let mainAvatarName: String
    let collectionViewAvatarName: String
    let colorName: String
}

class ThemeManager {
    static let shared = ThemeManager()

    let themes: [Theme] = [
        Theme(koreanName: "신입 병아리", mainAvatarName: "main_chick", collectionViewAvatarName: "c_chick", colorName: "chick"),
        Theme(koreanName: "눈을 반짝이는 곰돌이", mainAvatarName: "main_bear", collectionViewAvatarName: "c_bear", colorName: "bear"),
        Theme(koreanName: "깜찍한 토끼", mainAvatarName: "main_rabbit", collectionViewAvatarName: "c_rabbit", colorName: "rabbit"),
        Theme(koreanName: "먹보 판다", mainAvatarName: "main_panda", collectionViewAvatarName: "c_panda", colorName: "panda"),
        Theme(koreanName: "비오는 날 강아지", mainAvatarName: "main_puppy", collectionViewAvatarName: "c_puppy", colorName: "puppy"),
        Theme(koreanName: "철학자 너구리", mainAvatarName: "main_racoon", collectionViewAvatarName: "c_racoon", colorName: "racoon")
    ]
}
