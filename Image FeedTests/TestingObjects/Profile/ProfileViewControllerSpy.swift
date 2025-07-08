//
//  ProfileViewControllerSpy.swift
//  Image FeedTests
//
//  Created by Михаил Бобылев on 05.07.2025.
//

import Image_Feed
import Foundation

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var presenter: Image_Feed.ProfilePresenterProtocol?
    var updateAvatarCalled = false
    var updateUserInfoCalled = false
    
    func updateAvatar(url: URL) {
        updateAvatarCalled = true
    }
    
    func updateUserInfo(profile: Profile) {
        updateUserInfoCalled = true
    }
    
    func removeGradientPlaceholder() {
        
    }
    
    func configure(_ presenter: ProfilePresenterProtocol) {
        
    }
}
