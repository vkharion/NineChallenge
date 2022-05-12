//
//  URLSession.swift
//  Nine
//
//  Created by abc on 10/5/22.
//

import Foundation

extension URLSession {
    static var ephemeral: URLSession {
        // Configure to store any session-related data in RAM
        let config = URLSessionConfiguration.ephemeral
        return  URLSession(configuration: config)
    }
}


typealias DataTaskResult = (Data?, URLResponse?, Error?) -> Void

protocol URLSessionProtocol {
    func dataTaskWithURL(_ url: URL, completion: @escaping DataTaskResult)
          -> URLSessionDataTaskProtocol
}

protocol URLSessionDataTaskProtocol {
    func resume()
}

extension URLSession: URLSessionProtocol {
    
    struct StubDataTask: URLSessionDataTaskProtocol {
        let resumeBlock: () -> Void
        
        func resume() {
            resumeBlock()
        }
    }
    
    private var isUITesting: Bool {
      return ProcessInfo.processInfo.arguments.contains("UI-TESTING")
    }
    
    func dataTaskWithURL(_ url: URL, completion: @escaping DataTaskResult)
      -> URLSessionDataTaskProtocol
    {
        if let json = ProcessInfo.processInfo.environment[url.absoluteString], isUITesting {
            let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
            let data = json.data(using: .utf8)
            return StubDataTask(){
                completion(data, response, nil)
            }
        } else {
            return dataTask(with: url, completionHandler: completion) as URLSessionDataTaskProtocol
        }
    }
}

extension URLSessionDataTask: URLSessionDataTaskProtocol {}
