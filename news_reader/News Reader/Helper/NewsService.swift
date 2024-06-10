//
//  NewsService.swift
//  News Reader
//
//  Created by ashishKT on 08/06/24.
//

import Foundation
import Combine
import UIKit
import CoreData


protocol NewsService {
    func fetchNewsList<T: Codable>() -> Future<T, NewsServiceError>
}

enum Endpoint: String {
    case topHeadlines = "?country=us&apiKey=e86ff6eafda3433782db579b383c1346"
}

enum NewsServiceError: Error, LocalizedError {
    case urlError(URLError)
    case responseError(Int)
    case decodingError(DecodingError)
    case anyError
    
    var localizedDescription: String {
        switch self {
        case .urlError(let error):
            return error.localizedDescription
        case .decodingError(let error):
            return error.localizedDescription
        case .responseError(let error):
            return "Bad response code: \(error)"
        case .anyError:
            return "Unknown error has ocurred"
        }
    }
}
