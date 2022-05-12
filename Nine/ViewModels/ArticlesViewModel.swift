//
//  ArticlesViewModel.swift
//  Nine
//
//  Created by abc on 9/5/22.
//

import Foundation

protocol ArticlesViewModelDelegate: NSObjectProtocol {
    func viewStateChanged(_ viewState: ArticlesViewModel.ViewState)
    func handleError(_ error: Error)
}

class ArticlesViewModel {
    
    struct ViewState {
        let title: String
        var items: [Item]
        var reloadItemIndex: Int?
    }
    
    private(set) var viewState: ViewState! {
        didSet {
            delegate?.viewStateChanged(self.viewState)
        }
    }
    private(set) var error: Error? {
        didSet {
            if let error = self.error {
                self.delegate?.handleError(error)
            }
        }
    }
    
    private let dataProvider: EditorsChoiceProvider
    private let imageCache: ImageCache
    private weak var delegate: ArticlesViewModelDelegate?
    
    init(delegate: ArticlesViewModelDelegate, dataProvider: EditorsChoiceProvider = APIService(), imageCache: ImageCache = .publicCache) {
        self.delegate = delegate
        self.dataProvider = dataProvider
        self.imageCache = imageCache
        self.viewState = ViewState(title: "", items: [Item]())
    }
        
    func loadItems() {
        // Download and parse the JSON articles feed updating the view state
        dataProvider.getEditorsChoiceArticles { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let articles):
                // In case of success, use `displayName` as the articles title
                let title = articles.displayName
                // Display the latest articles first using the article's 'timeStamp'
                let items: [Item] = articles.assets
                    .sorted(by: { $0.timeStamp > $1.timeStamp })
                    .map({ Item(article: $0) })
                self.viewState = ViewState(title: title, items: items)
            case .failure(let error):
                self.error = error
            }
        }
    }
    
    func loadItemImage(_ item: Item) {
        // If there's a thumbnail image for the article, load it asynchronously and cache it
        guard let imageURL = item.imageURL else {
            return
        }
        imageCache.load(url: imageURL as NSURL, item: item) { [weak self] (fetchedItem, image) in
            guard let self = self else { return }
            // If the fetched image is different from the current item image
            if let img = image, img != fetchedItem.image {
                // Update the item image and change the view state
                let items = self.viewState.items
                if let itemIndex = items.firstIndex(of: fetchedItem) {
                    let item = items[itemIndex]
                    item.image = img
                    self.viewState = ViewState(title: self.viewState.title, items: items, reloadItemIndex: itemIndex)
                }
            }
        }
    }
}
