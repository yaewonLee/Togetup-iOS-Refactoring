//
//  LoginViewModel.swift
//  TogetUp
//
//  Created by 이예원 on 2023/09/01.
//

import Foundation
import Moya
import RxSwift
import RxMoya

struct LoginViewModel {
    private let provider: MoyaProvider<LoginService>
    
    init() {
        self.provider = MoyaProvider<LoginService>(plugins: [NetworkLogger()])
    }
    
    func loginReqeust(param: LoginRequest) -> Observable<LoginResponse> {
        return provider.rx.request(.kakao(param: param))
            .filterSuccessfulStatusCodes()
            .map(LoginResponse.self)
            .asObservable()
    }
}
