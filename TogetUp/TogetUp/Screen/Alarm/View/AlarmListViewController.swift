//
//  ViewController.swift
//  TogetUp
//
//  Created by 이예원 on 2023/08/14.
//

import UIKit

class AlarmListViewController: UIViewController {
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // customUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpNavigationBar()
    }
    
    private func setUpNavigationBar() {
        let titleLabel = UILabel()
        titleLabel.textColor = UIColor.black
        titleLabel.text = "알람"
        titleLabel.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 26)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: titleLabel)
        
    }
    
    private func customUI() {
    }
    
    
    @IBAction func createAlarmBtnTapped(_ sender: Any) {
        guard let vc = storyboard?.instantiateViewController(identifier: "CreateAlarmViewController") as? CreateAlarmViewController else { return }
        let navigationController = UINavigationController(rootViewController: vc)
        navigationController.modalPresentationStyle = .fullScreen
        navigationController.isNavigationBarHidden = true
        navigationController.navigationBar.backgroundColor = .clear
        navigationController.interactivePopGestureRecognizer?.isEnabled = true


        present(navigationController, animated: true)
    }
    
}

