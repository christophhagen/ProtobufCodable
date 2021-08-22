import XCTest
import ProtobufCodable
import SwiftProtobuf

final class RepeatedFieldsTests: XCTestCase {
    
    func testRepeatedPrimitives() throws {
        let codable = Repeated(
            unsigneds: [0,123,234567890])
        let pb = PB_Repeated.with {
            $0.unsigneds = codable.unsigneds
        }
        
        let codableData = try ProtobufEncoder().encode(codable)
        let protoData = try pb.serializedData()
        XCTAssertEqual(codableData.bytes, protoData.bytes)
        print(codableData.bytes)
        print(protoData.bytes)
    }
    
    func testMultipleRepeatedPrimitives() throws {
        let codable = Repeated(
            unsigneds: [0,123,234567890],
            messages: [
                BasicMessage(double: 3.14, int64: -1234567890, boolean: false),
                BasicMessage(float: -3.14, signedFixedInt32: -1234)
            ])
        let pb = PB_Repeated.with {
            $0.unsigneds = codable.unsigneds
            $0.messages = codable.messages.map { $0.protobuf }
        }

        let codableData = try ProtobufEncoder().encode(codable)
        let protoData = try pb.serializedData()
        XCTAssertEqual(codableData.bytes, protoData.bytes)
        print(codableData.bytes)
        print(protoData.bytes)
    }
    
    func testRepeatedPrimitivesVsMessages() throws {
        let values: [UInt32] = [0,123,234567890]
        let codable = Repeated(unsigneds: values)
        let codable2 = Repeated(messages: values.map { BasicMessage(unsignedInt32: $0) })
        let pb = PB_Repeated.with {
            $0.unsigneds = [0,123,234567890]
        }
        let pb2 = PB_Repeated.with {
            $0.messages = values.map { v in PB_BasicMessage.with { $0.unsignedInt32 = v } }
        }
        let res1 = try pb.serializedData().bytes
        let res2 = try ProtobufEncoder().encode(codable).bytes
        let res3 = try pb2.serializedData().bytes
        let res4 = try ProtobufEncoder().encode(codable2).bytes
        
        print(res1)
        print(res2)
        print(res3)
        print(res4)
        
    }
}
