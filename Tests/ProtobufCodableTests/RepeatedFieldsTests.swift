import XCTest
import ProtobufCodable
import SwiftProtobuf

final class RepeatedFieldsTests: XCTestCase {
    
    private var encoder: ProtobufEncoder {
        .init(omitDefaultValues: true)
    }
    
    func testRepeatedPrimitives() throws {
        let codable = Repeated(
            unsigneds: [0,123,234567890])
        try compareBinaryWithoutDefaults(codable)
    }
    
    func testMultipleRepeatedPrimitives() throws {
        let codable = Repeated(
            unsigneds: [0,123,234567890],
            messages: [
                BasicMessage(double: 3.14, int64: -1234567890, boolean: false),
                BasicMessage(float: -3.14, signedFixedInt32: -1234)
            ])
        try compareBinaryWithoutDefaults(codable)
    }
}
