import XCTest
import ProtobufCodable
import SwiftProtobuf

final class DictMessageTests: XCTestCase {
    
    func testStringDict() throws {
        let codable = DictContainer(stringDict: ["Some" : 123, "More" : 234])
        let pb = PB_DictContainer.with {
            $0.stringDict = codable.stringDict
        }
        let codableData = try ProtobufEncoder().encode(codable)
        let pbData = try pb.serializedData()
        XCTAssertEqual(codableData.bytes, pbData.bytes)
    }
    
    func testUIntDict() throws {
        let codable = DictContainer(uintDict:
                                        [123 : BasicMessage(int32: 234),
                                         3456 : BasicMessage(fixedInt32: 456)])
        let pb = PB_DictContainer.with {
            $0.uintDict = codable.uintDict.mapValues { $0.protobuf }
        }
        let codableData = try ProtobufEncoder().encode(codable)
        let pbData = try pb.serializedData()
        XCTAssertEqual(codableData.bytes, pbData.bytes)
    }
    
    func testIntDict() throws {
        let codable = DictContainer(intDict: [123 : BasicMessage(int32: 234),
                                              -345 : BasicMessage(fixedInt32: 456)])
        let newDict = Dictionary(uniqueKeysWithValues: codable.intDict.map { key, value in
                                    (Int64(key), value.protobuf) })
        let pb = PB_DictContainer.with {
            $0.intDict = newDict
        }
        let codableData = try ProtobufEncoder().encode(codable).bytes
        let pbData = try pb.serializedData().bytes
        
        // Encoding order for dictionaries is not guaranteed,
        // so check for both options
        let part1: [UInt8] =
            [26, 7, 8, 123, 18, 3, 24, 234, 1]
        let part2: [UInt8] =
            [26, 18, 8, 167, 253, 255, 255, 255, 255, 255, 255, 255, 1, 18, 5, 77, 200, 1, 0, 0]
        let option1 = part1 + part2
        let option2 = part2 + part1
        XCTAssertTrue(codableData == option1 || codableData == option2)
        XCTAssertTrue(pbData == option1 || pbData == option2)
    }
}


