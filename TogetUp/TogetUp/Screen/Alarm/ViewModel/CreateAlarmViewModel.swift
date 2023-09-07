//
//  CreateAlarmViewModel.swift
//  TogetUp
//
//  Created by 이예원 on 2023/09/07.
//

import Foundation
import RxSwift
import Moya

enum CreateAlarmError: Error {
    case network(MoyaError)
    case server(Int)
}

class CreateAlarmViewModel {
    private let provider: MoyaProvider<AlarmService>
    
    init() {
        self.provider = MoyaProvider<AlarmService>(plugins: [NetworkLogger()])
        }
    
    func createAlarm(param: CreateAlarmRequest) -> Single<Result<CreateAlarmResponse, CreateAlarmError>> {
        return provider.rx.request(.createAlarm(param: param))
            .filterSuccessfulStatusAndRedirectCodes()
            .map(CreateAlarmResponse.self)
            .map(Result.success)
            .catch { error in
                if let moyaError = error as? MoyaError {
                    switch moyaError {
                    case .statusCode(let response):
                        print("Status code: \(response.statusCode)")
                        return Single.just(.failure(.server(response.statusCode)))
                        
                    default:
                        print("Other error: \(moyaError.localizedDescription)")
                        return Single.just(.failure(.network(moyaError)))
                    }
                } else {
                    print("Unknown error: \(error)")
                    return Single.just(.failure(.network(MoyaError.underlying(error, nil))))
                }
            }
    }
}



