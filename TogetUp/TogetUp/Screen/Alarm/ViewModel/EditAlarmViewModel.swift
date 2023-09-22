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

enum CreateAlarmError: Error {
    case network(MoyaError)
    case server(Int)
}

class EditAlarmViewModel {
    private let provider: MoyaProvider<AlarmService>
    
    init() {
        self.provider = MoyaProvider<AlarmService>(plugins: [NetworkLogger()])
    }
    
    func getSingleAlarm(id: Int) -> Single<Result<GetSingleAlarmResponse, CreateAlarmError>> {
        return provider.rx.request(.getSingleAlarm(alarmId: id))
            .filterSuccessfulStatusAndRedirectCodes()
            .map(GetSingleAlarmResponse.self)
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
    
    func postAlarm(param: CreateAlarmRequest) -> Single<Result<CreateOrDeleteAlarmResponse, CreateAlarmError>> {
        return provider.rx.request(.createAlarm(param: param))
            .filterSuccessfulStatusAndRedirectCodes()
            .map(CreateOrDeleteAlarmResponse.self)
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
    
    func addAlarmToRealm(id: Int, missionId: Int, missionObjectId: Int, isSnoozeActivated: Bool, name: String, icon: String, isVibrate: Bool, alarmTime: Date, monday: Bool, tuesday: Bool, wednesday: Bool, thursday: Bool, friday: Bool, saturday: Bool, sunday: Bool, isActivated: Bool, missionName: String) {
        let newAlarm = Alarm()
        let realmInstance = try! Realm()
        let savedAlarms = realmInstance.objects(Alarm.self)
        print(savedAlarms)
        
        newAlarm.id = id
        newAlarm.missionId = missionId
        newAlarm.missionObjectId = missionObjectId
        newAlarm.isSnoozeActivated = isSnoozeActivated
        newAlarm.name = name
        newAlarm.icon = icon
        newAlarm.isVibrate = isVibrate
        newAlarm.alarmTime = alarmTime
        newAlarm.monday = monday
        newAlarm.tuesday = tuesday
        newAlarm.wednesday = wednesday
        newAlarm.thursday = thursday
        newAlarm.friday = friday
        newAlarm.saturday = saturday
        newAlarm.sunday = sunday
        newAlarm.isActivated = isActivated
        newAlarm.missionName = missionName
        
        do {
            try realmInstance.write {
                realmInstance.add(newAlarm, update: .modified)
                print(savedAlarms)
            }
        } catch {
            print("Error Saving content")
        }
    }
    
    func deleteAlarm(alarmId: Int) -> Single<Result<Int, CreateAlarmError>> {
        return provider.rx.request(.deleteAlarm(alarmId: alarmId)) 
            .filterSuccessfulStatusAndRedirectCodes()
            .map(CreateOrDeleteAlarmResponse.self)
            .flatMap { response -> Single<Result<Int, CreateAlarmError>> in
                if let resultId = response.result, resultId == alarmId {
                    let realmInstance = try! Realm()
                    if let alarmToDelete = realmInstance.objects(Alarm.self).filter("id == \(alarmId)").first {
                        do {
                            try realmInstance.write {
                                realmInstance.delete(alarmToDelete)
                            }
                            return Single.just(.success(resultId))
                        } catch {
                            print("Error deleting alarm from Realm")
                            return Single.just(.failure(.server(500)))
                        }
                    } else {
                        print("Alarm not found in Realm")
                        return Single.just(.failure(.server(404)))
                    }
                } else {
                    return Single.just(.failure(.server(response.httpStatusCode)))
                }
            }
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



