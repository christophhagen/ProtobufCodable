import XCTest
@testable import ProtobufCodable
import SwiftProtobuf

final class PrimitiveTypeTests: XCTestCase {

    private func roundTripSigned<T>(_ type: SignedValue<T>.Type = SignedValue<T>.self, _ values: T...) throws where T: SignedValueCompatible, T: Codable {
        try values.forEach { try roundTripCodable(type: type, SignedValue<T>.init(wrappedValue: $0)) }
    }

    private func roundTripFixed<T>(_ type: FixedWidth<T>.Type = FixedWidth<T>.self, _ values: T...) throws where T: FixedWidthCompatible, T: Codable, T: Equatable {
        try values.forEach { try roundTripCodable(type: type, FixedWidth<T>.init(wrappedValue: $0)) }
    }

    private func encodedData<T>(_ type: T.Type = T.self,
                                _ codable: T, hasLength length: Int) throws where T: Codable, T: Equatable {
        let data = try ProtobufEncoder().encode(codable)
        XCTAssertEqual(data.count, length)
        if data.count != length {
            print(data.bytes)
        }
    }

    private func encodedData<T>(_ type: T.Type = T.self,
                                _ codable: T, isEqualTo expected: Data) throws where T: Codable, T: Equatable {
        let data = try ProtobufEncoder().encode(codable)
        XCTAssertEqual(data, expected)
        if data != expected {
            print(data.bytes)
        }
    }
    
    func testUInt8() throws {
        try encodedData(UInt8.self, .max, isEqualTo: Data([255]))
        try roundTripCodable(UInt8.self, .zero, 123, 234, .max, .min)
        try roundTripCodable(Optional<UInt8>.self, .zero, 123, 234, .max, .min, nil)
    }
    
    func testInt8() throws {
        try encodedData(Int8.self, .max, isEqualTo: Data([127]))
        try roundTripCodable(Int8.self, .zero, 123, -123, .max, .min)
        try roundTripCodable(Optional<Int8>.self, .zero, 123, -123, .max, .min, nil)
    }
    
    func testUInt16() throws {
        let expected = Data([255, 255, 3])
        try encodedData(UInt16.self, .max, isEqualTo: expected)
        try roundTripCodable(UInt16.self, .zero, 12345, 23456, .max, .min)
        try roundTripCodable(Optional<UInt16>.self, .zero, 12345, 23456, .max, .min, nil)
    }
    
    func testInt16() throws {
        let expected = Data([255, 255, 1])
        try encodedData(Int16.self, .max, isEqualTo: expected)
        try roundTripCodable(Int16.self, .zero, 12345, -12345, .max, .min)
        try roundTripCodable(Optional<Int16>.self, .zero, 12345, -12345, .max, .min, nil)
    }
    
    func testUInt32() throws {
        try encodedData(UInt32.self, .max, hasLength: 5)
        try roundTripCodable(UInt32.self, .zero, 1234567890, 2345678901, .max, .min)
        try roundTripCodable(Optional<UInt32>.self, .zero, 1234567890, 2345678901, .max, .min, nil)
    }
    
    func testInt32() throws {
        try encodedData(Int32.self, .max, hasLength: 5)
        try roundTripCodable(Int32.self, .zero, 1234567890, -1234567890, .max, .min)
        try roundTripCodable(Optional<Int32>.self, .zero, 1234567890, -1234567890, .max, .min, nil)
    }
    
    func testUInt64() throws {
        try encodedData(UInt64.self, .max, hasLength: 10)
        try roundTripCodable(UInt64.self, .zero, 12345678901234567890, 2345678901234567890, .max, .min)
        try roundTripCodable(Optional<UInt64>.self, .zero, 12345678901234567890, 2345678901234567890, .max, .min, nil)
    }
    
    func testInt64() throws {
        try encodedData(Int64.self, .min, hasLength: 10)
        try roundTripCodable(Int64.self, .zero, 1234567890123456789, -1234567890123456789, .max, .min)
        try roundTripCodable(Optional<Int64>.self, .zero, 1234567890123456789, -1234567890123456789, .max, .min, nil)
    }
    
    func testFloat() throws {
        try roundTripCodable(Float.self, .infinity, .pi, .leastNonzeroMagnitude, .leastNormalMagnitude)
        try roundTripCodable(Optional<Float>.self, .infinity, .pi, .leastNonzeroMagnitude, .leastNormalMagnitude, nil)
    }
    
    func testDouble() throws {
        try roundTripCodable(Double.self, .zero, .infinity, .pi, .leastNonzeroMagnitude, .leastNormalMagnitude)
        try roundTripCodable(Optional<Double>.self, .zero, .infinity, .pi, .leastNonzeroMagnitude, .leastNormalMagnitude, nil)
    }
    
