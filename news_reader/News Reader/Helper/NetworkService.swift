//
//  NetworkService.swift
//  News Reader
//
//  Created by Aashish Kumar Tiwari on 08/06/24.
//

import Foundation
import Combine
import UIKit
import CoreData

class NetworkService: NewsService {
    
    static let shared = NetworkService()
    private let baseApiURL = "https://newsapi.org/v2/top-headlines"
    private let urlSession = URLSession.shared
    private var subscriptions = Set<AnyCancellable>()
    
    private let jsonDecoder: JSONDecoder = {
        let jsonDecoder = JSONDecoder()
        return jsonDecoder
    }()
    
    private init() {}
    
    
    // MARK: - NewsService protocol
    
    func fetchNewsList<T: Codable>() -> Future<T, NewsServiceError> {
        
        return Future<T, NewsServiceError> { [unowned self] promise in
            guard let url = self.createURL(with: Endpoint.topHeadlines.rawValue)
            else {
                return promise(.failure(.urlError(URLError(.unsupportedURL))))
            }
            
            self.urlSession.dataTaskPublisher(for: url)
                .tryMap { (data, response) -> Data in
                    guard let httpResponse = response as? HTTPURLResponse,
                          200...299 ~= httpResponse.statusCode
                    else {
                        throw NewsServiceError.responseError(
                            (response as? HTTPURLResponse)?.statusCode ?? 500)
                    }
                    return data
                }
                .decode(type: T.self,
                        decoder: self.jsonDecoder)
                .receive(on: RunLoop.main)
                .sink { completion in
                    if case let .failure(error) = completion {
                        switch error {
                        case let urlError as URLError:
                            promise(.failure(.urlError(urlError)))
                        case let decodingError as DecodingError:
                            promise(.failure(.decodingError(decodingError)))
                        case let apiError as NewsServiceError:
                            promise(.failure(apiError))
                        default:
                            promise(.failure(.anyError))
                        }
                    }
                }
        receiveValue: {
            promise(.success($0))
        }
        .store(in: &self.subscriptions)
        }
    }
        
    // MARK: - Create Endpoint
    
    private func createURL(with endpoint: String) -> URL? {
        
        guard let urlComponents = URLComponents(string: "\(baseApiURL)\(endpoint)")
        else { return nil }
        
        return urlComponents.url
    }
}
