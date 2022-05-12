//
//  Articles.swift
//  Nine
//
//  Created by abc on 7/5/22.
//

import Foundation


struct Articles: Codable {
    var displayName: String
    var assets: [Article]
}

struct Article: Codable, Equatable {
    var id: Int
    var url: String
    var headline: String
    var theAbstract: String
    var byLine: String
    var relatedImages: [RelatedImage]?
    var timeStamp: Int
}

struct RelatedImage: Codable, Equatable {
    var url: String
    var width: Int
    var height: Int
}

extension Article {
    // Returns the smallest image among 'relatedImages' if there are any
    var thumbnailImage: RelatedImage? {
        var minImage: RelatedImage?
        relatedImages?.forEach { image in
            if (image.size > 0 && image.size < minImage?.size ?? Int.max) {
                minImage = image
            }
        }
        return minImage
    }
}

extension RelatedImage {
    var size: Int {
        return width * height
    }
}


