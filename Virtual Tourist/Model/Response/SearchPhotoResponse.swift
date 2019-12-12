//
//  SearchPhotoResponse.swift
//  Virtual Tourist
//
//  Created by Saeed Khader on 08/12/2019.
//  Copyright © 2019 Saeed Khader. All rights reserved.
//

import Foundation

struct SearchPhotoResponse: Codable {
    let photos: Photos
}

struct Photos: Codable {
    let page: Int
    let pages: Int
    let perpage: Int
    let total: String
    let photo: [PhotoInfo]
}

struct PhotoInfo: Codable {
    let id: String
    let owner: String
    let secret: String
    let server: String
    let farm: Int
    let title: String
    let ispublic: Int
    let isfriend: Int
    let isfamily: Int
}
