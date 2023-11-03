//
//  GroupBoardViewModel.swift
//  TogetUp
//
//  Created by 이예원 on 2023/10/20.
//

import Foundation
import RxSwift
import Moya
import RxMoya

class GroupBoardViewModel {
    private let provider: MoyaProvider<GroupService>
    var titleSubject = BehaviorSubject<String?>(value: nil)
    
    init(provider: MoyaProvider<GroupService> = MoyaProvider<GroupService>(plugins: [NetworkLogger()])) {
        self.provider = provider
    }
    
    func getMissionLog(roomId: Int, localDateTime: String) -> Observable<GroupBoardResponse> {
        return provider.rx.request(.getMissionLog(roomId: roomId, localDateTime: localDateTime))
            .filterSuccessfulStatusCodes()
            .map(GroupBoardResponse.self)
            .asObservable()
            .do(onNext: { [weak self] response in
                self?.titleSubject.onNext(response.result.name)
            })
    }
}
