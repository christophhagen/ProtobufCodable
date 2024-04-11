import XCTest
@testable import ProtobufCodable

private struct Test: Codable {

    let value: Int

    @Fixed
    var fixed: Int

    @Signed
    var signed: Int

    var array: [Int]

    @Unpacked
    var unpacked: [Int]
}

final class ProtobufTests: XCTestCase {

    func testPrintStruct() throws {

        let value = Test(value: 123, fixed: 123, signed: 123, array: [123, 234], unpacked: [123, 234])
        let encoder = EncodingDescriptor()
        _ = try encoder.encode(value)
    }

}
