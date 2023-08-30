//
//  MissionListViewController.swift
//  TogetUp
//
//  Created by 이예원 on 2023/08/28.
//

import UIKit

class MissionListViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let leftBarButton = UIBarButtonItem(image: UIImage(named: "chevron-left"), style: .plain, target: self, action: #selector(back(_ :)))
        self.navigationItem.leftBarButtonItem = leftBarButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    
    @IBAction func objectMissionBtn(_ sender: UIButton) {
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "ObjectMissionListViewController") as? ObjectMissionListViewController else { return }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func back(_ sender: UIButton) {
        self.presentingViewController?.dismiss(animated: true)
    }
}
