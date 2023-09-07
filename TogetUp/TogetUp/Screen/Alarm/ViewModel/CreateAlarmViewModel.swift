//
//  CreateAlarmViewModel.swift
//  TogetUp
//
//  Created by 이예원 on 2023/09/07.
//

import RxSwift
import Moya

class CreateAlarmViewModel {
    private let provider = MoyaProvider<AlarmService>()
    
    func createAlarm(param: CreateAlarmRequest) -> Observable<CreateAlarmResponse> {
        return provider.rx.request(.createAlarm(param: param))
            .filterSuccessfulStatusCodes()
            .map(CreateAlarmResponse.self)
            .asObservable()
    }
}
