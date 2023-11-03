//
//  HomeViewController.swift
//  TogetUp
//
//  Created by 이예원 on 2023/08/18.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var coinView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customUI()
    }
    
    private func customUI() {
        progressBar.layer.cornerRadius = 5

        progressBar.clipsToBounds = true
        progressBar.layer.borderWidth = 2

        progressBar.layer.sublayers![1].cornerRadius = 5
        progressBar.layer.sublayers![1].borderWidth = 2
        progressBar.subviews[1].clipsToBounds = true
        
        coinView.layer.cornerRadius = 14
    }
}
