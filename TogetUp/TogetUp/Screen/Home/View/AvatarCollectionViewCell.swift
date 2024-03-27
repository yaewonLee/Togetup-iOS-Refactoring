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
    @IBOutlet weak var newLabel: UIImageView!
    
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
        let currentUserLevel = UserDataManager.shared.currentUserData?.userStat.level ?? 1
        
        if let theme = ThemeManager.shared.themes.first(where: { $0.koreanName == model.theme }) {
            newLabel.isHidden = !theme.isNew
            
            let currentUserLevel = UserDataManager.shared.currentUserData?.userStat.level ?? 1
            let image = UIImage(named: isSelected ? theme.collectionViewAvatarName : theme.collectionViewAvatarName)
            
            if currentUserLevel < model.unlockLevel {
                avatarImageView.image = image.map { convertToBlackAndWhite(image: $0) ?? UIImage() }
            } else {
                avatarImageView.image = image
            }
            
            if isSelected {
                avatarBackView.layer.borderWidth = 2
                checkImageView.tintColor = .black
                avatarBackView.backgroundColor = UIColor(named: theme.colorName)
                newLabel.isHidden = true
                ThemeManager.shared.updateIsNewStatusForAvatar(withId: theme.avatarId, toNewStatus: false)
            } else {
                avatarBackView.layer.borderWidth = 0
                avatarBackView.backgroundColor = UIColor(named: "neutral100")
                checkImageView.tintColor = UIColor(named: "neutral200")
            }
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
