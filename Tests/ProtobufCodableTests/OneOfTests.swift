import XCTest
import ProtobufCodable

final class OneOfTests: XCTestCase {

    private func compareToProto(_ value: StructWithOneOf) throws {
        try compare(value)
    }

    func testOneOfInt() throws {
        try compareToProto(.init(oneOf: .integer(123)))
    }

    func testOneOfString() throws {
        try compareToProto(.init(oneOf: .string("Some")))
    }

    func testOneOfBytes() throws {
        try compareToProto(.init(oneOf: .bytes(.init(repeating: 42, count: 3))))
    }

    func testOneOfMessage() throws {
        try compareToProto(.init(oneOf: .message(.init(double: 3.14))))
    }

    func testOneOfKeyCollision() throws {
        struct StructWithOneOf: Codable, Equatable {
            var value: Int32 = .zero
            var oneOf: MyOneOf

            enum CodingKeys: Int, CodingKey {
                case value = 1
                case oneOf = 1234 // Not relevant, unused
            }

            enum MyOneOf: OneOf, Codable, Equatable {
                case integer(Int)
                case string(String)

                enum CodingKeys: Int, CodingKey {
                    case integer = 1 // Conflict
                    case string = 2
                }
            }
        }
        // No collision
        _ = try ProtobufEncoder.encode(StructWithOneOf(oneOf: .string("More")))
        do {
            _ = try ProtobufEncoder.encode(StructWithOneOf(oneOf: .integer(2)))
            XCTFail("Expected encoding to fail due to conflicting keys")
        } catch EncodingError.invalidValue(let value, let context) {
            guard let value = value as? StructWithOneOf.MyOneOf else {
                XCTFail("Expected offending value \(value) to be Int")
                return
            }
            XCTAssertEqual(value, .integer(2))
            XCTAssertPathsEqual(context.codingPath, [1])
        }
    }

    func testOneOfInvalidKey() throws {
        struct StructWithOneOf: Codable, Equatable {
            var value: Int32 = .zero
            var oneOf: MyOneOf

            enum CodingKeys: Int, CodingKey {
                case value = 1
                case oneOf = 1234 // Not relevant, unused
            }

            enum MyOneOf: OneOf, Codable, Equatable {
                case integer(Int)
                case string(String)

                enum CodingKeys: Int, CodingKey {
                    case integer = 3
                    case string = 0 // Invalid field number
                }
            }
        }
        // No collision
        let value = StructWithOneOf(oneOf: .string("More"))
        do {
            _ = try ProtobufEncoder.encode(value)
            XCTFail("Expected encoding to fail")
        } catch EncodingError.invalidValue(let value, let context) {
            XCTAssertPathsEqual(context.codingPath, [0])
            guard let key = value as? CodingKey else {
                XCTFail("Expected offending value to be coding key")
                return
            }
            XCTAssertEqual(key.stringValue, "string")
        }
    }

    /**
     Set an invalid field number for the OneOf key, which should be ignored
     */
    func testIgnoreOneOfKey() throws {
        struct StructWithOneOf: Codable, Equatable {
            var value: Int32 = .zero
            var oneOf: MyOneOf

            enum CodingKeys: Int, CodingKey {
                case value = 1
                case oneOf = -1 // Not relevant, ignored
            }

            enum MyOneOf: OneOf, Codable, Equatable {
                case integer(Int)
                case string(String)

                enum CodingKeys: Int, CodingKey {
                    case integer = 2
                    case string = 3
                }
            }
        }
        // No errors expected
        let value = StructWithOneOf(oneOf: .string("More"))
        _ = try ProtobufEncoder.encode(value)
    }
}
