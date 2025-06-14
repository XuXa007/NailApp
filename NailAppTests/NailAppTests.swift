import XCTest
import Foundation
@testable import NailApp

final class NailAppTests: XCTestCase {

    func testExample() async throws {
        XCTAssertTrue(true)
    }
    
    func testAPIConnection() async throws {
        let expectation = XCTestExpectation(description: "API responds")
        
        // GET запрос
        let url = URL(string: "http://172.20.10.7:8080/api/designs")!
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            XCTAssertNil(error, "Should not have error")
            XCTAssertNotNil(data, "Should have data")
            
            if let httpResponse = response as? HTTPURLResponse {
                XCTAssertEqual(httpResponse.statusCode, 200, "Should return 200")
            }
            
            expectation.fulfill()
        }
        
        task.resume()
        await fulfillment(of: [expectation], timeout: 10.0)
    }
}
