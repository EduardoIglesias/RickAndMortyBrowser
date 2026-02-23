//
//  RickAndMortyBrowserUITestsLaunchTests.swift
//  RickAndMortyBrowser
//
//  Created by Eduardo Iglesias Fernandez on 23/2/26.
//

import XCTest

final class RickAndMortyBrowserUITestsLaunchTests: XCTestCase {
    // swiftlint:disable static_over_final_class
    override class var runsForEachTargetApplicationUIConfiguration: Bool { true }
    // swiftlint:enable static_over_final_class

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        // Insert steps here to perform after app launch but before taking a screenshot,
        // such as logging into a test account or navigating somewhere in the app

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
