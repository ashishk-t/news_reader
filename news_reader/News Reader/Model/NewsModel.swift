//
//  NewsModel.swift
//  News Reader
//
//  Created by ashishKT on 08/06/24.
//

import Foundation

// MARK: - NewsList
struct NewsList: Codable {
    let status: String?
    let totalResults: Int?
    let articles: [Article]?
}

// MARK: - Article
struct Article: Codable {
    let title: String?
    let description: String?
    let url: String?
    let urlToImage: String?
    let publishedAt: String?
    
    init(title: String?, description: String?,url: String?, urlToImage: String?, publishedAt: String?) {
        self.title = title
        self.description = description
        self.url = url
        self.urlToImage = urlToImage
        self.publishedAt = publishedAt
    }
    
    init(_ entity: CDArticle) {
        self.title = entity.title
        self.description = entity.descripn
        self.url = entity.url
        self.urlToImage = entity.urlToImage
        self.publishedAt = entity.publishedAt
    }
}
