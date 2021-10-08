import XCTest
@testable import ProtobufCodable
import SwiftProtobuf

final class OptionTests: XCTestCase {

    let encoderWithoutDefaults: ProtobufEncoder = {
        var encoder = ProtobufEncoder()
        encoder.omitDefaultValues = true
        return encoder
    }()

    let encoderWithIntegerKeys: ProtobufEncoder = {
        var encoder = ProtobufEncoder()
        encoder.requireIntegerCodingKeys = true
        return encoder
    }()

    func testDefaultValues() throws {
        let message = BasicMessage(double: 3.14)
        try compareBinary(message, to: encoderWithoutDefaults)
    }

    func testDefaultValuesEmptyObject() throws {
        let message = BasicMessage()
        try compareBinary(message, to: encoderWithoutDefaults)
    }

    func testDefaultValuesEmptyNestedObject() throws {
        let message = NestedMessage(basic: BasicMessage(float: 3.14))
        try compareBinary(message, to: encoderWithoutDefaults)
    }

    func testDefaultValuesEmptyRepeatedObject() throws {
        let message = Repeated(unsigneds: [1,2,3])
        try compareBinary(message, to: encoderWithoutDefaults)
    }

    func testMissingIntegerKeys() throws {
        let message = Repeated(unsigneds: [1,2,3])
        try roundTripCodable(message, using: encoderWithIntegerKeys)

        struct MissingIntKeyContainer: Codable, Equatable {

            let name: String

            let age: Int

            init(name: String = "", age: Int = 0) {
                self.name = name
                self.age = age
            }
        }
        let value = MissingIntKeyContainer(name: "Some", age: 42)
        do {
            try roundTripCodable(value, using: encoderWithIntegerKeys)
        } catch let error as ProtobufEncodingError {
            if case let .missingIntegerCodingKey(key) = error {
                XCTAssertEqual(key.stringValue, "name")
            } else {
                XCTFail("Unexpected error \(error)")
            }
        }
    }

}
