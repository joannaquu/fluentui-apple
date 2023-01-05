//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest

class TableViewCellFileAccessoryViewTest: XCTestCase {
    let app = XCUIApplication()
    var controlName: String = "TableViewCellFileAccessoryView"

    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false
        app.launch()
        navigateToControl(app: app, controlName: controlName)
    }

    // launch test that ensures the demo app does not crash and is on the correct control page
    func testLaunch() throws {
        XCTAssertTrue(app.navigationBars[controlName].exists)
    }
}
