//
//  ProfilePresenter.swift
//  Image Feed
//
//  Created by Михаил Бобылев on 05.07.2025.
//

import UIKit

public protocol ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol? { get set }
    func updateAvatar()
    func updateUserInfo()
    func logout()
}

final class ProfilePresenter: ProfilePresenterProtocol {
    weak var view: ProfileViewControllerProtocol?
    
    private let profileService: ProfileServiceProtocol
    private let profileImageService: ProfileImageServiceProtocol
    private let profileLogoutService: ProfileLogoutServiceProtocol
    
    init(profileService: ProfileServiceProtocol, profileImageService: ProfileImageServiceProtocol, profileLogoutService: ProfileLogoutServiceProtocol) {
        self.profileService = profileService
        self.profileImageService = profileImageService
        self.profileLogoutService = profileLogoutService
    }
    
    func updateAvatar() {
        guard
            let profileImageURL = profileImageService.avatarURL,
            let url = URL(string: profileImageURL)
        else {
            print("[updateAvatar]: Invalid profileImageURL")
            return
        }
        view?.updateAvatar(url: url)
    }
    
    func updateUserInfo() {
        guard let profile = profileService.profile else {
            print("[ProfileViewController.viewDidAppear]: No saved profile")
            return
        }
        
        view?.updateUserInfo(profile: profile)
        view?.removeGradientPlaceholder()
        updateAvatar()
    }
    
    func logout() {
        profileLogoutService.logout()
    }
}
