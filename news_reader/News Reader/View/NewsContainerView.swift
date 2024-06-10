//
//  NewsContainerView.swift
//  News Reader
//
//  Created by ashishKT on 08/06/24.
//

import UIKit
import Combine


class NewsContainerView: UIView {
    let activityIndicator = UIActivityIndicatorView(style: .large)
    private unowned var controller: UIViewController!
    
    var collectionView: UICollectionView!
    private var searchBar: UISearchBar!
    var cellID = "CollectionCell"
    private var subscriptions = Set<AnyCancellable>()
    private var viewModel = NewsCollectionViewModel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    convenience init(frame: CGRect, controller: UIViewController) {
        self.init(frame: frame)
        self.controller = controller
        
        setupView()
        setupCollectionView()
        setupBindings()
        loadViewModel()
    }
    
    
    // MARK: - Setup Methods
    
    func setupView() {
        backgroundColor = .systemBackground
        addSearchBar()
        addSubview(activityIndicator)
        activityIndicator.center = self.center
        activityIndicator.color = .systemBlue
    }
    
    func addSearchBar() {
        let yOffset =  controller.topBarHeight + 10
        searchBar = UISearchBar(frame: CGRect(x: 0, y: yOffset, width: frame.width, height: 44))
        searchBar.delegate = self
        addSubview(searchBar)
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchBar.widthAnchor.constraint(equalTo: self.widthAnchor),
            searchBar.topAnchor.constraint(equalTo: self.topAnchor, constant: yOffset)
        ])
    }
    
    func resetSearchText() {
        searchBar.text = ""
        viewModel.searchText = ""
    }
    
    func setupCollectionView() {
        
        let horizontalInsets: CGFloat = 20
        let viewWidth = frame.width
        
        // Cell Size
        let cellsPerRow: CGFloat = 1
        let totalHorizontalInsets = horizontalInsets + cellsPerRow
        let cellWidth = (viewWidth - totalHorizontalInsets) / cellsPerRow
        
        // CollectionView Layout
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(
            top: 8, left: horizontalInsets/2,
            bottom: 0, right: horizontalInsets/2)
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 1
        
        layout.itemSize = CGSize(width: cellWidth, height: cellWidth*0.5)
        
        // Instantiate CollectionView
        let yOffset =  self.searchBar.frame.maxY + 10.0
        let rect = CGRect(x: 0, y: yOffset, width: frame.width, height: frame.height - yOffset)
        collectionView = UICollectionView(
            frame: rect, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemGroupedBackground
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(NewsCollectionViewCell.self,
                                forCellWithReuseIdentifier: cellID)
        
        addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
       NSLayoutConstraint.activate([
        collectionView.widthAnchor.constraint(equalTo: self.widthAnchor),
        collectionView.topAnchor.constraint(equalTo:self.searchBar.bottomAnchor),
            collectionView.heightAnchor.constraint(equalTo: self.heightAnchor, constant: -(yOffset))
       ])
    }
    
    
    func loadViewModel() {
        bringSubviewToFront(activityIndicator)
        activityIndicator.startAnimating()
        viewModel.fetchData()
    }
    
    func loadBookmarks() {
        viewModel.loadBookmarks()
    }
    
    func setupBindings() {
        viewModel.$newsCellViewModels.sink { [weak self] _ in
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
                self?.activityIndicator.stopAnimating()
            }
        }.store(in: &subscriptions)
        
        viewModel.$searchText
            .debounce(for: 0.1, scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] text in
                self?.viewModel.filterArticles(text)
            }
            .store(in: &subscriptions)
    }
    
    func reloadCollectionData() {
        loadViewModel()
    }
}

extension NewsContainerView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return viewModel.newsCellViewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID,
                                                      for: indexPath) as! NewsCollectionViewCell
        let cellViewModel = viewModel.getCellViewModel(at: indexPath)
        cell.cellViewModel = cellViewModel
        return cell
    }
}

extension NewsContainerView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let parameter1 = viewModel.newsCellViewModels[indexPath.row].getNewsDetailUrl()
        NewsRouter.route(to: Route.toNewsDetail, from: controller, parameters: [parameter1 ?? ""])
    }
}

extension NewsContainerView: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("search text is \(searchText)")
        viewModel.searchText = searchText
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        viewModel.searchText = ""
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
