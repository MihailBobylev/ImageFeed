//
//  OAuth2Service.swift
//  Image Feed
//
//  Created by Михаил Бобылев on 19.05.2025.
//

import Foundation

enum AuthServiceError: Error {
    case invalidRequest
}

final class OAuth2Service {
    static let shared = OAuth2Service()
    private lazy var jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        return decoder
    }()
    
    private var myTask: URLSessionTask?
    private var lastCode: String?
    
    private init() {}
    
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        guard lastCode != code else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        myTask?.cancel()
        lastCode = code
        
        guard let request = makeOAuthTokenRequest(code: code) else { return }
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            guard let self else { return }
            switch result {
            case .success(let responseBody):
                myTask = nil
                lastCode = nil
                completion(.success(responseBody.accessToken))
            case .failure(let error):
                if let error = error as? NetworkError {
                    switch error {
                    case .httpStatusCode(let int):
                        print("[fetchOAuthToken.objectTask]: Bad status code: \(int)")
                    case .urlRequestError(let error):
                        print("[fetchOAuthToken.objectTask]: URL request error: \(error)")
                    case .urlSessionError:
                        print("[fetchOAuthToken.objectTask]: URL session error")
                    }
                } else {
                    print("[fetchOAuthToken.objectTask]: \(error.localizedDescription)")
                }
                completion(.failure(error))
            }
        }
        myTask = task
        task.resume()
    }
}

private extension OAuth2Service {
    func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard let baseURL = URL(string: "https://unsplash.com") else {
            print("[makeOAuthTokenRequest]: Failed to create URL")
            return nil
        }
        guard let url = URL(
            string: "/oauth/token"
            + "?client_id=\(Constants.accessKey)"
            + "&&client_secret=\(Constants.secretKey)"
            + "&&redirect_uri=\(Constants.redirectURI)"
            + "&&code=\(code)"
            + "&&grant_type=authorization_code",
            relativeTo: baseURL
        ) else {
            print("[makeOAuthTokenRequest]: URL creation error")
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        return request
    }
}
