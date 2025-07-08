//
//  ProfileImageServiceMock.swift
//  Image FeedTests
//
//  Created by Михаил Бобылев on 05.07.2025.
//

import Image_Feed
import Foundation

final class ProfileImageServiceMock: ProfileImageServiceProtocol {
    var avatarURL: String?
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, any Error>) -> Void) {
        avatarURL = "https://yandex.ru/"
    }
}
