import XCTest
import ProtobufCodable

final class FieldNumberTests: XCTestCase {

    private func encodeAndFail(withExpectedKey key: DecodingKey, encoding value: Encodable) throws {
        do {
            _ = try ProtobufEncoder.encode(value)
            XCTFail("Expected encoding to fail")
        } catch EncodingError.invalidValue(let value, let context) {
            XCTAssertPathsEqual(context.codingPath, [key])
            guard let key = value as? CodingKey else {
                XCTFail("Expected offending value to be coding key")
                return
            }
            XCTAssertEqual(key.stringValue, "value")
        }
    }

    func testMissingIntegerKey() throws {
        struct Test: Codable {
            let value: Int
        }
        try encodeAndFail(withExpectedKey: "value", encoding: Test(value: 123))
    }

    func testZeroIntegerKey() throws {
        struct Test: Codable {
            let value: Int
            enum CodingKeys: Int, CodingKey {
                case value = 0
            }
        }
        try encodeAndFail(withExpectedKey: 0, encoding: Test(value: 123))
    }

    func testNegativeIntegerKey() throws {
        struct Test: Codable {
            let value: Int
            enum CodingKeys: Int, CodingKey {
                case value = -1
            }
        }
        try encodeAndFail(withExpectedKey: -1, encoding: Test(value: 123))
    }

    func testOneBelowReservedIntegerKeyLowerBound() throws {
        struct Test: Codable {
            let value: Int
            enum CodingKeys: Int, CodingKey {
                case value = 18999
            }
        }
        _ = try ProtobufEncoder.encode(Test(value: 123))
    }

    func testReservedIntegerKeyLowerBound() throws {
        struct Test: Codable {
            let value: Int
            enum CodingKeys: Int, CodingKey {
                case value = 19000
            }
        }
        try encodeAndFail(withExpectedKey: 19000, encoding: Test(value: 123))
    }

    func testReservedIntegerKeyUpperBound() throws {
        struct Test: Codable {
            let value: Int
            enum CodingKeys: Int, CodingKey {
                case value = 19999
            }
        }
        try encodeAndFail(withExpectedKey: 19999, encoding: Test(value: 123))
    }

    func testOneAboveReservedIntegerKeyUpperBound() throws {
        struct Test: Codable {
            let value: Int
            enum CodingKeys: Int, CodingKey {
                case value = 20000
            }
        }
        _ = try ProtobufEncoder.encode(Test(value: 123))
    }

    func testOneBelowIntegerKeyUpperBound() throws {
        struct Test: Codable {
            let value: Int
            enum CodingKeys: Int, CodingKey {
                case value = 536_870_911
            }
        }
        _ = try ProtobufEncoder.encode(Test(value: 123))
    }

    func testIntegerKeyUpperBound() throws {
        struct Test: Codable {
            let value: Int
            enum CodingKeys: Int, CodingKey {
                case value = 536_870_912
            }
        }
        try encodeAndFail(withExpectedKey: 536_870_912, encoding: Test(value: 123))
    }

}
