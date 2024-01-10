//
//  UserDataManager.swift
//  TogetUp
//
//  Created by 이예원 on 12/2/23.
//

import Foundation

class UserDataManager {
    static let shared = UserDataManager()

    var currentUserData: UserData? {
        didSet {
            saveUserData()
        }
    }

    private init() {
        loadUserData()
    }

    func updateUser(user: UserData) {
        currentUserData = user
    }

    private func saveUserData() {
        if let userData = currentUserData {
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(userData) {
                UserDefaults.standard.set(encoded, forKey: "currentUserData")
            }
        } else {
            UserDefaults.standard.removeObject(forKey: "currentUserData")
        }
    }

    private func loadUserData() {
        if let userData = UserDefaults.standard.data(forKey: "currentUserData"),
           let decodedUserData = try? JSONDecoder().decode(UserData.self, from: userData) {
            currentUserData = decodedUserData
        }
    }
}

struct UserData: Codable {
    var avatarId: Int
    var name: String
    var email: String
    var userStat: UserStatus
}


