//
//  MissionPerformViewController.swift
//  TogetUp
//
//  Created by 이예원 on 2023/09/24.
//

import UIKit
import RxSwift
import RxCocoa
import AudioToolbox
import AVFoundation

class MissionPerformViewController: UIViewController {
    // MARK: - UI Components
    @IBOutlet weak var alarmAgainButton: UIButton!
    @IBOutlet weak var missionPerformButton: UIButton!
    @IBOutlet weak var iconBackgroundView: UIView!
    @IBOutlet weak var missionBackgroundView: UIView!
    @IBOutlet weak var currentDateLabel: UILabel!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var alarmIconLabel: UILabel!
    @IBOutlet weak var alarmNameLabel: UILabel!
    @IBOutlet weak var missionObjectLabel: UILabel!
    
    // MARK: - Properties
    private let viewModel = MissionPerformViewModel()
    private let disposeBag = DisposeBag()
    var objectEndpoint = ""
    var alarmIcon = ""
    var alarmName = ""
    var missionObject = ""
    var missionId = 0
    var alarmId = 0
    var isSnoozeActivated = false
    var isVibrate: Bool = true
    var audioPlayer: AVAudioPlayer?
    var vibrationTimer: Timer?
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        customUI()
        bindLabels()
        loadSound()
    }
    
    // MARK: - Custom Method
    private func customUI() {    
        if isSnoozeActivated {
            alarmAgainButton.isHidden = false
        }
        
        self.missionPerformButton.layer.cornerRadius = 12
        self.missionPerformButton.layer.borderWidth = 2
        
        self.iconBackgroundView.layer.cornerRadius = 170
        self.iconBackgroundView.layer.borderWidth = 2
        
        self.missionBackgroundView.layer.cornerRadius = 12
        self.missionBackgroundView.layer.borderWidth = 2
        
        self.alarmIconLabel.text = alarmIcon
        self.alarmNameLabel.text = alarmName
        self.missionObjectLabel.text = missionObject
    }
    
    private func bindLabels() {
        viewModel.currentDate
            .bind(to: currentDateLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.currentTime
            .bind(to: currentTimeLabel.rx.text)
            .disposed(by: disposeBag)
    }
    
    private func loadSound() {
        guard let soundURL = Bundle.main.url(forResource: "alarmSound", withExtension: "mp3") else {
            print("File not found")
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.play()
            
            if isVibrate {
                vibrationTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (_) in
                    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                })
            }
        } catch {
            print("Error loading audio file")
        }
    }
    
    private func stopSoundAndVibrate() {
        audioPlayer?.stop()
        audioPlayer?.currentTime = 0
        
        vibrationTimer?.invalidate()
        vibrationTimer = nil
    }
    
    // MARK: - @
    @IBAction func performButtonTapped(_ sender: UIButton) {
        stopSoundAndVibrate()
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .camera
        imagePickerController.allowsEditing = true
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func dismissMissionPage(_ sender: UIButton) {
        stopSoundAndVibrate()
        
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "TabBarViewController") else {
            return
        }
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
}

extension MissionPerformViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true) {
            if let capturedImage = info[.editedImage] as? UIImage {
                if let nextVC = self.storyboard?.instantiateViewController(identifier: "CapturedImageViewController") as? CapturedImageViewController {
                    nextVC.image = capturedImage
                    nextVC.missionEndpoint = self.objectEndpoint
                    nextVC.missionId = self.missionId
                    nextVC.alarmId = self.alarmId
                    self.present(nextVC, animated: true, completion: nil)
                }
            }
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            self.dismiss(animated: true)
        }
    }
}
