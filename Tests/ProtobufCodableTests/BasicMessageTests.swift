import XCTest
@testable import ProtobufCodable
import SwiftProtobuf

final class BasicMessageTests: XCTestCase {

    private func roundTripBasic(_ block: (inout BasicMessage) -> Void) throws {
        var message = BasicMessage()
        block(&message)
        try roundTripProtobuf(message)
    }

    func testMessageWithDouble() throws {
        try roundTripBasic { $0.double = 3.14 }
        try roundTripBasic { $0.double = -3.14 }
    }
    
    func testMessageWithFloat() throws {
        try roundTripBasic { $0.float = 3.14 }
        try roundTripBasic { $0.float = -3.14 }
    }
    
    func testMessageWithInt32() throws {
        try roundTripBasic { $0.int32 = 0 }
        try roundTripBasic { $0.int32 = 123 }
        try roundTripBasic { $0.int32 = -1234567890 }
    }
    
    func testMessageWithInt64() throws {
        try roundTripBasic { $0.int64 = 0 }
        try roundTripBasic { $0.int64 = 123 }
        try roundTripBasic { $0.int64 = -12345678901234 }
    }
    
    func testMessageWithUInt32() throws {
        try roundTripBasic { $0.unsignedInt32 = 0 }
        try roundTripBasic { $0.unsignedInt32 = 123 }
        try roundTripBasic { $0.unsignedInt32 = 1234567890 }
    }
    
    func testMessageWithUInt64() throws {
        try roundTripBasic { $0.unsignedInt64 = 0 }
        try roundTripBasic { $0.unsignedInt64 = 123 }
        try roundTripBasic { $0.unsignedInt64 = 123456789012345 }
    }
    
    func testMessageWithSignedInt32() throws {
        try roundTripBasic { $0.signedInt32 = 0 }
        try roundTripBasic { $0.signedInt32 = 123 }
        try roundTripBasic { $0.signedInt32 = -123456789 }
    }
    
    func testMessageWithSignedInt64() throws {
        try roundTripBasic { $0.signedInt64 = 0 }
        try roundTripBasic { $0.signedInt64 = 123 }
        try roundTripBasic { $0.signedInt64 = -123456789012345 }
    }
    
    func testMessageWithFixedUInt32() throws {
        try roundTripBasic { $0.fixedInt32 = 0 }
        try roundTripBasic { $0.fixedInt32 = 123 }
        try roundTripBasic { $0.fixedInt32 = 123456789 }
    }
    
    func testMessageWithFixedUInt64() throws {
        try roundTripBasic { $0.fixedInt64 = 0 }
        try roundTripBasic { $0.fixedInt64 = 123 }
        try roundTripBasic { $0.fixedInt64 = 123456789012345 }
    }
    
    func testMessageWithSignedFixedInt32() throws {
        try roundTripBasic { $0.signedFixedInt32 = 0 }
        try roundTripBasic { $0.signedFixedInt32 = 123 }
        try roundTripBasic { $0.signedFixedInt32 = -123456789 }
    }
    
    func testMessageWithSignedFixedInt64() throws {
        try roundTripBasic { $0.signedFixedInt64 = 0 }
        try roundTripBasic { $0.signedFixedInt64 = 123 }
        try roundTripBasic { $0.signedFixedInt64 = -123456789012345 }
    }
    
    func testMessageWithBoolean() throws {
        try roundTripBasic { $0.boolean = false }
        try roundTripBasic { $0.boolean = true }
    }
    
    func testMessageWithString() throws {
        try roundTripBasic { $0.string = "" }
        try roundTripBasic { $0.string = "SomeText" }
    }
    
    func testMessageWithBytes() throws {
        try roundTripBasic { $0.bytes = Data(repeating: 42, count: 24) }
        try roundTripBasic { $0.bytes = .empty }
        try roundTripBasic { $0.bytes = Data(repeating: 42, count: 1234) }
    }
}

