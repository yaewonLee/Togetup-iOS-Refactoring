//
//  OnboardingViewController.swift
//  TogetUp
//
//  Created by 이예원 on 3/30/24.
//

import UIKit
import Lottie

protocol ContentViewControllerDelegate: class {
    func didTapNextButton(_ sender: ContentViewController)
    func didFinishOnboarding()
}

class ContentViewController: UIViewController {
    @IBOutlet weak var lottieView: LottieAnimationView!
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var currentPageNumberLabel: UILabel!
    
    var lottieFileName = ""
    var currentPageNumber = 1
    var label1String = ""
    var label2String = ""
    var buttonTitle = "다음"
    private lazy var fullText = "\(currentPageNumber) / 3"
    private lazy var highlightedText = "\(currentPageNumber)"
    weak var delegate: ContentViewControllerDelegate?
    var isLastPage = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        setLottieAnimation()
    }
    
    private func setUpUI() {
        self.label1.text = label1String
        self.label2.text = label2String
        self.nextButton.layer.cornerRadius = 12
        self.nextButton.layer.borderWidth = 2
        self.currentPageNumberLabel.text = fullText
        
        applyColorToText(label: currentPageNumberLabel, fullText: fullText, highlightedText: highlightedText)
        self.currentPageNumberLabel.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 12)!
        self.currentPageNumberLabel.layer.cornerRadius = 12
        self.currentPageNumberLabel.clipsToBounds = true
        self.nextButton.setTitle(buttonTitle, for: .normal)
    }
    
    private func setLottieAnimation() {
        let animation = LottieAnimation.named(lottieFileName)
        lottieView.animation = animation
        lottieView.loopMode = .playOnce
        lottieView.animationSpeed = 1
        lottieView.play()
    }
    
    private func applyColorToText(label: UILabel, fullText: String, highlightedText: String) {
        let attributedString = NSMutableAttributedString(string: fullText)
        if let range = fullText.range(of: highlightedText) {
            let nsRange = NSRange(range, in: fullText)
            attributedString.addAttribute(.foregroundColor, value: UIColor.black, range: nsRange)
        }
        label.attributedText = attributedString
    }
    
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        if isLastPage {
            delegate?.didFinishOnboarding()
        } else {
            delegate?.didTapNextButton(self)
        }
    }
}
