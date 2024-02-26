//
//  AvatarCollectionViewCell.swift
//  TogetUp
//
//  Created by 이예원 on 11/27/23.
//

import UIKit

class AvatarCollectionViewCell: UICollectionViewCell {
    static let identifier = "AvatarCollectionViewCell"
    
    @IBOutlet weak var avatarBackView: UIImageView!
    @IBOutlet weak var checkImageView: UIImageView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var unlockLevelLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        customUI()
    }
    
    private func customUI() {
        self.layer.cornerRadius = 12
        self.clipsToBounds = true
        avatarBackView.layer.cornerRadius = 12

    }
    
    func setAttributes(with model: AvatarResult, isSelected: Bool, unlockLevel: Int) {
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
        
        if let imageName = themeToImageName[model.theme] {
            avatarImageView.image = UIImage(named: imageName)
        }
        
        if isSelected {
            avatarBackView.layer.borderWidth = 2
            if let colorName = themeToColorName[model.theme] {
                avatarBackView.backgroundColor = UIColor(named: colorName)
            }
        } else {
            avatarBackView.layer.borderWidth = 0
            avatarBackView.backgroundColor = UIColor(named: "neutral100")
        }
        unlockLevelLabel.text = "Lv.\(unlockLevel)"
    }
}
