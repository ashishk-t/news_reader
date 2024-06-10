//
//  NewsRouter.swift
//  NewsReader
//
//  Created by ashishKT on 08/06/24.
//

import Foundation
import UIKit

enum Route: String {
    case toNewsDetail
}

class NewsRouter {
    static func route(
        to routeID: Route,
        from context: UIViewController,
        parameters: [Any]?)
    {
        switch routeID {
        case Route.toNewsDetail:
            if let url = parameters?.first as? String, !url.isEmpty {
                let webViewController = WebViewController()
                webViewController.configureURL(url: url)
                context.navigationController?.pushViewController(webViewController, animated: true)
            }
        }
    }
}
