//
//  TitleLabel.swift
//  Virtual Tourist
//
//  Created by Saeed Khader on 07/12/2019.
//  Copyright © 2019 Saeed Khader. All rights reserved.
//

import Foundation
import UIKit

class TitleView: UIView {
        
    override func awakeFromNib() {
        super.awakeFromNib()

        let label = UILabel()
        label.text = "Virtual Tourist"
        label.tintColor = .black
        label.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        label.frame = CGRect(x: 0, y: 0, width: 200, height: 50)
        
        let blurEffect = UIBlurEffect(style: .regular)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.layer.cornerRadius = 10
        blurEffectView.clipsToBounds = true
        self.addSubview(blurEffectView)
        
        self.addSubview(label)
        
        label.center = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        
    }
}
