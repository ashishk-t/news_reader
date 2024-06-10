//
//  NewsCellViewModel.swift
//  News Reader
//
//  Created by ashishKT on 08/06/24.
//

import UIKit

protocol CellViewModelDelegate: AnyObject {
    func didTapDeleteBookmark(for cellModel: NewsCellViewModel)
}

struct NewsCellViewModel: Equatable {
    static func == (lhs: NewsCellViewModel, rhs: NewsCellViewModel) -> Bool {
            return lhs.newsDetailUrl == rhs.newsDetailUrl
    }
    weak var delegate: CellViewModelDelegate?

    
    let title: String?
    let summary: String?
    let thumbnailUrlString: String?
    let publishedAtString: String?
    let newsDetailUrl: String?
    
    func getNewsDetailUrl() -> String? {
        return newsDetailUrl
    }
    
    func getThumbnailUrlString() -> String? {
        return thumbnailUrlString
    }
    
    func getSummaryString() -> String? {
        return summary
    }
    
    func getTitleString() -> String? {
        return title
    }
    
    func getPublishedString() -> String? {
        return publishedAtString
    }
    
    func getPublishedTimeAgoString() -> String {
        return Utitlity.getTimeAgo(dateString: getPublishedString() ?? "")
    }
    
    func isBookmarked() -> Bool {
        return CoreDataService.shared.isBookmarkedArticle(getNewsDetailUrl())
    }
    
    func saveBookmark() {
        CoreDataService.shared.saveBookmark(Article(title: self.getTitleString(), description: self.summary, url: self.newsDetailUrl, urlToImage: self.thumbnailUrlString, publishedAt: self.publishedAtString))
    }
    
    func deleteBookmark() {
        CoreDataService.shared.deleteBookmark(self.newsDetailUrl, completion: {
            self.delegate?.didTapDeleteBookmark(for: self)
        })
        
    }
}
