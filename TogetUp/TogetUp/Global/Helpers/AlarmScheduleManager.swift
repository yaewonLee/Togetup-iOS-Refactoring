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
    
    func getNextAlarmDate(for alarm: Alarm, from referenceDate: Date) -> Date? {
        if alarm.isRepeatAlarm() {
            return getNextRepeatAlarmDate(for: alarm, from: referenceDate)
        } else {
            return getNextSingleAlarmDate(for: alarm, from: referenceDate)
        }
    }
    
    private func getNextRepeatAlarmDate(for alarm: Alarm, from referenceDate: Date) -> Date? {
        let calendar = Calendar.current
        var components = DateComponents(hour: alarm.alarmHour, minute: alarm.alarmMinute, second: 0)
        var nextDate = referenceDate
        
        let currentDateComponents = calendar.dateComponents([.hour, .minute, .second], from: referenceDate)
        let currentHour = currentDateComponents.hour!
        let currentMinute = currentDateComponents.minute!
        let currentSecond = currentDateComponents.second!
        
        if currentHour > alarm.alarmHour || (currentHour == alarm.alarmHour && currentMinute > alarm.alarmMinute) ||
            (currentHour == alarm.alarmHour && currentMinute == alarm.alarmMinute && currentSecond > 0) {
            nextDate = calendar.date(byAdding: .day, value: 1, to: nextDate)!
        }
        
        while true {
            if let alarmDate = calendar.nextDate(after: nextDate, matching: components, matchingPolicy: .strict) {
                let weekday = calendar.component(.weekday, from: alarmDate)
                if alarm.isActive(on: weekday) {
                    return alarmDate
                }
            }
            nextDate = calendar.date(byAdding: .day, value: 1, to: nextDate)!
        }
    }
    
    
    
    private func getNextSingleAlarmDate(for alarm: Alarm, from referenceDate: Date) -> Date? {
        let calendar = Calendar.current
        let components = DateComponents(hour: alarm.alarmHour, minute: alarm.alarmMinute)
        
        if let nextDate = calendar.nextDate(after: referenceDate, matching: components, matchingPolicy: .nextTime) {
            return nextDate > referenceDate ? nextDate : nil
        }
        return nil
    }
    
    
    private func scheduleNotification(at date: Date, with alarm: Alarm) {
        let content = UNMutableNotificationContent()
        content.title = "알람이 울리고 있어요!"
        content.body = "\(alarm.missionName)찍기 미션을 수행해주세요!"
        content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "alarmSound.mp3"))
        content.userInfo = ["alarmId": alarm.id]
        
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
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
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests { requests in
            let identifiersToRemove = requests.filter { request in
                request.identifier == "\(alarmId)"
            }.map { $0.identifier }
            
            if !identifiersToRemove.isEmpty {
                center.removePendingNotificationRequests(withIdentifiers: identifiersToRemove)
                print("Removed all notifications for alarm ID: \(alarmId)")
            } else {
                print("No notifications found for alarm ID: \(alarmId)")
            }
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
