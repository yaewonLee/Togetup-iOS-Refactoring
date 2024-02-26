//
//  AvatarCollectionViewCell.swift
//  TogetUp
//
//  Created by 이예원 on 11/27/23.
//

import UIKit
import CoreImage

class AvatarCollectionViewCell: UICollectionViewCell {
    static let identifier = "AvatarCollectionViewCell"
    
    @IBOutlet weak var avatarBackView: UIImageView!
    @IBOutlet weak var checkImageView: UIImageView!
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var unlockLevelLabel: UILabel!
    @IBOutlet weak var unlockLabelStackView: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        customUI()
    }
    
    private func customUI() {
        self.layer.cornerRadius = 12
        self.clipsToBounds = true
        avatarBackView.layer.cornerRadius = 12
    }
    
    func setAttributes(with model: AvatarResult, isSelected: Bool) {
        let themeToImageName: [String: String] = [
            "신입 병아리": "c_chick",
            "눈을 반짝이는 곰돌이": "c_bear",
            "깜찍한 토끼": "c_rabbit",
            "먹보 판다": "c_panda",
            "비 오는날 강아지": "c_puppy",
            "철학자 너구리": "c_racoon"
        ]
        
        let themeToColorName: [String: String] = [
            "신입 병아리": "chick",
            "눈을 반짝이는 곰돌이": "bear",
            "깜찍한 토끼": "rabbit",
            "먹보 판다": "panda",
            "비 오는날 강아지": "puppy",
            "철학자 너구리": "racoon"
        ]
        let currentUserLevel = UserDataManager.shared.currentUserData?.userStat.level ?? 1
        
        if let imageName = themeToImageName[model.theme], let image = UIImage(named: imageName) {
            let currentUserLevel = UserDataManager.shared.currentUserData?.userStat.level ?? 1
            
            if currentUserLevel < model.unlockLevel {
                avatarImageView.image = convertToBlackAndWhite(image: image)
            } else {
                avatarImageView.image = image
            }
        }
        
        if isSelected {
            avatarBackView.layer.borderWidth = 2
            checkImageView.tintColor = .black
            if let colorName = themeToColorName[model.theme] {
                avatarBackView.backgroundColor = UIColor(named: colorName)
            }
        } else {
            avatarBackView.layer.borderWidth = 0
            avatarBackView.backgroundColor = UIColor(named: "neutral100")
            checkImageView.tintColor = UIColor(named: "neutral200")
        }
        
        unlockLevelLabel.text = "Lv.\(model.unlockLevel)"
        
        self.isUserInteractionEnabled = currentUserLevel >= model.unlockLevel
        self.checkImageView.isHidden = currentUserLevel < model.unlockLevel
        self.unlockLabelStackView.isHidden = currentUserLevel >= model.unlockLevel
    }
    
    func convertToBlackAndWhite(image: UIImage) -> UIImage? {
        guard let ciImage = CIImage(image: image) else { return nil }
        
        let filter = CIFilter(name: "CIColorControls")
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        filter?.setValue(0.0, forKey: kCIInputSaturationKey)
        
        if let outputCIImage = filter?.outputImage,
           let outputCGImage = CIContext(options: nil).createCGImage(outputCIImage, from: outputCIImage.extent) {
            return UIImage(cgImage: outputCGImage)
        }
        return nil
    }    
}
