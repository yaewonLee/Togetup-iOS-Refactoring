//
//  UserDataManager.swift
//  TogetUp
//
//  Created by 이예원 on 12/2/23.
//

import Foundation

class UserDataManager {
    static let shared = UserDataManager()

    var currentUserData: HomeData? {
        didSet {
            saveUserData()
        }
    }

    private init() {
        loadUserData()
    }

    func updateHomeData(data: HomeData) {
        currentUserData = data
    }

    private func saveUserData() {
        if let userData = currentUserData {
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(userData) {
                UserDefaults.standard.set(encoded, forKey: "currentUserData")
                print("유저 정보 저장 완료")
            }
        } else {
            UserDefaults.standard.removeObject(forKey: "currentUserData")
        }
    }
    
    func updateUserStatus(level: Int, expPercentage: Double) {
            guard var currentUserData = currentUserData else {
                return
            }
            
            currentUserData.userStat.level = level
            currentUserData.userStat.expPercentage = expPercentage
            self.currentUserData = currentUserData
        }

    private func loadUserData() {
        if let userData = UserDefaults.standard.data(forKey: "currentUserData"),
           let decodedUserData = try? JSONDecoder().decode(HomeData.self, from: userData) {
            currentUserData = decodedUserData
        }
    }
}

struct HomeData: Codable {
    var avatarId: Int
    var name: String
    var userStat: UserStatus
}
