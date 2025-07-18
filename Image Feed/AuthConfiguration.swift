//
//  Constants.swift
//  Image Feed
//
//  Created by Михаил Бобылев on 18.05.2025.
//

import Foundation

enum Constants {
    static let accessKey = "OvbjT6lhXnOkSC_c8Os6Y4j_jPv4nYgTElYI-clqu0c"
    static let secretKey = "V9F0jqYRd3rwa2h72kwGhr0TnbQL7bLkJ6dMBDbFF5E"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let defaultBaseURL = URL(string: "https://api.unsplash.com")
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
}

struct AuthConfiguration {
    static var standard: AuthConfiguration {
        return AuthConfiguration(accessKey: Constants.accessKey,
                                 secretKey: Constants.secretKey,
                                 redirectURI: Constants.redirectURI,
                                 accessScope: Constants.accessScope,
                                 defaultBaseURL: Constants.defaultBaseURL,
                                 authURLString: Constants.unsplashAuthorizeURLString)
    }
    
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaultBaseURL: URL?
    let authURLString: String
}
