//
//  HomeViewModel.swift
//  TogetUp
//
//  Created by 이예원 on 11/27/23.
//

import Foundation
import RxSwift
import Moya
import RxMoya
import RxCocoa

class HomeViewModel {
    private let userProvider = MoyaProvider<UserService>()
    private var homeProvider = MoyaProvider<HomeService>()
    private var devProvider = MoyaProvider<DevService>()
    private let alarmProvider = MoyaProvider<AlarmService>()
    var avatars: [AvatarResult] = []
    var selectedAvatar: AvatarResult?
    private let networkManager = NetworkManager()
    private let realmManager = RealmAlarmDataManager()
    private let disposeBag = DisposeBag()
    var avatarSpeech: BehaviorSubject<String> = BehaviorSubject(value: "")
    
    func loadAvatars() -> Observable<AvatarResponse> {
        return userProvider.rx.request(.getAvatarList)
            .filterSuccessfulStatusCodes()
            .map(AvatarResponse.self)
            .do(onSuccess: { [weak self] response in
                self?.avatars = response.result ?? []
            })
            .asObservable()
    }
    
    func changeAvatar(avatarId: Int) -> Single<Result<Void, Error>> {
        return networkManager.handleAPIRequest(userProvider.rx.request(.changeAvatar(avatarId: avatarId)), dataType: AvatarResponse.self)
            .flatMap { result -> Single<Result<Void, Error>> in
                switch result {
                case .success(_):
                    return .just(.success(()))
                case .failure(let error):
                    return .just(.failure(error))
                }
            }
    }
    
    func updateSelectedAvatar(at index: Int) {
        selectedAvatar = avatars[index]
    }
    
    func getAvatarSpeech(avatarId: Int) -> Observable<String> {
        return networkManager.handleAPIRequest(homeProvider.rx.request(.getAvatarSpeech(avatarId: avatarId)), dataType: AvatarSpeechesResponse.self)
            .asObservable()
            .flatMap { result -> Observable<String> in
                switch result {
                case .success(let response):
                    let speech = response.result?.speech.replacingOccurrences(of: "\\n", with: "\n") ?? ""
                    return Observable.just(speech)
                case .failure(let error):
                    return Observable.error(error)
                }
            }
    }
    
    func getVersionCheck(currentVersion: String) -> Single<VersionCheckResponse> {
        return networkManager.handleAPIRequest(devProvider.rx.request(.versionCheck(currentAppVersion: currentVersion)), dataType: VersionCheckResponse.self)
            .flatMap { result -> Single<VersionCheckResponse> in
                switch result {
                case .success(let response):
                    return .just(response)
                case .failure(let error):
                    return .error(error)
                }
            }
    }
    
    func deactivateAlarms() {
        let activeAlarmIds = realmManager.fetchPastNonRepeatingActivatedAlarms()
        alarmProvider.rx.request(.deactivateAlarms(alarmIds: activeAlarmIds))
            .filterSuccessfulStatusCodes()
            .subscribe { response in
                switch response {
                case .success(let result):
                    self.realmManager.deactivateAlarms()
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
            .disposed(by: disposeBag)
    }
}
