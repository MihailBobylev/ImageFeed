//
//  Profile.swift
//  Image Feed
//
//  Created by Михаил Бобылев on 31.05.2025.
//

import Foundation

public struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String?
    
    public init(username: String, name: String, loginName: String, bio: String?) {
        self.username = username
        self.name = name
        self.loginName = loginName
        self.bio = bio
    }
}
