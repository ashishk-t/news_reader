//
//  NewsListingViewController.swift
//  News Reader
//
//  Created by ashishKT on 08/06/24.
//

import UIKit

class NewsListingViewController: UIViewController {
    var containerView: NewsContainerView!
    
    private let segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Top Headlines", "Bookmarks"])
        control.selectedSegmentIndex = 0
        
        return control
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    func setupView() {
        setupContainerView()
        setupSegmentedControl()
    }
    
    func setupContainerView() {
        containerView = NewsContainerView(
            frame: view.frame, controller: self)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(containerView)
        NSLayoutConstraint.activate([
             containerView.widthAnchor.constraint(equalTo: view.widthAnchor),
            containerView.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])
    }
    
    private func setupSegmentedControl() {
        segmentedControl.addTarget(self, action: #selector(segmentValueChanged(_:)), for: .valueChanged)
        self.navigationItem.titleView = segmentedControl//titleLabel
    }
    
    @objc private func segmentValueChanged(_ sender: UISegmentedControl) {
        containerView.resetSearchText()
        switch sender.selectedSegmentIndex {
        case 0:
            print("**topheadlines segment tapped")
            containerView.reloadCollectionData()
        case 1:
            print("**bookmarks segment tapped")
            containerView.loadBookmarks()
        default:
            break
        }
    }
}

extension UIViewController {
    var topBarHeight: CGFloat {
        var top = self.navigationController?.navigationBar.frame.height ?? 0.0
        let window = UIApplication.shared.windows.first(where: \.isKeyWindow)
        top += window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        return top
    }
}



