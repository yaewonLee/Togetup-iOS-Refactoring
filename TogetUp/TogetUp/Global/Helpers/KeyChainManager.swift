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
}
