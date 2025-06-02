//
//  ProfileViewController.swift
//  Image Feed
//
//  Created by Михаил Бобылев on 01.05.2025.
//

import UIKit
import SnapKit
import Kingfisher

final class ProfileViewController: UIViewController {
    private enum Constants {
        static let exitImageName = "exit"
    }
    
    private let mainVStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        return stack
    }()
    
    private let hStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        return stack
    }()
    
    private let userPickImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var logoutButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: Constants.exitImageName), for: .normal)
        button.addTarget(self, action: #selector(logoutTap), for: .touchUpInside)
        return button
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 23)
        label.textAlignment = .left
        label.textColor = .ypWhite
        return label
    }()
    
    private let userTagLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textAlignment = .left
        label.textColor = .ypGray
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textAlignment = .left
        label.textColor = .ypWhite
        return label
    }()
    
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private let oauth2TokenStorage = OAuth2TokenStorage.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        
        guard let profile = profileService.profile else {
            print("No saved profile")
            return
        }
        
        updateUserInfo(profile: profile)
        
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self else { return }
                updateAvatar()
            }
        updateAvatar()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        userPickImageView.layer.cornerRadius = userPickImageView.frame.width / 2
        userPickImageView.clipsToBounds = true
    }
    
    @objc func logoutTap(_ sender: Any) {
        print("logoutTap")
    }
}

private extension ProfileViewController {
    func setupUI() {
        view.backgroundColor = UIColor(resource: .ypBlack)
        view.addSubview(mainVStack)
        mainVStack.addArrangedSubview(hStack)
        mainVStack.addArrangedSubview(usernameLabel)
        mainVStack.addArrangedSubview(userTagLabel)
        mainVStack.addArrangedSubview(descriptionLabel)
        
        hStack.addArrangedSubview(userPickImageView)
        hStack.addArrangedSubview(logoutButton)
        
        mainVStack.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(32)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().inset(24)
        }
        
        userPickImageView.snp.makeConstraints { make in
            make.height.width.equalTo(70)
        }
    }
    
    func updateUserInfo(profile: Profile) {
        usernameLabel.text = profile.name
        userTagLabel.text = profile.loginName
        descriptionLabel.text = profile.bio ?? ""
    }
    
    func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL)
        else {
            print("Invalid profileImageURL")
            return
        }
        
        let processor = RoundCornerImageProcessor(cornerRadius: 16)
        userPickImageView.kf.indicatorType = .activity
        userPickImageView.kf.setImage(with: url,
                                      placeholder: UIImage(resource: .placeholder),
                                      options: [.processor(processor)])
    }
}
