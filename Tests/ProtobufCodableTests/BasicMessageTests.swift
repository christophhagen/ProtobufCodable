import XCTest
@testable import ProtobufCodable
import SwiftProtobuf

final class BasicMessageTests: XCTestCase {

    private func roundTripBasic(_ block: (inout BasicMessage) -> Void) throws {
        var message = BasicMessage()
        block(&message)
        try roundTripProtobuf(message)
    }

    func testEncodeStruct() throws {
        let message = BasicMessage(double: 3.14, int32: 123, fixedInt64: 234, string: "Some")
        let data = try ProtobufEncoder.encode(message)
        let decoded = try BasicMessage(protoObject: .init(serializedData: data))
        XCTAssertEqual(message, decoded)
        //try encoded(message, matches: data)
    }

    func testMessageWithDouble() throws {
        try roundTripBasic { $0.double = 3.14 }
        try roundTripBasic { $0.double = -3.14 }
        try roundTripBasic { $0.double = .greatestFiniteMagnitude }
        try roundTripBasic { $0.double = .leastNonzeroMagnitude }
    }
    
    func testMessageWithFloat() throws {
        try roundTripBasic { $0.float = 3.14 }
        try roundTripBasic { $0.float = -3.14 }
        try roundTripBasic { $0.float = .greatestFiniteMagnitude }
        try roundTripBasic { $0.float = .leastNonzeroMagnitude }
    }
    
    func testMessageWithInt32() throws {
        try roundTripBasic { $0.int32 = 0 }
        try roundTripBasic { $0.int32 = 123 }
        try roundTripBasic { $0.int32 = -1234567890 }
        try roundTripBasic { $0.int32 = .min }
        try roundTripBasic { $0.int32 = .max }
    }
    
    func testMessageWithInt64() throws {
        try roundTripBasic { $0.int64 = 0 }
        try roundTripBasic { $0.int64 = 123 }
        try roundTripBasic { $0.int64 = -12345678901234 }
        try roundTripBasic { $0.int64 = .min }
        try roundTripBasic { $0.int64 = .max }
        try roundTripBasic { $0.int64 = .zero }
    }
    
    func testMessageWithUInt32() throws {
        try roundTripBasic { $0.unsignedInt32 = 0 }
        try roundTripBasic { $0.unsignedInt32 = 123 }
        try roundTripBasic { $0.unsignedInt32 = 1234567890 }
        try roundTripBasic { $0.unsignedInt32 = .min }
        try roundTripBasic { $0.unsignedInt32 = .max }
        try roundTripBasic { $0.unsignedInt32 = .zero }
    }
    
    func testMessageWithUInt64() throws {
        try roundTripBasic { $0.unsignedInt64 = 0 }
        try roundTripBasic { $0.unsignedInt64 = 123 }
        try roundTripBasic { $0.unsignedInt64 = 123456789012345 }
        try roundTripBasic { $0.unsignedInt64 = .min }
        try roundTripBasic { $0.unsignedInt64 = .max }
        try roundTripBasic { $0.unsignedInt64 = .zero }
    }
    
    func testMessageWithSignedInt32() throws {
        try roundTripBasic { $0.signedInt32 = 0 }
        try roundTripBasic { $0.signedInt32 = 123 }
        try roundTripBasic { $0.signedInt32 = -123456789 }
        try roundTripBasic { $0.signedInt32 = .min }
        try roundTripBasic { $0.signedInt32 = .max }
        try roundTripBasic { $0.signedInt32 = .zero }
    }
    
    func testMessageWithSignedInt64() throws {
        try roundTripBasic { $0.signedInt64 = 0 }
        try roundTripBasic { $0.signedInt64 = 123 }
        try roundTripBasic { $0.signedInt64 = -123456789012345 }
        try roundTripBasic { $0.signedInt64 = .min }
        try roundTripBasic { $0.signedInt64 = .max }
        try roundTripBasic { $0.signedInt64 = .zero }
    }
    
    func testMessageWithFixedUInt32() throws {
        try roundTripBasic { $0.fixedInt32 = 0 }
        try roundTripBasic { $0.fixedInt32 = 123 }
        try roundTripBasic { $0.fixedInt32 = 123456789 }
        try roundTripBasic { $0.fixedInt32 = .min }
        try roundTripBasic { $0.fixedInt32 = .max }
        try roundTripBasic { $0.fixedInt32 = .zero }
    }
    
    func testMessageWithFixedUInt64() throws {
        try roundTripBasic { $0.fixedInt64 = 0 }
        try roundTripBasic { $0.fixedInt64 = 123 }
        try roundTripBasic { $0.fixedInt64 = 123456789012345 }
        try roundTripBasic { $0.fixedInt64 = .min }
        try roundTripBasic { $0.fixedInt64 = .max }
        try roundTripBasic { $0.fixedInt64 = .zero }
    }
    
    func testMessageWithSignedFixedInt32() throws {
        try roundTripBasic { $0.signedFixedInt32 = 0 }
        try roundTripBasic { $0.signedFixedInt32 = 123 }
        try roundTripBasic { $0.signedFixedInt32 = -123456789 }
        try roundTripBasic { $0.signedFixedInt32 = .min }
        try roundTripBasic { $0.signedFixedInt32 = .max }
        try roundTripBasic { $0.signedFixedInt32 = .zero }
    }
    
    func testMessageWithSignedFixedInt64() throws {
        try roundTripBasic { $0.signedFixedInt64 = 0 }
        try roundTripBasic { $0.signedFixedInt64 = 123 }
        try roundTripBasic { $0.signedFixedInt64 = -123456789012345 }
        try roundTripBasic { $0.signedFixedInt64 = .min }
        try roundTripBasic { $0.signedFixedInt64 = .max }
        try roundTripBasic { $0.signedFixedInt64 = .zero }
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

