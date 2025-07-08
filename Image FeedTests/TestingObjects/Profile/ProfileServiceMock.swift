//
//  ProfileServiceMock.swift
//  Image FeedTests
//
//  Created by Михаил Бобылев on 05.07.2025.
//

import Image_Feed
import Foundation

final class ProfileServiceMock: ProfileServiceProtocol {
    var profile: Profile?
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Image_Feed.Profile, any Error>) -> Void) {
        profile = Profile(username: "testUsername", name: "testName", loginName: "testLoginName", bio: "testBio")
    }
}
