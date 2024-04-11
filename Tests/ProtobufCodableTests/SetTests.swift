import XCTest
@testable import ProtobufCodable

final class SetEncodingTests: XCTestCase {

    private func compareToProto(_ value: StructWithSets) throws {
        try compare(value)
    }

    func testSetOfDouble() throws {
        try compareToProto(.init(double: [123, 234]))
    }

    func testSetOfFloat() throws {
        try compareToProto(.init(float: [123, 234]))
    }

    func testSetOfInt32() throws {
        try compareToProto(.init(int32: [123, 234]))
    }

    func testSetOfInt64() throws {
        try compareToProto(.init(int64: [123, 234]))
    }

    func testSetOfUInt32() throws {
        try compareToProto(.init(uint32: [123, 234]))
    }

    func testSetOfUInt64() throws {
        try compareToProto(.init(uint64: [123, 234]))
    }

    func testSetOfSInt32() throws {
        try compareToProto(.init(sint32: [123, 234]))
    }

    func testSetOfSInt64() throws {
        try compareToProto(.init(sint64: [123, 234]))
    }

    func testSetOfFixed32() throws {
        try compareToProto(.init(fixed32: [123, 234]))
    }

    func testSetOfFixed64() throws {
        try compareToProto(.init(fixed64: [123, 234]))
    }

    func testSetOfSFixed32() throws {
        try compareToProto(.init(sfixed32: [123, 234]))
    }

    func testSetOfSFixed64() throws {
        try compareToProto(.init(sfixed64: [123, 234]))
    }

    func testSetOfBool() throws {
        try compareToProto(.init(bool: [true, false]))
    }

    func testSetOfString() throws {
        try compareToProto(.init(string: ["Some", "More"]))
    }

    func testSetOfBytes() throws {
        try compareToProto(.init(bytes: [Data([123]), Data([234])]))
    }

    func testSetOfOptionals() throws {
        struct Test: Codable {
            let value: [Bool?]

            enum CodingKeys: Int, CodingKey {
                case value = 1
            }
        }
        do {
            _ = try ProtobufEncoder.encode(Test(value: [false, nil]))
        } catch EncodingError.invalidValue(let value, let context) {
            guard let value = value as? Optional<Bool> else {
                XCTFail("The unsupported value should be an optional bool")
                return
            }
            XCTAssertEqual(value, false)
            XCTAssertPathsEqual(context.codingPath, [1])
        }
    }

    func testOptionalSet() throws {
        struct StructWithSets: Codable, Equatable, ProtoComparable {

            var double: Set<Double>?

            enum CodingKeys: Int, CodingKey {
                case double = 1
            }

            var proto: MessageWithArrays {
                .with {
                    if let double {
                        $0.double = double.map { $0 }
                    }
                }
            }
        }
        try compare(StructWithSets(double: nil))
        try compare(StructWithSets(double: [3.14]))

        // Empty arrays will decode as nil
        let value = StructWithSets(double: [])
        let encoded = try ProtobufEncoder.encode(value)
        let decoded = try ProtobufDecoder.decode(StructWithSets.self, from: encoded)
        XCTAssertNotEqual(decoded, value)
    }
}
