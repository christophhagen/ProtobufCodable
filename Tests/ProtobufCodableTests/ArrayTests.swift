import XCTest
@testable import ProtobufCodable
import SwiftProtobuf

final class ArrayTests: XCTestCase {

    private struct Test: Codable {
        let int: Int
        let string: String
        enum CodingKeys: Int, CodingKey {
            case int = 1
            case string = 2
        }
    }

    func testEncodeArrayOfUInts() throws {
        let input: [UInt8] = [.zero, .min, .max]
        let data = Data([
            0, // Nil index set
            0, // zero
            0, // min
            255 // max
        ])
        try encoded(input, matches: data)
    }

    func testEncodeArrayOfStrings() throws {
        let input: [String] = ["Some", "More"]
        let data = Data([
            0, // Nil index set
            4, 83, 111, 109, 101, // Length 4, "Some"
            4, 77, 111, 114, 101 // Length 4, "More"
        ])
        try encoded(input, matches: data)
    }

    func testEncodeArrayOfStructs() throws {
        let input: [Test] = [.init(int: 123, string: "Some"), .init(int: 234, string: "More")]
        let data = Data([
            0, // Nil index set length
            8, // Length of first item
            8, // Field 1, varint
            123, // Varint 123
            18, // Field 2, length-delimited
            4, 83, 111, 109, 101, // Length 4, "Some"
            9, // Length of second item
            8, // Field 1, varint
            234, 1, // Varint 234
            18, // Field 2, length-delimited
            4, 77, 111, 114, 101 // Length 4, "More"
        ])
        try encoded(input, matches: data)
    }

    func testEncodeArrayOfOptionalInts() throws {
        let input: [Int?] = [123, 234, nil, 0]
        let data = Data([
            1, // Nil index set length
            2, // Nil value at index 2
            123, // Varint 123
            234, 1, // Varint 234
            0 // zero
        ])
        try encoded(input, matches: data)
    }

    func testEncodeArrayOfOptionalStrings() throws {
        let input: [String?] = ["Some", nil, "More", nil]
        let data = Data([
            2, // Nil index set length
            1, // Nil value at index 2
            3, // Nil value at index 3
            4, 83, 111, 109, 101, // Length 4, "Some"
            4, 77, 111, 114, 101 // Length 4, "More"
        ])
        try encoded(input, matches: data)
    }

    func testEncodeArrayOfOptionalStructs() throws {
        let input: [Test?] = [.init(int: 123, string: "Some"), nil,
                              .init(int: 234, string: "More"), nil]
        let data = Data([
            2, // Nil index set length
            1, // Nil value at index 2
            3, // Nil value at index 3
            8, // Length of first item
            8, // Field 1, varint
            123, // Varint 123
            18, // Field 2, length-delimited
            4, 83, 111, 109, 101, // Length 4, "Some"
            9, // Length of second item
            8, // Field 1, varint
            234, 1, // Varint 234
            18, // Field 2, length-delimited
            4, 77, 111, 114, 101 // Length 4, "More"
        ])
        try encoded(input, matches: data)
    }

    func testArrayUInt8() throws {
        try roundTripCodable([UInt8].self, [.zero,.min, .max])
    }

    func testArrayUInt16() throws {
        try roundTripCodable([UInt16].self, [.zero,.min, .max])
    }

    func testArrayUInt32() throws {
        try roundTripCodable([UInt32].self, [.zero,.min, .max])
    }

    func testArrayUInt64() throws {
        try roundTripCodable([UInt64].self, [.zero,.min, .max])
    }

    func testArrayUInt() throws {
        try roundTripCodable([UInt].self, [.zero,.min, .max])
    }

    func testArrayInt8() throws {
        try roundTripCodable([Int8].self, [.zero,.min, .max])
    }

    func testArrayInt16() throws {
        try roundTripCodable([Int16].self, [.zero,.min, .max])
    }

    func testArrayInt32() throws {
        try roundTripCodable([Int32].self, [.zero,.min, .max])
    }

    func testArrayInt64() throws {
        try roundTripCodable([Int64].self, [.zero,.min, .max])
    }

    func testArrayInt() throws {
        try roundTripCodable([Int].self, [.zero,.min, .max])
    }

    func testArrayFloat() throws {
        try roundTripCodable([Float].self, [.zero, .greatestFiniteMagnitude, .pi])
    }

    func testArrayDouble() throws {
        try roundTripCodable([Double].self, [.zero, .greatestFiniteMagnitude, .pi])
    }

    func testArrayBool() throws {
        try roundTripCodable([false, true, false])
    }

