import XCTest
import ProtobufCodable
import SwiftProtobuf

final class NestedMessageTests: XCTestCase {
    
    private let basic = BasicMessage(
        double: 3.14,
        int64: -123456789012345,
        unsignedInt32: 123456789,
        signedInt64: -234567890123456,
        fixedInt32: 2334567890,
        signedFixedInt32: 123456,
        boolean: false,
        string: "SomeText")
    
    func testNestedMessage() throws {
        let nested = Nested(double: -3.14, uint: 123567890)
        let nestedMessage = NestedMessage(basic: basic, nested: nested)
        
        try roundTrip(nestedMessage)
    }
    
    func testEmptyNestedMessage() throws {
        let nestedMessage = NestedMessage(basic: BasicMessage(double: 3.14), nested: Nested())
        
        try roundTrip(nestedMessage)
    }
    
    func testDeepNestedMessage() throws {
        let nested = Nested(double: -3.14, uint: 123567890)
        let nestedMessage = NestedMessage(basic: basic, nested: nested)
        let codableDeep = DeepNestedMessage(basic: basic, nested: nestedMessage)
        
        try roundTrip(codableDeep)
    }
}
