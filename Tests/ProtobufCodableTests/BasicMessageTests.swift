import XCTest
import ProtobufCodable
import SwiftProtobuf

final class BasicMessageTests: XCTestCase {

    func roundTripCompare<T>(type: T.Type = T.self, _ value: T) throws where T: Codable, T: Equatable {
        let data = try ProtobufEncoder().encode(value)
        let decoded = try ProtobufDecoder().decode(T.self, from: data)
        XCTAssertEqual(decoded, value)
        if decoded != value {
            print(value)
            print(data.bytes)
        }
    }

    func roundTrip(_ block: (inout BasicMessage) -> Void) throws {
        var message = BasicMessage()
        block(&message)
        let data = try message.protobuf.serializedData()
        let decodedCodable: BasicMessage = try ProtobufDecoder().decode(from: data)
        XCTAssertEqual(message, decodedCodable)
        let data2 = try ProtobufEncoder().encode(message)
        let decodedProtobuf = try BasicMessage.ProtobufType(serializedData: data2)
        XCTAssertEqual(decodedProtobuf, message.protobuf)

        let decoded: BasicMessage = try ProtobufDecoder().decode(from: data)
        XCTAssertEqual(decoded, message)
    }

    func testMessageWithDouble() throws {
        try roundTrip { $0.double = 3.14 }
        try roundTrip { $0.double = -3.14 }
    }
    
    func testMessageWithFloat() throws {
        try roundTrip { $0.float = 3.14 }
        try roundTrip { $0.float = -3.14 }
    }
    
    func testMessageWithInt32() throws {
        try roundTrip { $0.int32 = 0 }
        try roundTrip { $0.int32 = 123 }
        try roundTrip { $0.int32 = -1234567890 }
    }
    
    func testMessageWithInt64() throws {
        try roundTrip { $0.int64 = 0 }
        try roundTrip { $0.int64 = 123 }
        try roundTrip { $0.int64 = -12345678901234 }
    }
    
    func testMessageWithUInt32() throws {
        try roundTrip { $0.unsignedInt32 = 0 }
        try roundTrip { $0.unsignedInt32 = 123 }
        try roundTrip { $0.unsignedInt32 = 1234567890 }
    }
    
    func testMessageWithUInt64() throws {
        try roundTrip { $0.unsignedInt64 = 0 }
        try roundTrip { $0.unsignedInt64 = 123 }
        try roundTrip { $0.unsignedInt64 = 123456789012345 }
    }
    
    func testMessageWithSignedInt32() throws {
        try roundTrip { $0.signedInt32 = 0 }
        try roundTrip { $0.signedInt32 = 123 }
        try roundTrip { $0.signedInt32 = -123456789 }
    }
    
    func testMessageWithSignedInt64() throws {
        try roundTrip { $0.signedInt64 = 0 }
        try roundTrip { $0.signedInt64 = 123 }
        try roundTrip { $0.signedInt64 = -123456789012345 }
    }
    
    func testMessageWithFixedUInt32() throws {
        try roundTrip { $0.fixedInt32 = 0 }
        try roundTrip { $0.fixedInt32 = 123 }
        try roundTrip { $0.fixedInt32 = 123456789 }
    }
    
    func testMessageWithFixedUInt64() throws {
        try roundTrip { $0.fixedInt64 = 0 }
        try roundTrip { $0.fixedInt64 = 123 }
        try roundTrip { $0.fixedInt64 = 123456789012345 }
    }
    
    func testMessageWithSignedFixedInt32() throws {
        try roundTrip { $0.signedFixedInt32 = 0 }
        try roundTrip { $0.signedFixedInt32 = 123 }
        try roundTrip { $0.signedFixedInt32 = -123456789 }
    }
    
    func testMessageWithSignedFixedInt64() throws {
        try roundTrip { $0.signedFixedInt64 = 0 }
        try roundTrip { $0.signedFixedInt64 = 123 }
        try roundTrip { $0.signedFixedInt64 = -123456789012345 }
    }
    
    func testMessageWithBoolean() throws {
        try roundTrip { $0.boolean = false }
        try roundTrip { $0.boolean = true }
    }
    
    func testMessageWithString() throws {
        try roundTrip { $0.string = "" }
        try roundTrip { $0.string = "SomeText" }
    }
    
    func testMessageWithBytes() throws {
        try roundTrip { $0.bytes = Data(repeating: 42, count: 24) }
        try roundTrip { $0.bytes = .empty }
        try roundTrip { $0.bytes = Data(repeating: 42, count: 1234) }
    }
}

