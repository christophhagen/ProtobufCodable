import XCTest
@testable import ProtobufCodable

final class ArrayEncodingTests: XCTestCase {

    private func compareToProto(_ value: StructWithArrays) throws {
        try compare(value)
    }

    func testArrayOfDouble() throws {
        try compareToProto(.init(double: [123, 234]))
    }
    
    func testArrayOfFloat() throws {
        try compareToProto(.init(float: [123, 234]))
    }
    
    func testArrayOfInt32() throws {
        try compareToProto(.init(int32: [123, 234]))
    }
    
    func testArrayOfInt64() throws {
        try compareToProto(.init(int64: [123, 234]))
    }
    
    func testArrayOfUInt32() throws {
        try compareToProto(.init(uint32: [123, 234]))
    }
    
    func testArrayOfUInt64() throws {
        try compareToProto(.init(uint64: [123, 234]))
    }
    
    func testArrayOfSInt32() throws {
        try compareToProto(.init(sint32: [123, 234]))
    }
    
    func testArrayOfSInt64() throws {
        try compareToProto(.init(sint64: [123, 234]))
    }

    func testArrayOfFixed32() throws {
        try compareToProto(.init(fixed32: [123, 234]))
    }
    
    func testArrayOfFixed64() throws {
        try compareToProto(.init(fixed64: [123, 234]))
    }
    
    func testArrayOfSFixed32() throws {
        try compareToProto(.init(sfixed32: [123, 234]))
    }
    
    func testArrayOfSFixed64() throws {
        try compareToProto(.init(sfixed64: [123, 234]))
    }
    
    func testArrayOfBool() throws {
        try compareToProto(.init(bool: [true, false]))
    }
    
    func testArrayOfString() throws {
        try compareToProto(.init(string: ["Some", "More"]))
    }
    
    func testArrayOfBytes() throws {
        try compareToProto(.init(bytes: [Data([123]), Data([234])]))
    }

    func testArrayOfOptionals() throws {
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

    func testOptionalArray() throws {
        struct StructWithArrays: Codable, Equatable, ProtoComparable {

            var double: [Double]?

            enum CodingKeys: Int, CodingKey {
                case double = 1
            }

            var proto: MessageWithArrays {
                .with {
                    if let double {
                        $0.double = double
                    }
                }
            }
        }
        try compare(StructWithArrays(double: nil))
        try compare(StructWithArrays(double: [3.14]))
        
        // Empty arrays will decode as nil
        let value = StructWithArrays(double: [])
        let encoded = try ProtobufEncoder.encode(value)
        let decoded = try ProtobufDecoder.decode(StructWithArrays.self, from: encoded)
        XCTAssertNotEqual(decoded, value)
    }
}
