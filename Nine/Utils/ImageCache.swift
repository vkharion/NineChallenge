//
//  ImageCache.swift
//  Nine
//
//  Created by abc on 9/5/22.
//  Adapted from the "Async Image Loading" documentaion example

import UIKit
import Foundation

public class ImageCache {
    
    public static let publicCache = ImageCache(urlSession: URLSession.ephemeral)
    
    private let cachedImages = NSCache<NSURL, UIImage>()
    private var loadingResponses = [NSURL: [(Item, UIImage?) -> Void]]()
    private var urlSession: URLSessionProtocol!
    
    init(urlSession: URLSessionProtocol) {
        self.urlSession = urlSession
    }
    
    public final func image(url: NSURL) -> UIImage? {
        return cachedImages.object(forKey: url)
    }
    
    // Returns the cached image if available, otherwise asynchronously loads and caches it.
    // The completion handler is called with a retrieved (or previously cached) image or `nil` in case of any errors.
    final func load(url: NSURL, item: Item, completion: @escaping (Item, UIImage?) -> Void) {
        
        // Check for a cached image
        if let cachedImage = image(url: url) {
            DispatchQueue.main.async {
                completion(item, cachedImage)
            }
            return
        }
        
        // In case there are more than one requestor for the image, we append their completion block
        if loadingResponses[url] != nil {
            loadingResponses[url]?.append(completion)
            return
        } else {
            loadingResponses[url] = [completion]
        }
        
        // Go fetch the image
        urlSession.dataTaskWithURL(url as URL) { (data, response, error) in
            // Check for the error, then data and try to create the image
            guard let responseData = data, let image = UIImage(data: responseData),
                let blocks = self.loadingResponses[url], error == nil else {
                DispatchQueue.main.async {
                    print("Failed to fetch image \(String(describing: url.absoluteString)) error: \(String(describing: error))")
                    completion(item, nil)
                }
                return
            }
            
            // Cache the image
            self.cachedImages.setObject(image, forKey: url, cost: responseData.count)
            
            // Iterate over each requestor for the image and pass it back
            for block in blocks {
                DispatchQueue.main.async {
                    block(item, image)
                }
            }
            
            // Clear out the requestors, so that if network calls for the same image
            // complete after this one, the completion handlers of those requestors
            // aren't called again
            self.loadingResponses[url] = nil
            
        }.resume()
    }
        
}
