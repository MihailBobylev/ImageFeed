//
//  PhotoResult.swift
//  Image Feed
//
//  Created by Михаил Бобылев on 19.06.2025.
//

import Foundation

struct PhotoResult: Decodable {
    let id: String
    let createdAt: String?
    let width: Int
    let height: Int
    let description: String?
    let likedByUser: Bool
    let urls: UrlsResult
    
    struct UrlsResult: Decodable {
        let full: String
        let thumb: String
    }
    
    private enum CodingKeys: String, CodingKey {
        case id, width, height, description, urls
        case createdAt = "created_at"
        case likedByUser = "liked_by_user"
    }
}
