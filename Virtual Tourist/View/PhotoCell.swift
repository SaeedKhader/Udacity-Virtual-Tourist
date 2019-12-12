//
//  PhotoCell.swift
//  Virtual Tourist
//
//  Created by Saeed Khader on 07/12/2019.
//  Copyright © 2019 Saeed Khader. All rights reserved.
//

import Foundation
import UIKit

class PhotoCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var checkedIcon: UIImageView!
    
    var blurEffectView = UIVisualEffectView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.layer.cornerRadius = 10
        blurEffectView.clipsToBounds = true
        blurEffectView.alpha = 0
        imageView.addSubview(blurEffectView)
        
        imageView.layer.cornerRadius = 10
    }
    
    func setUpStyle(selected: Bool){
        UIView.animate(withDuration: 0.3) {
            self.checkedIcon.alpha = selected ? 1 : 0
            self.blurEffectView.alpha = selected ? 1 : 0
        }
    }
    
    func getPhoto(photo: Photo) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate

        if let photoData = photo.data {
            self.imageView.image = UIImage(data: photoData)
        } else {
            self.imageView.kf.indicatorType = .activity
            self.imageView.kf.setImage(with: URL(string: photo.url!), placeholder: UIImage(named: "placeholder"), options: [ .transition(.fade(0.5)), .memoryCacheExpiration(.expired)], progressBlock: nil) { (reults) in
                switch reults {
                case .success(let value):
                    photo.data = value.image.jpegData(compressionQuality: 1)
                    try? appDelegate.dataController.viewContext.save()
                case .failure(let error):
                    _ = error
                }
            }
        }
    }
}
