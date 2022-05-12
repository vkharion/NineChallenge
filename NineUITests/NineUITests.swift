//
//  NineUITests.swift
//  NineUITests
//
//  Created by abc on 7/5/22.
//

import XCTest

class NineUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // Checks that `ArticlesTableViewController` presents articles from the test
    // payload correctly
    func testArticlesTableViewControllerArticles() throws {
        let app = XCUIApplication()
        app.launchArguments += ["UI-TESTING"]
        
        let urlString = "https://bruce-v2-mob.fairfaxmedia.com.au/1/coding_test/13ZZQX/full"
        let data = UITestUtils.loadResource("Payload", withExtension: "json")!
        let jsonString = String(data: data, encoding: .utf8)
        app.launchEnvironment[urlString] = jsonString
        
        app.launch()
        
        let tableQuery = app.tables.element
        
        // Wait for the table view to appear
        XCTAssertTrue(tableQuery.waitForExistence(timeout: 1.0))
        
        // Check the navigation bar title
        let navBar = app.navigationBars.element
        XCTAssertNotNil(navBar.staticTexts["AFR iPad Editor's Choice"])
        
        // Check for the total number of articles
        XCTAssertEqual(tableQuery.cells.count, 13)
        
        // Check for the correct labels for the first cell
        let firstCell = tableQuery.cells.firstMatch
        XCTAssertEqual(firstCell.staticTexts.count, 3)
        XCTAssertTrue(firstCell.staticTexts["Macquarie’s compliance cost explosion"].exists)
        let predAbstract = NSPredicate(format: "label == %@", "Diversified investment banking and funds management group Macquarie could soon be spending more on compliance than technology investment.")
        XCTAssertEqual(firstCell.staticTexts.matching(predAbstract).count, 1)
        XCTAssertTrue(firstCell.staticTexts["Tony Boyd"].exists)
    }

    // Tests `ArticlesTableViewController` to ensure that tapping on the first cell
    // presents a web view with the matching article
    func testArticlesDetailViewController() throws {
        let app = XCUIApplication()
        app.launchArguments += ["UI-TESTING"]
        
        let urlString = "https://bruce-v2-mob.fairfaxmedia.com.au/1/coding_test/13ZZQX/full"
        let data = UITestUtils.loadResource("Payload", withExtension: "json")!
        let jsonString = String(data: data, encoding: .utf8)
        app.launchEnvironment[urlString] = jsonString
        
        app.launch()
        
        let tableQuery = app.tables.element
        
        // Wait for the table view to appear
        XCTAssertTrue(tableQuery.waitForExistence(timeout: 1.0))
               
        
        tableQuery.cells.firstMatch.tap()
        
        // Wait for the web view to appear
        let webView = app.webViews.element
        XCTAssertTrue(webView.waitForExistence(timeout: 1.0))
        
        XCTAssertTrue(webView/*@START_MENU_TOKEN@*/.otherElements["article"]/*[[".otherElements[\"Four ways you can beat afternoon tiredness (Medibank chief executive David Koczkar reaches for his cello)\"].otherElements[\"article\"]",".otherElements[\"article\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.children(matching: .other)["Macquarie’s compliance cost explosion"].exists)
    }
}


// MARK: - UITestUtils

class UITestUtils {

    // Returns a resource file URL from the test bundle
    class func resourceURL(_ resource: String, withExtension: String) -> URL? {
        return Bundle(for: UITestUtils.self).url(forResource: resource, withExtension: withExtension)
    }

    // Loads a resource file from the test bundle
    class func loadResource(_ resource: String, withExtension: String) -> Data? {
        if let resourceURL = resourceURL(resource, withExtension: withExtension)  {
            return try? Data(contentsOf: resourceURL)
        }
        return nil
    }
}
