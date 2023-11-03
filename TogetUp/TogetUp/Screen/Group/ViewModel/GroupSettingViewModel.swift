//
//  GroupSettingViewModel.swift
//  TogetUp
//
//  Created by 이예원 on 2023/10/19.
//

import Foundation
import RxSwift
import Moya
import RxMoya


class GroupSettingViewModel {
    private let provider: MoyaProvider<GroupService>
    
    init(provider: MoyaProvider<GroupService> = MoyaProvider<GroupService>(plugins: [NetworkLogger()])) {
        self.provider = provider
    }
    
    func getGroupDetail(roomId: Int) -> Observable<GroupSettingResponse> {
        return provider.rx.request(.getGroupDetail(roomId: roomId))
            .filterSuccessfulStatusCodes()
            .map(GroupSettingResponse.self)
            .asObservable()
    }
    
    func deleteMember(roomId: Int) -> Observable<DeleteMemberResponse> {
        return provider.rx.request(.deleteMember(roomId: roomId))
            .filterSuccessfulStatusCodes()
            .map(DeleteMemberResponse.self)
            .asObservable()
    }
}
