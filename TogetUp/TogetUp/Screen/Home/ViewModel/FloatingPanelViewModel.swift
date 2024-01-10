//
//  FloatingPanelViewModel.swift
//  TogetUp
//
//  Created by 이예원 on 11/28/23.
//

import Foundation
import RxSwift
import Moya
import RxMoya

class FloatingPanelViewModel {
    private let provider: MoyaProvider<HomeService>
    
    init() {
        self.provider = MoyaProvider<HomeService>(plugins: [NetworkLogger()])
    }
    
    func getTimeLine() -> Observable<TimelineResponse> {
        return provider.rx.request(.getTimeLine)
            .filterSuccessfulStatusCodes()
            .map(TimelineResponse.self)
            .asObservable()
    }
}
