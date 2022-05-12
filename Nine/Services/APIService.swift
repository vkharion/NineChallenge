//
//  APIService.swift
//  Nine
//
//  Created by abc on 8/5/22.
//

import Foundation

enum NetworkError: Error {
    case invalidResponse(URLResponse?)
}

protocol EndpointsProvider {
    var editorsChoiceURL: URL { get }
}

protocol EditorsChoiceProvider {
    func getEditorsChoiceArticles(completion: @escaping (Result<Articles, Error>) -> Void)
}



class APIService: EditorsChoiceProvider {
    
    struct Endpoints: EndpointsProvider {
        let editorsChoiceURL = URL(string: "https://bruce-v2-mob.fairfaxmedia.com.au/1/coding_test/13ZZQX/full")!
    }
        
    private let decoder = JSONDecoder()
    private var endpoints: EndpointsProvider!
    private var urlSession: URLSessionProtocol!
    
    init(endpoints: EndpointsProvider = Endpoints(), urlSession: URLSessionProtocol = URLSession.ephemeral) {
        self.endpoints = endpoints
        self.urlSession = urlSession
    }
    
    
    // MARK: - EditorsChoiceProvider
    
    func getEditorsChoiceArticles(completion: @escaping (Result<Articles, Error>) -> Void) {
        
        // Fetch the data from the endpoint
        urlSession.dataTaskWithURL(endpoints.editorsChoiceURL) { [unowned self] (data, response, error) in
            
            let result = Result { () throws -> Articles in
                
                // Check for any network errors
                if let error = error {
                    throw error
                }
                
                // Try to parse the response articles
                guard let responseData = data else {
                    throw NetworkError.invalidResponse(response)
                }
                
                return try self.decoder.decode(Articles.self, from: responseData)
            }

            DispatchQueue.main.async {
                completion(result)
            }
            
        }.resume()
    }
    
}

