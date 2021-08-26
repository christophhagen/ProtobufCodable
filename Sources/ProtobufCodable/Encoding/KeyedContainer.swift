import Foundation

class KeyedContainer<Key: CodingKey>: TreeNode, KeyedEncodingContainerProtocol {
    
    var encoder: Encoder
    
    init(encoder: Encoder, parent: TreeNode, key: CodingKey) {
        self.encoder = encoder
        super.init(type: parent.wireType, field: key.intValue!, codingPath: parent.codingPath + [key])
    }
    
    init(encoder: Encoder, parent: TreeNode) {
        self.encoder = encoder
        super.init(type: parent.wireType, field: parent.field, codingPath: parent.codingPath)
    }
    
    func encodeNil(forKey key: Key) throws {
        throw ProtobufEncodingError.notImplemented
    }
    
    /**
     Encodes a primitive for the given key.
     
     A primitive is encoded using its wire type and field. Default values are omitted.
     - Parameter value: The value to encode.
     - Parameter key: The key to associate the value with.
     */
    func encodePrimitive(_ primitive: BinaryEncodable, forField field: Int) throws {
        guard !primitive.isDefaultValue else {
            return
        }
        try addChild {
            DataNode(data: try primitive.binaryData(),
                     type: primitive.wireType,
                     field: field,
                     codingPath: codingPath)
        }
    }
    
    /**
     Encodes a message for the given key.
     
     - Parameter value: The value to encode.
     - Parameter key: The key to associate the value with.
     */
    func encodeChild(_ value: Encodable, forKey key: CodingKey) throws {
        let child = addChild {
            EncodingNode(parent: self, key: key)
        }
        try value.encode(to: child)
    }
    
    /**
     Encodes the given dictionary for the given key.
     
     A dictionary is encoded as a set of key-value pairs, which are encoded within a container using field ids 1 (key) and 2 (value).
     - Parameter value: The value to encode.
     - Parameter key: The key to associate the value with.
     */
    func encodeDict(_ value: Encodable, forKey key: CodingKey) throws {
        let child = addChild {
            DictNode(parent: self, key: key)
        }
        try value.encode(to: child)
    }
    
    /**
     Encodes the given value for the given key.
     - Parameter value: The value to encode.
     - Parameter key: The key to associate the value with.
     */
    func encode<T>(_ value: T, forKey key: Key) throws where T : Encodable {
        guard let field = key.intValue else {
            throw ProtobufEncodingError.missingIntegerCodingKey(key)
        }
        switch value {
        case let primitive as BinaryEncodable:
            try encodePrimitive(primitive, forField: field)
        case is Dictionary<AnyHashable, Any>:
            try encodeDict(value, forKey: key)
        default:
            try encodeChild(value, forKey: key)
        }
    }
    
    /**
     Stores a keyed container for the given key and returns it.
     - Parameter keyType: The key type to use for the container.
     - Parameter key: The key to encode the container for.
     - Returns: A new keyed encoding container.
     */
    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        let child = addChild {
            KeyedContainer<NestedKey>(encoder: encoder, parent: self, key: key)
        }
        return KeyedEncodingContainer(child)
    }
    
    /**
     Stores an unkeyed container for the given key and returns it.
     - Parameter key: The key to encode the container for.
     - Returns: A new unkeyed container.
     */
    func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        addChild {
            UnkeyedContainer(encoder: encoder, parent: self, key: key)
        }
    }
    
    func superEncoder() -> Encoder {
        encoder
    }
    
    func superEncoder(forKey key: Key) -> Encoder {
        encoder
    }
    
    override var description: String {
        description(forClass: "Keyed")
    }
}
