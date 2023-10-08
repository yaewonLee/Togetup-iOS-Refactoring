//
//  CapturedImageViewController.swift
//  TogetUp
//
//  Created by 이예원 on 2023/09/25.
//

import UIKit
import RxSwift
import Lottie

class CapturedImageViewController: UIViewController {
    // MARK: - UI Components
    @IBOutlet weak var capturedImageView: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var progressBar: LottieAnimationView!
    @IBOutlet weak var progressView: UIView!
    @IBOutlet weak var filmAgainButton: UIButton!
    @IBOutlet weak var successLabel: UILabel!
    
    
    // MARK: - Properties
    var image = UIImage()
    var missionId = 0
    var missionEndpoint = ""
    private let viewModel = MissionProcessViewModel()
    private let disposeBag = DisposeBag()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        capturedImageView.image = image
        customUI()
        print("missionId: \(missionId), endPoint: \(missionEndpoint)")
        
        if missionId == 1 {
            progressView.backgroundColor = UIColor(named: "secondary050")
            successLabel.isHidden = true
            showSuccessView()
        } else {
            postMissionImage()
            setLottieAnimation()
        }
    }
    
    // MARK: - Custom Method
    private func customUI() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.progressView.isHidden = false
        }
        progressView.layer.cornerRadius = 12
        progressView.layer.borderWidth = 2
    }
    
    private func postMissionImage() {
        let endPoint = missionId == 2 ? "object-detection/\(missionEndpoint)" : "face-recognition/\(missionEndpoint)"
        viewModel.sendMissionImage(objectName: endPoint, missionImage: image)
            .subscribe(onNext: { response in
                print(response)
                self.handleResponse(response)
            }, onError: { error in
                print(error.localizedDescription)
            })
            .disposed(by: disposeBag)
    }
    
    private func handleResponse(_ response: MissionDetectResponse) {
        progressView.backgroundColor = UIColor(named: "secondary050")
        progressBar.isHidden = true
        if response.message == "미션을 성공하지 못했습니다." {
            statusLabel.text = "인식에 실패했어요😢"
            filmAgainButton.isHidden = false
        } else {
            let url = URL(string: response.result!.filePath)!
            self.capturedImageView.load(url: url)
            showSuccessView()
        }
    }
    
    private func showSuccessView() {
        statusLabel.text = "미션 성공🎉"
        successLabel.isHidden = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "TabBarViewController") else {
                return
            }
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true)
        }
    }
    
    private func setLottieAnimation() {
        let animation = LottieAnimation.named("progress")
        progressBar.animation = animation
        progressBar.loopMode = .loop
        progressBar.animationSpeed = 1
        progressBar.play()
    }
    
    // MARK: - @
    @IBAction func filmAgainButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
}
