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
            let alarms = realm.objects(Alarm.self).sorted {
                ($0.alarmHour * 60 + $0.alarmMinute) < ($1.alarmHour * 60 + $1.alarmMinute)
            }
            return Array(alarms)
        }
    
    func saveAlarms<T>(_ alarms: [T], transform: (T) -> Alarm) {
            do {
                try realm.write {
                    alarms.map(transform).forEach { realm.add($0, update: .modified) }
                }
            } catch {
                print("Error saving alarms: \(error)")
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
    
    func updateAlarm(with request: CreateOrEditAlarmRequest, for alarmId: Int, missionEndpoint: String, missionKoreanName: String) {
        do {
            try realm.write {
                let alarm = realm.object(ofType: Alarm.self, forPrimaryKey: alarmId)
                if alarm == nil {
                    let newAlarm = Alarm()
                    newAlarm.id = alarmId 
                    mapRequestToAlarm(request, alarm: newAlarm, missionEndpoint: missionEndpoint, missionKoreanName: missionKoreanName)
                    realm.add(newAlarm)
                } else {
                    mapRequestToAlarm(request, alarm: alarm!, missionEndpoint: missionEndpoint, missionKoreanName: missionKoreanName)
                }
            }
        } catch {
            print("Error updating or adding alarm: \(error)")
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
    
    private func mapRequestToAlarm(_ request: CreateOrEditAlarmRequest, alarm: Alarm, missionEndpoint: String, missionKoreanName: String) {
        alarm.missionId = request.missionId
        alarm.missionObjectId = request.missionObjectId ?? 1
        alarm.isSnoozeActivated = request.isSnoozeActivated
        alarm.name = request.name
        alarm.icon = request.icon
        alarm.isVibrate = request.isVibrate
        alarm.alarmHour = getHour(from: request.alarmTime)
        alarm.alarmMinute = getMinute(from: request.alarmTime)
        alarm.monday = request.monday
        alarm.tuesday = request.tuesday
        alarm.wednesday = request.wednesday
        alarm.thursday = request.thursday
        alarm.friday = request.friday
        alarm.saturday = request.saturday
        alarm.sunday = request.sunday
        alarm.isActivated = request.isActivated
        alarm.missionName = missionKoreanName
        alarm.missionEndpoint = missionEndpoint
    }
    
    private func getHour(from time: String) -> Int {
        let components = time.split(separator: ":").map(String.init)
        return Int(components[0]) ?? 0
    }
    
    private func getMinute(from time: String) -> Int {
        let components = time.split(separator: ":").map(String.init)
        return Int(components.count > 1 ? components[1] : "0") ?? 0
    }
}
