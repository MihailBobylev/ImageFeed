//
//  ProfileLogoutService.swift
//  Image Feed
//
//  Created by Михаил Бобылев on 24.06.2025.
//

import Foundation
import WebKit

public protocol ProfileLogoutServiceProtocol {
    func logout()
}

final class ProfileLogoutService: ProfileLogoutServiceProtocol {
    static let shared = ProfileLogoutService()
    
    private init() { }
    
    func logout() {
        ProfileService.shared.cleanProfileInfo()
        ProfileImageService.shared.cleanAvatarInfo()
        ImagesListService.shared.cleanPhotos()
        OAuth2TokenStorage.shared.token = nil
        cleanCookies()
        
        returnToSplashScreen()
    }
}

private extension ProfileLogoutService {
    func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
    
    func returnToSplashScreen() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("[returnToSplashScreen]: Invalid Configuration")
            return
        }
        window.rootViewController = SplashViewController()
    }
}
