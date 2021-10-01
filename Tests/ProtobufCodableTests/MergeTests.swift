import XCTest
import ProtobufCodable

private struct ArrayContainer: Codable {

    enum CodingKeys: Int, CodingKey {
        case array = 1
    }

    let array: [Int]
}

class MergeTests: XCTestCase {

    func testAppendArrays() throws {
        let first = ArrayContainer(array: [1,2,3])
        let second = ArrayContainer(array: [4,5,6])

        let encoder = ProtobufEncoder()
        let firstData = try encoder.encode(first)
        let secondData = try encoder.encode(second)

        let decoded: ArrayContainer = try ProtobufDecoder().decode(from: firstData + secondData)
        XCTAssertEqual(decoded.array, first.array + second.array)
    }
}