    func testSignedInt16() throws {
        try roundTripSigned(SignedValue<Int16>.self, .zero, 123, -123, .min, .max)
    }
    
    func testSignedInt32() throws {
        try roundTripSigned(SignedValue<Int32>.self, .zero, 123, -123, .min, .max)
    }
    
    func testSignedInt64() throws {
        try roundTripSigned(SignedValue<Int32>.self, .zero, 123, -123, .min, .max)
    }
    
    func testFixedInt16() throws {
        try roundTripFixed(FixedWidth<UInt16>.self, .zero, 123, .min, .max)
    }
    
    func testFixedInt32() throws {
        try roundTripFixed(FixedWidth<UInt32>.self, .zero, 123, .min, .max)
    }
    
    func testFixedInt64() throws {
        try roundTripFixed(FixedWidth<UInt64>.self, .zero, 123, .min, .max)
    }
    
    func testSignedFixedInt16() throws {
        try roundTripFixed(FixedWidth<Int16>.self, .zero, 123, -123, .min, .max)
    }
    
    func testSignedFixedInt32() throws {
        try roundTripFixed(FixedWidth<Int32>.self, .zero, 123, -123, .min, .max)
    }
    
    func testSignedFixedInt64() throws {
        try roundTripFixed(FixedWidth<Int64>.self, .zero, 123, -123, .min, .max)
    }
    
    func testBoolean() throws {
        try roundTripCodable(Bool.self, false, true)
        try roundTripCodable(Optional<Bool>.self, false, true, nil)
    }
    
    // Note: String and bytes have wire type 2 (lengthDelimited),
    // and contain additional bytes for the length after the tag
    func testString() throws {
        // [4, 83, 111, 109, 101]
        // [0]
        // [15, 65, 32, 108, 111, 110, 103, 101, 114, 32, 115, 116, 114, 105, 110, 103]
        try roundTripCodable(String.self, "Some", .empty, "A longer string")
        // [4, 83, 111, 109, 101]
        // [0]
        // [15, 65, 32, 108, 111, 110, 103, 101, 114, 32, 115, 116, 114, 105, 110, 103]
        // []
        try roundTripCodable(Optional<String>.self, "Some", .empty, "A longer string", nil)
    }
    
    func testBytes() throws {
        // [0]
        // [0, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42]
        // [0, 42, ... 42]
        let input = Data(repeating: 42, count: 24)
        try encoded(input, matches: Data([0]) + input)
        try roundTripCodable(Data.self, .empty, Data(repeating: 42, count: 24), Data(repeating: 42, count: 1234))
        // [0]
        // [0, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42]
        // [0, 42, ... 42]
        // []
        try roundTripCodable(Optional<Data>.self, .empty, Data(repeating: 42, count: 24), Data(repeating: 42, count: 1234), nil)
    }

    func testDictionaries() throws {
        // [8, 0, 18, 4, 122, 101, 114, 111]
        try roundTripCodable([Int : String].self, [.zero : "zero"])

        // [8, 8, 0, 18, 4, 122, 101, 114, 111, 7, 8, 123, 18, 3, 49, 50, 51]
        try roundTripCodable([Int : String].self, [.zero : "zero", 123 : "123"])

        // [8, 10, 4, 122, 101, 114, 111, 16, 0, 4, 8, 123, 16, 123]
        try roundTripCodable([String : Int].self, ["zero" : .zero, "123" : 123])

        // Either: [7, 8, 123, 18, 3, 49, 50, 51,   8, 8, 0, 18, 4, 122, 101, 114, 111]
        // or:     [8, 8, 0, 18, 4, 122, 101, 114, 111,   7, 8, 123, 18, 3, 49, 50, 51]
        try roundTripCodable([Int32 : String].self, [.zero : "zero", 123 : "123"])

        // [6, 12, 18, 3, 110, 105, 108, 8, 8, 0, 18, 4, 122, 101, 114, 111, 7, 8, 123, 18, 3, 49, 50, 51]
        try roundTripCodable([Int32? : String].self, [.zero : "zero", 123 : "123", nil : "nil"])

        // [2, 12, 20, 8, 8, 0, 18, 4, 122, 101, 114, 111, 7, 8, 123, 18, 3, 49, 50, 51]
        try roundTripCodable([Int32? : String?].self, [.zero : "zero", 123 : "123", nil : nil])

    }

    func testOptionals() throws {
        try encodedData(Optional<UInt8>.self, 123, isEqualTo: Data([123]))
        try encodedData(Optional<UInt8>.self, nil, isEqualTo: Data([]))
    }
}
