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
    let unlockLevel: Int
    var isNew: Bool
}

class ThemeManager {
    static let shared = ThemeManager()
    
    private(set) var themes: [Avatar] {
        didSet {
            updateIsNewValuesInUserDefaults()
        }
    }
    
    private init() {
        themes = []
        loadThemes()
        loadIsNewValuesFromUserDefaults()
    }
    
    func loadThemes() {
        themes = [
            Avatar(avatarId: 1, koreanName: "신입 병아리", mainAvatarName: "main_chick", collectionViewAvatarName: "c_chick", colorName: "chick", unlockLevel: 1, isNew: false),
            Avatar(avatarId: 2, koreanName: "눈을 반짝이는 곰돌이", mainAvatarName: "main_bear", collectionViewAvatarName: "c_bear", colorName: "bear", unlockLevel: 15, isNew: false),
            Avatar(avatarId: 3, koreanName: "깜찍한 토끼", mainAvatarName: "main_rabbit", collectionViewAvatarName: "c_rabbit", colorName: "rabbit", unlockLevel: 30, isNew: false),
            Avatar(avatarId: 4, koreanName: "먹보 판다", mainAvatarName: "main_panda", collectionViewAvatarName: "c_panda", colorName: "panda", unlockLevel: 45, isNew: false),
            Avatar(avatarId: 5, koreanName: "비오는 날 강아지", mainAvatarName: "main_puppy", collectionViewAvatarName: "c_puppy", colorName: "puppy", unlockLevel: 60, isNew: false),
            Avatar(avatarId: 6, koreanName: "철학자 너구리", mainAvatarName: "main_racoon", collectionViewAvatarName: "c_racoon", colorName: "racoon", unlockLevel: 75, isNew: false)
        ]
    }
    
    private func loadIsNewValuesFromUserDefaults() {
        themes = themes.map { theme in
            var modifiedTheme = theme
            let key = "\(theme.avatarId)_isNew"
            modifiedTheme.isNew = UserDefaults.standard.bool(forKey: key)
            return modifiedTheme
        }
    }
    
    private func updateIsNewValuesInUserDefaults() {
        for theme in themes {
            UserDefaults.standard.set(theme.isNew, forKey: "\(theme.avatarId)_isNew")
        }
    }
    
    func updateIsNewForAvatar(withUnlockLevel level: Int, isNew: Bool) {
        if let index = themes.firstIndex(where: { $0.unlockLevel == level }) {
            themes[index].isNew = isNew
        }
    }
    
    func updateIsNewStatusForAvatar(withId id: Int, toNewStatus isNew: Bool) {
        guard let index = themes.firstIndex(where: { $0.avatarId == id }) else { return }
        themes[index].isNew = isNew
        updateIsNewValuesInUserDefaults()
    }

}
