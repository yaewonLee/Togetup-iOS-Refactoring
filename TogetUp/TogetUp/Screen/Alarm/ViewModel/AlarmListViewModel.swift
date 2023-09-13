//
//  AlarmListViewModel.swift
//  TogetUp
//
//  Created by 이예원 on 2023/09/12.
//

import Foundation
import RxMoya
import RxSwift
import Moya

struct AlarmListViewModel {
    let provider: MoyaProvider<AlarmService>
    var alarms = PublishSubject<[GetAlarmListResult]>()
    private let disposeBag = DisposeBag()
    
    init() {
        self.provider = MoyaProvider<AlarmService>(plugins: [NetworkLogger()])
    }

    func getAlarmList(type: String) {
            provider.rx.request(.getAlarmList(type: type))
                .filterSuccessfulStatusCodes()
                .map(GetAlarmListResponse.self)
                .subscribe(onSuccess: { response in
                    if let result = response.result {
                        self.alarms.onNext(result)
                    }
                }, onFailure: { error in
                    print(error.localizedDescription)
                })
                .disposed(by: disposeBag)
        }
}

