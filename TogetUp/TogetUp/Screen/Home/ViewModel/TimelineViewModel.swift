//
//  TimelineViewModel.swift
//  TogetUp
//
//  Created by 이예원 on 11/28/23.
//

import Foundation
import RxSwift
import Moya
import RxMoya

class TimelineViewModel {
    var timelineData: BehaviorSubject<Result<TimeLineResult?, NetWorkingError>> = BehaviorSubject(value: .success(nil))
    var nextAlarmId: Int? = nil
    let disposeBag = DisposeBag()
    let networkManager = NetworkManager()
    let provider = MoyaProvider<HomeService>()

    func fetchTimelineData() {
        let request = provider.rx.request(.getTimeLine)
        networkManager.handleAPIRequest(request, dataType: TimelineResponse.self)
            .subscribe { [weak self] result in
                switch result {
                case .success(let response):
                    switch response {
                    case .success(let data):
                        self?.timelineData.onNext(.success(data.result))
                        self?.nextAlarmId = data.result?.nextAlarm?.id
                    case .failure(let error):
                        self?.timelineData.onNext(.failure(error))
                    }
                case .failure(let error):
                    print("Request failed with error: \(error.localizedDescription)")
                    self?.timelineData.onNext(.failure(.network(MoyaError.underlying(error, nil))))
                }
            }.disposed(by: disposeBag)
    }
}
