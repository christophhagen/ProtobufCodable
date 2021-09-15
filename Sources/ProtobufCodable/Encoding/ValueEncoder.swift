import Foundation

final class ValueEncoder: TreeNode, SingleValueEncodingContainer {

    func encodeNil() throws {
        // Nil values in single value containers are signaled by omitting the field from the message.
        // The absence of a value is then treated as a nil value.
        // This breaks when ommiting default values.
    }
    
    private func encodePrimitive(_ primitive: BinaryEncodable) throws {
        if primitive.isDefaultValue && omitDefaultValues {
            return
        }
        
        // Note: Default values are encoded in repeated fields
        try addChild {
            DataNode(data: try primitive.binaryData(),
                     userInfo: userInfo,
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
        nodeDescription(forClass: "Value")
    }
}
