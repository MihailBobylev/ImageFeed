//
//  ProfileViewController.swift
//  Image Feed
//
//  Created by Михаил Бобылев on 01.05.2025.
//

import UIKit
import SnapKit

final class ProfileViewController: UIViewController {
    private enum Constants {
        static let userPickImageName = "userpick"
        static let exitImageName = "exit"
        static let usernameText = "Екатерина Новикова"
        static let usertagText = "@ekaterina_nov"
        static let descriptionText = "Hello, world!"
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
        let imageView = UIImageView(image: UIImage(named: Constants.userPickImageName))
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 16
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
        label.text = Constants.usernameText
        label.font = .systemFont(ofSize: 23)
        label.textAlignment = .left
        label.textColor = .ypWhite
        return label
    }()
    
    private let userTagLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.usertagText
        label.font = .systemFont(ofSize: 13)
        label.textAlignment = .left
        label.textColor = .ypGray
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.descriptionText
        label.font = .systemFont(ofSize: 13)
        label.textAlignment = .left
        label.textColor = .ypWhite
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    @objc func logoutTap(_ sender: Any) {
        print("logoutTap")
    }
}

private extension ProfileViewController {
    func setupUI() {
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
}
