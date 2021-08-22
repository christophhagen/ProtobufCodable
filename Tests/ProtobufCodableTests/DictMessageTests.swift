import XCTest
import ProtobufCodable
import SwiftProtobuf

final class DictMessageTests: XCTestCase {
    
    func testIntDict() throws {
        let codable = DictContainer(intDict: ["Some" : 123, "More" : 234])
        let pb = PB_DictContainer.with {
            $0.intDict = codable.intDict
        }
        let codableData = try ProtobufEncoder().encode(codable)
        let pbData = try pb.serializedData()
        XCTAssertEqual(codableData.bytes, pbData.bytes)
    }
    
    func testMessageDict() throws {
        let codable = DictContainer(messageDict:
                                        [123 : BasicMessage(int32: 234),
                                         345 : BasicMessage(fixedInt32: 456)])
        let pb = PB_DictContainer.with {
            $0.messageDict = codable.messageDict.mapValues { $0.protobuf }
        }
        let codableData = try ProtobufEncoder().encode(codable)
        let pbData = try pb.serializedData()
        XCTAssertEqual(codableData.bytes, pbData.bytes)
    }
}


