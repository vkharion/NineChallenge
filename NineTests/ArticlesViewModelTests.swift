//
//  ArticlesViewModelTests.swift
//  NineTests
//
//  Created by abc on 10/5/22.
//

import XCTest
@testable import Nine

class ArticlesViewModelTests: XCTestCase {
    
    let imageData = TestUtils.imageData(id: 1)
    var session: MockURLSession!
    var imageCache: ImageCache!
    var viewModel: ArticlesViewModel!
    var delegate: ArticlesViewModelDelegateProxy!
    var dataProvider: ArticlesDataProvider!
    
    override func setUpWithError() throws {
        // Configure the image cache to return the test image by default
        session = MockURLSession()
        imageCache = ImageCache(urlSession: session)
        session.nextDataTask = MockURLSessionDataTask(data: imageData)
        
        delegate = ArticlesViewModelDelegateProxy()
        dataProvider = ArticlesDataProvider()
        viewModel = ArticlesViewModel(delegate: delegate, dataProvider: dataProvider, imageCache: imageCache)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // Checks that `loadItems` populates the view state with the correct title as well as
    // the correct items sorted by timestamp in the descending order
    func testLoadItems() throws {
        let expViewState = XCTestExpectation(description: "viewStateChanged")
        let expError = XCTestExpectation(description: "no error reported")
        expError.isInverted = true
        let articles = TestUtils.loadArticles()!
        
        dataProvider.completionHandler = { completion in
            completion(.success(articles))
        }
        
        delegate.viewStateChangedBlock = { viewState in
            // Check the view state so that
            // 1) Title matches `displayName`
            XCTAssertEqual(viewState.title, articles.displayName)
            
            // 2) Items have been populated correctly and sorted by timestamp in a descending order
            let items = TestUtils.loadItems()?.sorted(by: { $0.timestamp > $1.timestamp })
            XCTAssertEqual(viewState.items, items)
            
            // Indicate that the view has changed as expected
            expViewState.fulfill()
        }
        
        delegate.handleErrorBlock = { error in
            // Indicate the error was reported unexpectedly
            expError.fulfill()
        }
        
        viewModel.loadItems()
        
        // Wait for the expectations to fulfill or time out.
        wait(for: [expViewState, expError], timeout: 1.0)
    }
    
    // Checks that `loadItems` reports errors from its data provider to the delegate
    // and keeps the view state unchanged
    func testLoadItemsOnError() throws {
        let expViewState = XCTestExpectation(description: "view state has not changed")
        expViewState.isInverted = true
        let expError = XCTestExpectation(description: "error reported")
        let error = NetworkError.invalidResponse(nil)
        
        dataProvider.completionHandler = { completion in
            completion(.failure(error))
        }
        
        delegate.viewStateChangedBlock = { viewState in
            // Indicate that the view state did change unexpectedly
            expViewState.fulfill()
        }
        
        delegate.handleErrorBlock = { error in
            if case .invalidResponse(_) = error as? NetworkError {
                // Indicate that the error has been reported to the delegate
                expError.fulfill()
            }
        }
        
        viewModel.loadItems()
        
        // Wait for the expectations to fulfill or time out.
        wait(for: [expViewState, expError], timeout: 1.0)
    }

    // Checks that `loadItemImage` 1) loads the image asynchronously, 2) caches it and
    // 3) triggers the state view update
    func testLoadItemImage() throws {
        let expViewState1 = XCTestExpectation(description: "viewStateChanged (loadItems)")
        let expViewState2 = XCTestExpectation(description: "viewStateChanged (loadItemImage#1)")
        let articles = TestUtils.loadArticles()!
        
        dataProvider.completionHandler = { completion in
            completion(.success(articles))
        }
        
        delegate.viewStateChangedBlock = { viewState in
            // Indicate that the view state did change
            expViewState1.fulfill()
        }
        
        XCTAssertTrue(viewModel.viewState.items.isEmpty)
        
        viewModel.loadItems()
        
        // Wait until initial load completes or time out.
        wait(for: [expViewState1], timeout: 1.0)
                        
        
        // Once the initial load is complete, check that
        // 1) view state `items` have been populated and
        // 2) items have no thumbnail
        XCTAssertFalse(viewModel.viewState.items.isEmpty)
        
        for item in viewModel.viewState.items {
            XCTAssertNil(item.image)
        }

        // Prepare the delegate and request the thumbnail image for the first item
        delegate.viewStateChangedBlock = { viewState in
            // Indicate that the view state did change a second time
            expViewState2.fulfill()
        }
        
        viewModel.loadItemImage(viewModel.viewState.items.first!)
        
        // Wait until the image loading completes or time out.
        wait(for: [expViewState2], timeout: 2.0)
        
        XCTAssertNotNil(viewModel.viewState.items.first?.image)
        
        // Finally, attempt to fetch the image for the second time ensuring that
        // the view state is not changed

        let expViewState3 = XCTestExpectation(description: "viewStateChanged (loadItemImage#2)")
        expViewState3.isInverted = true
        
        delegate.viewStateChangedBlock = { viewState in
            // Indicate that the view state did change a second time
            expViewState3.fulfill()
        }
        
        // Wait for the expectations or time out.
        wait(for: [expViewState3], timeout: 1.0)
    }

    // Tests `loadItemImage` to ensure that an error loading the thumbnail image isn't
    // reported via the delegate
    func testLoadItemImageOnError() throws {
        let expViewState1 = XCTestExpectation(description: "viewStateChanged (loadItems)")
        let expViewState2 = XCTestExpectation(description: "viewStateChanged (loadItemImage#1)")
        expViewState2.isInverted = true
        let expError = XCTestExpectation(description: "error reported (loadItemImage#1)")
        expError.isInverted = true
        let expImageCacheLoad = XCTestExpectation(description: "imageCache.load ")
        let error = NetworkError.invalidResponse(nil)
        
        dataProvider.completionHandler = { completion in
            let articles = TestUtils.loadArticles()!
            completion(.success(articles))
        }
        
        delegate.viewStateChangedBlock = { viewState in
            // Indicate that the view state did change
            expViewState1.fulfill()
        }
        
        viewModel.loadItems()
        
        // Wait until initial load completes or time out.
        wait(for: [expViewState1], timeout: 1.0)
                        
        
        // Once the initial load is complete, check that `items` have been populated
        XCTAssertFalse(viewModel.viewState.items.isEmpty)
        
        // Override the image cache session to return an error
        session.nextDataTask = MockURLSessionDataTask{ completion in
            completion(nil, nil, error)
            // Indicate the image has been requested from the cache
            expImageCacheLoad.fulfill()
        }

        // Prepare the delegate and request the thumbnail image for the first item
        delegate.viewStateChangedBlock = { viewState in
            // Indicate that the view state has changed unexpectely
            expViewState2.fulfill()
        }
        
        delegate.handleErrorBlock = { error in
            // Indicate that the error has been reported unexpectely
            expError.fulfill()
        }
        
        viewModel.loadItemImage(viewModel.viewState.items.first!)
        
        // Wait the expectations or time out.
        wait(for: [expImageCacheLoad, expViewState2, expError], timeout: 3.0)
    }
    
}

// MARK: - ArticlesViewModelDelegateProxy

class ArticlesViewModelDelegateProxy: NSObject, ArticlesViewModelDelegate {
    
    var viewStateChangedBlock: ((_ viewState: ArticlesViewModel.ViewState) -> Void)?
    var handleErrorBlock: ((_ error: Error) -> Void)?
    
    func viewStateChanged(_ viewState: ArticlesViewModel.ViewState) {
        viewStateChangedBlock?(viewState)
    }
    
    func handleError(_ error: Error) {
        handleErrorBlock?(error)
    }
}

// MARK: - ArticlesDataProvider

class ArticlesDataProvider: EditorsChoiceProvider {
    typealias CompletionHandler = (Result<Articles, Error>) -> Void
    
    var completionHandler: ((CompletionHandler) -> Void)?
    
    func getEditorsChoiceArticles(completion: @escaping CompletionHandler) {
        if let handler = completionHandler {
            handler(completion)
        } else {
            fatalError("Missing `completionHandler`")
        }
    }
}
