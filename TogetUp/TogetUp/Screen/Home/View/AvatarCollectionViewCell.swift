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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 12
        avatarBackView.layer.cornerRadius = 12
        self.clipsToBounds = true
    }
    
    func setAttributes(with model: AvatarResult, isSelected: Bool) {
        let themeToImageName: [String: String] = [
            "신입 병아리": "c_chick",
            "눈을 반짝이는 곰돌이": "c_bear",
            "깜찍한 토끼": "c_rabbit"
        ]
        
        let themeToColorName: [String: String] = [
            "신입 병아리": "chick",
            "눈을 반짝이는 곰돌이": "bear",
            "깜찍한 토끼": "rabbit"
        ]
        
        if let imageName = themeToImageName[model.theme] {
            avatarImageView.image = UIImage(named: imageName)
        }
        
        if isSelected {
            if let colorName = themeToColorName[model.theme] {
                avatarBackView.backgroundColor = UIColor(named: colorName)
            }
        } else {
            avatarBackView.backgroundColor = UIColor(named: "neutral100")
        }
    }
}
