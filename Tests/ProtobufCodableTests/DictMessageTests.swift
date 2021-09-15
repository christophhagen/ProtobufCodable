import XCTest
import ProtobufCodable
import SwiftProtobuf

final class DictMessageTests: XCTestCase {
    
    private func roundTrip(_ block: (inout DictContainer) -> Void) throws {
        try roundTripBoth(block)
    }
    
    func testStringDict() throws {
        try roundTrip {
            $0.stringDict = ["Some" : 123, "More" : 234]
        }
    }
    
    func testUIntDict() throws {
        try roundTrip {
            $0.uintDict = [123 : BasicMessage(int32: 234),
                           3456 : BasicMessage(fixedInt32: 456)]
        }
    }
    
    func testIntDict() throws {
        try roundTrip {
            $0.intDict = [123 : BasicMessage(int32: 234),
                          -345 : BasicMessage(fixedInt32: 456)]
        }
    }
}


