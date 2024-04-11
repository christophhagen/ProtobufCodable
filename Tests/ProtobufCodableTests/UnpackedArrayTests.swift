import XCTest
@testable import ProtobufCodable

final class UnpackedArrayEncodingTests: XCTestCase {

    private func compareToProto(_ value: StructWithUnpackedArrays) throws {
        let valueProto = value.proto
        let protoData = try valueProto.serializedData()

        let encoder = ProtobufEncoder()
        let codableData = try encoder.encode(value)
        XCTAssertEqual(Array(codableData), Array(protoData))

        let decoder = ProtobufDecoder()
        let decoded = try decoder.decode(StructWithUnpackedArrays.self, from: protoData)
        XCTAssertEqual(value, decoded)

        let decodedProto = try MessageWithUnpackedArrays(serializedData: codableData)
        XCTAssertEqual(decodedProto, valueProto)
    }

    func testUnpackedArrayOfDouble() throws {
        try compareToProto(.init(double: [.zero, 123, 234]))
    }

    func testUnpackedArrayOfFloat() throws {
        try compareToProto(.init(float: [.zero, 123, 234]))
    }

    func testUnpackedArrayOfInt32() throws {
        try compareToProto(.init(int32: [.zero, 123, 234]))
    }

    func testUnpackedArrayOfInt64() throws {
        try compareToProto(.init(int64: [.zero, 123, 234]))
    }

    func testUnpackedArrayOfUInt32() throws {
        try compareToProto(.init(uint32: [.zero, 123, 234]))
    }

    func testUnpackedArrayOfUInt64() throws {
        try compareToProto(.init(uint64: [.zero, 123, 234]))
    }

    func testUnpackedArrayOfSInt32() throws {
        try compareToProto(.init(sint32: [.zero, 123, 234]))
    }

    func testUnpackedArrayOfSInt64() throws {
        try compareToProto(.init(sint64: [.zero, 123, 234]))
    }

    func testUnpackedArrayOfFixed32() throws {
        try compareToProto(.init(fixed32: [.zero, 123, 234]))
    }

    func testUnpackedArrayOfFixed64() throws {
        try compareToProto(.init(fixed64: [.zero, 123, 234]))
    }

    func testUnpackedArrayOfSFixed32() throws {
        try compareToProto(.init(sfixed32: [.zero, 123, 234]))
    }

    func testUnpackedArrayOfSFixed64() throws {
        try compareToProto(.init(sfixed64: [.zero, 123, 234]))
    }

    func testUnpackedArrayOfBool() throws {
        try compareToProto(.init(bool: [false, true, false]))
    }
}
