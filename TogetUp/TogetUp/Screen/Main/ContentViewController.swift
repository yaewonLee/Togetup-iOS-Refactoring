//
//  OnboardingViewController.swift
//  TogetUp
//
//  Created by 이예원 on 3/30/24.
//

import UIKit
import Lottie
import SnapKit
import Then

protocol ContentViewControllerDelegate: AnyObject {
    func didTapNextButton(_ sender: ContentViewController)
    func didFinishOnboarding()
}

class ContentViewController: UIViewController {
    private let lottieView = LottieAnimationView()
    var label1 = UILabel().then {
        $0.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 30)
    }
    var label2 = UILabel().then {
        $0.font =  UIFont(name: "AppleSDGothicNeo-Regular", size: 16)
        $0.numberOfLines = 2
        $0.textAlignment = .center
    }
    let nextButton = UIButton().then {
        $0.layer.cornerRadius = 12
        $0.layer.borderWidth = 2
        $0.backgroundColor = UIColor(named: "primary400")
        $0.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 16)
        $0.tintColor = .white
    }
    var currentPageNumberLabel = UILabel().then {
        $0.backgroundColor = .white.withAlphaComponent(0.7)
        $0.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 12)!
        $0.textColor = UIColor(named: "neutral400")
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
        $0.textAlignment = .center
    }
    let bottomView = UIView().then {
        $0.backgroundColor = .white
    }
    
    var lottieFileName = ""
    var currentPageNumber = 1
    var label1String = ""
    var label2String = ""
    var buttonTitle = "다음"
    var backgroundColor = UIColor(named: "primary100")
    
    weak var delegate: ContentViewControllerDelegate?
    var isLastPage = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setConstraints()
        setUpUI()
        setLottieAnimation()
        addActions()
    }
    
    private func setUpUI() {
        self.view.backgroundColor = self.backgroundColor
        self.label1.text = label1String
        self.label2.text = label2String
        
        let fullText = "\(currentPageNumber) / 3"
        let highlightedText = "\(currentPageNumber)"
        
        self.currentPageNumberLabel.text = fullText
        applyColorToText(label: currentPageNumberLabel, fullText: fullText, highlightedText: highlightedText)
        self.nextButton.setTitle(buttonTitle, for: .normal)
    }
    
    private func setLottieAnimation() {
        let animation = LottieAnimation.named(lottieFileName)
        lottieView.animation = animation
        lottieView.loopMode = .playOnce
        lottieView.animationSpeed = 1
        playAnimationWithDelay()
    }
    
    private func playAnimationWithDelay() {
        lottieView.play { [weak self] finished in
            guard finished else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self?.playAnimationWithDelay()
            }
        }
    }
    
    private func applyColorToText(label: UILabel, fullText: String, highlightedText: String) {
        let attributedString = NSMutableAttributedString(string: fullText)
        if let range = fullText.range(of: highlightedText) {
            let nsRange = NSRange(range, in: fullText)
            attributedString.addAttribute(.foregroundColor, value: UIColor.black, range: nsRange)
        }
        label.attributedText = attributedString
    }
    
    private func addActions() {
           nextButton.addTarget(self, action: #selector(nextButtonTapped(_:)), for: .touchUpInside)
       }
    
    @objc func nextButtonTapped(_ sender: UIButton) {
        if isLastPage {
            delegate?.didFinishOnboarding()
        } else {
            delegate?.didTapNextButton(self)
        }
    }
}

extension ContentViewController {
    private func setConstraints() {
        [lottieView, bottomView, currentPageNumberLabel].forEach {
            view.addSubview($0)
        }
        [label1, label2, nextButton].forEach {
            bottomView.addSubview($0)
        }
        
        lottieView.snp.makeConstraints { make in
            if UIScreen.main.bounds.height <= 667 {
                make.height.equalTo(412)
            } else {
                make.left.right.equalToSuperview()
            }
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().priority(.high)
        }
        
        bottomView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.left.right.equalToSuperview()
            make.top.equalTo(lottieView.snp.bottom)
            if UIScreen.main.bounds.height <= 667 {
                make.height.equalTo(255)
            } else {
                make.height.equalTo(342)
            }
            
        }
        
        currentPageNumberLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(24)
            make.width.equalTo(57)
            make.bottom.equalTo(lottieView.snp.bottom).offset(-24)
        }
        
        label1.snp.makeConstraints { make in
            make.height.equalTo(44)
            make.centerX.equalToSuperview()
            if UIScreen.main.bounds.height <= 667 {
                make.top.equalTo(bottomView.snp.top).offset(27)
            } else {
                make.top.equalTo(bottomView.snp.top).offset(40)
            }
        }
        
        label2.snp.makeConstraints { make in
            make.height.equalTo(48)
            make.centerX.equalToSuperview()
            make.top.equalTo(label1.snp.bottom).offset(16)
        }
        
        nextButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(56)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(-24)
        }
        
    }
}
