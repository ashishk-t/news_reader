//
//  CoreDataService.swift
//  News Reader
//
//  Created by ashishKT on 08/06/24.
//

import Foundation
import UIKit
import CoreData
import Combine

class CoreDataService : NewsService {
    
    static let shared = CoreDataService()
    private var subscriptions = Set<AnyCancellable>()
    func fetchNewsList<T: Codable>() -> Future<T, NewsServiceError> {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        return Future<T, NewsServiceError> { [unowned self] promise in
            do {
                let items = try context.fetch(CDArticle.fetchRequest()).map(Article.init)
                //onSuccess(items)
                promise(.success(items as! T))
            } catch (let error) {
                print("error-Fetching data")
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
    }
    
    func saveBookmark(_ article: Article) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let newArticle = CDArticle(context: context)
        newArticle.title = article.title
        newArticle.publishedAt = article.publishedAt
        newArticle.descripn = article.description
        newArticle.url = article.url
        newArticle.urlToImage = article.urlToImage
        do {
            try context.save()
        } catch {
            print("*** error-Saving article data")
        }
    }
    
    func isBookmarkedArticle(_ url: String?) -> Bool {
        guard let url = url, !url.isEmpty else {
            return false
        }
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return false }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "CDArticle")
        fetchRequest.predicate = NSPredicate(format: "url = %@", url)
        do { let articles =  try managedContext.fetch(fetchRequest)
            return articles.count > 0 ? true : false
        }
        catch {
            return false
        }
    }
    
    func deleteBookmark(_ url: String?, completion: () -> ()) {
        guard let url = url, !url.isEmpty else {
            return
        }
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "CDArticle")
        fetchRequest.predicate = NSPredicate(format: "url = %@", url)
        do { let articles =  try managedContext.fetch(fetchRequest)
            for article in articles {
                managedContext.delete(article as! NSManagedObject)
            }
            try managedContext.save()
            completion()
        }
        catch {
            print("** error deleting bookmark")
        }
    }
}
