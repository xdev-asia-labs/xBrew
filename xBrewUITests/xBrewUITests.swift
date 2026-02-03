import XCTest

/// UI Tests for capturing App Store screenshots
/// Captures only the app window (not full screen)
@MainActor
class xBrewUITests: XCTestCase {
    
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments = ["--screenshot-mode"]
        app.launch()
        
        // Wait for app to fully load
        sleep(3)
        
        // Activate the app window
        app.activate()
    }
    
    override func tearDownWithError() throws {
        // Clean up if needed
    }
    
    // MARK: - Helper to capture screenshot of WINDOW ONLY
    
    func captureScreenshot(name: String) {
        // Use windows.firstMatch.screenshot() to capture only the main window
        let window = app.windows.firstMatch
        if window.exists {
            let screenshot = window.screenshot()
            let attachment = XCTAttachment(screenshot: screenshot)
            attachment.name = name
            attachment.lifetime = .keepAlways
            add(attachment)
        } else {
            // Fallback to app screenshot
            let screenshot = app.screenshot()
            let attachment = XCTAttachment(screenshot: screenshot)
            attachment.name = name
            attachment.lifetime = .keepAlways
            add(attachment)
        }
    }
    
    // MARK: - Screenshot Tests
    
    func test01Dashboard() throws {
        // Dashboard is the default view
        captureScreenshot(name: "01_Dashboard")
    }
    
    func test02Packages() throws {
        let packagesText = app.staticTexts["Packages"].firstMatch
        if packagesText.waitForExistence(timeout: 3) {
            packagesText.click()
            sleep(1)
        }
        captureScreenshot(name: "02_Packages")
    }
    
    func test03Casks() throws {
        let casksText = app.staticTexts["Casks"].firstMatch
        if casksText.waitForExistence(timeout: 3) {
            casksText.click()
            sleep(1)
        }
        captureScreenshot(name: "03_Casks")
    }
    
    func test04Services() throws {
        let servicesText = app.staticTexts["Services"].firstMatch
        if servicesText.waitForExistence(timeout: 3) {
            servicesText.click()
            sleep(1)
        }
        captureScreenshot(name: "04_Services")
    }
    
    func test05Taps() throws {
        let tapsText = app.staticTexts["Taps"].firstMatch
        if tapsText.waitForExistence(timeout: 3) {
            tapsText.click()
            sleep(1)
        }
        captureScreenshot(name: "05_Taps")
    }
    
    func test06Maintenance() throws {
        let maintenanceText = app.staticTexts["Maintenance"].firstMatch
        if maintenanceText.waitForExistence(timeout: 3) {
            maintenanceText.click()
            sleep(1)
        }
        captureScreenshot(name: "06_Maintenance")
    }
}
