import XCTest
@testable import ProtobufCodable
import SwiftProtobuf

final class PrimitiveTypeTests: XCTestCase {

    func roundTrip<T>(_ type: T.Type = T.self, _ value: T) throws where T: Codable, T: Equatable {
        let data = try ProtobufEncoder().encode(value)
        print("Data: \(data.bytes)")
        let decoded = try ProtobufDecoder().decode(T.self, from: data)
        XCTAssertEqual(decoded, value)
        if decoded != value {
            print("Type: \(Swift.type(of: value))")
            print("Original: \(value)")
            print("Decoded:  \(decoded)")
            print("Data: \(data.bytes)")
        }
    }

    private func roundTripCompare<T>(_ type: T.Type = T.self, _ values: T...) throws where T: Codable, T: Equatable {
        try values.forEach { try roundTrip(type, $0) }
    }
    
    private func roundTripCompare<T>(_ type: SignedValue<T>.Type = SignedValue<T>.self, _ values: T...) throws {
        try values.forEach { try roundTrip(type, SignedValue<T>.init(wrappedValue: $0)) }
    }
    
    private func roundTripCompare<T>(_ type: FixedLength<T>.Type = FixedLength<T>.self, _ values: T...) throws {
        try values.forEach { try roundTrip(type, FixedLength<T>.init(wrappedValue: $0)) }
    }
    
    func testUInt8() throws {
        try roundTripCompare(UInt8.self, .zero, 123, 234, .max, .min)
        try roundTripCompare(Optional<UInt8>.self, .zero, 123, 234, .max, .min, nil)
    }
    
    func testInt8() throws {
        try roundTripCompare(Int8.self, .zero, 123, -123, .max, .min)
        try roundTripCompare(Optional<Int8>.self, .zero, 123, -123, .max, .min, nil)
    }
    
    func testUInt16() throws {
        try roundTripCompare(UInt16.self, .zero, 12345, 23456, .max, .min)
        try roundTripCompare(Optional<UInt16>.self, .zero, 12345, 23456, .max, .min, nil)
    }
    
    func testInt16() throws {
        try roundTripCompare(Int16.self, .zero, 12345, -12345, .max, .min)
        try roundTripCompare(Optional<Int16>.self, .zero, 12345, -12345, .max, .min, nil)
    }
    
    func testUInt32() throws {
        try roundTripCompare(UInt32.self, .zero, 1234567890, 2345678901, .max, .min)
        try roundTripCompare(Optional<UInt32>.self, .zero, 1234567890, 2345678901, .max, .min, nil)
    }
    
    func testInt32() throws {
        try roundTripCompare(Int32.self, .zero, 1234567890, -1234567890, .max, .min)
        try roundTripCompare(Optional<Int32>.self, .zero, 1234567890, -1234567890, .max, .min, nil)
    }
    
    func testUInt64() throws {
        try roundTripCompare(UInt64.self, .zero, 12345678901234567890, 2345678901234567890, .max, .min)
        try roundTripCompare(Optional<UInt64>.self, .zero, 12345678901234567890, 2345678901234567890, .max, .min, nil)
    }
    
    func testInt64() throws {
        try roundTripCompare(Int64.self, .zero, 1234567890123456789, -1234567890123456789, .max, .min)
        try roundTripCompare(Optional<Int64>.self, .zero, 1234567890123456789, -1234567890123456789, .max, .min, nil)
    }
    
    func testFloat() throws {
        try roundTripCompare(Float.self, .infinity, .pi, .leastNonzeroMagnitude, .leastNormalMagnitude)
        try roundTripCompare(Optional<Float>.self, .infinity, .pi, .leastNonzeroMagnitude, .leastNormalMagnitude, nil)
    }
    
    func testDouble() throws {
        try roundTripCompare(Double.self, .zero, .infinity, .pi, .leastNonzeroMagnitude, .leastNormalMagnitude)
        try roundTripCompare(Optional<Double>.self, .zero, .infinity, .pi, .leastNonzeroMagnitude, .leastNormalMagnitude, nil)
    }
    
    func testSignedInt32() throws {
        try roundTripCompare(SignedValue<Int32>.self, .zero, 123, -123, .min, .max)
    }
    
    func testSignedInt64() throws {
        try roundTripCompare(SignedValue<Int32>.self, .zero, 123, -123, .min, .max)
    }
    
    func testFixedInt32() throws {
        try roundTripCompare(FixedLength<UInt32>.self, .zero, 123, .min, .max)
    }
    
