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
    let provider = MoyaProvider<WithdrawlService>().rx
    
    func deleteUser() -> Observable<WithdrawlResponse> {
        return provider.request(.deleteUser)
            .filterSuccessfulStatusCodes()
            .map(WithdrawlResponse.self)
            .asObservable()
    }
}
