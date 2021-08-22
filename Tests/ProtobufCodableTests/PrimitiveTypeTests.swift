import XCTest
import ProtobufCodable
import SwiftProtobuf

final class PrimitiveTypeTests: XCTestCase {
    
    private func compare<T: Encodable>(_ value: T, leadingBytes: Int = 1, _ block: (inout PB_BasicMessage, T) -> Void) throws {
        let pbData = try PB_BasicMessage.with { block(&$0, value) }
            .serializedData().dropFirst(leadingBytes)
        let codableData = try ProtobufEncoder().encode(value)
        XCTAssertEqual(pbData.bytes, codableData.bytes)
        if pbData.bytes != codableData.bytes {
            print("PB: \(pbData.bytes)")
            print("CO: \(codableData.bytes)")
        }
    }
    
    func testDouble() throws {
        try compare(0) { $0.double = $1 }
        try compare(3.14) { $0.double = $1 }
        try compare(-3.14) { $0.double = $1 }
    }
    
    func testFloat() throws {
        try compare(0) { $0.float = $1 }
        try compare(3.14) { $0.float = $1 }
        try compare(-3.14) { $0.float = $1 }
    }
    
    func testInt32() throws {
        try compare(0) { $0.int32 = $1 }
        try compare(123) { $0.int32 = $1 }
        try compare(-123) { $0.int32 = $1 }
    }
    
    func testInt64() throws {
        try compare(0) { $0.int64 = $1 }
        try compare(123) { $0.int64 = $1 }
        try compare(-123) { $0.int64 = $1 }
    }
    
    func testUInt32() throws {
        try compare(0) { $0.unsignedInt32 = $1 }
        try compare(123) { $0.unsignedInt32 = $1 }
        try compare(1234567890) { $0.unsignedInt32 = $1 }
    }
    
    func testUInt64() throws {
        try compare(0) { $0.unsignedInt64 = $1 }
        try compare(123) { $0.unsignedInt64 = $1 }
        try compare(123456789012345) { $0.unsignedInt64 = $1 }
    }
    
    func testSignedInt32() throws {
        try compare(SignedValue<Int32>(wrappedValue: 0)) { $0.signedInt32 = $1.wrappedValue }
        try compare(SignedValue<Int32>(wrappedValue: 123)) { $0.signedInt32 = $1.wrappedValue }
        try compare(SignedValue<Int32>(wrappedValue: -123)) { $0.signedInt32 = $1.wrappedValue }
    }
    
    func testSignedInt64() throws {
        try compare(SignedValue<Int64>(wrappedValue: 0)) { $0.signedInt64 = $1.wrappedValue }
        try compare(SignedValue<Int64>(wrappedValue: 123)) { $0.signedInt64 = $1.wrappedValue }
        try compare(SignedValue<Int64>(wrappedValue: -123)) { $0.signedInt64 = $1.wrappedValue }
    }
    
    func testFixedInt32() throws {
        try compare(FixedLength<UInt32>(wrappedValue: 0)) { $0.fixedInt32 = $1.wrappedValue }
        try compare(FixedLength<UInt32>(wrappedValue: 123)) { $0.fixedInt32 = $1.wrappedValue }
        try compare(FixedLength<UInt32>(wrappedValue: 1234567890)) { $0.fixedInt32 = $1.wrappedValue }
    }
    
    func testFixedInt64() throws {
        try compare(FixedLength<UInt64>(wrappedValue: 0)) { $0.fixedInt64 = $1.wrappedValue }
        try compare(FixedLength<UInt64>(wrappedValue: 123)) { $0.fixedInt64 = $1.wrappedValue }
        try compare(FixedLength<UInt64>(wrappedValue: 123456789012345)) { $0.fixedInt64 = $1.wrappedValue }
    }
    
    func testSignedFixedInt32() throws {
        try compare(FixedLength<Int32>(wrappedValue: 0)) {
            $0.signedFixedInt32 = $1.wrappedValue
        }
        try compare(FixedLength<Int32>(wrappedValue: 123)) {
            $0.signedFixedInt32 = $1.wrappedValue
        }
        try compare(FixedLength<Int32>(wrappedValue: -1234567890)) {
            $0.signedFixedInt32 = $1.wrappedValue
        }
    }
    
    func testSignedFixedInt64() throws {
        try compare(FixedLength<Int64>(wrappedValue: 0)) {
            $0.signedFixedInt64 = $1.wrappedValue
        }
        try compare(FixedLength<Int64>(wrappedValue: 123)) {
            $0.signedFixedInt64 = $1.wrappedValue
        }
        try compare(FixedLength<Int64>(wrappedValue: -123456789012345)) {
            $0.signedFixedInt64 = $1.wrappedValue
        }
    }
    
    func testBoolean() throws {
        try compare(true) { $0.boolean = $1 }
        try compare(false) { $0.boolean = $1 }
    }
    
    // Note: String and bytes have wire type 2,
    // and contain additional bytes after the tag
    func testString() throws {
        try compare("", leadingBytes: 2) { $0.string = $1 }
        try compare("SomeText", leadingBytes: 2) { $0.string = $1 }
    }
    
    func testBytes() throws {
        try compare(Data.empty, leadingBytes: 2) { $0.bytes = $1 }
        try compare(Data(repeating: 42, count: 24), leadingBytes: 2) { $0.bytes = $1 }
        try compare(Data(repeating: 42, count: 1234), leadingBytes: 3) { $0.bytes = $1 }
    }
}
