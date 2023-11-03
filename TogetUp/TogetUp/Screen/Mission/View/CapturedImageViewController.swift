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
    @IBOutlet weak var pointLabel: UILabel!
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var goHomeButton: UIButton!
    @IBOutlet weak var goGroupButton: UIButton!
    
    
    @IBOutlet weak var statusLabelTopMargin: NSLayoutConstraint!
    @IBOutlet weak var successLabelTopMargin: NSLayoutConstraint!
    
    // MARK: - Properties
    var image = UIImage()
    var missionId = 0
    var missionEndpoint = ""
    private let viewModel = MissionProcessViewModel()
    private let disposeBag = DisposeBag()
    var countdownTimer: Timer?
    var countdownValue = 5
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        capturedImageView.image = image
        customUI()
        print("missionId: \(missionId), endPoint: \(missionEndpoint)")
        
        if missionId == 1 {
            progressView.backgroundColor = UIColor(named: "secondary050")
            successLabel.isHidden = true
            statusLabel.text = "미션 성공🎉"
            successLabel.isHidden = false
            pointLabel.isHidden = false
        } else {
            postMissionImage()
            setLottieAnimation()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        pointLabel.layer.cornerRadius = 12
        pointLabel.layer.masksToBounds = true
    }
    
    // MARK: - Custom Method
    private func customUI() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.progressView.isHidden = false
        }
        progressView.layer.cornerRadius = 12
        progressView.layer.borderWidth = 2
        goHomeButton.layer.cornerRadius = 12
        goHomeButton.layer.borderWidth = 2
        goGroupButton.layer.cornerRadius = 12
        goGroupButton.layer.borderWidth = 2
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
            statusLabel.text = "미션 성공🎉"
            successLabel.isHidden = false
            progressView.isHidden = false
            pointLabel.isHidden = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                self.progressView.isHidden = true
                let url = URL(string: response.result!.filePath)!
                self.capturedImageView.load(url: url)
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.successLabel.text = ""
                    self.progressView.isHidden = false
                    self.successLabel.isHidden = false
                    self.successLabelTopMargin.constant = 5
                    self.successLabel.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 12)
                    self.successLabel.textColor = UIColor(named: "neutral400")
                    self.statusLabelTopMargin.constant = 24
                    self.successLabel.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 16)
                    self.pointLabel.isHidden = true
                    self.stackView.isHidden = false
                    self.statusLabel.text = "그룹 게시판 업로드 완료"
                    self.startCountdown()
                }
            }
        }
    }
    
    func startCountdown() {
        countdownTimer?.invalidate()
        
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if self.countdownValue > 0 {
                self.successLabel.text = "\(self.countdownValue)초후 자동으로 홈 이동"
                self.countdownValue -= 1
            } else {
                timer.invalidate()
                self.navigateToHome()
            }
        }
    }
    
    func navigateToHome() {
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "TabBarViewController") else {
            return
        }
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
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
    
    @IBAction func moveToGroupBoard(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Group", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "GroupListViewController") as? GroupListViewController {
            let navigationController = UINavigationController(rootViewController: vc)
            navigationController.modalPresentationStyle = .fullScreen
            self.present(navigationController, animated: true, completion: nil)
        }
    }
}
