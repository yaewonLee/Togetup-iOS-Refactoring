//
//  OnboardingLottieViewController.swift
//  TogetUp
//
//  Created by 이예원 on 3/31/24.
//

import UIKit

class OnboardingViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    var pages = [UIViewController]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate = self
        configurePages()
        if let firstPage = pages.first {
            setViewControllers([firstPage], direction: .forward, animated: true, completion: nil)
        }
    }
    
    func configurePages() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let pageData = [
            (lottieFileName: "1_onboarding", currentPageNumber: 1, label1String: "찰칵 찍어서 알람 종료", label2String: "지정한 물체를 촬영하면 \nAI가 인식해서 알람을 꺼줘요", buttonTitle: "다음"),
            (lottieFileName: "2_onboarding", currentPageNumber: 2, label1String: "친구와 함께 목표를 향해", label2String: "같은 미션을 수행하는 그룹에 참여해 \n다른 친구의 기록을 보며 의욕 충전", buttonTitle: "다음"),
            (lottieFileName: "3_onboarding", currentPageNumber: 3, label1String: "내 스타일로 앱꾸하기", label2String: "특정 레벨마다 해금되는 다양한 캐릭터와 \n테마로 원하는 화면을 꾸며봐요", buttonTitle: "시작하기")
        ]
        
        for (index, data) in pageData.enumerated() {
            if let pageContentVC = storyboard.instantiateViewController(withIdentifier: "ContentViewController") as? ContentViewController {
                pageContentVC.delegate = self
                pageContentVC.lottieFileName = data.lottieFileName
                pageContentVC.currentPageNumber = data.currentPageNumber
                pageContentVC.label1String = data.label1String
                pageContentVC.label2String = data.label2String
                pageContentVC.buttonTitle = data.buttonTitle
                pageContentVC.isLastPage = index == pageData.count - 1
                pages.append(pageContentVC)
            }
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController), viewControllerIndex > 0 else {
            return nil
        }
        return pages[viewControllerIndex - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController), viewControllerIndex < pages.count - 1 else {
            return nil
        }
        return pages[viewControllerIndex + 1]
    }
}

extension OnboardingViewController: ContentViewControllerDelegate {
    func didFinishOnboarding() {
        AppStatusManager.shared.markAsLaunched()
        if let loginViewController = storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController {
            loginViewController.modalPresentationStyle = .fullScreen
            present(loginViewController, animated: true)
        }
    }
    
    func didTapNextButton(_ sender: ContentViewController) {
        if let currentIndex = pages.firstIndex(of: sender), currentIndex < pages.count - 1 {
            let nextViewController = pages[currentIndex + 1]
            setViewControllers([nextViewController], direction: .forward, animated: true)
        }
    }
}
