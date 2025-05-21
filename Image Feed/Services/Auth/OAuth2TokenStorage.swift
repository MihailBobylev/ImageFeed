//
//  OAuth2TokenStorage.swift
//  Image Feed
//
//  Created by Михаил Бобылев on 20.05.2025.
//

import Foundation

final class OAuth2TokenStorage {
    private enum Keys: String {
        case accessToken
    }
    
    static let shared = OAuth2TokenStorage()
    private let storage: UserDefaults = .standard
    
    var token: String? {
        get {
            storage.string(forKey: Keys.accessToken.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.accessToken.rawValue)
        }
    }
}
