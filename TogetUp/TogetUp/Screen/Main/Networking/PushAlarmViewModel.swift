//
//  PushAlarmViewModel.swift
//  TogetUp
//
//  Created by 이예원 on 11/20/23.
//

import Foundation
import RxSwift
import RxMoya
import Moya

class PushAlarmViewModel {
    private let provider: MoyaProvider<UserService>
    
    init(provider: MoyaProvider<UserService> = MoyaProvider<UserService>(plugins: [NetworkLogger()])) {
        self.provider = provider
    }
    
    func sendFcmToken(token: String) -> Observable<PushAlarmResponse> {
        return provider.rx.request(.sendFcmToken(fcmToken: token))
            .filterSuccessfulStatusCodes()
            .map(PushAlarmResponse.self)
            .asObservable()
    }
}
