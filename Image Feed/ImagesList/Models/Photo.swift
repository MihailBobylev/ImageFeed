//
//  Photo.swift
//  Image Feed
//
//  Created by Михаил Бобылев on 19.06.2025.
//

import Foundation

public struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
}
