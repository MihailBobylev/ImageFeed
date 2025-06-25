//
//  ProfileImageService.swift
//  Image Feed
//
//  Created by Михаил Бобылев on 31.05.2025.
//

import Foundation

final class ProfileImageService {
    static let shared = ProfileImageService()
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    private let oauth2TokenStorage = OAuth2TokenStorage.shared
    
    private lazy var jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        return decoder
    }()
    
    private(set) var avatarURL: String?
    private var myTask: URLSessionTask?
    private var username: String?
    
    private init() {}
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        guard self.username != username else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        myTask?.cancel()
        self.username = username
        
        guard let request = makeProfileImageRequest(username: username) else { return }
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            guard let self else { return }
            
            switch result {
            case .success(let userResult):
                myTask = nil
                self.username = nil
                avatarURL = userResult.profileImage?.small
                completion(.success(userResult.profileImage?.small ?? ""))
                NotificationCenter.default
                    .post(
                        name: ProfileImageService.didChangeNotification,
                        object: self,
                        userInfo: ["URL": userResult.profileImage?.small ?? ""])
            case .failure(let error):
                if let error = error as? NetworkError {
                    switch error {
                    case .httpStatusCode(let int):
                        print("[fetchProfileImageURL.objectTask]: Bad status code: \(int)")
                    case .urlRequestError(let error):
                        print("[fetchProfileImageURL.objectTask]: URL request error: \(error)")
                    case .urlSessionError:
                        print("[fetchProfileImageURL.objectTask]: URL session error")
                    }
                } else {
                    print("[fetchProfileImageURL.objectTask]: \(error.localizedDescription)")
                }
                completion(.failure(error))
            }
        }
        
        myTask = task
        task.resume()
    }
    
    func cleanAvatarInfo() {
        avatarURL = nil
    }
}

private extension ProfileImageService {
    func makeProfileImageRequest(username: String) -> URLRequest? {
        guard let baseURL = Constants.defaultBaseURL else {
            print("[makeProfileImageRequest]: Failed to create URL")
            return nil
        }
        guard let url = URL(
            string: "/users/\(username)",
            relativeTo: baseURL
        ) else {
            print("[makeProfileImageRequest]: URL creation error")
            return nil
        }

        guard let token = oauth2TokenStorage.token else {
            print("[makeProfileImageRequest]: No auth token")
            return nil
        }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = HTTPMethod.get.rawValue
        return request
    }
}
