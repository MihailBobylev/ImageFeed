//
//  ProfileService.swift
//  Image Feed
//
//  Created by Михаил Бобылев on 31.05.2025.
//

import Foundation

public protocol ProfileServiceProtocol {
    var profile: Profile? { get }
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void)
}

final class ProfileService: ProfileServiceProtocol {
    static let shared = ProfileService()
    private lazy var jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        return decoder
    }()
    
    private(set) var profile: Profile?
    
    private var myTask: URLSessionTask?
    private var actualAuthToken: String?
    
    private init() {}
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        guard actualAuthToken != token else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        myTask?.cancel()
        actualAuthToken = token
        
        guard let request = makeProfileRequest(authToken: token) else { return }

        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            guard let self else { return }
            switch result {
            case .success(let profileResult):
                myTask = nil
                actualAuthToken = nil
                let name = ([profileResult.firstName, profileResult.lastName]
                    .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { !$0.isEmpty })
                    .joined(separator: " ")
                let profile = Profile(username: profileResult.username,
                                      name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                                      loginName: "@" + profileResult.username,
                                      bio: profileResult.bio)
                self.profile = profile
                completion(.success(profile))
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
        
        myTask = task
        task.resume()
    }
    
    func cleanProfileInfo() {
        profile = nil
    }
}

private extension ProfileService {
    func makeProfileRequest(authToken: String) -> URLRequest? {
        guard let baseURL = Constants.defaultBaseURL else {
            print("[makeProfileRequest]: Failed to create URL")
            return nil
        }
        guard let url = URL(
            string: "/me",
            relativeTo: baseURL
        ) else {
            print("[makeProfileRequest]: URL creation error")
            return nil
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        request.httpMethod = HTTPMethod.get.rawValue
        return request
    }
}
