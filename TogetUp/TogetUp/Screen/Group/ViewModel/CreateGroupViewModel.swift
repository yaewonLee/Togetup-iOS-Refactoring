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
    var isPostGroupButtonEnabled: Observable<Bool> {
        return Observable.combineLatest(groupName, alarmName)
            .map { groupName, alarmName in
                return !(groupName?.isEmpty ?? true) && !alarmName.isEmpty
            }
    }
    
    init(provider: MoyaProvider<GroupService> = MoyaProvider<GroupService>(plugins: [NetworkLogger()])) {
        self.provider = provider
    }
    
    func postGroup(param: CreateGroupRequest) -> Observable<CreateGroupResponse> {
        return provider.rx.request(.createGroup(param: param))
            .filterSuccessfulStatusCodes()
            .map(CreateGroupResponse.self)
            .asObservable()
    }
    
    func updateAlarmName(name: String) {
        alarmName.onNext(name)
    }
}
