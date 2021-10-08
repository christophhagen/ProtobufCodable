import XCTest
@testable import ProtobufCodable
import SwiftProtobuf

final class OptionTests: XCTestCase {

    let encoderWithoutDefaults: ProtobufEncoder = {
        var encoder = ProtobufEncoder()
        encoder.omitDefaultValues = true
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

}
