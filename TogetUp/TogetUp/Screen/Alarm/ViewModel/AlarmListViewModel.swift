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
    private let provider = MoyaProvider<AlarmService>()
    var alarms = BehaviorSubject<[Alarm]>(value: [])
    private let disposeBag = DisposeBag()
    private let realmManager = AlarmDataManager()
    private let networkManager = NetworkManager()
    
    private lazy var realmInstance: Realm = {
        return try! Realm()
    }()
    
    func fetchAlarmsFromRealm() {
        let alarmsFromRealm = realmManager.fetchAlarms()
        alarms.onNext(alarmsFromRealm)
    }
    
    func getAndSaveAlarmList(type: String) {
        provider.rx.request(.getAlarmList(type: type))
            .filterSuccessfulStatusCodes()
            .map(GetAlarmListResponse.self)
            .subscribe(onSuccess: { [weak self] response in
                if let result = response.result {
                    self?.saveAlarmsToRealm(result)
                    self?.scheduleActiveAlarms()
                    self?.fetchAlarmsFromRealm()
                }
            }, onFailure: handleNetworkError)
            .disposed(by: disposeBag)
    }
    
    private func scheduleActiveAlarms() {
        let alarms = realmInstance.objects(Alarm.self).filter("isActivated == true")
        for alarm in alarms {
            print(alarm)
            AlarmScheduleManager.shared.scheduleAlarmById(with: alarm.id)
        }
    }
    
    func getGroupAlarmList() -> Observable<[GetAlarmResult]> {
        return provider.rx.request(.getAlarmList(type: "group"))
            .filterSuccessfulStatusCodes()
            .map(GetAlarmListResponse.self)
            .map { $0.result ?? [] }
            .asObservable()
    }
    
    private func handleNetworkError(_ error: Error) {
        print(error.localizedDescription)
    }
    
    private func saveAlarmsToRealm(_ alarms: [GetAlarmResult]) {
        realmManager.saveAlarms(alarms) { apiAlarm in
            let alarm = Alarm()
            alarm.id = apiAlarm.id
            
            if let missionId = apiAlarm.getMissionRes?.id,
               let missionObjectId = apiAlarm.getMissionObjectRes?.id,
               let missionName = apiAlarm.getMissionObjectRes?.kr,
               let missionEndpoint = apiAlarm.getMissionObjectRes?.name {
                alarm.missionId = missionId
                alarm.missionObjectId = missionObjectId
                alarm.missionName = missionName
                alarm.missionEndpoint = missionEndpoint
            }
            
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
            
            let timeComponents = apiAlarm.alarmTime.split(separator: ":").map { Int($0) }
            
            if timeComponents.count >= 2,
               let hour = timeComponents[0],
               let minute = timeComponents[1] {
                alarm.alarmHour = hour
                alarm.alarmMinute = minute
            } else {
                print(#function, "Invalid time format:", apiAlarm.alarmTime)
            }
            return alarm
        }
        AlarmScheduleManager.shared.refreshAllScheduledNotifications()
    }
    
    func editAlarmToggle(alarmId: Int) {
        let alarmRequest = realmManager.createToggleAlarmRequest(alarmId: alarmId)
        
        networkManager.handleAPIRequest(provider.rx.request(.editAlarm(alarmId: alarmId, param: alarmRequest)), dataType: CreateEditDeleteAlarmResponse.self)
            .subscribe(onSuccess: { [weak self] result in
                switch result {
                case .success(let response):
                    self?.updateRealmDatabaseWithResponse(response, for: alarmId)
                    AlarmScheduleManager.shared.toggleAlarmActivation(for: alarmId)
                case .failure(let error):
                    print("알람 수정 오류: \(error.localizedDescription)")
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func updateRealmDatabaseWithResponse(_ response: CreateEditDeleteAlarmResponse, for alarmId: Int) {
        if let alarm = realmInstance.object(ofType: Alarm.self, forPrimaryKey: alarmId) {
            try! realmInstance.write {
                alarm.isActivated.toggle()
            }
        }
    }

    func deleteAlarm(alarmId: Int) {
        networkManager.handleAPIRequest(provider.rx.request(.deleteAlarm(alarmId: alarmId)), dataType: CreateEditDeleteAlarmResponse.self)
            .subscribe(onSuccess: { [weak self] result in
                switch result {
                case .success:
                    self?.realmManager.deleteAlarm(alarmId: alarmId)
                    self?.fetchAlarmsFromRealm()
                    AlarmScheduleManager.shared.removeNotification(for: alarmId)
                case .failure(let error):
                    self?.handleNetworkError(error)
                }
            })
            .disposed(by: disposeBag)
    }
}
