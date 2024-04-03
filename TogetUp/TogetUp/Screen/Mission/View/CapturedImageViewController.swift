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
    @IBOutlet weak var statusLabelTopMargin: NSLayoutConstraint!
    @IBOutlet weak var successLabelTopMargin: NSLayoutConstraint!
    @IBOutlet weak var levelUpLabel: UILabel!
    @IBOutlet weak var congratLabel: UILabel!
    
    // MARK: - Properties
    var image = UIImage()
    var missionId = 0
    var missionEndpoint: String?
    private let viewModel = MissionProcessViewModel()
    private let disposeBag = DisposeBag()
    private var countdownTimer: Timer?
    private var countdownValue = 5
    private var filePath = ""
    var alarmId = 0
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        capturedImageView.image = image
        customUI()
        postMissionImage()
        setLottieAnimation()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        pointLabel.layer.cornerRadius = 12
        pointLabel.layer.masksToBounds = true
        levelUpLabel.layer.cornerRadius = 12
        levelUpLabel.layer.masksToBounds = true
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
        var missionName: String = ""
        
        switch missionId {
        case 1:
            missionName = "direct-registration"
        case 2:
            missionName = "object-detection"
        case 3:
            missionName = "expression-recognition"
        default:
            print("알 수 없는 미션 ID")
            return
        }
        
        viewModel.sendMissionImage(missionName: missionName, object: self.missionEndpoint, missionImage: image)
            .subscribe(onNext: { response in
                self.handleMissionDetectResponse(response)
                let param = MissionCompleteRequest(alarmId: self.alarmId, missionPicLink: response.result?.filePath ?? "")
                self.completeMission(with: param)
            }, onError: { error in
                print(error.localizedDescription)
            })
            .disposed(by: disposeBag)
    }
    
    private func handleMissionDetectResponse(_ response: MissionDetectResponse) {
        progressView.backgroundColor = UIColor(named: "secondary050")
        progressBar.isHidden = true
        if response.message == "미션을 성공하지 못했습니다." || response.message == "탐지된 객체가 없습니다." {
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
            }
        }
    }
    
    private func completeMission(with param: MissionCompleteRequest) {
        viewModel.completeMission(param: param) { result in
            switch result {
            case .success(let response):
                if let userLevelUp = response.result?.userLevelUp, userLevelUp {
                    self.handleCompleteResponseUI(response)
                }
                self.startCountdown()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func handleCompleteResponseUI(_ response: MissionCompleteResponse) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if response.result?.userLevelUp ?? false {
                self.statusLabel.text = "LEVEL UP"
                self.successLabel.isHidden = true
                self.pointLabel.isHidden = true
                self.levelUpLabel.isHidden = false
                self.congratLabel.isHidden = false
                self.configureLevelUpLabel(userLevel: response.result?.userStat.level ?? 0)
            }
        }
    }
    
    private func configureLevelUpLabel(userLevel: Int) {
        let text = "  \(userLevel - 1) ⭢ \(userLevel)   "
        let attributedString = NSMutableAttributedString(string: text)
        let textLength = text.count
        let startLocation = 5
        
        let range = NSRange(location: startLocation, length: textLength - startLocation)
        attributedString.addAttribute(.foregroundColor, value: UIColor(named: "secondary500")!, range: range)
        
        levelUpLabel.attributedText = attributedString
    }
    
    private func startCountdown() {
        countdownTimer?.invalidate()
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if self.countdownValue > 0 {
                self.countdownValue -= 1
            } else {
                timer.invalidate()
                self.navigateToHome()
            }
        }
    }
    
    private func navigateToHome() {
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
}
