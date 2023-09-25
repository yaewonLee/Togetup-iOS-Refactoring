//
//  MissionPerformViewModel.swift
//  TogetUp
//
//  Created by 이예원 on 2023/09/25.
//

import Foundation
import RxSwift
import RxCocoa

class MissionPerformViewModel {
    let currentDate: Observable<String>
    let currentTime: Observable<String>
    
    init() {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        
        // For Date
        formatter.dateFormat = "M월 d일 EEEE"
        let initialDate = Observable.just(formatter.string(from: Date()))
        currentDate = Observable.concat([initialDate, Observable.never()])
        
        // For Time
        formatter.dateFormat = "hh:mm"
        let initialTime = Observable.just(formatter.string(from: Date()))
        let updatingTime = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
            .map { _ in formatter.string(from: Date()) }
        currentTime = Observable.merge(initialTime, updatingTime)
    }
}



