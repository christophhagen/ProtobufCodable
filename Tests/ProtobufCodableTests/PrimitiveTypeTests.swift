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
    
    func testUInt8() throws {
        try roundTripCodable(UInt8.self, .zero, 123, 234, .max, .min)
        try roundTripCodable(Optional<UInt8>.self, .zero, 123, 234, .max, .min, nil)
    }
    
    func testInt8() throws {
        try roundTripCodable(Int8.self, .zero, 123, -123, .max, .min)
        try roundTripCodable(Optional<Int8>.self, .zero, 123, -123, .max, .min, nil)
    }
    
    func testUInt16() throws {
        try roundTripCodable(UInt16.self, .zero, 12345, 23456, .max, .min)
        try roundTripCodable(Optional<UInt16>.self, .zero, 12345, 23456, .max, .min, nil)
    }
    
    func testInt16() throws {
        try roundTripCodable(Int16.self, .zero, 12345, -12345, .max, .min)
        try roundTripCodable(Optional<Int16>.self, .zero, 12345, -12345, .max, .min, nil)
    }
    
    func testUInt32() throws {
        try roundTripCodable(UInt32.self, .zero, 1234567890, 2345678901, .max, .min)
        try roundTripCodable(Optional<UInt32>.self, .zero, 1234567890, 2345678901, .max, .min, nil)
    }
    
    func testInt32() throws {
        try roundTripCodable(Int32.self, .zero, 1234567890, -1234567890, .max, .min)
        try roundTripCodable(Optional<Int32>.self, .zero, 1234567890, -1234567890, .max, .min, nil)
    }
    
    func testUInt64() throws {
        try roundTripCodable(UInt64.self, .zero, 12345678901234567890, 2345678901234567890, .max, .min)
        try roundTripCodable(Optional<UInt64>.self, .zero, 12345678901234567890, 2345678901234567890, .max, .min, nil)
    }
    
    func testInt64() throws {
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
        // []
        // [0, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42]
        // [0, 42, ... 42]
        try roundTripCodable(Data.self, .empty, Data(repeating: 42, count: 24), Data(repeating: 42, count: 1234))
        try roundTripCodable(Optional<Data>.self, .empty, Data(repeating: 42, count: 24), Data(repeating: 42, count: 1234), nil)
    }

    func testArrays() throws {
        try roundTripCodable([UInt8].self, [.zero,.min, .max])
        try roundTripCodable([UInt16].self, [.zero,.min, .max])
        try roundTripCodable([UInt32].self, [.zero,.min, .max])
        try roundTripCodable([UInt64].self, [.zero,.min, .max])
        try roundTripCodable([UInt].self, [.zero,.min, .max])
        try roundTripCodable([Int8].self, [.zero,.min, .max])
        try roundTripCodable([Int16].self, [.zero,.min, .max])
        try roundTripCodable([Int32].self, [.zero,.min, .max])
        try roundTripCodable([Int64].self, [.zero,.min, .max])
        try roundTripCodable([Int].self, [.zero,.min, .max])
        try roundTripCodable([Float].self, [.zero, .greatestFiniteMagnitude, .pi])
        try roundTripCodable([Double].self, [.zero, .greatestFiniteMagnitude, .pi])
        try roundTripCodable([Bool].self, [false, true, false])
        try roundTripCodable([String].self, ["Some", "More", ""])
        try roundTripCodable([Data].self, [.empty, Data(repeating: 42, count: 12)])
    }

    func testArraysWithOptionals() throws {
        // [2, 1, 3, 0, 255]
        try roundTripCodable([Optional<UInt8>].self, [.zero, nil, .max, nil])

        // [3, 1, 2, 4, 0, 255]
        try roundTripCodable([Optional<UInt8>].self, [.zero, nil, nil, .max, nil])

        // [3, 1, 3, 4, 0, 255]
        try roundTripCodable([Optional<UInt8>].self, [.zero, nil, .max, nil, nil])

        // [1, 3, 0, 0, 255]
        try roundTripCodable([Optional<UInt8>].self, [.zero, .min, .max, nil])

        // [1, 3, 0, 0, 255, 255, 3]
        try roundTripCodable([Optional<UInt16>].self, [.zero, .min, .max, nil])

        // [1, 3, 0, 0, 255, 255, 255, 255, 15]
        try roundTripCodable([Optional<UInt32>].self, [.zero, .min, .max, nil])

        // [1, 3, 0, 0, 255, 255, 255, 255, 255, 255, 255, 255, 255, 1]
        try roundTripCodable([Optional<UInt64>].self, [.zero, .min, .max, nil])

        // [1, 3, 0, 0, 255, 255, 255, 255, 255, 255, 255, 255, 255, 1]
        try roundTripCodable([Optional<UInt>].self, [.zero, .min, .max, nil])

        // [1, 3, 0, 128, 127]
        try roundTripCodable([Optional<Int8>].self, [.zero, .min, .max, nil])

        // [1, 3, 0, 128, 128, 254, 255, 255, 255, 255, 255, 255, 1, 255, 255, 1]
        try roundTripCodable([Optional<Int16>].self, [.zero, .min, .max, nil])

        // [1, 3, 0, 128, 128, 128, 128, 248, 255, 255, 255, 255, 1, 255, 255, 255, 255, 7]
        try roundTripCodable([Optional<Int32>].self, [.zero, .min, .max, nil])

        // [1, 3, 0, 128, 128, 128, 128, 128, 128, 128, 128, 128, 1, 255, 255, 255, 255, 255, 255, 255, 255, 127]
        try roundTripCodable([Optional<Int64>].self, [.zero, .min, .max, nil])

        // [1, 3, 0, 128, 128, 128, 128, 128, 128, 128, 128, 128, 1, 255, 255, 255, 255, 255, 255, 255, 255, 127]
        try roundTripCodable([Optional<Int>].self, [.zero, .min, .max, nil])

        // [1, 3,  0, 0, 0, 0,  255, 255, 127, 127,  218, 15, 73, 64]
        try roundTripCodable([Optional<Float>].self, [.zero, .greatestFiniteMagnitude, .pi, nil])

        // [1, 3, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255, 255, 255, 255, 239, 127, 24, 45, 68, 84, 251, 33, 9, 64]
        try roundTripCodable([Optional<Double>].self, [.zero, .greatestFiniteMagnitude, .pi, nil])

        // [1, 3, 0, 1, 0]
        try roundTripCodable([Optional<Bool>].self, [false, true, false, nil])

        // [1, 3, 4, 83, 111, 109, 101, 4, 77, 111, 114, 101, 0]
        try roundTripCodable([Optional<String>].self, ["Some", "More", "", nil])

        // [1, 2, 0, 12, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42]
        try roundTripCodable([Optional<Data>].self, [.empty, Data(repeating: 42, count: 12), nil])

        // [1, 3, 0, 255, 255, 255, 255, 15, 254, 255, 255, 255, 15]
        try roundTripCodable([Optional<SignedValue<Int32>>].self, [.zero ,.min, .max, nil])

        // [1, 3, 0, 255, 255, 255, 255, 255, 255, 255, 255, 255, 1, 254, 255, 255, 255, 255, 255, 255, 255, 255, 1]
        try roundTripCodable([Optional<SignedValue<Int64>>].self, [.zero ,.min, .max, nil])

        // [1, 3, 0, 0, 0, 0, 0, 0, 0, 128, 255, 255, 255, 127]
        try roundTripCodable([Optional<FixedWidth<Int32>>].self, [.zero ,.min, .max, nil])

        // [1, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 128, 255, 255, 255, 255, 255, 255, 255, 127]
        try roundTripCodable([Optional<FixedWidth<Int64>>].self, [.zero ,.min, .max, nil])

        // [1, 3, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255, 255]
        try roundTripCodable([Optional<FixedWidth<UInt32>>].self, [.zero ,.min, .max, nil])

        // [1, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255, 255, 255, 255, 255, 255]
        try roundTripCodable([Optional<FixedWidth<UInt64>>].self, [.zero ,.min, .max, nil])
        
    }

    func testDictionaries() throws {
        // [8, 8, 0, 18, 4, 122, 101, 114, 111]
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
}
