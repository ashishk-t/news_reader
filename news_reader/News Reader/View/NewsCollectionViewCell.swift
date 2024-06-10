//
//  NewsCollectionViewCell.swift
//  News Reader
//
//  Created by ashishKT on 08/06/24.
//

import UIKit

class NewsCollectionViewCell: UICollectionViewCell {
    var imageView: UIImageView!
    var titleLabel: UILabel!
    var summaryLabel: UILabel!
    var labelStack: UIStackView!
    var bookmarkButton: UIButton!
    var publishedTimeAgo: UILabel!
    private var isBookmarked = false
    
    // MARK: - View Model
    
    var cellViewModel: NewsCellViewModel? {
        didSet {
            let imageUrl =  URL(string: cellViewModel?.getThumbnailUrlString() ?? "NA")
            Utitlity.fetchImage(from: imageUrl!, completion: { image in
                DispatchQueue.main.async {
                    self.imageView.image = image
                }
            })
            
            titleLabel.text = cellViewModel?.getTitleString()
            publishedTimeAgo.text = cellViewModel?.getPublishedTimeAgoString()
            summaryLabel.text = cellViewModel?.getSummaryString()
            
            updateBookmarkState()
        }
    }
    
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    private func setupSeparatorView() {
        contentView.addSubview(separatorView)
        
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            separatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupCell()
        addViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setupCell() {
        backgroundColor = .secondarySystemGroupedBackground
        layer.cornerRadius = 6
        setupSeparatorView()
    }
    
    func addViews() {
        imageView = getImageView()
        bookmarkButton = getBookmarkButton()
        addSubview(imageView)
        addSubview(bookmarkButton)
        publishedTimeAgo = getLabel(fontSize: 14, weigth: .regular, numberOfLines: 1)
        addSubview(publishedTimeAgo)
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(
                equalTo: leadingAnchor, constant: 8),
            imageView.widthAnchor.constraint(
                equalToConstant: frame.width/3.5),
            imageView.heightAnchor.constraint(
                equalToConstant: frame.width/4),
            imageView.topAnchor.constraint(
                equalTo: topAnchor, constant: 10),
            imageView.bottomAnchor.constraint(
                equalTo: bottomAnchor, constant: -50),
            bookmarkButton.bottomAnchor.constraint(
                equalTo: bottomAnchor, constant: -10),
            bookmarkButton.trailingAnchor.constraint(
                equalTo: trailingAnchor, constant: -10),
            bookmarkButton.widthAnchor.constraint(
                equalToConstant: 25),
            bookmarkButton.heightAnchor.constraint(
                equalToConstant: 25),
            publishedTimeAgo.bottomAnchor.constraint(
                equalTo: bottomAnchor, constant: -10),
            publishedTimeAgo.leadingAnchor.constraint(
                equalTo: leadingAnchor, constant: 8),
            publishedTimeAgo.heightAnchor.constraint(
                equalToConstant: 25),
        ])
        
        titleLabel = getLabel(fontSize: 14, weigth: .bold, numberOfLines: 3)
        summaryLabel = getLabel(fontSize: 12, weigth: .regular, numberOfLines: 4)
        
        labelStack = getStackView()
        addSubview(titleLabel)
        addSubview(summaryLabel)
        addSubview(labelStack)
        labelStack.addArrangedSubview(titleLabel)
        labelStack.addArrangedSubview(summaryLabel)
        
        NSLayoutConstraint.activate([
            labelStack.leadingAnchor.constraint(
                equalTo: imageView.trailingAnchor, constant: 8),
            labelStack.trailingAnchor.constraint(
                equalTo: trailingAnchor, constant: -8),
            labelStack.topAnchor.constraint(
                equalTo: topAnchor, constant: 10),
            labelStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -50),
            titleLabel.leadingAnchor.constraint(equalTo: labelStack.leadingAnchor),
            summaryLabel.leadingAnchor.constraint(equalTo: labelStack.leadingAnchor)
        ])
    }
    // MARK: - UI Helper Methods
    
    func getLabel(fontSize: CGFloat, weigth: UIFont.Weight, numberOfLines: Int = 2) -> UILabel {
        let newLabel = Utitlity.createLabel(
            with: .darkText, text: "", alignment: .left,
            font: UIFont.systemFont(ofSize: fontSize, weight: weigth))
        newLabel.adjustsFontSizeToFitWidth = false
        newLabel.numberOfLines = numberOfLines
        newLabel.lineBreakMode = .byTruncatingTail
        return newLabel
    }
    
    func getStackView() -> UIStackView {
        let stackView = Utitlity.createStackView(
            .vertical, distribution: .equalSpacing)
        stackView.spacing = 1
        return stackView
    }
    
    func getImageView() -> UIImageView {
        let imageView = Utitlity.createImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }
    
    func getBookmarkImageView() -> UIImageView {
        let imageView = Utitlity.createImageView()
        imageView.image = UIImage(systemName: "book")
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }
    
    override func prepareForReuse() {
        imageView.image = nil
        titleLabel.text = ""
        summaryLabel.text = ""
        publishedTimeAgo.text = ""
    }
    
    func getBookmarkButton() -> UIButton {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "book"), for: .normal)
        button.addTarget(self, action: #selector(bookmarkTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    
    func updateBookmarkState() {
        isBookmarked = cellViewModel?.isBookmarked() ?? false
        if isBookmarked {
            bookmarkButton.setImage(UIImage(systemName: "book.fill"), for: .normal)
        }
        else {
            bookmarkButton.setImage(UIImage(systemName: "book"), for: .normal)
        }
    }
    
    @objc func bookmarkTapped() {
        if isBookmarked {
            cellViewModel?.deleteBookmark()
        }
        else {
            cellViewModel?.saveBookmark()
        }
        updateBookmarkState()
    }
}
