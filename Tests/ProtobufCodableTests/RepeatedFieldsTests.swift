import XCTest
import ProtobufCodable
import SwiftProtobuf

final class RepeatedFieldsTests: XCTestCase {
    
    func testRepeatedPrimitives() throws {
        let codable = Repeated(
            unsigneds: [123, .zero, 234567890])
        try roundTripProtobuf(codable)
    }

    func testRepeatedComplexObjects() throws {
        let codable = Repeated(
            messages: [
                BasicMessage(double: 3.14, int64: -1234567890, boolean: false),
                BasicMessage(float: -3.14, signedFixedInt32: -1234)
            ])
        try roundTripProtobuf(codable)
    }
    
    func testMultipleRepeatedPrimitives() throws {
        let codable = Repeated(
            unsigneds: [0,123,234567890],
            messages: [
                BasicMessage(double: 3.14, int64: -1234567890, boolean: false),
                BasicMessage(float: -3.14, signedFixedInt32: -1234)
            ])
        try roundTripProtobuf(codable)
    }

    func testDecoding() throws {
        let unsigneds = Data([
            10, /* tag */
            6, /* length */
            0, /* value 0 */
            123, /* value 123 */
            210, 241, 236, 111]) /* value 234567890 */

        let message1 = Data([
            18, /* Tag: 18, */
            67, /* Len: 67, */
            9, 31, 133, 235, 81, 184, 30, 9, 64,
            21, 0, 0, 0, 0,
            24, 0,
            32, 174, 250, 167, 179, 251, 255, 255, 255, 255, 1,
            40, 0,
            48, 0,
            56, 0,
            64, 0,
            77, 0, 0, 0, 0,
            81, 0, 0, 0, 0, 0, 0, 0, 0,
            93, 0, 0, 0, 0,
            97, 0, 0, 0, 0, 0, 0, 0, 0,
            104, 0,
            114, 0,
            122, 0])
        let message2 = Data([
            18, /* Tag: 18, */
            58, /* Len: 58, */
            9, 0, 0, 0, 0, 0, 0, 0, 0,
            21, 195, 245, 72, 192,
            24, 0,
            32, 0,
            40, 0,
            48, 0,
            56, 0,
            64, 0,
            77, 0, 0, 0, 0,
            81, 0, 0, 0, 0, 0, 0, 0, 0,
            93, 46, 251, 255, 255,
            97, 0, 0, 0, 0, 0, 0, 0, 0,
            104, 0,
            114, 0,
            122, 0])
        let data = unsigneds + message1 + message2
        let _ = try PB_Repeated(serializedData: data)
    }

    func testRepeatedStrings() throws {
        let codable = Repeated(
            strings: ["some", "more", "third"])
        try roundTripProtobuf(codable)
    }
}
