//
//  RealmDataManger.swift
//  TogetUp
//
//  Created by 이예원 on 1/21/24.
//

import Foundation
import RealmSwift

enum RealmError: Error {
    case alarmNotFound
}

class AlarmDataManager {
    private var realm: Realm {
        return try! Realm()
    }
    
    func fetchAlarms() -> [Alarm] {
        return Array(realm.objects(Alarm.self).sorted(by: {
            let time1InMinutes = $0.alarmHour * 60 + $0.alarmMinute
            let time2InMinutes = $1.alarmHour * 60 + $1.alarmMinute
            return time1InMinutes < time2InMinutes
        }))
    }
    
    func saveAlarms<T>(_ alarms: [T], transform: (T) -> Alarm) -> Result<[Alarm], Error> {
        do {
            var savedAlarms = [Alarm]()
            try realm.write {
                for alarmData in alarms {
                    let alarm = transform(alarmData)
                    realm.add(alarm, update: .modified)
                    savedAlarms.append(alarm)
                }
            }
            return .success(savedAlarms)
        } catch {
            return .failure(error)
        }
    }
    
    func updateIsActivated(alarmId: Int, field: String, value: Any) -> Result<Void, Error> {
        do {
            try realm.write {
                guard let alarmToUpdate = realm.object(ofType: Alarm.self, forPrimaryKey: alarmId) else {
                    throw RealmError.alarmNotFound
                }
                alarmToUpdate.setValue(value, forKey: field)
            }
            return .success(())
        } catch {
            return .failure(error)
        }
    }
    
    func updateAlarm(alarmId: Int, with newData: Alarm) -> Result<Void, Error> {
        do {
            try realm.write {
                guard let alarmToUpdate = realm.object(ofType: Alarm.self, forPrimaryKey: alarmId) else {
                    throw RealmError.alarmNotFound
                }
                //필드 업데이트 로직
                alarmToUpdate.name = newData.name
                alarmToUpdate.isActivated = newData.isActivated
            }
            return .success(())
        } catch {
            return .failure(error)
        }
    }
    
    func deleteAlarm(alarmId: Int) {
        do {
            if let alarmToDelete = realm.object(ofType: Alarm.self, forPrimaryKey: alarmId) {
                try realm.write {
                    realm.delete(alarmToDelete)
                }
            }
        } catch {
            print("Error deleting alarm from realm: \(error)")
        }
    }
    
    func createToggleAlarmRequest(alarmId: Int) -> CreateOrEditAlarmRequest {
        guard let storedAlarm = realm.object(ofType: Alarm.self, forPrimaryKey: alarmId) else {
            fatalError("Alarm not found")
        }
        
        let alarmString = String(format: "%02d:%02d", storedAlarm.alarmHour, storedAlarm.alarmMinute)
        var objectIdParam: Int? = storedAlarm.missionObjectId
        if storedAlarm.missionId == 1 {
            objectIdParam = nil
        }
        
        return CreateOrEditAlarmRequest(
            missionId: storedAlarm.missionId,
            missionObjectId: objectIdParam,
            isSnoozeActivated: storedAlarm.isSnoozeActivated,
            name: storedAlarm.name,
            icon: storedAlarm.icon,
            isVibrate: storedAlarm.isVibrate,
            alarmTime: alarmString,
            monday: storedAlarm.monday,
            tuesday: storedAlarm.tuesday,
            wednesday: storedAlarm.wednesday,
            thursday: storedAlarm.thursday,
            friday: storedAlarm.friday,
            saturday: storedAlarm.saturday,
            sunday: storedAlarm.sunday,
            isActivated: !storedAlarm.isActivated,
            roomId: nil,
            snoozeInterval: 0,
            snoozeCnt: 0
        )
    }
    
    private func mapRequestToAlarm(_ request: CreateOrEditAlarmRequest, alarm: Alarm) {
        alarm.missionId = request.missionId
        alarm.missionObjectId = request.missionObjectId ?? 1
        alarm.isSnoozeActivated = request.isSnoozeActivated
        alarm.name = request.name
        alarm.icon = request.icon
        alarm.isVibrate = request.isVibrate
        alarm.alarmHour = getHour(from: request.alarmTime)
        alarm.alarmMinute = getMinute(from: request.alarmTime)
        alarm.days = [request.monday, request.tuesday, request.wednesday, request.thursday, request.friday, request.saturday, request.sunday]
        alarm.isActivated = request.isActivated
        alarm.missionName = request.name
        alarm.missionEndpoint = request.missionEndpoint
    }
    
    private func getHour(from time: String) -> Int {
        let components = time.split(separator: ":").map(String.init)
        return Int(components[0]) ?? 0
    }
    
    private func getMinute(from time: String) -> Int {
        let components = time.split(separator: ":").map(String.init)
        return Int(components.count > 1 ? components[1] : "0") ?? 0
    }
    
    func updateAlarmFields(alarm: Alarm, missionId: Int, missionObjectId: Int, isSnoozeActivated: Bool, name: String, icon: String, isVibrate: Bool, alarmHour: Int, alarmMinute: Int, days: [Bool], isActivated: Bool, missionName: String, missionEndpoint: String) {
        alarm.missionId = missionId
        alarm.missionObjectId = missionObjectId
        alarm.isSnoozeActivated = isSnoozeActivated
        alarm.name = name
        alarm.icon = icon
        alarm.isVibrate = isVibrate
        alarm.alarmHour = alarmHour
        alarm.alarmMinute = alarmMinute
        alarm.monday = days[0]
        alarm.tuesday = days[1]
        alarm.wednesday = days[2]
        alarm.thursday = days[3]
        alarm.friday = days[4]
        alarm.saturday = days[5]
        alarm.sunday = days[6]
        alarm.isActivated = isActivated
        alarm.missionName = missionName
        alarm.missionEndpoint = missionEndpoint
    }
    
    func saveOrUpdateAlarmInRealm(id: Int, missionId: Int, missionObjectId: Int, isSnoozeActivated: Bool, name: String, icon: String, isVibrate: Bool, alarmHour: Int, alarmMinute: Int, days: [Bool], isActivated: Bool, missionName: String, missionEndpoint: String) {
        let realmInstance = try! Realm()
        
        if let alarm = realmInstance.objects(Alarm.self).filter("id == \(id)").first {
            try? realmInstance.write {
                updateAlarmFields(alarm: alarm, missionId: missionId, missionObjectId: missionObjectId, isSnoozeActivated: isSnoozeActivated, name: name, icon: icon, isVibrate: isVibrate, alarmHour: alarmHour, alarmMinute: alarmMinute, days: days, isActivated: isActivated, missionName: missionName, missionEndpoint: missionEndpoint)
            }
            AlarmScheduleManager.shared.toggleAlarmActivation(for: id)
        } else {
            let newAlarm = Alarm()
            newAlarm.id = id
            updateAlarmFields(alarm: newAlarm, missionId: missionId, missionObjectId: missionObjectId, isSnoozeActivated: isSnoozeActivated, name: name, icon: icon, isVibrate: isVibrate, alarmHour: alarmHour, alarmMinute: alarmMinute, days: days, isActivated: isActivated, missionName: missionName, missionEndpoint: missionEndpoint)
            try? realmInstance.write {
                realmInstance.add(newAlarm, update: .modified)
            }
            AlarmScheduleManager.shared.scheduleNotification(for: id)
        }
    }
}
