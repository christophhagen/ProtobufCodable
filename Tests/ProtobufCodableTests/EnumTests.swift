import XCTest
import ProtobufCodable

/**
 let mirror = Mirror(reflecting: something)
 mirror.displayStyle == .Enum
 */

final class EnumTests: XCTestCase {

    private func compareToProto(_ value: StructWithEnum) throws {
        try compare(value)
    }

    func testEnumInStruct() throws {
        try compareToProto(.init(value: .one))
        try compareToProto(.init(value: .zero))
    }

    func testEnumWithInt64() throws {
        struct StructWithEnum: Codable, Equatable {

            let value: Enum

            enum Enum: Int64, Codable {
                case zero = 0
                case one = 1
            }

            enum CodingKeys: Int, CodingKey {
                case value = 1
            }
        }
        _ = try ProtobufEncoder.encode(StructWithEnum(value: .one))
    }

    func testEnumWithInt32() throws {
        struct StructWithEnum: Codable, Equatable {

            let value: Enum

            enum Enum: Int32, Codable {
                case zero = 0
                case one = 1
            }

            enum CodingKeys: Int, CodingKey {
                case value = 1
            }
        }
        _ = try ProtobufEncoder.encode(StructWithEnum(value: .one))
    }

    func testEnumWithInvalidRawValue() throws {
        struct StructWithEnum: Codable, Equatable {

            let value: Enum

            enum Enum: UInt64, Codable {
                case zero = 0
                case one = 1
            }

            enum CodingKeys: Int, CodingKey {
                case value = 1
            }
        }
        do {
            _ = try ProtobufEncoder().encode(StructWithEnum(value: .one))
            XCTFail("Enums with RawValue other than Int should fail")
        } catch EncodingError.invalidValue(let value, let context) {
            XCTAssertPathsEqual(context.codingPath, [1])
            guard let value = value  as? UInt64 else {
                XCTFail("Expected offending value \(value) to be UInt64")
                return
            }
            XCTAssertEqual(value, 1)
        }
    }

    func testOptionalEnumInStruct() throws {
        struct StructWithEnum: Codable, Equatable, ProtoComparable {

            let value: Enum?

            enum Enum: Int, Codable {
                case zero = 0
                case one = 1
            }

            enum CodingKeys: Int, CodingKey {
                case value = 1
            }

            var proto: MessageWithEnum {
                .with {
                    if let value {
                        $0.value = .init(rawValue: value.rawValue)!
                    }
                }
            }
        }
        try compare(StructWithEnum(value: .one))
        try compare(StructWithEnum(value: nil))
    }

    func testOneAboveEnumRawValueLowerLimit() throws {
        struct StructWithEnum: Codable, Equatable {

            let value: Enum

            enum Enum: Int, Codable {
                case min = -2147483648
            }

            enum CodingKeys: Int, CodingKey {
                case value = 1
            }
        }
        _ = try ProtobufEncoder().encode(StructWithEnum(value: .min))
    }

    func testEnumRawValueLowerLimit() throws {
        struct StructWithEnum: Codable, Equatable {

            let value: Enum

            enum Enum: Int, Codable {
                case min = -2147483649
            }

            enum CodingKeys: Int, CodingKey {
                case value = 1
            }
        }
        do {
            _ = try ProtobufEncoder().encode(StructWithEnum(value: .min))
            XCTFail("Enums with unsupported raw value should fail")
        } catch EncodingError.invalidValue(let value, let context) {
            XCTAssertPathsEqual(context.codingPath, [1])
            guard let value = value  as? Int else {
                XCTFail("Expected offending value \(value) to be Int, not \(type(of: value))")
                return
            }
            XCTAssertEqual(value, -2147483649)
        }
    }

    func testOneBelowEnumRawValueUpperLimit() throws {
        struct StructWithEnum: Codable, Equatable {

            let value: Enum

            enum Enum: Int, Codable {
                case min = 2147483647
            }

            enum CodingKeys: Int, CodingKey {
                case value = 1
            }
        }
        _ = try ProtobufEncoder().encode(StructWithEnum(value: .min))
    }

    func testEnumRawValueUpperLimit() throws {
        struct StructWithEnum: Codable, Equatable {

            let value: Enum

            enum Enum: Int, Codable {
                case min = 2147483648
            }

            enum CodingKeys: Int, CodingKey {
                case value = 1
            }
        }
        do {
            _ = try ProtobufEncoder().encode(StructWithEnum(value: .min))
            XCTFail("Enums with unsupported raw value should fail")
        } catch EncodingError.invalidValue(let value, let context) {
            XCTAssertPathsEqual(context.codingPath, [1])
            guard let value = value  as? Int else {
                XCTFail("Expected offending value \(value) to be Int, not \(type(of: value))")
                return
            }
            XCTAssertEqual(value, 2147483648)
        }
    }
}
