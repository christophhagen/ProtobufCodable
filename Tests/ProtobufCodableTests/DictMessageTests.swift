import XCTest
import ProtobufCodable
import SwiftProtobuf

final class DictMessageTests: XCTestCase {

    func testStringDict() throws {
        try roundTripProtobuf(DictContainer(stringDict: ["Some" : 123, "More" : 234]))
    }
    
    func testUIntDict() throws {
        try roundTripProtobuf(DictContainer(
            uintDict: [123 : BasicMessage(int32: 234),
                       3456 : BasicMessage(fixedInt32: 456)]))
    }
    
    func testIntDict() throws {
        try roundTripProtobuf(DictContainer(
            intDict: [123 : BasicMessage(int32: 234),
                      -345 : BasicMessage(fixedInt32: 456)]))
    }
}

