//
//  ImagesListService.swift
//  Image Feed
//
//  Created by Михаил Бобылев on 19.06.2025.
//

import Foundation

public protocol ImagesListServiceProtocol {
    var photos: [Photo] { get }
    func fetchPhotosNextPage(authToken: String)
    func changeLike(photoId: String, isLike: Bool, authToken: String, _ completion: @escaping (Result<Void, Error>) -> Void)
    func cleanPhotos()
}

final class ImagesListService: ImagesListServiceProtocol {
    static let shared = ImagesListService()
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    private(set) var photos: [Photo] = []
    private let formatter = ISO8601DateFormatter()
    private let perPage = 10
    private var page = 1
    private var myTask: URLSessionTask?
    
    func fetchPhotosNextPage(authToken: String) {
        guard myTask == nil, let request = makeImagesListRequest(nextPage: page, authToken: authToken) else { return }
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self else { return }
            switch result {
            case .success(let photoResult):
                myTask = nil
                page += 1
                let resultPhotos: [Photo] = photoResult.map({ photoResult in
                    self.formatter.formatOptions = [.withInternetDateTime]
                    let createdAt = self.formatter.date(from: photoResult.createdAt ?? "")
                    
                    return Photo(id: photoResult.id,
                                 size: CGSize(width: photoResult.width, height: photoResult.height),
                                 createdAt: createdAt,
                                 welcomeDescription: photoResult.description,
                                 thumbImageURL: photoResult.urls.thumb,
                                 largeImageURL: photoResult.urls.full,
                                 isLiked: photoResult.likedByUser)
                })
                
                self.photos.append(contentsOf: resultPhotos)
                NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: self)
            case .failure(let error):
                if let error = error as? NetworkError {
                    switch error {
                    case .httpStatusCode(let int):
                        print("[fetchProfile.objectTask]: Bad status code: \(int)")
                    case .urlRequestError(let error):
                        print("[fetchProfile.objectTask]: URL request error: \(error)")
                    case .urlSessionError:
                        print("[fetchProfile.objectTask]: URL session error")
                    }
                } else {
                    print("[fetchProfile.objectTask]: \(error.localizedDescription)")
                }
            }
        }
        myTask = task
        task.resume()
    }
    
    func changeLike(photoId: String, isLike: Bool, authToken: String, _ completion: @escaping (Result<Void, Error>) -> Void) {
        guard let request = makeChangeLikeRequest(photoId: photoId, isLike: isLike, authToken: authToken) else { return }
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<ChangeLikeResult, Error>) in
            guard let self else { return }
            switch result {
            case .success:
                if let index = photos.firstIndex(where: { $0.id == photoId }) {
                    let photo = photos[index]
                    let newPhoto = Photo(
                        id: photo.id,
                        size: photo.size,
                        createdAt: photo.createdAt,
                        welcomeDescription: photo.welcomeDescription,
                        thumbImageURL: photo.thumbImageURL,
                        largeImageURL: photo.largeImageURL,
                        isLiked: !photo.isLiked
                    )
                    photos[index] = newPhoto
                }
                completion(.success(()))
            case .failure(let error):
                if let error = error as? NetworkError {
                    switch error {
                    case .httpStatusCode(let int):
                        print("[fetchProfile.objectTask]: Bad status code: \(int)")
                    case .urlRequestError(let error):
                        print("[fetchProfile.objectTask]: URL request error: \(error)")
                    case .urlSessionError:
                        print("[fetchProfile.objectTask]: URL session error")
                    }
                } else {
                    print("[fetchProfile.objectTask]: \(error.localizedDescription)")
                }
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    func cleanPhotos() {
        photos = []
    }
}

private extension ImagesListService {
    func makeImagesListRequest(nextPage: Int, authToken: String) -> URLRequest? {
        guard let baseURL = Constants.defaultBaseURL else {
            print("[makeImagesListRequest]: Failed to create URL")
            return nil
        }
        
        var urlComponents = URLComponents(url: baseURL.appendingPathComponent("/photos"), resolvingAgainstBaseURL: true)
        urlComponents?.queryItems = [
            URLQueryItem(name: "page", value: String(nextPage)),
            URLQueryItem(name: "per_page", value: String(perPage))
        ]
        
        guard let url = urlComponents?.url else {
            print("[makeImagesListRequest]: URL creation error")
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func makeChangeLikeRequest(photoId: String, isLike: Bool, authToken: String) -> URLRequest? {
        guard let baseURL = Constants.defaultBaseURL else {
            print("[makeChangeLikeRequest]: Failed to create URL")
            return nil
        }
        
        guard let url = URL(
            string: "/photos/\(photoId)/like",
            relativeTo: baseURL
        ) else {
            print("[makeChangeLikeRequest]: URL creation error")
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = isLike ? HTTPMethod.delete.rawValue : HTTPMethod.post.rawValue
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        return request
    }
}
