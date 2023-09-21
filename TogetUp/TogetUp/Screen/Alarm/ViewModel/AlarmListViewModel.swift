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
import RealmSwift

class AlarmListViewModel {
    private let provider: MoyaProvider<AlarmService>
    private var realm: Realm?
    var alarms = BehaviorSubject<[Alarm]>(value: [])
    private let disposeBag = DisposeBag()
    
    init() {
        self.provider = MoyaProvider<AlarmService>(plugins: [NetworkLogger()])
    }
    
    func fetchAlarmsFromRealm() {
        let realm = try! Realm()
        let alarmsFromRealm = realm.objects(Alarm.self).sorted(byKeyPath: "alarmTime")
        
        alarms.onNext(Array(alarmsFromRealm))
    }
    
    func getAndSaveAlarmList(type: String) {
        provider.rx.request(.getAlarmList(type: type))
            .filterSuccessfulStatusCodes()
            .map(GetAlarmListResponse.self)
            .subscribe(onSuccess: { [weak self] response in
                if let result = response.result {
                    self?.saveAlarmsToRealm(result)
                    self?.fetchAlarmsFromRealm()
                }
            }, onFailure: { error in
                print(error.localizedDescription)
            })
            .disposed(by: disposeBag)
    }
    
    private func saveAlarmsToRealm(_ alarms: [GetAlarmListResult]) {
        let realm = try! Realm()
        try! realm.write {
            for apiAlarm in alarms {
                let alarm = Alarm()
                alarm.id = apiAlarm.id
                if let missionId = apiAlarm.getMissionRes?.id,
                   let missionObjectId = apiAlarm.getMissionObjectRes?.id,
                   let missionName = apiAlarm.getMissionObjectRes?.kr {
                    alarm.missionId = missionId
                    alarm.missionObjectId = missionObjectId
                    alarm.missionName = missionName
                }
                alarm.isSnoozeActivated = apiAlarm.isSnoozeActivated
                alarm.name = apiAlarm.name
                alarm.icon = apiAlarm.icon
                alarm.isVibrate = apiAlarm.isVibrate
                alarm.monday = apiAlarm.monday
                alarm.tuesday = apiAlarm.tuesday
                alarm.wednesday = apiAlarm.wednesday
                alarm.thursday = apiAlarm.thursday
                alarm.friday = apiAlarm.friday
                alarm.saturday = apiAlarm.saturday
                alarm.sunday = apiAlarm.sunday
                alarm.isActivated = apiAlarm.isActivated
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "HH:mm:ss"
                
                let alarmTimeString = apiAlarm.alarmTime
                print(alarmTimeString)
                if let alarmTimeDate = dateFormatter.date(from: alarmTimeString) {
                    alarm.alarmTime = alarmTimeDate
                } else {
                    print(#function)
                }
                realm.add(alarm, update: .modified)
            }
        }
    }

    func deleteAlarm(alarmId: Int) {
        provider.rx.request(.deleteAlarm(alarmId: alarmId))
            .filterSuccessfulStatusCodes()
            .subscribe(onSuccess: { [weak self] _ in
                guard let self = self else { return }
                let realm = try! Realm()
                // 삭제할 알람을 찾기
                if let alarmToDelete = realm.objects(Alarm.self).filter("id == %@", alarmId).first {
                    var currentAlarms = try? self.alarms.value()
                    currentAlarms?.removeAll(where: { $0.id == alarmId })
                    // Realm에서 알람 삭제
                    try? realm.write {
                        realm.delete(alarmToDelete)
                    }
                    // 업데이트된 알람 리스트를 onNext로 보냄
                    if let updatedAlarms = currentAlarms {
                        self.alarms.onNext(updatedAlarms)
                    }
                }
            }, onFailure: { error in
                print(error.localizedDescription)
            })
            .disposed(by: disposeBag)
    }
}


