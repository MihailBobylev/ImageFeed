//
//  ProfileViewController.swift
//  Image Feed
//
//  Created by Михаил Бобылев on 01.05.2025.
//

import UIKit
import SnapKit
import Kingfisher

public protocol ProfileViewControllerProtocol: AnyObject {
    var presenter: ProfilePresenterProtocol? { get set }
    func configure(_ presenter: ProfilePresenterProtocol)
    func updateAvatar(url: URL)
    func updateUserInfo(profile: Profile)
    func removeGradientPlaceholder()
}

final class ProfileViewController: UIViewController, ProfileViewControllerProtocol {
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
        button.accessibilityIdentifier = "logoutButton"
        button.setImage(UIImage(resource: .exit), for: .normal)
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
    
    private var profileImageServiceObserver: NSObjectProtocol?
    private var userPickAnimationLayer: CALayer?
    private var animationLayers = Set<CALayer>()
    private var isGradientAdded = false
    
    var presenter: ProfilePresenterProtocol?
    
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
                presenter?.updateAvatar()
            }
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        userPickImageView.layer.cornerRadius = userPickImageView.frame.width / 2
        userPickImageView.clipsToBounds = true
        
        if !isGradientAdded {
            makeGradientLayer()
            isGradientAdded = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter?.updateUserInfo()
    }
    
    func configure(_ presenter: ProfilePresenterProtocol) {
        self.presenter = presenter
        self.presenter?.view = self
    }
    
    @objc func logoutTap(_ sender: Any) {
        AlertPresenter.showLogoutAlert(in: self) { [weak self] in
            self?.presenter?.logout()
        }
    }
}

extension ProfileViewController {
    func updateAvatar(url: URL) {
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
    
    func updateUserInfo(profile: Profile) {
        usernameLabel.text = profile.name
        userTagLabel.text = profile.loginName
        descriptionLabel.text = profile.bio ?? ""
    }
    
    func removeGradientPlaceholder() {
        animationLayers.forEach { gradLayer in
            gradLayer.removeFromSuperlayer()
        }
        animationLayers.removeAll()
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
    
    func makeGradientLayer() {
        userPickAnimationLayer = userPickImageView.addGradientPlaceholder(in: CGRect(origin: .zero, size: CGSize(width: 70, height: 70)), withRadius: 35)
        animationLayers.insert(usernameLabel.addGradientPlaceholder(in: CGRect(origin: .zero, size: CGSize(width: 223, height: 18)), withRadius: 9))
        animationLayers.insert(userTagLabel.addGradientPlaceholder(in: CGRect(origin: CGPoint(x: 0, y: 20), size: CGSize(width: 89, height: 18)), withRadius: 9))
        animationLayers.insert(descriptionLabel.addGradientPlaceholder(in: CGRect(origin: CGPoint(x: 0, y: 40), size: CGSize(width: 67, height: 18)), withRadius: 9))
    }
}
