import XCTest
@testable import ProtobufCodable

final class ProtobufPrimitiveTests: XCTestCase {

    private func compare(_ value: StructWithPrimitives, to expected: [UInt8]) throws {
        let protoData = try value.proto.serializedData()
        XCTAssertEqual(Array(protoData), expected)
        let encoder = ProtobufEncoder()
        let codableData = try encoder.encode(value)
        XCTAssertEqual(Array(codableData), expected)

        let decoder = ProtobufDecoder()
        let decoded = try decoder.decode(StructWithPrimitives.self, from: codableData)
        XCTAssertEqual(value, decoded)
    }

    func testDoubleValue() throws {
        try compare(.init(double: 123), to: [
            1 << 3 | 1, 
            0, 0, 0, 0, 0, 192, 94, 64
        ])
    }

    func testFloatValue() throws {
        try compare(.init(float: 123), to:  [
            2 << 3 | 5, 
            0, 0, 246, 66
        ])
    }

    func testInt32Value() throws {
        try compare(.init(int32: 123), to: [
            3 << 3 | 0,
            123
        ])
    }

    func testInt64Value() throws {
        try compare(.init(int64: 123), to: [
            4 << 3 | 0,
            123
        ])
    }

    func testUInt32Value() throws {
        try compare(.init(uint32: 123), to: [
            5 << 3 | 0,
            123
        ])
    }

    func testUInt64Value() throws {
        try compare(.init(uint64: 123), to: [
            6 << 3 | 0,
            123
        ])
    }

    func testSInt32Value() throws {
        try compare(.init(sint32: 123), to: [
            7 << 3 | 0,
            246, 1
        ])
    }

    func testSInt64Value() throws {
        try compare(.init(sint64: 123), to: [
            8 << 3 | 0,
            246, 1
        ])
    }

    func testFixed32Value() throws {
        try compare(.init(fixed32: 123), to: [
            9 << 3 | 5,
            123, 0, 0, 0
        ])
    }

    func testFixed64Value() throws {
        try compare(.init(fixed64: 123), to: [
            10 << 3 | 1,
            123, 0, 0, 0, 0, 0, 0, 0
        ])
    }

    func testSFixed32Value() throws {
        try compare(.init(sfixed32: 123), to: [
            11 << 3 | 5,
            123, 0, 0, 0
        ])
    }

    func testSFixed64Value() throws {
        try compare(.init(sfixed64: 123), to: [
            12 << 3 | 1, 123, 0, 0, 0, 0, 0, 0, 0
        ])
    }

    func testBoolValue() throws {
        try compare(.init(bool: true), to: [
            13 << 3 | 0, 1
        ])
    }

    func testStringValue() throws {
        try compare(.init(string: "abc"), to: [
            14 << 3 | 2,
            3, 97, 98, 99
        ])
    }

    func testBytesValue() throws {
        try compare(.init(bytes: .init(repeating: 2, count: 3)), to: [
            15 << 3 | 2,
            3, 2, 2, 2
        ])
    }
}
