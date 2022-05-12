//
//  APIServiceTests.swift
//  NineTests
//
//  Created by abc on 10/5/22.
//

import XCTest
@testable import Nine

class APIServiceTests: XCTestCase {
    
    var session: MockURLSession!
    var apiService: APIService!

    override func setUpWithError() throws {
        super.setUp()
        session = MockURLSession()
        apiService = APIService(urlSession: session)
    }

    // Checks that `getEditorsChoiceArticles` uses the correct endpoint URL
    func testEditorsChoiceURL() throws {
        let editorsChoiceURL = URL(string: "https://bruce-v2-mob.fairfaxmedia.com.au/1/coding_test/13ZZQX/full")!
        apiService.getEditorsChoiceArticles { result in }
        XCTAssertEqual(session.lastURL, editorsChoiceURL)
    }
    
    // Checks that `getEditorsChoiceArticles` starts a network request by resuming the task
    func testGetEditorsChoiceArticlesResumes() throws {
        let dataTask = MockURLSessionDataTask()
        
        session.nextDataTask = dataTask

        apiService.getEditorsChoiceArticles { result in }
        XCTAssert(dataTask.isResumed)
    }
    
    // Checks that `getEditorsChoiceArticles` returns correct `displayName` as well as
    // the correct number of articles and related images
    func testGetEditorsChoiceArticlesResultSuccess() throws {
        
        let jsonData = TestUtils.loadResource("Payload", withExtension: "json")
        let dataTask = MockURLSessionDataTask(data: jsonData)
        
        session.nextDataTask = dataTask
        let expectation = XCTestExpectation(description: "Get articles asynchronously")
        
        apiService.getEditorsChoiceArticles { result in
            switch result {
            case .success(let articles):
                XCTAssertEqual(articles.displayName, "AFR iPad Editor's Choice")
                XCTAssertEqual(articles.assets.count, 13)
                XCTAssertEqual(articles.assets[0].relatedImages?.count, 8)
                // Check all articles for equality
                XCTAssertEqual(articles.assets, TestUtils.loadArticles()?.assets)
            case .failure(let error):
                XCTFail("Unexpected error \(error)")
            }
            expectation.fulfill()
        }
        
        // Wait for the expectation to fulfill or time out.
        wait(for: [expectation], timeout: 1.0)
    }
    
    // Checks that `getEditorsChoiceArticles` reports a network error when it occurs
    func testGetEditorsChoiceArticlesResultFailure() throws {
                
        let error = NetworkError.invalidResponse(nil)
        let dataTask = MockURLSessionDataTask(data: nil, error: error)
        
        session.nextDataTask = dataTask
        let expectation = XCTestExpectation(description: "Get articles asynchronously")
        
        apiService.getEditorsChoiceArticles { result in
            switch result {
            case .success(_):
                XCTFail("Unexpected result")
            case .failure(_ as NetworkError):
                break
            case .failure(let error):
                XCTFail("Unexpected error \(error)")
            }
            expectation.fulfill()
        }
        
        // Wait for the expectation to fulfill or time out.
        wait(for: [expectation], timeout: 1.0)
    }
    
    // Checks that `getEditorsChoiceArticles` can handle malformed response JSON and
    // correctly report `Swift.DecodingError`
    func testGetEditorsChoiceArticlesMalformed() throws {
                
        let jsonData = TestUtils.loadResource("PayloadMalformed", withExtension: "json")
        let dataTask = MockURLSessionDataTask(data: jsonData)
        
        session.nextDataTask = dataTask
        let expectation = XCTestExpectation(description: "Get articles asynchronously")
        
        apiService.getEditorsChoiceArticles { result in
            switch result {
            case .success(_):
                XCTFail("Unexpected result")
            case .failure(_ as Swift.DecodingError):
                break
            case .failure(let error):
                XCTFail("Unexpected error: \(error)")
            }
            expectation.fulfill()
        }
        
        // Wait for the expectation to fulfill or time out.
        wait(for: [expectation], timeout: 1.0)
    }
}



