//
//  Utils.swift
//  TogetUp
//
//  Created by 이예원 on 5/12/24.
//

import Foundation
import UIKit

public class AppVersionCheckManager {
    static let shared = AppVersionCheckManager()
    
    func getBuildVersion() -> String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
    }
    
    func openAppStore(url: String) {
        if let url = URL(string: url), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    func closeApp() {
        UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            exit(0)
        }
    }
}