    func testFixedInt64() throws {
        try roundTripCompare(FixedLength<UInt64>.self, .zero, 123, .min, .max)
    }
    
    func testSignedFixedInt32() throws {
        try roundTripCompare(FixedLength<Int32>.self, .zero, 123, -123, .min, .max)
    }
    
    func testSignedFixedInt64() throws {
        try roundTripCompare(FixedLength<Int64>.self, .zero, 123, -123, .min, .max)
    }
    
    func testBoolean() throws {
        try roundTripCompare(Bool.self, false, true)
        try roundTripCompare(Optional<Bool>.self, false, true, nil)
    }
    
    // Note: String and bytes have wire type 2 (lengthDelimited),
    // and contain additional bytes for the length after the tag
    func testString() throws {
        // [4, 83, 111, 109, 101]
        // [0]
        // [15, 65, 32, 108, 111, 110, 103, 101, 114, 32, 115, 116, 114, 105, 110, 103]
        try roundTripCompare(String.self, "Some", .empty, "A longer string")
        // [4, 83, 111, 109, 101]
        // [0]
        // [15, 65, 32, 108, 111, 110, 103, 101, 114, 32, 115, 116, 114, 105, 110, 103]
        // []
        try roundTripCompare(Optional<String>.self, "Some", .empty, "A longer string", nil)
    }
    
    func testBytes() throws {
        // []
        // [0, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42]
        // [0, 42, ... 42]
        try roundTripCompare(Data.self, .empty, Data(repeating: 42, count: 24), Data(repeating: 42, count: 1234))
        try roundTripCompare(Optional<Data>.self, .empty, Data(repeating: 42, count: 24), Data(repeating: 42, count: 1234), nil)
    }

    func testArrays() throws {
        try roundTripCompare([UInt8].self, [.zero,.min, .max])
        try roundTripCompare([UInt16].self, [.zero,.min, .max])
        try roundTripCompare([UInt32].self, [.zero,.min, .max])
        try roundTripCompare([UInt64].self, [.zero,.min, .max])
        try roundTripCompare([UInt].self, [.zero,.min, .max])
        try roundTripCompare([Int8].self, [.zero,.min, .max])
        try roundTripCompare([Int16].self, [.zero,.min, .max])
        try roundTripCompare([Int32].self, [.zero,.min, .max])
        try roundTripCompare([Int64].self, [.zero,.min, .max])
        try roundTripCompare([Int].self, [.zero,.min, .max])
        try roundTripCompare([Float].self, [.zero, .greatestFiniteMagnitude, .pi])
        try roundTripCompare([Double].self, [.zero, .greatestFiniteMagnitude, .pi])
        try roundTripCompare([Bool].self, [false, true, false])
        try roundTripCompare([String].self, ["Some", "More", ""])
        try roundTripCompare([Data].self, [.empty, Data(repeating: 42, count: 12)])
    }

