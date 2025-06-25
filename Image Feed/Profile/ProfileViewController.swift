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
    private var userPickAnimationLayer: CALayer?
    private var animationLayers = Set<CALayer>()
    private var isGradientAdded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self else { return }
                updateAvatar()
            }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        userPickImageView.layer.cornerRadius = userPickImageView.frame.width / 2
        userPickImageView.clipsToBounds = true
        
        if !isGradientAdded {
            makeGradientLayer()
            isGradientAdded = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let profile = profileService.profile else {
            print("[ProfileViewController.viewDidAppear]: No saved profile")
            return
        }
        
        updateUserInfo(profile: profile)
        removeGradientPlaceholder()
        updateAvatar()
    }
    
    @objc func logoutTap(_ sender: Any) {
        AlertPresenter.showLogoutAlert(in: self) {
            ProfileLogoutService.shared.logout()
        }
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
            print("[updateAvatar]: Invalid profileImageURL")
            return
        }
        
        let processor = RoundCornerImageProcessor(cornerRadius: 16)
        userPickImageView.kf.indicatorType = .activity
        userPickImageView.kf.setImage(with: url,
                                      options: [.processor(processor)]) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                userPickAnimationLayer?.removeFromSuperlayer()
                userPickAnimationLayer = nil
            case .failure(let error):
                print("[updateAvatar]: \(error)")
            }
        }
    }
    
    func makeGradientLayer() {
        userPickAnimationLayer = addGradientPlaceholder(to: userPickImageView,
                                                        in: CGRect(origin: .zero, size: CGSize(width: 70, height: 70)),
                                                        withRadius: 35)
        animationLayers.insert(addGradientPlaceholder(to: usernameLabel,
                                                      in: CGRect(origin: .zero, size: CGSize(width: 223, height: 18)),
                                                      withRadius: 9))
        animationLayers.insert(addGradientPlaceholder(to: userTagLabel,
                                                      in: CGRect(origin: CGPoint(x: 0, y: 20), size: CGSize(width: 89, height: 18)),
                                                      withRadius: 9))
        animationLayers.insert(addGradientPlaceholder(to: descriptionLabel,
                                                      in: CGRect(origin: CGPoint(x: 0, y: 40), size: CGSize(width: 67, height: 18)),
                                                      withRadius: 9))
    }
    
    func addGradientPlaceholder(to view: UIView, in rect: CGRect, withRadius radius: CGFloat) -> CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.frame = rect
        gradient.locations = [0, 0.1, 0.3]
        gradient.colors = [
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor,
            UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 1).cgColor,
            UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.cornerRadius = radius
        gradient.masksToBounds = true
        
        let gradientChangeAnimation = CABasicAnimation(keyPath: "locations")
        gradientChangeAnimation.duration = 1.0
        gradientChangeAnimation.repeatCount = .infinity
        gradientChangeAnimation.fromValue = [0, 0.1, 0.3]
        gradientChangeAnimation.toValue = [0, 0.8, 1]
        gradient.add(gradientChangeAnimation, forKey: "locationsChange")
        
        view.layer.addSublayer(gradient)
        
        return gradient
    }
    
    func removeGradientPlaceholder() {
        animationLayers.forEach { gradLayer in
            gradLayer.removeFromSuperlayer()
        }
        animationLayers.removeAll()
    }
}
