//
//  OAuth2Service.swift
//  Image Feed
//
//  Created by Михаил Бобылев on 19.05.2025.
//

import Foundation

final class OAuth2Service {
    static let shared = OAuth2Service()
    private lazy var jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    private init() {}
    
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let request = makeOAuthTokenRequest(code: code) else { return }
        
        let fulfillCompletionOnTheMainThread: (Result<String, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        let task = URLSession.shared.data(for: request) { result in
            switch result {
            case .success(let data):
                do {
                    let responseBody = try self.jsonDecoder.decode(OAuthTokenResponseBody.self, from: data)
                    fulfillCompletionOnTheMainThread(.success(responseBody.accessToken))
                } catch {
                    print("Decode error: \(error.localizedDescription)")
                    fulfillCompletionOnTheMainThread(.failure(error))
                }
            case .failure(let error):
                if let error = error as? NetworkError {
                    switch error {
                    case .httpStatusCode(let int):
                        print("Bad status code: \(int)")
                    case .urlRequestError(let error):
                        print("URL request error: \(error)")
                    case .urlSessionError:
                        print("URL session error")
                    }
                } else {
                    print("Error: \(error.localizedDescription)")
                }
                fulfillCompletionOnTheMainThread(.failure(error))
            }
        }
        
        task.resume()
    }
}

private extension OAuth2Service {
    func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard let baseURL = URL(string: "https://unsplash.com") else {
            print("baseURL is incorrect")
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
            print("URL creation error")
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        return request
    }
}
