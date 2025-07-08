//
//  ImagesListServiceMock.swift
//  Image FeedTests
//
//  Created by Михаил Бобылев on 06.07.2025.
//

import Image_Feed

final class ImagesListServiceMock: ImagesListServiceProtocol {
    var photos: [Photo] = []
    var didCallFetchPhotosNextPage = false
    var didCallChangeLike = false
    var changeLikeResult: Result<Void, Error>?
    
    func fetchPhotosNextPage(authToken: String) {
        didCallFetchPhotosNextPage = true
    }

    func changeLike(photoId: String, isLike: Bool, authToken: String, _ completion: @escaping (Result<Void, Error>) -> Void) {
        didCallChangeLike = true
        if let result = changeLikeResult {
            completion(result)
        }
    }
    
    func cleanPhotos() {
        
    }
}
