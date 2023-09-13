//
//  ObjectMissionViewModel.swift
//  TogetUp
//
//  Created by 이예원 on 2023/09/11.
//

import Foundation
import RxMoya
import RxSwift
import Moya

struct MissionViewModel {
    let provider = MoyaProvider<MissionService>()
    
    func getMissionList(missionId: Int) -> Observable<GetMissionListResponse> {
        return provider.rx.request(.getMissionList(missionId: missionId))
            .filterSuccessfulStatusCodes()
            .map(GetMissionListResponse.self)
            .asObservable()
    }
}
