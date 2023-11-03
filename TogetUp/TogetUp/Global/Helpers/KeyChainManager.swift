//
//  KeyChainManager.swift
//  TogetUp
//
//  Created by 이예원 on 2023/08/18.
//

import Foundation
import KeychainAccess

class KeyChainManager {
    static let shared = KeyChainManager()
    private let keychain = Keychain(service: "com.yaewon.TogetUp")
    
    private init() {}
    
    func clearAll() {
        do {
            try keychain.removeAll()
            print("All data has been removed from the Keychain.")
        } catch let error {
            print("Failed to remove all data from the Keychain: \(error.localizedDescription)")
        }
    }
    
    func saveUserInformation(name: String, email: String) {
        do {
            try keychain.set(name, key: "name")
            try keychain.set(email, key: "email")
            print("User information has been saved in the Keychain.")
        } catch let error {
            print("Failed to save user information: \(error.localizedDescription)")
        }
    }
    
    func getUserInformation() -> (name: String?, email: String?) {
        do {
            let name = try keychain.get("name")
            let email = try keychain.get("email")            
            return (name, email)
        } catch let error {
            print("Failed to get user information : \(error.localizedDescription)")
            return (nil,nil)
        }
    }
    
    func saveUserIdentifier(_ userIdentifier: String) {
        do {
            try keychain.set(userIdentifier, key: "userIdentifier")
            print("UserIdentifier가 키체인에 저장되었습니다.")
        } catch let error {
            print("UserIdentifier 저장 실패: \(error.localizedDescription)")
        }
    }
    
    func getUserIdentifier() -> String? {
        do {
            let userIdentifier = try keychain.get("userIdentifier")
            return userIdentifier
        } catch let error {
            print("UserIdentifier 읽기 실패: \(error.localizedDescription)")
            return nil
        }
    }
    
    func saveToken(_ token: String) {
        do{
            try keychain.set(token, key:"jwtToken")
            print("JWT Token이 키체인에 저장되었습니다.")
        } catch let error {
            print("JWT Token 저장 실패 : \(error.localizedDescription)")
        }
    }
    
    func getToken() -> String? {
        do {
            let token = try keychain.get("jwtToken")
            return token
        } catch let error {
            print("JWT Token 읽기 실패 : \(error.localizedDescription)")
            return nil
        }
    }
    
    func removeToken() {
        do {
            try keychain.remove("jwtToken")
            print("JWT Token이 키체인에서 삭제되었습니다.")
        } catch let error {
            print("JWT Token 삭제 실패 : \(error.localizedDescription)")
        }
    }
}
