//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest

class HUDTestSwiftUI: XCTestCase {
    let app = XCUIApplication()
    var controlName: String = "HUD"

    override func setUpWithError() throws {
        try super.setUpWithError()
        app.launch()
        navigateToControl(app: app, controlName: controlName)
        app.staticTexts["SwiftUI Demo"].tap()
    }

    // launch test that ensures the demo app does not crash and is on the correct control page
    func testLaunch() throws {
        XCTAssertTrue(app.navigationBars.element(matching: NSPredicate(format: "identifier CONTAINS %@", controlName)).exists)
    }
}
