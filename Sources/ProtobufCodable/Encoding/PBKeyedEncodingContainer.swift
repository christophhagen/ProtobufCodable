import Foundation

class PBKeyedEncodingContainer<Key: CodingKey>: TreeNode, KeyedEncodingContainerProtocol {
    
    var encoder: Encoder
    
    init(encoder: Encoder, parent: TreeNode, key: CodingKey) {
        self.encoder = encoder
        super.init(type: parent.wireType, field: key.intValue!, codingPath: parent.codingPath + [key])
    }
    
    init(encoder: Encoder, parent: TreeNode?) {
        self.encoder = encoder
        super.init(type: parent?.wireType, field: parent?.field, codingPath: parent?.codingPath)
    }
    
    func encodeNil(forKey key: Key) throws {
        trace()
        throw ProtobufEncodingError.notImplemented
    }
    
    func encodePrimitive(_ primitive: BinaryPrimitiveEncodable, forField field: Int) throws {
        guard !primitive.isDefaultValue else {
            trace("\(path) - Ommitting default value for key '\(field)'")
            return
        }
        trace("\(path) - Encoding primitive type '\(type(of: primitive))' (\(primitive)) for key '\(field)'")
        try encodeBinary(primitive, forField: field)
    }
    
    func encodeBinary(_ binary: BinaryEncodable, forField field: Int) throws {
        trace("\(path) - Encoding binary type '\(type(of: binary))' (\(binary)) for key '\(field)'")
        try addChild {
            DataNode(data: try binary.binaryData(),
                     type: binary.wireType,
                     field: field,
                     codingPath: codingPath)
        }
    }
    
    func encodeChild(_ value: Encodable, forKey key: CodingKey) throws {
        trace("\(path) - Encoding '\(type(of: value))' (\(value)) for key '\(key.stringValue)'")
        let child = addChild {
            EncodingNode(parent: self, key: key)
        }
        try value.encode(to: child)
    }
    
    func encodeDict(_ value: Encodable, forKey key: CodingKey) throws {
        let child = addChild {
            DictNode(parent: self, key: key)
        }
        try value.encode(to: child)
    }
    
    func encode<T>(_ value: T, forKey key: Key) throws where T : Encodable {
        guard let field = key.intValue else {
            trace("\(path) - Encoding '\(type(of: value))' (\(value)) for key '\(key.stringValue)': No int key")
            throw ProtobufEncodingError.missingIntegerCodingKey(key)
        }
        switch value {
        case let primitive as BinaryPrimitiveEncodable:
            try encodePrimitive(primitive, forField: field)
        case let encodable as BinaryEncodable:
            try encodeBinary(encodable, forField: field)
        case is Dictionary<AnyHashable, Any>:
            try encodeDict(value, forKey: key)
        default:
            try encodeChild(value, forKey: key)
        }
    }
    
    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        trace("\(path) for key '\(key.stringValue)'")
        let child = addChild {
            PBKeyedEncodingContainer<NestedKey>(encoder: encoder, parent: self, key: key)
        }
        return KeyedEncodingContainer(child)
    }
    
    func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        trace("\(path)")
        return addChild {
            PBUnkeyedEncodingContainer(encoder: encoder, parent: self, key: key)
        }
    }
    
    func superEncoder() -> Encoder {
        trace("\(path)")
        return encoder
    }
    
    func superEncoder(forKey key: Key) -> Encoder {
        trace("\(path)")
        return encoder
    }
    
    override var description: String {
        description(forClass: "Keyed")
    }
}
