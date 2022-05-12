//
//  MockURLSession.swift
//  NineTests
//
//  Created by abc on 12/5/22.
//

import Foundation
@testable import Nine

// URLSession mocking is based on https://masilotti.com/testing-nsurlsession/

class MockURLSession: URLSessionProtocol {
    
    var nextDataTask: MockURLSessionDataTask?
    private(set) var lastURL: URL?
    
    func dataTaskWithURL(_ url: URL, completion: @escaping DataTaskResult) -> URLSessionDataTaskProtocol {
        lastURL = url
        // Passed on the completion handler to be called on `resume()`
        let dataTask = nextDataTask ?? MockURLSessionDataTask()
        dataTask.completion = completion
        return dataTask
    }
}

class MockURLSessionDataTask: URLSessionDataTaskProtocol {
    
    typealias ResumeBlock = (@escaping DataTaskResult) -> Void

    private(set) var isResumed = false
    private(set) var data: Data?
    private(set) var error: Error?
    private(set) var resumeBlock: ResumeBlock?
    
    var completion: DataTaskResult?

    init(data: Data? = nil, error: Error? = nil) {
        self.data = data
        self.error = error
    }
    
    init(resumeBlock: @escaping ResumeBlock) {
        self.resumeBlock = resumeBlock
    }

    func resume() {
        isResumed = true
        guard let completion = completion else {
            return
        }
        
        if let resumeBlock = resumeBlock {
            resumeBlock(completion)
        } else {
            completion(data, nil, error)
        }
    }
}
