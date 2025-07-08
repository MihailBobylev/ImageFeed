//
//  ProfileLogoutServiceMock.swift
//  Image FeedTests
//
//  Created by Михаил Бобылев on 05.07.2025.
//

import Image_Feed
import Foundation

final class ProfileLogoutServiceMock: ProfileLogoutServiceProtocol {
    var logoutCalled = false
    
    func logout() {
        logoutCalled = true
    }
}
