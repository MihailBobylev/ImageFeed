//
//  SplashViewController.swift
//  Image Feed
//
//  Created by Михаил Бобылев on 20.05.2025.
//

import UIKit
import SnapKit

final class SplashViewController: UIViewController {
    private let logoImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(resource: .splashScreenLogo))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let oauth2TokenStorage = OAuth2TokenStorage.shared
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        if let token = oauth2TokenStorage.token {
            fetchProfile(authToken: token)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if oauth2TokenStorage.token == nil {
            let storyboard = UIStoryboard(name: "Main", bundle: .main)
            guard let authVC = storyboard.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else {
                print("Error in finding: AuthViewController")
                return
            }
            authVC.delegate = self
            let navVC = UINavigationController(rootViewController: authVC)
            navVC.modalPresentationStyle = .fullScreen
            present(navVC, animated: true)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid Configuration")
            return
        }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        vc.dismiss(animated: true) { [weak self] in
            guard let self else { return }
            guard let token = oauth2TokenStorage.token else {
                print("[didAuthenticateWithCode]: No auth token")
                return
            }
            
            fetchProfile(authToken: token)
        }
    }
}

private extension SplashViewController {
    func setupUI() {
        view.backgroundColor = UIColor(resource: .ypBlack)
        view.addSubview(logoImageView)
        
        logoImageView.snp.makeConstraints { make in
            make.height.equalTo(78)
            make.width.equalTo(75)
            make.center.equalToSuperview()
        }
    }
    
    func fetchProfile(authToken: String) {
        UIBlockingProgressHUD.show()
        profileService.fetchProfile(authToken) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            guard let self else { return }
            switch result {
            case .success(let profile):
                fetchProfileImageURL(username: profile.username)
                switchToTabBarController()
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func fetchProfileImageURL(username: String) {
        profileImageService.fetchProfileImageURL(username: username) { result in
            switch result {
            case .success:
                break
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }
    }
}
