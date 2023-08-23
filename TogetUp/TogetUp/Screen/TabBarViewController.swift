//
//  TabBarViewController.swift
//  TogetUp
//
//  Created by 이예원 on 2023/08/18.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.selectedIndex = 1
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.navigationController?.isNavigationBarHidden = true
        configureBorder()
    }
    
    private func configureBorder() {
        let topBorderHeight: CGFloat = 2
        let topBorderColor = UIColor.black.cgColor

        let borderLayer = CALayer()
        borderLayer.frame = CGRect(x: 0 , y: 0, width: tabBar.bounds.width, height: topBorderHeight)
        borderLayer.backgroundColor = topBorderColor

        tabBar.layer.addSublayer(borderLayer)
    }


}
