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
        let codable = DictContainer(intDict: [-345 : BasicMessage(fixedInt32: 456),
                                              123 : BasicMessage(int32: 234)])
        let newDict = Dictionary(uniqueKeysWithValues: codable.intDict.map { key, value in
                                    (Int64(key), value.protobuf) })
        let pb = PB_DictContainer.with {
            $0.intDict = newDict
        }
        let codableData = try ProtobufEncoder().encode(codable)
        let pbData = try pb.serializedData()
        XCTAssertEqual(codableData.bytes, pbData.bytes)
    }
}


