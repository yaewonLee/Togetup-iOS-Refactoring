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

class CreateAlarmViewModel {
    private let provider: MoyaProvider<AlarmService>
    
    init() {
        self.provider = MoyaProvider<AlarmService>(plugins: [NetworkLogger()])
    }
    
    func postAlarm(param: CreateAlarmRequest) -> Single<Result<CreateAlarmResponse, CreateAlarmError>> {
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
}



