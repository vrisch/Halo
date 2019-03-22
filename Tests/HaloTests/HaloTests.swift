import Foundation
import XCTest
import Halo

extension Tag {
    static let test = Tag(rawValue: 100)
}

class HaloTests: XCTestCase {
    func testExample() {
        let stackView = UIStackView()
        XCTAssertNotNil(stackView.add(element: .button(tag: .test, style: .none, title: "Test")))
        XCTAssertEqual(stackView.arrangedSubviews.count, 1)
    }

    func testGet() {
        let stackView = UIStackView()
        stackView.add(element: .button(tag: .test, style: .none, title: "Test"))
        #if os(OSX)
            XCTAssertNotNil(stackView.get(NSButton.self, tag: .test))
        #else
            XCTAssertNotNil(stackView.get(UIButton.self, tag: .test))
        #endif
    }

    static var allTests = [
        ("testExample", testExample),
        ("testGet", testGet),
    ]
}
