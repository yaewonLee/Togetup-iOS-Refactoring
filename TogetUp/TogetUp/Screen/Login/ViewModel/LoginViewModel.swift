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
    private let provider = MoyaProvider<LoginService>().rx
    
    func kakoLogin(param: KakaoLoginRequest) -> Observable<Response> {
        return provider.request(.kakao(param: param))
            .filterSuccessfulStatusCodes()
            .asObservable()
    }
    
}
