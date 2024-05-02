//
//  AlarmScheduleManager.swift
//  TogetUp
//
//  Created by 이예원 on 2023/09/26.
//

import Foundation
import UserNotifications
import RealmSwift
import AudioToolbox

class AlarmScheduleManager {
    static let shared = AlarmScheduleManager()
    
    func scheduleAlarmById(with alarmId: Int) {
        let realm = try! Realm()
        guard let alarm = realm.object(ofType: Alarm.self, forPrimaryKey: alarmId), alarm.isActivated else { return }
        
        if let nextAlarmTime = getNextAlarmDate(for: alarm, from: Date()) {
            scheduleNotification(at: nextAlarmTime, with: alarm)
        }
    }
    
    private func getNextAlarmDate(for alarm: Alarm, from referenceDate: Date) -> Date? {
        let calendar = Calendar.current
        var components = DateComponents()
        components.hour = alarm.alarmHour
        components.minute = alarm.alarmMinute
        components.second = 0

        // 요일 반복 여부를 검사
        if alarm.isRepeatAlarm() {
            // 요일 반복이 있는 경우
            var nextDate = referenceDate
            repeat {
                if let alarmDate = calendar.nextDate(after: nextDate, matching: components, matchingPolicy: .nextTime) {
                    let weekday = calendar.component(.weekday, from: alarmDate)
                    if alarm.isActive(on: weekday) {
                        return alarmDate
                    }
                    nextDate = calendar.date(byAdding: .day, value: 1, to: alarmDate)!
                } else {
                    break
                }
            } while true
        } else {
            // 요일 반복이 없는 경우, 다음 가능한 시간 계산
            if let nextDate = calendar.nextDate(after: referenceDate, matching: components, matchingPolicy: .nextTime) {
                return nextDate > referenceDate ? nextDate : nil
            }
        }
        return nil
    }

    
    
    private func scheduleNotification(at date: Date, with alarm: Alarm) {
        let content = UNMutableNotificationContent()
        content.title = "Alarm: \(alarm.name)"
        content.body = "It's time for \(alarm.missionName)!"
        content.sound = alarm.isVibrate ? UNNotificationSound.defaultCritical : UNNotificationSound.default
        
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        let repeats = alarm.isRepeatAlarm() // 반복 여부에 따라 다르게 설정
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: repeats)
        
        let request = UNNotificationRequest(identifier: "\(alarm.id)", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
    
    private func fetchAlarmFromDatabase(alarmId: Int) -> Alarm? {
        let realm = try? Realm()
        return realm?.object(ofType: Alarm.self, forPrimaryKey: alarmId)
    }
    
    func removeNotification(for alarmId: Int) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let identifiersToRemove = requests.filter {
                $0.content.userInfo["alarmId"] as? Int == alarmId
            }.map { $0.identifier }
            
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiersToRemove)
        }
    }
    
    func toggleAlarmActivation(for alarmId: Int) {
        let realm = try? Realm()
        guard let alarm = realm?.object(ofType: Alarm.self, forPrimaryKey: alarmId) else {
            print("Alarm with ID \(alarmId) not found in Realm")
            return
        }
        if alarm.isActivated {
            scheduleAlarmById(with: alarmId)
        } else {
            removeNotification(for: alarmId)
        }
    }
    
    func refreshAllScheduledNotifications() {
        guard let allAlarms = fetchAllAlarmsFromDatabase() else { return }
        for alarm in allAlarms where alarm.isActivated {
            scheduleAlarmById(with: alarm.id)
        }
    }
    
    func fetchAllAlarmsFromDatabase() -> [Alarm]? {
        do {
            let realm = try Realm()
            let alarms = realm.objects(Alarm.self)
            return Array(alarms)
        } catch let error {
            print("Error accessing Realm: \(error)")
            return nil
        }
    }
}

extension Alarm {
    func isActive(on weekday: Int) -> Bool {
        switch weekday {
        case 1: return sunday
        case 2: return monday
        case 3: return tuesday
        case 4: return wednesday
        case 5: return thursday
        case 6: return friday
        case 7: return saturday
        default: return false
        }
    }
}
