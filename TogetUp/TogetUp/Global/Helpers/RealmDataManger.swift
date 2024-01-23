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
                guard let alarmToUpdate = realm.objects(Alarm.self).filter("id == %@", alarmId).first else {
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
                guard let alarmToUpdate = realm.objects(Alarm.self).filter("id == %@", alarmId).first else {
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
            if let alarmToDelete = realm.objects(Alarm.self).filter("id == %@", alarmId).first {
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
}
