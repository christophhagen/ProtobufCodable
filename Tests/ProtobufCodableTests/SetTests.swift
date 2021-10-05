import XCTest
@testable import ProtobufCodable
import SwiftProtobuf

final class SetTests: XCTestCase {

    func testSet() throws {
        
        let test: Set<Int> = [1,2,3,4,5]
        try roundTripCodable(test)
    }
    
    func testNestedSet() throws {
        
        struct Test: Codable, Equatable {
            
            let a: Set<Int>
        }
        
        let test = Test(a: [1,2,3,4,5])
        try roundTripCodable(test)
    }
}
