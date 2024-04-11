import XCTest
import ProtobufCodable

final class MapTests: XCTestCase {

    private func compareToProto(_ value: StructWithMaps) throws {
        try compare(value)
    }

    func testUInt32Map() throws {
        try compareToProto(.init(uintToString: [123 : "Some"]))
    }

    func testStringMap() throws {
        try compareToProto(.init(stringToBytes: ["Some" : Data(repeating: 42, count: 3)]))
    }

    func testIntMap() throws {
        try compareToProto(.init(intToMessage: [123 : .init(double: 3.14)]))
    }

    func testMapWithInvalidKey() throws {
        struct Test: Codable, Equatable {
            let value: [Double: Int]

            enum CodingKeys: Int, CodingKey {
                case value = 1
            }
        }
        do {
            _ = try ProtobufEncoder().encode(Test(value: [1 : 1]))
        } catch EncodingError.invalidValue(let value, let context) {
            XCTAssertPathsEqual(context.codingPath, [1])
            guard let value = value as? [Double : Int] else {
                XCTFail("Expected offending type [Double : Int], but got \(type(of: value))")
                return
            }
            XCTAssertEqual(value, [1:1])
        }
    }

    func testRepeatedMap() throws {
        struct Test: Codable, Equatable {
            let value: [[Int: Int]]

            enum CodingKeys: Int, CodingKey {
                case value = 1
            }
        }
        do {
            _ = try ProtobufEncoder().encode(Test(value: [[1 : 1]]))
        } catch EncodingError.invalidValue(let value, let context) {
            XCTAssertPathsEqual(context.codingPath, [1])
            guard let value = value as? [Int : Int] else {
                XCTFail("Expected offending type [Int : Int], but got \(type(of: value))")
                return
            }
            XCTAssertEqual(value, [1:1])
        }
    }

    func testNestedMap() throws {
        struct Test: Codable, Equatable {
            let value: [Int: [Int:Int]]

            enum CodingKeys: Int, CodingKey {
                case value = 1
            }
        }
        do {
            _ = try ProtobufEncoder().encode(Test(value: [1 : [1:1]]))
        } catch EncodingError.invalidValue(let value, let context) {
            XCTAssertPathsEqual(context.codingPath, [1])
            guard let value = value as? [Int : Int] else {
                XCTFail("Expected offending type [Int : Int], but got \(type(of: value))")
                return
            }
            XCTAssertEqual(value, [1:1])
        }
    }
}
