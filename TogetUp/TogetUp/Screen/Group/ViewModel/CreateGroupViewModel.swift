//
//  CreateGroupViewModel.swift
//  TogetUp
//
//  Created by 이예원 on 2023/10/16.
//

import Foundation
import RxSwift
import Moya
import RxMoya

class CreateGroupViewModel {
    private let provider: MoyaProvider<GroupService>
    var groupName = PublishSubject<String?>()
    var alarmName = BehaviorSubject<String>(value: "")
    var alarmData = BehaviorSubject<AlarmData?>(value: nil)
    var isPostGroupButtonEnabled: Observable<Bool> {
        return Observable.combineLatest(groupName, alarmName)
            .map { groupName, alarmName in
                return !(groupName?.isEmpty ?? true) && !alarmName.isEmpty
            }
    }
    
    init(provider: MoyaProvider<GroupService> = MoyaProvider<GroupService>(plugins: [NetworkLogger()])) {
        self.provider = provider
    }
    
    func updateAlarm(name: String, icon: String, alarmTime: String, monday: Bool, tuesday: Bool, wednesday: Bool, thursday: Bool, friday: Bool, saturday: Bool, sunday: Bool, isSnoozeActivated: Bool, isVibrate: Bool, missionId: Int, missionObjectId: Int?, missionKr: String) {
        let data = AlarmData(name: name, icon: icon, alarmTime: alarmTime, weekdays: [monday, tuesday, wednesday, thursday, friday, saturday, sunday], missionKr: missionKr)
        alarmData.onNext(data)
        alarmName.onNext(name)
    }
    
    func postGroup(param: CreateGroupRequest) -> Observable<CreateGroupResponse> {
        return provider.rx.request(.createGroup(param: param))
            .filterSuccessfulStatusCodes()
            .map(CreateGroupResponse.self)
            .asObservable()
    }
}

struct AlarmData {
    var name: String
    var icon: String
    var alarmTime: String
    var weekdays: [Bool]
    var missionKr: String
}
