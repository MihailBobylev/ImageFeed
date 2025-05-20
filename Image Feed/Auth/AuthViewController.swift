//
//  AuthViewController.swift
//  Image Feed
//
//  Created by Михаил Бобылев on 18.05.2025.
//

import UIKit

protocol AuthViewControllerDelegate: AnyObject {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String)
}

final class AuthViewController: UIViewController {
    private enum Constants {
        static let navBackButtonImageName = "nav_back_button"
        static let showWebViewSegueIdentifier = "ShowWebView"
    }
    private let oauth2Service = OAuth2Service.shared
    private let oauth2TokenStorage = OAuth2TokenStorage()
    
    weak var delegate: AuthViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBackButton()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.showWebViewSegueIdentifier {
            guard
                let webViewViewController = segue.destination as? WebViewViewController
            else {
                assertionFailure("Failed to prepare for \(Constants.showWebViewSegueIdentifier)")
                return
            }
            webViewViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        navigationController?.popViewController(animated: true)
        fetchOAuthToken(code)
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        navigationController?.popViewController(animated: true)
    }
}

private extension AuthViewController {
    func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: Constants.navBackButtonImageName)
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: Constants.navBackButtonImageName)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = .ypBlack
    }
    
    func fetchOAuthToken(_ code: String) {
        oauth2Service.fetchOAuthToken(code) { [weak self] result in
            guard let self else { return }
            switch result {
            case let .success(token):
                oauth2TokenStorage.token = token
                delegate?.authViewController(self, didAuthenticateWithCode: code)
            case let .failure(error):
                if let error = error as? NetworkError {
                    switch error {
                    case .httpStatusCode(let int):
                        print("Bad status code: \(int)")
                    case .urlRequestError(let error):
                        print("URL request error: \(error)")
                    case .urlSessionError:
                        print("URL session error")
                    }
                } else {
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
    }
}
