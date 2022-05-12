//
//  ImageCacheTests.swift
//  NineTests
//
//  Created by abc on 10/5/22.
//

import XCTest
@testable import Nine

class ImageCacheTests: XCTestCase {
    
    var session: MockURLSession!
    var imageCache: ImageCache!
    var imageURL: URL!
    var imageData: Data!
    let item = TestUtils.loadItems()!.first!
    
    override func setUpWithError() throws {
        super.setUp()
        session = MockURLSession()
        imageCache = ImageCache(urlSession: session)
        imageURL = TestUtils.imageURL(id: 1)!
        imageData = try! Data(contentsOf: imageURL)
    }

    // Checks that `load` uses the correct URL to retrieve the image
    func testLoadURL() throws {
        let imageURL = TestUtils.imageURL(id: 1)!
        imageCache.load(url: imageURL as NSURL, item: item) { (_, _) in }
        XCTAssertEqual(session.lastURL, imageURL)
    }
    
    // Checks that `load` starts a network request by resuming the task
    func testLoadResumesTask() throws {
        let dataTask = MockURLSessionDataTask()
        
        session.nextDataTask = dataTask
        
        imageCache.load(url: imageURL as NSURL, item: item) { (_, _) in }
        XCTAssert(dataTask.isResumed)
    }
    
    // Checks that `load` returns the correct image data
    func testLoadImageData() throws {
        let dataTask = MockURLSessionDataTask(data: imageData)
        let expectation = XCTestExpectation(description: "Get image asynchronously")
        
        session.nextDataTask = dataTask
        
        imageCache.load(url: imageURL as NSURL, item: item) { [unowned self] (item, image) in
            XCTAssertEqual(image?.pngData(), UIImage(data: self.imageData)?.pngData())
            expectation.fulfill()
        }
        
        // Wait for the expectation to fulfill or time out.
        wait(for: [expectation], timeout: 1.0)
    }
    
    // Checks that `load` returns `nil` for the image when a network error occurs
    func testLoadOnError() throws {
        let error = NetworkError.invalidResponse(nil)
        let dataTask = MockURLSessionDataTask(data: nil, error: error)
        let expectation = XCTestExpectation(description: "Get image asynchronously")
        
        session.nextDataTask = dataTask
        
        imageCache.load(url: imageURL as NSURL, item: item) { (item, image) in
            XCTAssertNil(image)
            expectation.fulfill()
        }
        
        // Wait for the expectation to fulfill or time out.
        wait(for: [expectation], timeout: 1.0)
    }
    
    // Checks that `load` returns a cached image when it's requested again
    func testLoadCache() throws {
        let dataTask1 = MockURLSessionDataTask(data: imageData)
        let expectation1 = XCTestExpectation(description: "Get image asynchronously")
        let expectation2 = XCTestExpectation(description: "Get image asynchronously")
        
        session.nextDataTask = dataTask1
        
        var fetchedImage: UIImage?
        imageCache.load(url: imageURL as NSURL, item: item) { [unowned self] (item, image) in
            XCTAssertEqual(image?.pngData(), UIImage(data: self.imageData)?.pngData())
            fetchedImage = image
            expectation1.fulfill()
        }
        
        // Wait for the expectation to fulfill or time out.
        wait(for: [expectation1], timeout: 1.0)
        
        XCTAssertTrue(dataTask1.isResumed)
            
        // Once the image was retrieved, initiate another load image request
        // checking that the previously fetched image is returned without another
        // network request being issued
        let dataTask2 = MockURLSessionDataTask()
        session.nextDataTask = dataTask2

        imageCache.load(url: imageURL as NSURL, item: item) { (item, image) in
            XCTAssertEqual(image, fetchedImage)
            expectation2.fulfill()
        }
        
        // Wait for the expectation to fulfill or time out.
        wait(for: [expectation2], timeout: 1.0)

        XCTAssertFalse(dataTask2.isResumed)
    }
    
    // Check that `load` calls a completion handler on all requestors
    // in case the requested images was not previously cached
    func testLoadMultipleRequestors() throws {
        let expectation1 = XCTestExpectation(description: "Get image asynchronously #1")
        let expectation2 = XCTestExpectation(description: "Get image asynchronously #2")
        var dataTask1Completion: DataTaskResult?
        
        let dataTask1 = MockURLSessionDataTask{ completion in
            // Save the completion handler for the first `load` invocation
            // and call it only after the second `load` invocation is made,
            // so that once it's called there are two requestors registered for the image
            dataTask1Completion = completion
        }
        
        session.nextDataTask = dataTask1
        
        var fetchedImage1: UIImage?
        
        imageCache.load(url: imageURL as NSURL, item: item) { (item, image) in
            XCTAssertNotNil(image)
            fetchedImage1 = image
            expectation1.fulfill()
        }
            
        let dataTask2 = MockURLSessionDataTask(data: imageData)
        session.nextDataTask = dataTask2
        
        var fetchedImage2: UIImage?

        imageCache.load(url: imageURL as NSURL, item: item) { (item, image) in
            XCTAssertNotNil(image)
            fetchedImage2 = image
            expectation2.fulfill()
        }
        
        // Once both `load` requests have been issued, call the completion handler
        // for the first data task imitating that the image was eventually fetched
        dataTask1Completion?(imageData, nil, nil)
        
        // Wait until both completion handlers have been called or time out.
        wait(for: [expectation1, expectation2], timeout: 1.0)
        
        // Data task #2 should never have been resumed
        XCTAssertTrue(dataTask1.isResumed)
        XCTAssertFalse(dataTask2.isResumed)
        
        XCTAssertEqual(fetchedImage1, fetchedImage2)
        XCTAssertEqual(fetchedImage1?.pngData(), fetchedImage2?.pngData())
    }

}
