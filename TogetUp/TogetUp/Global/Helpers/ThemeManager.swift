//
//  ThemeManager.swift
//  TogetUp
//
//  Created by 이예원 on 2/27/24.
//

import Foundation

struct Avatar {
    let avatarId: Int
    let mainAvatarName: String
    let collectionViewAvatarName: String
    let colorName: String
    let unlockLevel: Int
    var isNew: Bool
    let defaultSpeech: String
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
            Avatar(avatarId: 1, mainAvatarName: "main_chick", collectionViewAvatarName: "home_chick", colorName: "chick", unlockLevel: 1, isNew: true, defaultSpeech: "안녕, 내가 니 선임이야~"),
            Avatar(avatarId: 2, mainAvatarName: "main_bear", collectionViewAvatarName: "home_bear", colorName: "bear", unlockLevel: 15, isNew: false, defaultSpeech: "나랑 같이 우주탐험 하지 않을래?"),
            Avatar(avatarId: 3, mainAvatarName: "main_rabbit", collectionViewAvatarName: "home_rabbit", colorName: "rabbit", unlockLevel: 30, isNew: false, defaultSpeech: "사랑을 나누어 드릴게요..."),
            Avatar(avatarId: 4, mainAvatarName: "main_panda", collectionViewAvatarName: "home_panda", colorName: "panda", unlockLevel: 45, isNew: false, defaultSpeech: "먹는게 세상에서 제일 좋아~"),
            Avatar(avatarId: 5, mainAvatarName: "main_puppy", collectionViewAvatarName: "home_puppy", colorName: "puppy", unlockLevel: 60, isNew: false, defaultSpeech: "저와 비오는 날을 함께 해요!"),
            Avatar(avatarId: 6, mainAvatarName: "main_racoon", collectionViewAvatarName: "home_racoon", colorName: "racoon", unlockLevel: 75, isNew: false, defaultSpeech: "널 철학의 세계로 인도하지...")
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
