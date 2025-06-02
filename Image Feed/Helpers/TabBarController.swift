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
        let imagesListViewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController")
        let profileViewController = ProfileViewController()
        profileViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(resource: .tabProfileActive),
            selectedImage: nil
        )
        self.viewControllers = [imagesListViewController, profileViewController]
    }
}
