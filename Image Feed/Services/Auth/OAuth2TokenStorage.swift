//
//  OAuth2TokenStorage.swift
//  Image Feed
//
//  Created by Михаил Бобылев on 20.05.2025.
//

import Foundation
import SwiftKeychainWrapper

public protocol OAuth2TokenStorageProtocol {
    var token: String? { get set }
}

final class OAuth2TokenStorage: OAuth2TokenStorageProtocol {
    private enum Keys: String {
        case accessToken
    }
    
    static let shared = OAuth2TokenStorage()
    private let storage: KeychainWrapper = .standard
    
    var token: String? {
        get {
            storage.string(forKey: Keys.accessToken.rawValue)
        }
        set {
            guard let newValue else {
                storage.removeObject(forKey: Keys.accessToken.rawValue)
                return
            }
            storage.set(newValue, forKey: Keys.accessToken.rawValue)
        }
    }
}
