//
//  BevUITests.swift
//  BevUITests
//
//  Created by Jacob Bartlett on 28/12/2023.
//

import XCTest

final class BevUITests: XCTestCase {
    
    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI-TESTING"]
        app.launch()
    }

    override func tearDown() {
        app = nil
        super.tearDown()
    }

    func test_launch_displaysNavTitle() {
        let navTitleElement = app.staticTexts["Bev"]
        XCTAssertTrue(navTitleElement.exists)
    }
    
    func test_load_displaysBeers() {
        let buzzElement = app.staticTexts["Buzz"]
        let trashyElement = app.staticTexts["Trashy Blonde"]
        XCTAssertTrue(buzzElement.exists)
        XCTAssertTrue(trashyElement.exists)
    }
    
    func test_selectBeer_navigatesToDetailsScreen() {
        let buzzElement = app.staticTexts["Buzz"]
        buzzElement.tap()
        let detailsScreenHeaderElement = app.staticTexts["DRINK THIS WITH"]
        XCTAssertTrue(detailsScreenHeaderElement.exists)
    }
    
    func test_searchBeer() {
        let searchBar = app.searchFields["Search 2 beers"]
        XCTAssertTrue(searchBar.exists)
        searchBar.tap()
        searchBar.typeText("Trashy")
        let buzzElement = app.staticTexts["Buzz"]
        let trashyElement = app.staticTexts["Trashy Blonde"]
        XCTAssertFalse(buzzElement.exists)
        XCTAssertTrue(trashyElement.exists)
    }
}
