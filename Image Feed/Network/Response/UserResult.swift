//
//  UserResult.swift
//  Image Feed
//
//  Created by Михаил Бобылев on 31.05.2025.
//

import Foundation

struct UserResult: Codable {
    let profileImage: ProfileImage?
    
    private enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}

struct ProfileImage: Codable {
    let small: String?
}
