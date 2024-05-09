//
//  AppStatusManager.swift
//  TogetUp
//
//  Created by 이예원 on 2023/09/18.
//

import Foundation

class AppStatusManager {
    static let shared = AppStatusManager()

    private init() { }

    var isFirstLaunch: Bool {
        return !UserDefaults.standard.bool(forKey: "isFirstLaunch")
    }

    func markAsLaunched() {
        UserDefaults.standard.set(true, forKey: "isFirstLaunch")
    }
    
    var isFirstLogin: Bool {
        return !UserDefaults.standard.bool(forKey: "isFirstLogin")
    }
    
    func markAsLogined() {
        UserDefaults.standard.set(true, forKey: "isFirstLogin")
    }
    
    func markAsLoginedToFalse() {
        UserDefaults.standard.set(false, forKey: "isFirstLogin")
    }

    func clearSensitiveDataOnFirstLaunch() {
        if isFirstLaunch {
            KeyChainManager.shared.clearAll()
        }
    }
}
