//
//  ProfilePresenterSpy.swift
//  Image FeedTests
//
//  Created by Михаил Бобылев on 05.07.2025.
//

import Image_Feed
import Foundation

final class ProfilePresenterSpy: ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol?
    var updateAvatarCalled = false
    var updateUserInfoCalled = false
    
    func updateAvatar() {
        updateAvatarCalled = true
    }
    
    func updateUserInfo() {
        updateUserInfoCalled = true
    }
    
    func logout() {
        
    }
}
