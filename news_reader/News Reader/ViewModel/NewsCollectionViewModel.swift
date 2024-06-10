//
//  NewsCollectionViewModel.swift
//  News Reader
//
//  Created by ashishKT on 08/06/24.
//

import Foundation
import Combine

class NewsCollectionViewModel: ObservableObject {
    
    private var subscriptions = Set<AnyCancellable>()
//    var searchText: String? {
//        didSet {
//            if let text = searchText?.lowercased(), !text.isEmpty {
//                self.newsCellViewModels = createCellViewModels(from: self.newsArticles.filter { $0.title?.lowercased().contains(text) ?? true })
//            }
//            else {
//                self.newsCellViewModels = createCellViewModels(from: newsArticles)
//            }
//        }
//    }
    @Published var searchText: String = ""
    @Published var newsCellViewModels: [NewsCellViewModel] = []
    var newsArticles: [Article] = []
    
    
    // MARK: - Fetch Data
    
    // Fetch data through the API
    func fetchData() {
        NetworkService.shared.fetchNewsList()
        .sink { [unowned self] completion in
            if case let .failure(error) = completion {
                self.handleError(error)
            }
        }
        receiveValue: { [unowned self] in
            let newsList : NewsList = $0
            newsArticles = newsList.articles ?? []
            self.newsCellViewModels = self.createCellViewModels(from: newsArticles)
        }
        .store(in: &self.subscriptions)
    }
    
    func loadBookmarks() {
       CoreDataService.shared.fetchNewsList()
        .sink { [unowned self] completion in
            if case let .failure(error) = completion {
                self.handleError(error)
            }
        }
        receiveValue: { [unowned self] in
            newsArticles = $0 ?? []
            self.newsCellViewModels = self.createCellViewModels(from: newsArticles, delegate: self)
        }
        .store(in: &self.subscriptions)
    }
    
    func filterArticles(_ searchText: String?) {
        if let text = searchText?.lowercased(), !text.isEmpty {
            self.newsCellViewModels = createCellViewModels(from: self.newsArticles.filter { $0.title?.lowercased().contains(text) ?? true })
        }
        else {
            self.newsCellViewModels = createCellViewModels(from: newsArticles)
        }
    }
    
    func saveBookmark(_ article: Article) {
        CoreDataService.shared.saveBookmark(article)
    }
    
    func createCellViewModels(from resultsArray: [Article], delegate: CellViewModelDelegate? = nil) -> [NewsCellViewModel] {
        var viewModels: [NewsCellViewModel] = []
        
        for result in resultsArray {
            let cellViewModel = buildCellModel(from: result, delegate: delegate)
            viewModels.append(cellViewModel)
        }
        
        return viewModels
    }
    
    func buildCellModel(from newsArticle: Article, delegate: CellViewModelDelegate? = nil) -> NewsCellViewModel {
        return NewsCellViewModel(delegate: delegate, title: newsArticle.title, summary: newsArticle.description, thumbnailUrlString: newsArticle.urlToImage, publishedAtString: newsArticle.publishedAt, newsDetailUrl: newsArticle.url)
    }
    
    func getCellViewModel(at indexPath: IndexPath) -> NewsCellViewModel {
        return newsCellViewModels[indexPath.row]
    }
    
    func handleError(_ apiError: NewsServiceError) {
        print("ERROR: \(apiError.localizedDescription)!")
    }
}

extension NewsCollectionViewModel : CellViewModelDelegate {
    func didTapDeleteBookmark(for cellModel: NewsCellViewModel) {
        self.newsCellViewModels.removeAll { $0.newsDetailUrl == cellModel.newsDetailUrl}
    }
}
