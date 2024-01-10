//
//  GroupJoinViewModel.swift
//  TogetUp
//
//  Created by 이예원 on 11/30/23.
//

import Foundation
import Moya
import RxSwift
import RxMoya

struct GroupJoinViewModel {
    private let provider = MoyaProvider<GroupService>()
    
    //    init() {
    //        self.provider = MoyaProvider<GroupService>(plugins: [NetworkLogger()])
    //    }
    
    func getGroupDetail(code: String) -> Observable<InviteDetailResponse> {
        return provider.rx.request(.getGroupDetailWithCode(code: code))
            .filterSuccessfulStatusCodes()
            .map(InviteDetailResponse.self)
            .asObservable()
    }
}
