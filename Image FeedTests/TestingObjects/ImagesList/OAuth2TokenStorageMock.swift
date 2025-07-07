//
//  OAuth2TokenStorageMock.swift
//  Image FeedTests
//
//  Created by Михаил Бобылев on 06.07.2025.
//

import Image_Feed

final class OAuth2TokenStorageMock: OAuth2TokenStorageProtocol {
    var token: String? = "mock_token"
}