    func testArrayString() throws {
        let input = ["Some", "More", ""]
        let data = Data([
            0,
            4,
            83, 111, 109, 101,
            4,
            77, 111, 114, 101,
            0])
        try encoded(input, matches: data)
        try roundTripCodable(["Some", "More", ""])
    }

    func testArrayData() throws {
        try roundTripCodable([Data].self, [.empty, Data(repeating: 42, count: 12)])
    }

    func testArrayComplex() throws {
        let input = [
            BasicMessage(double: 3.14, float: 3.14, int32: 123, int64: 123),
            BasicMessage(double: -3.14, float: -3.14, int32: 123, int64: 123),
            BasicMessage(double: 3.14, float: 3.14, int32: -123, int64: -123),
        ]
        let data = Data([
            0, // Nil index set
            60, // Length of first message
            9, 31, 133, 235, 81, 184, 30, 9, 64, // double
            21, 195, 245, 72, 64, // float
            24, 123, // int32
            32, 123, // int64
            40, 0, // uint32
            48, 0, // uint64
            56, 0, // sint32
            64, 0, // sint64
            77, 0, 0, 0, 0, // sfixed32
            81, 0, 0, 0, 0, 0, 0, 0, 0, // sfixed64
            93, 0, 0, 0, 0, // fixed32
            97, 0, 0, 0, 0, 0, 0, 0, 0, // fixed64
            104, 0, // bool
            114, 0, // string
            122, 0, // bytes
            60, // Length of second message
            9, 31, 133, 235, 81, 184, 30, 9, 192, // double
            21, 195, 245, 72, 192, // float
            24, 123, // int32
            32, 123, // int64
            40, 0, // uint32
            48, 0, // uint64
            56, 0, // sint32
            64, 0, // sint64
            77, 0, 0, 0, 0, // sfixed32
            81, 0, 0, 0, 0, 0, 0, 0, 0, // sfixed64
            93, 0, 0, 0, 0, // fixed32
            97, 0, 0, 0, 0, 0, 0, 0, 0, // fixed64
            104, 0, // bool
            114, 0, // string
            122, 0, // bytes
            78, // Length of third message
            9, 31, 133, 235, 81, 184, 30, 9, 64, // double
            21, 195, 245, 72, 64, // float
            24, 133, 255, 255, 255, 255, 255, 255, 255, 255, 1,
            32, 133, 255, 255, 255, 255, 255, 255, 255, 255, 1,
            40, 0, // uint32
            48, 0, // uint64
            56, 0, // sint32
            64, 0, // sint64
            77, 0, 0, 0, 0, // sfixed32
            81, 0, 0, 0, 0, 0, 0, 0, 0, // sfixed64
            93, 0, 0, 0, 0, // fixed32
            97, 0, 0, 0, 0, 0, 0, 0, 0, // fixed64
            104, 0, // bool
            114, 0, // string
            122, 0, // bytes
        ])
        try encoded(input, matches: data)
        try roundTripCodable(input)
    }

    func testArraysWithOptional() throws {
        // [2, 1, 3, 0, 255]
        try roundTripCodable([Optional<UInt8>].self, [.zero, nil, .max, nil])
        // [3, 1, 2, 4, 0, 255]
        try roundTripCodable([Optional<UInt8>].self, [.zero, nil, nil, .max, nil])
        // [3, 1, 3, 4, 0, 255]
        try roundTripCodable([Optional<UInt8>].self, [.zero, nil, .max, nil, nil])
        // [1, 3, 0, 0, 255]
        try roundTripCodable([Optional<UInt8>].self, [.zero, .min, .max, nil])
    }

    func testArraysWithOptionalUInt16() throws {
        // [1, 3, 0, 0, 255, 255, 3]
        try roundTripCodable([Optional<UInt16>].self, [.zero, .min, .max, nil])
    }

    func testArraysWithOptionalUInt32() throws {
        // [1, 3, 0, 0, 255, 255, 255, 255, 15]
        try roundTripCodable([Optional<UInt32>].self, [.zero, .min, .max, nil])
    }

    func testArraysWithOptionalUInt64() throws {
        // [1, 3, 0, 0, 255, 255, 255, 255, 255, 255, 255, 255, 255, 1]
        try roundTripCodable([Optional<UInt64>].self, [.zero, .min, .max, nil])
    }

    func testArraysWithOptionalUInt() throws {
        // [1, 3, 0, 0, 255, 255, 255, 255, 255, 255, 255, 255, 255, 1]
        try roundTripCodable([Optional<UInt>].self, [.zero, .min, .max, nil])
    }

    func testArraysWithOptionalInt8() throws {
        // [1, 3, 0, 128, 127]
        try roundTripCodable([Optional<Int8>].self, [.zero, .min, .max, nil])
    }

