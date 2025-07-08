//
//  TabBarController.swift
//  Image Feed
//
//  Created by Михаил Бобылев on 01.06.2025.
//

import UIKit

final class TabBarController: UITabBarController {
    private enum Constants {
        static let imageListVC = "ImagesListViewController"
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        guard let imagesListViewController = storyboard.instantiateViewController(withIdentifier: Constants.imageListVC) as? ImagesListViewController else {
            assertionFailure("Failed to prepare for \(Constants.imageListVC)")
            return
        }
        let imageListService = ImagesListService.shared
        let oauth2TokenStorage = OAuth2TokenStorage()
        let imageListPresenter = ImagesListPresenter(imagesListService: imageListService,
                                                     oauth2TokenStorage: oauth2TokenStorage)
        imagesListViewController.configure(imageListPresenter)
        
        let profileViewController = ProfileViewController()
        let profileService = ProfileService.shared
        let profileImageService = ProfileImageService.shared
        let profileLogoutService = ProfileLogoutService.shared
        let profilePresenter = ProfilePresenter(profileService: profileService,
                                                profileImageService: profileImageService,
                                                profileLogoutService: profileLogoutService)
        profileViewController.configure(profilePresenter)
        profileViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(resource: .tabProfileActive),
            selectedImage: nil
        )
        self.viewControllers = [imagesListViewController, profileViewController]
    }
}
