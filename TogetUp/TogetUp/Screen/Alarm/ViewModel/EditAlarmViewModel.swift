//
//  CreateAlarmViewModel.swift
//  TogetUp
//
//  Created by 이예원 on 2023/09/07.
//

import Foundation
import RxSwift
import Moya
import RealmSwift

class EditAlarmViewModel {
    private let provider = MoyaProvider<AlarmService>()
    private let realmManager = AlarmDataManager()
    private let networkManager = NetworkManager()
    
    var errorMessage = PublishSubject<String>()
    
    func getSingleAlarm(alarmId: Int) -> Single<GetSingleAlarmResponse> {
        return networkManager.handleAPIRequest(provider.rx.request(.getSingleAlarm(alarmId: alarmId)), dataType: GetSingleAlarmResponse.self)
            .flatMap { result -> Single<GetSingleAlarmResponse> in
                switch result {
                case .success(let response):
                    return .just(response)
                case .failure(let error):
                    let message = self.networkManager.errorMessage(for: error)
                    self.errorMessage.onNext(message)
                    return .error(error)
                }
            }
    }
    
    func postAlarm(param: CreateOrEditAlarmRequest, missionEndpoint: String) -> Single<Result<Void, Error>> {
        return networkManager.handleAPIRequest(provider.rx.request(.createAlarm(param: param)), dataType: CreateEditDeleteAlarmResponse.self)
            .flatMap { [weak self] result -> Single<Result<Void, Error>> in
                switch result {
                case .success(let response):
                    let alarmId = response.result
                    self?.realmManager.updateAlarm(with: param, for: alarmId ?? 0, missionEndpoint: missionEndpoint)
                    return .just(.success(()))
                case .failure(let error):
                    return .just(.failure(error))
                }
            }
    }
    
    func editAlarm(param: CreateOrEditAlarmRequest, missionEndpoint: String, alarmId: Int) -> Single<Result<Void, Error>> {
        return networkManager.handleAPIRequest(provider.rx.request(.editAlarm(alarmId: alarmId, param: param)), dataType: CreateEditDeleteAlarmResponse.self)
            .flatMap { [weak self] result -> Single<Result<Void, Error>> in
                switch result {
                case .success:
                    self?.realmManager.updateAlarm(with: param, for: alarmId, missionEndpoint: missionEndpoint)
                    return .just(.success(()))
                case .failure(let error):
                    return .just(.failure(error))
                }
            }
    }
    
    func deleteAlarm(alarmId: Int) -> Single<Result<Void, Error>> {
        return networkManager.handleAPIRequest(provider.rx.request(.deleteAlarm(alarmId: alarmId)), dataType: CreateEditDeleteAlarmResponse.self)
            .flatMap { [weak self] result -> Single<Result<Void, Error>> in
                switch result {
                case .success:
                    self?.realmManager.deleteAlarm(alarmId: alarmId)
                    return .just(.success(()))
                case .failure(let error):
                    return .just(.failure(error))
                }
            }
    }
}
