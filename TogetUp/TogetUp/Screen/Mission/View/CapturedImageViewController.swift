//
//  CapturedImageViewController.swift
//  TogetUp
//
//  Created by 이예원 on 2023/09/25.
//

import UIKit
import RxSwift

class CapturedImageViewController: UIViewController {
    // MARK: - UI Components
    @IBOutlet weak var capturedImageView: UIImageView!
    
    // MARK: - Properties
    var image = UIImage()
    private let viewModel = MissionProcessViewModel()
    private let disposeBag = DisposeBag()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.capturedImageView.image = image
        postMissionImage()
    }
    
    // MARK: - Custom Method
    private func postMissionImage() {
        viewModel.sendMissionImage(objectName: "object-detection/potted plant", missionImage: image)
            .subscribe(onNext: { response in
                print(response)
            }, onError: { error in
                print(error.localizedDescription)
            })
            .disposed(by: disposeBag)
    }
}
