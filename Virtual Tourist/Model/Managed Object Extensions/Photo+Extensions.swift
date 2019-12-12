//
//  Photo+Extensions.swift
//  Virtual Tourist
//
//  Created by Saeed Khader on 12/12/2019.
//  Copyright © 2019 Saeed Khader. All rights reserved.
//

import Foundation

extension Photo {
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        creationDate = Date()
    }
}
