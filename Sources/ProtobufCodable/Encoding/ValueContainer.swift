import Foundation

final class ValueContainer: TreeNode, SingleValueEncodingContainer {

    func encodeNil() throws {
        throw ProtobufEncodingError.notImplemented
    }
    
    private func encodePrimitive(_ primitive: BinaryEncodable) throws {
        guard !primitive.isDefaultValue else {
            return
        }
        
        // Note: Default values are encoded in repeated fields
        try addChild {
            DataNode(data: try primitive.binaryData(),
                     type: primitive.wireType,
                     codingPath: codingPath)
        }
    }
    
    func encode<T>(_ value: T) throws where T : Encodable {
        switch value {
        case let primitive as BinaryEncodable:
            try encodePrimitive(primitive)
        default:
            throw ProtobufEncodingError.notImplemented
        }
    }
    
    override var description: String {
        description(forClass: "Value")
    }
}