    func testArraysWithOptionals() throws {
        // [2, 1, 3, 0, 255]
        try roundTripCompare([Optional<UInt8>].self, [.zero, nil, .max, nil])

        // [3, 1, 2, 4, 0, 255]
        try roundTripCompare([Optional<UInt8>].self, [.zero, nil, nil, .max, nil])

        // [3, 1, 3, 4, 0, 255]
        try roundTripCompare([Optional<UInt8>].self, [.zero, nil, .max, nil, nil])

        // [1, 3, 0, 0, 255]
        try roundTripCompare([Optional<UInt8>].self, [.zero, .min, .max, nil])

        // [1, 3, 0, 0, 255, 255, 3]
        try roundTripCompare([Optional<UInt16>].self, [.zero, .min, .max, nil])

        // [1, 3, 0, 0, 255, 255, 255, 255, 15]
        try roundTripCompare([Optional<UInt32>].self, [.zero, .min, .max, nil])

        // [1, 3, 0, 0, 255, 255, 255, 255, 255, 255, 255, 255, 255, 1]
        try roundTripCompare([Optional<UInt64>].self, [.zero, .min, .max, nil])

        // [1, 3, 0, 0, 255, 255, 255, 255, 255, 255, 255, 255, 255, 1]
        try roundTripCompare([Optional<UInt>].self, [.zero, .min, .max, nil])

        // [1, 3, 0, 128, 127]
        try roundTripCompare([Optional<Int8>].self, [.zero, .min, .max, nil])

        // [1, 3, 0, 128, 128, 254, 255, 255, 255, 255, 255, 255, 1, 255, 255, 1]
        try roundTripCompare([Optional<Int16>].self, [.zero, .min, .max, nil])

        // [1, 3, 0, 128, 128, 128, 128, 248, 255, 255, 255, 255, 1, 255, 255, 255, 255, 7]
        try roundTripCompare([Optional<Int32>].self, [.zero, .min, .max, nil])

        // [1, 3, 0, 128, 128, 128, 128, 128, 128, 128, 128, 128, 1, 255, 255, 255, 255, 255, 255, 255, 255, 127]
        try roundTripCompare([Optional<Int64>].self, [.zero, .min, .max, nil])

        // [1, 3, 0, 128, 128, 128, 128, 128, 128, 128, 128, 128, 1, 255, 255, 255, 255, 255, 255, 255, 255, 127]
        try roundTripCompare([Optional<Int>].self, [.zero, .min, .max, nil])

        // [1, 3,  0, 0, 0, 0,  255, 255, 127, 127,  218, 15, 73, 64]
        try roundTripCompare([Optional<Float>].self, [.zero, .greatestFiniteMagnitude, .pi, nil])

        // [1, 3, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255, 255, 255, 255, 239, 127, 24, 45, 68, 84, 251, 33, 9, 64]
        try roundTripCompare([Optional<Double>].self, [.zero, .greatestFiniteMagnitude, .pi, nil])

        // [1, 3, 0, 1, 0]
        try roundTripCompare([Optional<Bool>].self, [false, true, false, nil])

        // [1, 3, 4, 83, 111, 109, 101, 4, 77, 111, 114, 101, 0]
        try roundTripCompare([Optional<String>].self, ["Some", "More", "", nil])

        // [1, 2, 0, 12, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42]
        try roundTripCompare([Optional<Data>].self, [.empty, Data(repeating: 42, count: 12), nil])

        // [1, 3, 0, 255, 255, 255, 255, 15, 254, 255, 255, 255, 15]
        try roundTripCompare([Optional<SignedValue<Int32>>].self, [.zero ,.min, .max, nil])

        // [1, 3, 0, 255, 255, 255, 255, 255, 255, 255, 255, 255, 1, 254, 255, 255, 255, 255, 255, 255, 255, 255, 1]
        try roundTripCompare([Optional<SignedValue<Int64>>].self, [.zero ,.min, .max, nil])

        // [1, 3, 0, 0, 0, 0, 0, 0, 0, 128, 255, 255, 255, 127]
        try roundTripCompare([Optional<FixedLength<Int32>>].self, [.zero ,.min, .max, nil])

        // [1, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 128, 255, 255, 255, 255, 255, 255, 255, 127]
        try roundTripCompare([Optional<FixedLength<Int64>>].self, [.zero ,.min, .max, nil])

        // [1, 3, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255, 255]
        try roundTripCompare([Optional<FixedLength<UInt32>>].self, [.zero ,.min, .max, nil])

        // [1, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255, 255, 255, 255, 255, 255]
        try roundTripCompare([Optional<FixedLength<UInt64>>].self, [.zero ,.min, .max, nil])
        
    }

    func testDictionaries() throws {
        // [8, 8, 0, 18, 4, 122, 101, 114, 111]
        try roundTripCompare([Int : String].self, [.zero : "zero"])

        // [8, 8, 0, 18, 4, 122, 101, 114, 111, 7, 8, 123, 18, 3, 49, 50, 51]
        try roundTripCompare([Int : String].self, [.zero : "zero", 123 : "123"])

        // [8, 10, 4, 122, 101, 114, 111, 16, 0, 4, 8, 123, 16, 123]
        try roundTripCompare([String : Int].self, ["zero" : .zero, "123" : 123])

        // Either: [7, 8, 123, 18, 3, 49, 50, 51,   8, 8, 0, 18, 4, 122, 101, 114, 111]
        // or:     [8, 8, 0, 18, 4, 122, 101, 114, 111,   7, 8, 123, 18, 3, 49, 50, 51]
        try roundTripCompare([Int32 : String].self, [.zero : "zero", 123 : "123"])

        // [6, 12, 18, 3, 110, 105, 108, 8, 8, 0, 18, 4, 122, 101, 114, 111, 7, 8, 123, 18, 3, 49, 50, 51]
        try roundTripCompare([Int32? : String].self, [.zero : "zero", 123 : "123", nil : "nil"])

        // [2, 12, 20, 8, 8, 0, 18, 4, 122, 101, 114, 111, 7, 8, 123, 18, 3, 49, 50, 51]
        try roundTripCompare([Int32? : String?].self, [.zero : "zero", 123 : "123", nil : nil])

    }
}