    func testArraysWithOptionalInt16() throws {
        // [1, 3, 0, 128, 128, 254, 255, 255, 255, 255, 255, 255, 1, 255, 255, 1]
        try roundTripCodable([Optional<Int16>].self, [.zero, .min, .max, nil])
    }

    func testArraysWithOptionalInt32() throws {
        // [1, 3, 0, 128, 128, 128, 128, 248, 255, 255, 255, 255, 1, 255, 255, 255, 255, 7]
        try roundTripCodable([Optional<Int32>].self, [.zero, .min, .max, nil])
    }

    func testArraysWithOptionalInt64() throws {
        // [1, 3, 0, 128, 128, 128, 128, 128, 128, 128, 128, 128, 1, 255, 255, 255, 255, 255, 255, 255, 255, 127]
        try roundTripCodable([Optional<Int64>].self, [.zero, .min, .max, nil])
    }

    func testArraysWithOptionalInt() throws {
        // [1, 3, 0, 128, 128, 128, 128, 128, 128, 128, 128, 128, 1, 255, 255, 255, 255, 255, 255, 255, 255, 127]
        try roundTripCodable([Optional<Int>].self, [.zero, .min, .max, nil])
    }

    func testArraysWithOptionalFloat() throws {
        // [1, 3,  0, 0, 0, 0,  255, 255, 127, 127,  218, 15, 73, 64]
        try roundTripCodable([Optional<Float>].self, [.zero, .greatestFiniteMagnitude, .pi, nil])
    }

    func testArraysWithOptionalDouble() throws {
        // [1, 3, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255, 255, 255, 255, 239, 127, 24, 45, 68, 84, 251, 33, 9, 64]
        try roundTripCodable([Optional<Double>].self, [.zero, .greatestFiniteMagnitude, .pi, nil])
    }

    func testArraysWithOptionalBool() throws {
        // [1, 3, 0, 1, 0]
        try roundTripCodable([Optional<Bool>].self, [false, true, false, nil])
    }

    func testArraysWithOptionalString() throws {
        // [1, 3, 4, 83, 111, 109, 101, 4, 77, 111, 114, 101, 0]
        try roundTripCodable([Optional<String>].self, ["Some", "More", "", nil])
    }

    func testArraysWithOptionalData() throws {
        // [1, 2, 0, 12, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42]
        try roundTripCodable([Optional<Data>].self, [.empty, Data(repeating: 42, count: 12), nil])
    }

    func testArraysWithOptionalSInt32() throws {
        // [1, 3, 0, 255, 255, 255, 255, 15, 254, 255, 255, 255, 15]
        try roundTripCodable([Optional<SignedValue<Int32>>].self, [.zero ,.min, .max, nil])
    }

    func testArraysWithOptionalSInt64() throws {
        // [1, 3, 0, 255, 255, 255, 255, 255, 255, 255, 255, 255, 1, 254, 255, 255, 255, 255, 255, 255, 255, 255, 1]
        try roundTripCodable([Optional<SignedValue<Int64>>].self, [.zero ,.min, .max, nil])
    }

    func testArraysWithOptionalFixedInt32() throws {
        // [1, 3, 0, 0, 0, 0, 0, 0, 0, 128, 255, 255, 255, 127]
        try roundTripCodable([Optional<FixedWidth<Int32>>].self, [.zero ,.min, .max, nil])
    }

    func testArraysWithOptionalFixedInt64() throws {
        // [1, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 128, 255, 255, 255, 255, 255, 255, 255, 127]
        try roundTripCodable([Optional<FixedWidth<Int64>>].self, [.zero ,.min, .max, nil])
    }

    func testArraysWithOptionalFixedUInt32() throws {
        // [1, 3, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255, 255]
        try roundTripCodable([Optional<FixedWidth<UInt32>>].self, [.zero ,.min, .max, nil])
    }

    func testArraysWithOptionalFixedUInt64() throws {
        // [1, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255, 255, 255, 255, 255, 255]
        try roundTripCodable([Optional<FixedWidth<UInt64>>].self, [.zero ,.min, .max, nil])
    }

    func testArrayWithOptionalComplex() throws {
        let input: [BasicMessage?] = [
            BasicMessage(double: 3.14, float: 3.14, int32: 123, int64: 123),
            nil,
            BasicMessage(double: -3.14, float: -3.14, int32: 123, int64: 123),
            BasicMessage(double: 3.14, float: 3.14, int32: -123, int64: -123),
            nil,
            nil
        ]
        try roundTripCodable(input)
    }
}
