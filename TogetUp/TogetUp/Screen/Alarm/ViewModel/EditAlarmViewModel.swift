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

    // MARK: - API Call Methods
    func handleAPIRequest<T: Decodable>(_ request: Single<Response>) -> Single<Result<T, CreateAlarmError>> {
        return request
            .filterSuccessfulStatusAndRedirectCodes()
            .map(T.self)
            .map(Result.success)
            .catch { error -> Single<Result<T, CreateAlarmError>> in
                if let moyaError = error as? MoyaError {
                    switch moyaError {
                    case .statusCode(let response):
                        return Single.just(.failure(.server(response.statusCode)))
                    default:
                        return Single.just(.failure(.network(moyaError)))
                    }
                } else {
                    return Single.just(.failure(.network(MoyaError.underlying(error, nil))))
                }
            }
    }

    func getSingleAlarm(id: Int) -> Single<Result<GetSingleAlarmResponse, CreateAlarmError>> {
        return handleAPIRequest(provider.rx.request(.getSingleAlarm(alarmId: id)))
    }

    func postAlarm(param: CreateOrEditAlarmRequest) -> Single<Result<CreateEditDeleteAlarmResponse, CreateAlarmError>> {
        return handleAPIRequest(provider.rx.request(.createAlarm(param: param)))
    }

    func editAlarmAPI(alarmId: Int, param: CreateOrEditAlarmRequest) -> Single<Result<CreateEditDeleteAlarmResponse, CreateAlarmError>> {
        return handleAPIRequest(provider.rx.request(.editAlarm(alarmId: alarmId, param: param)))
    }

    func deleteAlarm(alarmId: Int) -> Single<Result<Int, CreateAlarmError>> {
        return provider.rx.request(.deleteAlarm(alarmId: alarmId))
            .filterSuccessfulStatusAndRedirectCodes()
            .map(CreateEditDeleteAlarmResponse.self)
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



    // MARK: - Realm Methods
    func saveOrUpdateAlarmInRealm(id: Int, missionId: Int, missionObjectId: Int, isSnoozeActivated: Bool, name: String, icon: String, isVibrate: Bool, alarmTime: Date, days: [Bool], isActivated: Bool, missionName: String) {
        let realmInstance = try! Realm()

        if let alarm = realmInstance.objects(Alarm.self).filter("id == \(id)").first {
            try? realmInstance.write {
                updateAlarmFields(alarm: alarm, missionId: missionId, missionObjectId: missionObjectId, isSnoozeActivated: isSnoozeActivated, name: name, icon: icon, isVibrate: isVibrate, alarmTime: alarmTime, days: days, isActivated: isActivated, missionName: missionName)
            }
        } else {
            let newAlarm = Alarm()
            newAlarm.id = id
            updateAlarmFields(alarm: newAlarm, missionId: missionId, missionObjectId: missionObjectId, isSnoozeActivated: isSnoozeActivated, name: name, icon: icon, isVibrate: isVibrate, alarmTime: alarmTime, days: days, isActivated: isActivated, missionName: missionName)

            try? realmInstance.write {
                realmInstance.add(newAlarm, update: .modified)
            }
        }
    }

    private func updateAlarmFields(alarm: Alarm, missionId: Int, missionObjectId: Int, isSnoozeActivated: Bool, name: String, icon: String, isVibrate: Bool, alarmTime: Date, days: [Bool], isActivated: Bool, missionName: String) {
        alarm.missionId = missionId
        alarm.missionObjectId = missionObjectId
        alarm.isSnoozeActivated = isSnoozeActivated
        alarm.name = name
        alarm.icon = icon
        alarm.isVibrate = isVibrate
        alarm.alarmTime = alarmTime
        alarm.monday = days[0]
        alarm.tuesday = days[1]
        alarm.wednesday = days[2]
        alarm.thursday = days[3]
        alarm.friday = days[4]
        alarm.saturday = days[5]
        alarm.sunday = days[6]
        alarm.isActivated = isActivated
        alarm.missionName = missionName
    }
}




