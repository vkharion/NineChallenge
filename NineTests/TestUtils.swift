//
//  TestUtils.swift
//  NineTests
//
//  Created by abc on 10/5/22.
//

import Foundation
@testable import Nine

class TestUtils {
    
    // Returns a resource file URL from the test bundle
    class func resourceURL(_ resource: String, withExtension: String) -> URL? {
        return Bundle(for: TestUtils.self).url(forResource: resource, withExtension: withExtension)
    }
    
    // Loads a resource file from the test bundle
    class func loadResource(_ resource: String, withExtension: String) -> Data? {
        if let resourceURL = resourceURL(resource, withExtension: withExtension)  {
            return try? Data(contentsOf: resourceURL)
        }
        return nil
    }

    // Loads articles from the payload resource file
    class func loadArticles() -> Articles? {
        let jsonData = loadResource("Payload", withExtension: "json")
        
        let decoder = JSONDecoder()
        return try? decoder.decode(Articles.self, from: jsonData!)
    }
    
    // Loads items from the payload resource file
    class func loadItems() -> [Item]? {
        return loadArticles()?.assets.map({ return Item(article: $0) })
    }
    
    class func imageURL(id: Int) -> URL? {
        return resourceURL("UIImage_\(id)", withExtension: "png")!
    }
    
    class func imageData(id: Int) -> Data? {
        if let url = imageURL(id: id) {
            return try? Data(contentsOf: url)
        }
        return nil
    }
}





