import Foundation

final class PBValueContainer: TreeNode, SingleValueEncodingContainer {

    func encodeNil() throws {
        trace()
        throw ProtobufEncodingError.notImplemented
    }
    
    private func encodePrimitive(_ primitive: BinaryPrimitiveEncodable) throws {
        guard !primitive.isDefaultValue else {
            trace("\(path) - Ommitting default value")
            return
        }
        trace("\(path) - Encoding primitive type '\(type(of: primitive))' (\(primitive))")
        try encodeBinary(primitive)
    }
    
    private func encodeBinary(_ binary: BinaryEncodable) throws {
        // Note: Default values are encoded in repeated fields
        try addChild {
            DataNode(data: try binary.binaryData(),
                     type: binary.wireType,
                     codingPath: codingPath)
        }
    }
    
    func encode<T>(_ value: T) throws where T : Encodable {
        switch value {
        case let primitive as BinaryPrimitiveEncodable:
            try encodePrimitive(primitive)
        case let binary as BinaryEncodable:
            try encodeBinary(binary)
        default:
            throw ProtobufEncodingError.notImplemented
        }
    }
    
    override var description: String {
        description(forClass: "Value")
    }
}
