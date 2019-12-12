//
//  FlickrClient.swift
//  Virtual Tourist
//
//  Created by Saeed Khader on 08/12/2019.
//  Copyright © 2019 Saeed Khader. All rights reserved.
//

import Foundation
import class UIKit.UIImage

class FlickrClient {
    
    
    // MARK: - Auth
    struct Auth {
        static let apiKey = "741b6163cbd1869d5677649ee7770b89"
        static let secret = "668b30868394c640"
    }
    
    // MARK: - Endpoints
    
    enum Endpoints {
        static let base = "https://api.flickr.com/services/rest"
        
        case photoSearch(Double, Double, Int16)
        case getPhoto(PhotoInfo)

        var stringValue: String {
            switch self {
            case .photoSearch(let lat, let lon, let page):
                return Endpoints.base + "?method=flickr.photos.search&api_key=741b6163cbd1869d5677649ee7770b89&accuracy=11&format=json&nojsoncallback=1&per_page=21&page=\(page)&lat=\(lat)&lon=\(lon)"
            case .getPhoto(let photo):
                return "https://farm\(photo.farm).staticflickr.com/\(photo.server)/\(photo.id)_\(photo.secret).jpg"
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    
    // MARK: - HTTP Methods
    
    class func taskForGETRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?)->Void ) {
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }

            do {
                let responseObject = try JSONDecoder().decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil, error)
                }

            }
        }
        task.resume()
    }
    
    
    
    // MARK: - Client Functions
    
    class func photoSearch(lat: Double, lon: Double, page: Int16, completion: @escaping ([String], Error?)->Void ) {
        taskForGETRequest(url: Endpoints.photoSearch(lat, lon, page).url, responseType: SearchPhotoResponse.self) { (response, error) in
            guard let response = response else {
                completion([], error)
                return
            }
            var urls = [String]()
            for photoInfo in response.photos.photo {
                urls.append(Endpoints.getPhoto(photoInfo).stringValue)
            }
            completion(urls, nil)
        }
    }
    
}
