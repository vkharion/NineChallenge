//
//  Item.swift
//  Nine
//
//  Created by abc on 9/5/22.
//

import UIKit

enum Section: Int {
    case main
}

class Item: Hashable {
        
    let id: Int
    let url: URL
    let headline: String
    let abstract: String
    let byLine: String
    var image: UIImage?
    let imageURL: URL?
    let timestamp: Int
    
    init(id: Int, url: URL, headline: String, abstract: String, byLine: String, image: UIImage?, imageURL: URL?, timestamp: Int) {
        self.id = id
        self.url = url
        self.headline = headline
        self.abstract = abstract
        self.byLine = byLine
        self.image = image
        self.imageURL = imageURL
        self.timestamp = timestamp
    }

    // MARK: - Hashable
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Item, rhs: Item) -> Bool {
        return lhs.id == rhs.id
    }
}

extension Item {
    convenience init(article: Article) {
        // If there's a thumbnail image to be used on the cell, create its URL
        let imageURL = article.thumbnailImage != nil ? URL(string: article.thumbnailImage!.url) : nil
        self.init(id: article.id, url: URL(string: article.url)!, headline: article.headline, abstract: article.theAbstract, byLine: article.byLine, image: nil, imageURL: imageURL, timestamp: article.timeStamp)

    }
}
