import XCTest
import ProtobufCodable
import SwiftProtobuf

final class BasicMessageTests: XCTestCase {
    
    private func compare<T: Codable>(_ type: T.Type, _ value: T, block: (T, inout PB_BasicMessage, inout BasicMessage) -> Void) throws {
        var codableMessage = BasicMessage()
        let pbData = try PB_BasicMessage.with {
            block(value, &$0, &codableMessage)
        }.serializedData()
        let codableData = try ProtobufEncoder().encode(codableMessage)
        XCTAssertEqual(pbData.bytes, codableData.bytes)
    }
    
    func testMessageWithDouble() throws {
        try compare(Double.self, 3.14) { value, pb, c in
            pb.double = value
            c.double = value
        }
        try compare(Double.self, -3.14) { value, pb, c in
            pb.double = value
            c.double = value
        }
    }
    
    func testMessageWithFloat() throws {
        try compare(Float.self, 3.14) { value, pb, c in
            pb.float = value
            c.float = value
        }
        try compare(Float.self, -3.14) { value, pb, c in
            pb.float = value
            c.float = value
        }
    }
    
    func testMessageWithInt32() throws {
        try compare(Int32.self, 0) { value, pb, c in
            pb.int32 = value
            c.int32 = value
        }
        try compare(Int32.self, 123) { value, pb, c in
            pb.int32 = value
            c.int32 = value
        }
        try compare(Int32.self, -1234567890) { value, pb, c in
            pb.int32 = value
            c.int32 = value
        }
    }
    
    func testMessageWithInt64() throws {
        try compare(Int64.self, 0) { value, pb, c in
            pb.int64 = value
            c.int64 = value
        }
        try compare(Int64.self, 123) { value, pb, c in
            pb.int64 = value
            c.int64 = value
        }
        try compare(Int64.self, -12345678901234) { value, pb, c in
            pb.int64 = value
            c.int64 = value
        }
    }
    
    func testMessageWithUInt32() throws {
        try compare(UInt32.self, 0) { value, pb, c in
            pb.unsignedInt32 = value
            c.unsignedInt32 = value
        }
        try compare(UInt32.self, 123) { value, pb, c in
            pb.unsignedInt32 = value
            c.unsignedInt32 = value
        }
        try compare(UInt32.self, 1234567890) { value, pb, c in
            pb.unsignedInt32 = value
            c.unsignedInt32 = value
        }
    }
    
    func testMessageWithUInt64() throws {
        try compare(UInt64.self, 0) { value, pb, c in
            pb.unsignedInt64 = value
            c.unsignedInt64 = value
        }
        try compare(UInt64.self, 123) { value, pb, c in
            pb.unsignedInt64 = value
            c.unsignedInt64 = value
        }
        try compare(UInt64.self, 123456789012345) { value, pb, c in
            pb.unsignedInt64 = value
            c.unsignedInt64 = value
        }
    }
    
    func testMessageWithSignedInt32() throws {
        try compare(Int32.self, 0) { value, pb, c in
            pb.signedInt32 = value
            c.signedInt32 = value
        }
        try compare(Int32.self, 123) { value, pb, c in
            pb.signedInt32 = value
            c.signedInt32 = value
        }
        try compare(Int32.self, -123456789) { value, pb, c in
            pb.signedInt32 = value
            c.signedInt32 = value
        }
    }
    
    func testMessageWithSignedInt64() throws {
        try compare(Int64.self, 0) { value, pb, c in
            pb.signedInt64 = value
            c.signedInt64 = value
        }
        try compare(Int64.self, 123) { value, pb, c in
            pb.signedInt64 = value
            c.signedInt64 = value
        }
        try compare(Int64.self, -123456789012345) { value, pb, c in
            pb.signedInt64 = value
            c.signedInt64 = value
        }
    }
    
    func testMessageWithFixedUInt32() throws {
        try compare(UInt32.self, 0) { value, pb, c in
            pb.fixedInt32 = value
            c.fixedInt32 = value
        }
        try compare(UInt32.self, 123) { value, pb, c in
            pb.fixedInt32 = UInt32(value)
            c.fixedInt32 = value
        }
        try compare(UInt32.self, 123456789) { value, pb, c in
            pb.fixedInt32 = UInt32(value)
            c.fixedInt32 = value
        }
    }
    
    func testMessageWithFixedUInt64() throws {
        try compare(UInt64.self, 0) { value, pb, c in
            pb.fixedInt64 = UInt64(value)
            c.fixedInt64 = value
        }
        try compare(UInt64.self, 123) { value, pb, c in
            pb.fixedInt64 = UInt64(value)
            c.fixedInt64 = value
        }
        try compare(UInt64.self, 123456789) { value, pb, c in
            pb.fixedInt64 = UInt64(value)
            c.fixedInt64 = value
        }
    }
    
    func testMessageWithSignedFixedInt32() throws {
        try compare(Int32.self, 0) { value, pb, c in
            pb.signedFixedInt32 = Int32(value)
            c.signedFixedInt32 = value
        }
        try compare(Int32.self, 123) { value, pb, c in
            pb.signedFixedInt32 = Int32(value)
            c.signedFixedInt32 = value
        }
        try compare(Int32.self, -123456789) { value, pb, c in
            pb.signedFixedInt32 = Int32(value)
            c.signedFixedInt32 = value
        }
    }
    
    func testMessageWithSignedFixedInt64() throws {
        try compare(Int64.self, 0) { value, pb, c in
            pb.signedFixedInt64 = Int64(value)
            c.signedFixedInt64 = value
        }
        try compare(Int64.self, 123) { value, pb, c in
            pb.signedFixedInt64 = Int64(value)
            c.signedFixedInt64 = value
        }
        try compare(Int64.self, -123456789) { value, pb, c in
            pb.signedFixedInt64 = Int64(value)
            c.signedFixedInt64 = value
        }
    }
    
    func testMessageWithBoolean() throws {
        try compare(Bool.self, false) { value, pb, c in
            pb.boolean = value
            c.boolean = value
        }
        try compare(Bool.self, true) { value, pb, c in
            pb.boolean = value
            c.boolean = value
        }
    }
    
    func testMessageWithString() throws {
        try compare(String.self, "") { value, pb, c in
            pb.string = value
            c.string = value
        }
        try compare(String.self, "SomeText") { value, pb, c in
            pb.string = value
            c.string = value
        }
    }
    
    func testMessageWithBytes() throws {
        try compare(Data.self, Data(repeating: 42, count: 24)) { value, pb, c in
            pb.bytes = value
            c.bytes = value
        }
        try compare(Data.self, Data.empty) { value, pb, c in
            pb.bytes = value
            c.bytes = value
        }
        try compare(Data.self, Data(repeating: 42, count: 1234)) { value, pb, c in
            pb.bytes = value
            c.bytes = value
        }
    }
}

