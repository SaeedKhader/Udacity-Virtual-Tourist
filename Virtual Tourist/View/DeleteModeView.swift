//
//  DeleteModeView.swift
//  Virtual Tourist
//
//  Created by Saeed Khader on 08/12/2019.
//  Copyright © 2019 Saeed Khader. All rights reserved.
//

import Foundation
import UIKit

class DeleteModeView: UIView {
        
    override func awakeFromNib() {
        super.awakeFromNib()

        let label = UILabel()
        label.text = "Tap Pin To Delete"
        label.textColor = .systemRed
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        label.frame = CGRect(x: 0, y: 0, width: 200, height: 45)
        
        let redBGView = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        redBGView.layer.backgroundColor = #colorLiteral(red: 1, green: 0.2380615771, blue: 0.2715646029, alpha: 0.2031517551)
        redBGView.layer.cornerRadius = 20
        
        self.addSubview(redBGView)
        
        let blurEffect = UIBlurEffect(style: .regular)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.layer.cornerRadius = 20
        blurEffectView.clipsToBounds = true
        self.addSubview(blurEffectView)
        
        self.addSubview(label)
        
        label.center = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        
    }
}
