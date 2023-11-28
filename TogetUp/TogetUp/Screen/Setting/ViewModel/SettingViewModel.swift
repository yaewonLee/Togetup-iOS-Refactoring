//
//  SettingViewModel.swift
//  TogetUp
//
//  Created by 이예원 on 2023/09/03.
//

import Foundation
import RxSwift
import Moya
import RxMoya

class SettingViewModel {
    let provider: MoyaProvider<UserService>
    
    init() {
        self.provider = MoyaProvider<UserService>(plugins: [NetworkLogger()])
    }
    
    func deleteUser() -> Observable<WithdrawlResponse> {
        return provider.rx.request(.deleteUser)
            .filterSuccessfulStatusCodes()
            .map(WithdrawlResponse.self)
            .asObservable()
    }
    
    func deleteAppleUser(authorizationCode: String) -> Observable<WithdrawlResponse> {
        return provider.rx.request(.deleteAppleUser(code: authorizationCode))
            .filterSuccessfulStatusCodes()
            .map(WithdrawlResponse.self)
            .asObservable()
    }
}
